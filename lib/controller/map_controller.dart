import 'dart:convert';
import 'dart:developer';

import 'package:flexible_polyline_dart/flutter_flexible_polyline.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class MapXController extends GetxController {
  Rx<LatLng> currentLocation = LatLng(8.6525, 123.4228).obs;
  RxList<LatLng> routePoints = <LatLng>[].obs;
  var isLoading = true.obs;
  Rx<LatLng?> userLocation = Rx<LatLng?>(null);
  @override
  void onInit() {
    super.onInit();
    requestPermissionAndTrack();
    // _startLocationListener();
  }

  void _startLocationListener() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar("Location Error", "Enable GPS to use this feature");
      return;
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar("Permission Denied", "Location permission is required");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar(
          "Permission Denied", "Location services are permanently denied.");
      return;
    }

    // Start listening to location updates
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // Update every 5 meters
      ),
    ).listen((Position position) {
      currentLocation.value = LatLng(position.latitude, position.longitude);
      update(); // Notify UI
    });
  }

  static const String apiKey = "-sg6CTyTAGS_EIj9w95ZRJmqlKjUtCpa6JEWG8CG8_c";
  Future<void> fetchRoute(List<Map<String, String>> places) async {
    isLoading.value = true;

    if (places.length < 2) {
      log("Not enough places for a route.");
      isLoading.value = false;
      return;
    }

    // 🚗 Set transport mode to flexible
    String transportMode = "car"; // Default to driving

    // Start and End points
    String origin = "${places.first['lat']},${places.first['lng']}";
    String destination = "${places.last['lat']},${places.last['lng']}";

    // Waypoints (HERE API uses `via=`)
    String viaPoints = places.length > 2
        ? places.sublist(1, places.length - 1).map((place) {
            return "&via=${place['lat']},${place['lng']}";
          }).join("")
        : "";

    // 📌 Allow walking in mixed routes
    String url = "https://router.hereapi.com/v8/routes?"
        "transportMode=$transportMode"
        "&origin=$origin"
        "&destination=$destination"
        "&return=polyline,actions"
        "&apiKey=$apiKey"
        "$viaPoints";

    log("API URL: $url");

    try {
      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data['routes'] == null ||
            data['routes'].isEmpty ||
            data['routes'][0]['sections'] == null ||
            data['routes'][0]['sections'].isEmpty) {
          log("Invalid API response: ${response.body}");
          return;
        }

        List<LatLng> polylineCoordinates = [];

        for (var section in data['routes'][0]['sections']) {
          if (section.containsKey('polyline')) {
            polylineCoordinates.addAll(decodeHerePolyline(section['polyline']));
          }

          // 🚶‍♂️ If a walking section is included, adjust UI
          if (section['transport']['mode'] == 'pedestrian') {
            log("Walking section detected!");
          }
        }

        // Assign the route to an observable list
        routePoints.assignAll(polylineCoordinates);
        log("Decoded Route Points: $routePoints");
      } else {
        log("API Error: ${response.body}");
      }
    } catch (e) {
      log("Exception occurred: $e");
    } finally {
      isLoading.value = false;
    }
  }

  List<LatLng> decodeHerePolyline(String encoded) {
    final decodedList = FlexiblePolyline.decode(encoded);
    return decodedList.map((point) => LatLng(point.lat, point.lng)).toList();
  }

  Future<void> requestPermissionAndTrack() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar(
        "Permission Denied",
        "Location permission is permanently denied. Enable it in settings.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      trackUserLocation();
    }
  }

  void trackUserLocation() {
    Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update when user moves 10 meters
      ),
    ).listen((Position position) {
      userLocation.value = LatLng(position.latitude, position.longitude);
    });
  }
}
//rRKUcmqXtJ03mkvsrzYS
//-sg6CTyTAGS_EIj9w95ZRJmqlKjUtCpa6JEWG8CG8_c