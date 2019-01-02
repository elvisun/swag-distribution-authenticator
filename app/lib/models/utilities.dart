import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

String getFaceCount(QuerySnapshot snapshot) {
  return snapshot?.documents?.length.toString() ??
      '0';
}
