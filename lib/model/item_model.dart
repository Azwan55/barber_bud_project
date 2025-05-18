import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ItemModel {
  String id;
  String name;
  String image;
  double price;
  int qty;
  Color color; // Added color field

  ItemModel({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.qty,
    required this.color,
  });

  // Convert Firestore document to ItemModel
  factory ItemModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ItemModel(
      id: doc.id, // Use Firestore document ID as item ID
      name: data['name'] ?? '',
      image: data['image'] ?? '',
      price: (data['price'] as num).toDouble(),
      qty: data['qty'] ?? 1,
      color: Color(data['color']as int ?? 0xFFFFFFFF), // Convert integer to Color
    );
  }

  // Convert ItemModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'image': image,
      'price': price,
      'qty': qty,
      'color': color.value, // Store color as an integer
    };
  }
}
