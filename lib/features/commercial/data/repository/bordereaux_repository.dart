import "package:flutter/widgets.dart";
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gestiap/features/commercial/data/models/bordereaux_model.dart';

Future<void> addBordereau(BordereauModel bordereau) async {
  await FirebaseFirestore.instance
      .collection('bordereaux')
      .doc(bordereau.id)
      .set(bordereau.toMap());
}

Future<void> updateBordereau(BordereauModel bordereau) async {
  await FirebaseFirestore.instance
      .collection('bordereaux')
      .doc(bordereau.id)
      .update(bordereau.toMap());
}

Future<List<BordereauModel>> getBordereaux() async {
  final snapshot =
      await FirebaseFirestore.instance
          .collection('bordereaux')
          .orderBy('date', descending: true)
          .get();
  return snapshot.docs
      .map((doc) => BordereauModel.fromMap(doc.data()))
      .toList();
}
