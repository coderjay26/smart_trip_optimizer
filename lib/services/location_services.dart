import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';

class LocationServices extends GetxController {
  Rx<Position?> currentPosition = Rx<Position?>(null);
  RxBool isListening = false.obs;
  Stream<Position>? positionStream;

  @override
  void onInit() {
    super.onInit();
    _requestPermission();
  }

  /// Request Location Permission
  Future<void> _requestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar("Error", "Location services are disabled.");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar(
            "Permission Denied", "Please enable location permissions.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar(
          "Permission Denied", "Location access is permanently denied.");
      return;
    }

    // If permission granted, start listening
    startListening();
  }

  /// Start Listening to Location Changes
  void startListening() {
    if (isListening.value) return;

    positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Updates every 10 meters
      ),
    );

    positionStream!.listen((Position position) {
      currentPosition.value = position;
      update();
    });

    isListening.value = true;
  }

  /// Stop Listening
  void stopListening() {
    positionStream = null;
    isListening.value = false;
  }
}
