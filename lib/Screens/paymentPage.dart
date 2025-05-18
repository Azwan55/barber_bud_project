import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_year_project/Resources/constant.dart';
import 'package:final_year_project/provider/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

class PaymentPage extends StatefulWidget {
  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool isProcessing = false;

  List<Map<String, dynamic>> voucherList = [];
  Map<String, dynamic>? selectedVoucher;

  @override
  void initState() {
    super.initState();
    fetchVouchers();
  }

  Future<void> fetchVouchers() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.email)
          .collection('vouchers')
          .where('isUsed', isEqualTo: false)
          .get();

      List<Map<String, dynamic>> vouchers = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['name'],
          'totalDiscount': doc['totalDiscount'],
        };
      }).toList();

      setState(() {
        voucherList = vouchers;
      });
    } catch (e) {
      print('Error fetching vouchers: $e');
    }
  }

  Future<void> makePayment(double amount) async {
    setState(() => isProcessing = true);

    String selectedPaymentMethod =
        Provider.of<CartProvider>(context, listen: false).selectedPaymentMethod;

    if (selectedPaymentMethod == "eWallet") {
      await payWithEwallet(amount);
    } else if (selectedPaymentMethod == "Cash") {
      await payWithCash(amount);
    }

    await fetchVouchers(); // Refresh voucher dropdown
    setState(() {
      selectedVoucher = null;
      isProcessing = false;
    });
  }

  Future<void> payWithEwallet(double amount) async {
    try {
      double amountToPay = amount; // Default to the amount passed

      QuerySnapshot walletSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.email)
          .collection('ewallet')
          .limit(1)
          .get();

      if (walletSnapshot.docs.isNotEmpty) {
        DocumentReference userWalletRef = walletSnapshot.docs.first.reference;
        var balanceData = walletSnapshot.docs.first['balance'];
        double currentBalance = 0.0;

        if (balanceData is num) {
          currentBalance = balanceData.toDouble();
        } else if (balanceData is String) {
          currentBalance = double.tryParse(balanceData) ?? 0.0;
        }

        if (currentBalance >= amountToPay) {
          await userWalletRef.update({'balance': currentBalance - amountToPay});

          QuerySnapshot orderSnapshot = await FirebaseFirestore.instance
              .collection('Users')
              .doc(currentUser.email)
              .collection('orders')
              .orderBy('timestamp', descending: true)
              .limit(1)
              .get();

          if (orderSnapshot.docs.isNotEmpty) {
            String orderId = orderSnapshot.docs.first.id;

            await FirebaseFirestore.instance
                .collection('Users')
                .doc(currentUser.email)
                .collection('transactions')
                .add({
              'timestamp': FieldValue.serverTimestamp(),
              'orderId': orderId,
              'amount': amountToPay,
              'status': 'Pending',
              'paymentMethod': 'eWallet',
              'voucherUsed':
                  selectedVoucher != null ? selectedVoucher!['name'] : 'None',
            });

            if (selectedVoucher != null) {
              await FirebaseFirestore.instance
                  .collection('Users')
                  .doc(currentUser.email)
                  .collection('vouchers')
                  .doc(selectedVoucher!['id'])
                  .update({'isUsed': true});
            }

            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                  "Payment successful! See your order status at Orders Page"),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("No recent orders found."),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
            ));
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Insufficient balance!"),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("E-Wallet account not found."),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error processing eWallet payment: $e"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 5),
      ));
    }
  }

  Future<void> payWithCash(double amount) async {
    try {
      double amountToPay = amount; // Default to the amount passed

      DocumentReference cashPaymentRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.email)
          .collection('transactions')
          .doc();

      await cashPaymentRef.set({
        'amount': amountToPay, // Use the discounted amount here
        'paymentMethod': 'Cash',
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'Pending',
        'voucherUsed':
            selectedVoucher != null ? selectedVoucher!['name'] : 'None',
      });

      if (selectedVoucher != null) {
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser.email)
            .collection('vouchers')
            .doc(selectedVoucher!['id'])
            .update({'isUsed': true});
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            "Payment of RM $amountToPay recorded. Please pay in cash. See your order status at Orders Page."),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error processing cash payment: $e"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 5),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    double deliveryFee = 5;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: SecondaryColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("Make Payment", style: TextStyle(color: SecondaryColor)),
        centerTitle: true,
        backgroundColor: PrimaryColor,
      ),
      body: Consumer<CartProvider>(
        builder: (context, provider, child) {
          double subtotal = provider.price + deliveryFee;
          double discountPercent = selectedVoucher != null
              ? (selectedVoucher!['totalDiscount'] as num).toDouble()
              : 0.0;
          double discountAmount = subtotal * (discountPercent / 100);
          double totalAfterDiscount = subtotal - discountAmount;

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Payment Details',
                    style: TextStyle(color: SecondaryColor, fontSize: 20)),
                SizedBox(height: 10),
                Row(
                  children: [
                    Text('Services Subtotal',
                        style: TextStyle(color: SecondaryColor, fontSize: 13)),
                    Spacer(),
                    Text('RM ${provider.price.toStringAsFixed(2)}',
                        style: TextStyle(color: SecondaryColor, fontSize: 13)),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Text('Delivery Fee',
                        style: TextStyle(color: SecondaryColor, fontSize: 13)),
                    Spacer(),
                    Text('RM $deliveryFee',
                        style: TextStyle(color: SecondaryColor, fontSize: 13)),
                  ],
                ),
                SizedBox(height: 10),
                if (discountPercent > 0)
                  Row(
                    children: [
                      Text('Discount (${discountPercent.toStringAsFixed(0)}%)',
                          style: TextStyle(
                              color: Colors.greenAccent, fontSize: 13)),
                      Spacer(),
                      Text('-RM ${discountAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                              color: Colors.greenAccent, fontSize: 13)),
                    ],
                  ),
                Divider(color: Colors.grey),
                Row(
                  children: [
                    Text('Total Amount',
                        style: TextStyle(color: SecondaryColor, fontSize: 20)),
                    Spacer(),
                    Text('RM ${totalAfterDiscount.toStringAsFixed(2)}',
                        style: TextStyle(color: SecondaryColor, fontSize: 20)),
                  ],
                ),
                SizedBox(height: 30),
                Text("Apply Voucher:",
                    style: TextStyle(color: Colors.white, fontSize: 18)),
                SizedBox(height: 10),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return DropdownButtonFormField<Map<String, dynamic>>(
                      value: selectedVoucher,
                      items: voucherList.map((voucher) {
                        return DropdownMenuItem<Map<String, dynamic>>(
                          value: voucher,
                          child: Container(
                            width: constraints.maxWidth -
                                50, // Give some padding space
                            child: Text(
                              "${voucher['name']} - ${voucher['totalDiscount']}% OFF",
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedVoucher = value;
                        });
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      hint: Text("Select a voucher",
                          style: TextStyle(color: Colors.grey)),
                    );
                  },
                ),
                SizedBox(height: 30),
                Text("Select Payment Method:",
                    style: TextStyle(color: Colors.white, fontSize: 18)),
                SizedBox(height: 10),
                Column(
                  children: [
                    RadioListTile(
                      activeColor: SecondaryColor,
                      title: Text("Ewallet",
                          style: TextStyle(color: Colors.white)),
                      value: "eWallet",
                      groupValue: provider.selectedPaymentMethod,
                      onChanged: (value) {
                        provider.setSelectedPaymentMethod(value.toString());
                      },
                    ),
                    RadioListTile(
                      activeColor: SecondaryColor,
                      title:
                          Text("Cash", style: TextStyle(color: Colors.white)),
                      value: "Cash",
                      groupValue: provider.selectedPaymentMethod,
                      onChanged: (value) {
                        provider.setSelectedPaymentMethod(value.toString());
                      },
                    ),
                  ],
                ),
                Spacer(),
                Center(
                  child: ElevatedButton(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Text("Make Payment",
                          style: TextStyle(color: PrimaryColor, fontSize: 15)),
                    ),
                    onPressed: () async {
                      double deliveryFee = 5;

                      // Get the current price before any cart reset
                      double subtotal =
                          context.read<CartProvider>().price + deliveryFee;
                      double discountPercent = selectedVoucher != null
                          ? (selectedVoucher!['totalDiscount'] as num)
                              .toDouble()
                          : 0.0;
                      double discountAmount =
                          subtotal * (discountPercent / 100);
                      double totalAfterDiscount = subtotal - discountAmount;

                      await provider.checkout(
                        finalTotal: totalAfterDiscount,
                        voucherUsed: selectedVoucher != null
                            ? selectedVoucher!['name']
                            : null,
                      );

                      await makePayment(
                          totalAfterDiscount); // Use the stored discounted total
                      Navigator.pushReplacementNamed(context, 'home');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SecondaryColor,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      textStyle: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
