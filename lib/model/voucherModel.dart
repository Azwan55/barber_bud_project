import 'package:cloud_firestore/cloud_firestore.dart';


class VoucherModel {
  String id;
  String name;
  String image;
  double totalDiscount;
  bool isUsed = false; // Default value for isused

  VoucherModel({
    required this.id,
    required this.name,
    required this.image,
    required this.totalDiscount,
    required this.isUsed,
  });

  // Convert Firestore document to VoucherModel
  factory VoucherModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return VoucherModel(
      id: doc.id,
      name: data['name'] ?? '',
      image: data['image'] ?? '',
      totalDiscount: (data['totalDiscount'] as num).toDouble(),
      isUsed: data['isUsed'] ?? false, // Default value for isused
    );
  }

  // Convert VoucherModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'image': image,
      'totalDiscount': totalDiscount,
      'isUsed': isUsed, // Default value for isused

    };
  }
}

class VoucherList {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Reference to user's vouchers collection
  CollectionReference getVoucherCollection(String userEmail) {
    return _firestore.collection('Users').doc(userEmail).collection('vouchers');
  }

  // Add a voucher
  Future<void> addVoucher(String userEmail, VoucherModel voucher) async {
    await getVoucherCollection(userEmail).add(voucher.toFirestore());
  }

  // Fetch all vouchers for a user
  Stream<List<VoucherModel>> getVouchers(String userEmail) {
    return getVoucherCollection(userEmail).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => VoucherModel.fromFirestore(doc)).toList();
    });
  }
}
