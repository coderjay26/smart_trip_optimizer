import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../model/user_model.dart';

class HomeController extends GetxController {
  FirebaseAuth _auth = FirebaseAuth.instance;
  Rx<User?> firebaseUser = Rx<User?>(null);
  var places = [].obs;
  @override
  void onInit() {
    super.onInit();
    firebaseUser.bindStream(_auth.authStateChanges());
    fetchPlaces();
  }

  Future<UserModel?> getUserInfo() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userInfoSnapshot = await FirebaseFirestore.instance
            .collection('User')
            .doc(user.uid)
            .get();

        if (userInfoSnapshot.exists) {
          return UserModel.fromMap(
              userInfoSnapshot.data() as Map<String, dynamic>);
        } else {
          print("User info not found!");
          Get.offAndToNamed('/registerScreen');
          return null;
        }
      } else {
        print("No user is logged in!");
        Get.offAndToNamed('/loginScreen');
        return null;
      }
    } catch (e) {
      print("Error getting user info: $e");
      return null;
    }
  }

  Future<void> fetchPlaces() async {
    const String apiKey = 'AIzaSyBtgjzhgUsHs_2DRX0a4Q4eQqrzoE1wb40';
    const String location = '10.3371483,123.9327035';
    const String radius = '1500';
    const String type = 'point_of_interest';

    // const url =
    //     'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$location&radius=$radius&keyword=landmark|restaurant|park&key=$apiKey';

    // try {
    //   final response = await http.get(Uri.parse(url));

    //   if (response.statusCode == 200) {
    //     final data = json.decode(response.body);

    //     if (data['results'] != null) {
    //       places.value = data['results'];
    //     } else {
    //       debugPrint('No results found');
    //     }
    //   } else {
    //     throw Exception(
    //         'Failed to load places. Status code: ${response.statusCode}');
    //   }
    // } catch (e) {
    //   debugPrint('Error fetching places: $e');
    // }

    // update();
    // final types = [
    //   'beach',
    //   'hotel',
    //   'lodging',
    //   'resort',
    //   'restaurant',
    //   'park',
    //   'museum',
    //   'cafe',
    //   'tourist_attraction',
    //   'natural_feature'
    // ];
    const List<String> types = [
      'restaurant',
      'park',
      'museum',
      'cafe',
    ];

    for (final type in types) {
      final url =
          'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$location&radius=$radius&type=$type&key=$apiKey';

      try {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          if (data['results'] != null) {
            places.addAll(data['results']);
          }
        }
      } catch (e) {
        debugPrint('Error fetching places for type $type: $e');
      }
    }

    update();
  }
}
