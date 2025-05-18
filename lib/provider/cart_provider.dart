import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/item_model.dart';

class CartProvider extends ChangeNotifier {
  List<ItemModel> _cartItems = [];
  double _price = 0.0;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _SelectedPaymentMethod = "eWallet"; // Default payment method

  List<ItemModel> get cartItems => _cartItems;
  double get price => _price;
  String get selectedPaymentMethod => _SelectedPaymentMethod;

  CartProvider() {
    fetchCartFromFirestore();
  }

  User? get currentUser => _auth.currentUser;

  Future<void> fetchCartFromFirestore() async {
    if (currentUser == null || currentUser!.email == null) return;

    final snapshot = await _firestore
        .collection('Users')
        .doc(currentUser!.email)
        .collection('cart')
        .get();

    _cartItems.clear();

    for (var doc in snapshot.docs) {
      try {
        _cartItems.add(ItemModel.fromFirestore(doc));
      } catch (e, stacktrace) {
        print("Error parsing item: $e\n$stacktrace");
      }
    }

    _calculateTotal();
    notifyListeners();
  }

  void setSelectedPaymentMethod(String method) {
    _SelectedPaymentMethod = method;
    notifyListeners();
  }

  void addItem(ItemModel item) async {
    if (currentUser == null || currentUser!.email == null) return;

    var cartRef = _firestore
        .collection('Users')
        .doc(currentUser!.email)
        .collection('cart')
        .doc(item.id);
    var docSnapshot = await cartRef.get();

    if (docSnapshot.exists) {
      await cartRef.update({'qty': FieldValue.increment(1)});
    } else {
      await cartRef.set({
        ...item.toFirestore(),
        'qty': 1,
      });
    }

    fetchCartFromFirestore();
    notifyListeners();
  }

  void removeItem(ItemModel item) async {
    if (currentUser == null || currentUser!.email == null) return;

    var cartRef = _firestore
        .collection('Users')
        .doc(currentUser!.email)
        .collection('cart')
        .doc(item.id);
    var docSnapshot = await cartRef.get();

    if (!docSnapshot.exists) return;

    int currentQty = docSnapshot.data()?['qty'] ?? 1;

    if (currentQty > 1) {
      await cartRef.update({'qty': FieldValue.increment(-1)});
    } else {
      await cartRef.delete();
    }

    fetchCartFromFirestore();
    notifyListeners();
  }

  void _calculateTotal() {
    _price = _cartItems.fold(0, (sum, item) => sum + (item.price * item.qty));
  }

  Future<void> checkout(
      {required double finalTotal, String? voucherUsed}) async {
    if (currentUser == null || currentUser!.email == null) return;

    String orderId = DateTime.now().millisecondsSinceEpoch.toString();
    String userEmail = currentUser!.email!;

    // Step 1: Fetch Location Info
    DocumentSnapshot locationSnapshot = await _firestore
        .collection('Users')
        .doc(userEmail)
        .collection('Location')
        .doc('doc') // Change this if your doc ID is different
        .get();

    Map<String, dynamic> locationData = locationSnapshot.exists
        ? locationSnapshot.data() as Map<String, dynamic>
        : {};

    // Prepare location fields (use null if not found)
    String? address = locationData['address'];
    double? latitude = locationData['latitude'];
    double? longitude = locationData['longitude'];

    // Step 2: Fetch the user's phone number from the Users collection
    DocumentSnapshot userSnapshot =
        await _firestore.collection('Users').doc(userEmail).get();

    String? phoneNumber; // Initialize phoneNumber to null
    if (userSnapshot.exists && userSnapshot.data() != null) {
      // Explicitly cast userSnapshot.data() to Map<String, dynamic>
      final userData = userSnapshot.data() as Map<String, dynamic>;
      phoneNumber = userData['phoneNumber'] as String?; // Cast to String
    }

    // Step 3: Prepare order data
    final orderData = {
      'id': orderId,
      'items': _cartItems.map((item) => item.toFirestore()).toList(),
      'total': finalTotal,
      'status': 'Pending',
      'paymentMethod': _SelectedPaymentMethod,
      'voucherUsed': voucherUsed ?? 'None',
      'timestamp': FieldValue.serverTimestamp(),
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'userPhoneNumber': phoneNumber, // Add phone number to the order data
      'userEmail': userEmail,
      'orderTaken': 'Not yet'
    };

    // Step 4: Save order
    await _firestore
        .collection('Users')   //save orders for user views
        .doc(userEmail)
        .collection('orders')
        .doc(orderId)
        .set(orderData);

  // Denormalize: Save in global 'orders' collection
  await _firestore
      .collection('orders') //need to save this so barber can view all available order from database
      .doc(orderId)         // firestore cannot read all orders accross all users
      .set(orderData);


    // Step 6: Clear the cart
    for (var item in _cartItems) {
      await _firestore
          .collection('Users')
          .doc(userEmail)
          .collection('cart')
          .doc(item.id)
          .delete();
    }

    _cartItems.clear();
    _price = 0.0;
    notifyListeners();
  }
}
