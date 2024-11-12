// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class UserModel {
  String firstName;
  String middleName;
  String lastName;
  String age;
  String address;
  String email;
  UserModel({
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.age,
    required this.address,
    required this.email,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
      'age': age,
      'address': address,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      firstName: map['firstName'] as String,
      middleName: map['middleName'] as String,
      lastName: map['lastName'] as String,
      age: map['age'] as String,
      address: map['address'] as String,
      email: map['email'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  Future<void> saveInfo(userId) async {
    try {
      await FirebaseFirestore.instance.collection('User').doc(userId).set({
        'firstName': firstName,
        'middleName': middleName,
        'lastName': lastName,
        'address': address,
        'age': age,
        'email': email,
      });
    } catch (e) {
      debugPrint('UserModel->saveInfo: $e');
    }
  }
}
