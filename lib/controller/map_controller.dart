import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:math';

import 'package:flexible_polyline_dart/flutter_flexible_polyline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class MapXController extends GetxController {
  Rx<LatLng> currentLocation = LatLng(8.6525, 123.4228).obs;
  RxList<LatLng> routePoints = <LatLng>[].obs;
  RxList<String> instructions =
      <String>[].obs; // Observable list for instructions
  RxString currentInstruction =
      ''.obs; // Observable for the current instruction
  var isLoading = true.obs;
  Rx<LatLng?> userLocation = Rx<LatLng?>(null);
  final FlutterTts flutterTts = FlutterTts();
  var heading = 0.0.obs; // Observable for heading
  @override
  void onInit() {
    super.onInit();
    requestPermissionAndTrack();
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
        distanceFilter: 0, // Update every 5 meters
      ),
    ).listen((Position position) {
      currentLocation.value = LatLng(position.latitude, position.longitude);

      update(); // Notify UI
    });
  }

  static const String apiKey = "-sg6CTyTAGS_EIj9w95ZRJmqlKjUtCpa6JEWG8CG8_c";

  Future<void> fetchRoute(
    List<Map<String, String>> places,
    String lat,
    String lng,
  ) async {
    isLoading.value = true;

    if (places.length < 2) {
      print("Not enough places for a route.");
      isLoading.value = false;
      return;
    }

    // 🚗 Set transport mode to flexible
    String transportMode = "car"; // Default to driving

    // Start and End points
    // String origin = "${places.first['lat']},${places.first['lng']}";
    final updatedPlaces = [
      {
        'lat': lat,
        'lng': lng,
      },
      ...places,
    ];
    print("Current Location: $lat, $lng");
    print("Places: $updatedPlaces");
    // String origin = myLoc.value;
    // String destination = "${places.last['lat']},${places.last['lng']}";
    String origin =
        "${updatedPlaces.first['lat']},${updatedPlaces.first['lng']}";
    String destination =
        "${updatedPlaces.last['lat']},${updatedPlaces.last['lng']}";

    String viaPoints = updatedPlaces.length > 2
        ? updatedPlaces.sublist(1, updatedPlaces.length - 1).map((place) {
            return "&via=${place['lat']},${place['lng']}";
          }).join("")
        : "";
    // Waypoints (HERE API uses `via=`)
    // String viaPoints = places.length > 2
    //     ? places.sublist(1, places.length - 1).map((place) {
    //         return "&via=${place['lat']},${place['lng']}";
    //       }).join("")
    //     : "";

    // 📌 Allow walking in mixed routes
    String url = "https://router.hereapi.com/v8/routes?"
        "transportMode=$transportMode"
        "&origin=$origin"
        "&destination=$destination"
        "&return=polyline,actions"
        "&traffic=true"
        "&apiKey=$apiKey"
        "$viaPoints";

    print("API URL: $url");

    try {
      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data['routes'] == null ||
            data['routes'].isEmpty ||
            data['routes'][0]['sections'] == null ||
            data['routes'][0]['sections'].isEmpty) {
          print("Invalid API response: ${response.body}");
          return;
        }

        List<LatLng> polylineCoordinates = [];
        instructions.clear(); // Clear old instructions
        List<Map<String, dynamic>> actions = []; // List to store actions

        // Create a list of Futures to handle async tasks if needed
        List<Future<void>> sectionTasks = [];

        // Process each section asynchronously if needed
        for (var section in data['routes'][0]['sections']) {
          sectionTasks.add(Future(() async {
            if (section.containsKey('polyline')) {
              polylineCoordinates
                  .addAll(decodeHerePolyline(section['polyline']));
            }
            print('Polyline Length: ${polylineCoordinates.length}');
            // 🧭 Extract instructions (actions) for each section
            if (section.containsKey('actions')) {
              actions.addAll(
                  (section['actions'] as List).cast<Map<String, dynamic>>());
            }
          }));
        }

        // Wait for all section processing to finish
        await Future.wait(sectionTasks);

        // Now that all sections are processed, assign the route to an observable list
        routePoints.assignAll(polylineCoordinates);
        print("Route Points Length: ${routePoints.length}");
        dev.log("Decoded Route Points: $routePoints");

        // Start tracking user progress with actions
        for (var action in actions) {
          instructions.add(_formatInstruction(action));
        }

        _trackUserProgress(actions);
      } else {
        print("API Error: ${response.body}");
      }
    } catch (e) {
      print("Exception occurred: $e");
    } finally {
      isLoading.value = false;
    }
  }

  String _formatInstruction(Map<String, dynamic> action) {
    String actionType = action['action'] ?? '';
    String direction = action['direction'] ?? '';
    int length = action['length'] ?? 0;

    switch (actionType) {
      case 'depart':
        return "Start your journey.";
      case 'turn':
        return "Turn ${direction.isNotEmpty ? direction : ''} in ${length} meters.";
      case 'arrive':
        return "You have arrived at your destination.";
      case 'keep':
        return "Keep ${direction.isNotEmpty ? direction : ''} for ${length} meters.";
      case 'continue':
        return "Continue straight for ${length} meters.";
      default:
        return "Proceed as directed.";
    }
  }

  void _trackUserProgress(List<Map<String, dynamic>> actions) async {
    print('Actions Track Length: ${actions.length}');
    Timer.periodic(Duration(seconds: 5), (timer) async {
      LatLng? userLoc = userLocation.value;

      if (userLoc == null) {
        print("User location is null. Stopping progress tracking.");
        timer.cancel();
        return;
      }

      if (actions.isEmpty || routePoints.isEmpty) {
        print("No more actions or route points. Stopping progress tracking.");
        currentInstruction.value = "You have arrived at your destination.";
        // timer.cancel();
        // return;
      }

      // Get the next action
      Map<String, dynamic> nextAction = actions.first;
      int offset = nextAction['offset'];

      // Validate the offset
      if (offset < 0 || offset >= routePoints.length) {
        print("Invalid offset: $offset. Stopping progress tracking.");
        timer.cancel();
        return;
      }

      // Get the route point corresponding to the offset
      LatLng nextPoint = routePoints[offset];

      // Calculate the distance to the next point
      double distanceToNextPoint = _calculateDistance(userLoc, nextPoint);
      print('Distance to next point: $distanceToNextPoint meters');

      if (distanceToNextPoint <= 50.0) {
        // Threshold distance in meters
        // Update the current instruction
        currentInstruction.value = _formatInstruction(nextAction);
        print("Updated instruction: ${currentInstruction.value}");
        speak(currentInstruction.value);
        // Remove the completed action
        actions.removeAt(0);
        instructions.removeAt(0);
        print(
            "Action completed. Remaining actions: ${actions.length} Route Points: ${routePoints.length}, Offset: $offset");
        // If no more actions or route points, stop the timer
        if (actions.isEmpty || routePoints.isEmpty) {
          currentInstruction.value = "You have arrived at your destination.";
          print("Route completed. Stopping progress tracking.");

          // timer.cancel();
        }
        if (currentInstruction.value ==
            "You have arrived at your destination.") {
          routePoints.removeRange(0, offset);
          await Future.delayed(Duration(seconds: 6));
          currentInstruction.value = "Start your next journey.";
        }
      }
    });
  }

  Future<void> speak(String text) async {
    try {
      await flutterTts.setLanguage("en-US");
      await flutterTts.setPitch(1.0);
      await flutterTts.setSpeechRate(0.5); // adjust if needed
      await flutterTts.speak(text);
    } catch (e) {
      print("Error speaking: $e");
    }
  }

// Helper method to calculate distance between two LatLng points
  double _calculateDistance(LatLng start, LatLng end) {
    const double R = 6371000; // Radius of the Earth in meters
    double lat1 = start.latitude * (pi / 180); // Convert to radians
    double lon1 = start.longitude * (pi / 180);
    double lat2 = end.latitude * (pi / 180);
    double lon2 = end.longitude * (pi / 180);

    double dlat = lat2 - lat1;
    double dlon = lon2 - lon1;

    double a = sin(dlat / 2) * sin(dlat / 2) +
        cos(lat1) * cos(lat2) * sin(dlon / 2) * sin(dlon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c; // Distance in meters
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
        // distanceFilter: 5, // Update when user moves 10 meters
      ),
    ).listen((Position position) {
      userLocation.value = LatLng(position.latitude, position.longitude);
      heading.value = position.heading; // Update heading
    });
  }
}
//rRKUcmqXtJ03mkvsrzYS
//-sg6CTyTAGS_EIj9w95ZRJmqlKjUtCpa6JEWG8CG8_c