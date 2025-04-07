import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../model/user_model.dart';

class HomeController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Rx<User?> firebaseUser = Rx<User?>(null);
  String apiKey = 'fsq32LNAY1BKHcXejQoztES+aunSzVug9Oyaajv0r/RbC/I=';
  var places = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> filteredPlaces = <Map<String, dynamic>>[].obs;
  var travelMode = 'walking'.obs;
  final Rx<LatLng?> userLocation = Rx<LatLng?>(null);

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

  void filterPlaces(String query) {
    if (query.isEmpty) {
      filteredPlaces.value = List.from(places); // Reset to original list
    } else {
      filteredPlaces.value = places
          .where((place) => place['name']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    }
    update();
  }

  Future<void> fetchPlaces() async {
    const String lat = "8.6253";
    const String lon = "123.3946";
    const int radius = 30000;
    const String categories = "16000,12086,19000,13000,16011,16032";

    const url =
        "https://api.foursquare.com/v3/places/search?near=Dapitan City, Philippines"
        "&categories=$categories&limit=50";

    developer.log(url);

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": apiKey,
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['results'] != null) {
          List<Map<String, dynamic>> fetchedPlaces = [];

          for (var place in data['results']) {
            String placeName = (place['name'] ?? 'Unknown').toString();

            developer.log('Original Place Name: $placeName');

            if (placeName.toLowerCase().contains('lodge')) {
              placeName =
                  placeName.replaceAll(RegExp(r'\b[Ll]odge\b'), 'Restaurant');
              developer.log('Updated Place Name: $placeName');
            }
            String category =
                (place['categories'] != null && place['categories'].isNotEmpty)
                    ? place['categories'][0]['name']
                    : 'No description available';
            if (category.toLowerCase().contains('fuel') ||
                category.toLowerCase().contains('gas station')) {
              continue;
            }

            String fsqId = place['fsq_id'] ?? ''; // Get the Foursquare ID

            // Fetch the image for this place
            String imageUrl = await fetchPlaceImage(fsqId) ??
                'https://via.placeholder.com/600';

            fetchedPlaces.add({
              'name': placeName,
              'image': imageUrl,
              'description': category,
              'address': (place['location'] != null &&
                      place['location']['formatted_address'].isNotEmpty)
                  ? place['location']['formatted_address']
                  : 'No description available',
              'lat': place['geocodes']['main']['latitude'].toString(),
              'lng': place['geocodes']['main']['longitude'].toString(),
            });
          }
          // ✅ Manually Add Static Places
          List<Map<String, dynamic>> staticPlaces = [
            {
              'name': "Rizal Shrine",
              'image':
                  "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTanLTcfIcRJDxmSdbstdo_Mya7OQfTlf4KzQ&s",
              'description': "Historical Landmark",
              'address': "Dapitan City, Philippines",
              'lat': "8.666964",
              'lng': "123.417202",
            },
            {
              'name': "Dakak Beach Resort",
              'image':
                  "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcROR-EKVWJgtI-GwOeXroZUdJwHHDHr9lPZcA&s",
              'description': "Beach Resort",
              'address': "Dapitan City, Philippines",
              'lat': "8.695322",
              'lng': "123.393373",
            },
            {
              'name': "Glorious Fantasyland",
              'image':
                  "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcREEYgOmF6jrrR1fJhdQmOsGn0veXqJNgysrCRWkZvkbn020isaaijwl4deF28zcfN2-_k&usqp=CAU",
              'description': "Theme Park",
              'address': "Dapitan City, Philippines",
              'lat': "8.647824",
              'lng': "123.417666",
            },
            {
              'name': "Casa del Rio",
              'image':
                  "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTvGksRaRWMPOhh7py7mlDmbepQcnW_W9H_wQ&s",
              'description': "Hotel & Resort",
              'address': "Dapitan City, Philippines",
              'lat': "8.647824",
              'lng': "123.417666",
            },
          ];

          // Merge API Results with Static Places
          places.value = [...staticPlaces, ...fetchedPlaces];
        }
      } else {
        debugPrint('Error: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error fetching places: $e');
    }
    filterPlaces('');
  }

  Future<String?> fetchPlaceImage(String fsqId) async {
    // const String apiKey = "YOUR_FOURSQUARE_API_KEY";
    final url = "https://api.foursquare.com/v3/places/$fsqId/photos";

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": apiKey,
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.isNotEmpty) {
          final firstPhoto = data.first;
          return "${firstPhoto['prefix']}300x300${firstPhoto['suffix']}";
        }
      }
    } catch (e) {
      debugPrint('Error fetching image: $e');
    }
    return null;
  }

  double haversine(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371; // Earth radius in km
    double dLat = (lat2 - lat1) * pi / 180;
    double dLon = (lon2 - lon1) * pi / 180;
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) *
            cos(lat2 * pi / 180) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double getEstimatedTravelTime(double distance) {
    Map<String, double> speedPerMode = {
      'walking': 5,
      'bicycling': 15,
      'driving': 50,
    };

    double speed = speedPerMode[travelMode.value] ?? 5;
    return (distance / speed) * 60;
  }
}
