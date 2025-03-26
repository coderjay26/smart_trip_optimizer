import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:smart_trip_optimizer/controller/map_controller.dart';

class MapScreen extends StatelessWidget {
  final List<Map<String, String>> places;
  final MapXController routeController = Get.put(MapXController());

  MapScreen({required this.places});

  @override
  Widget build(BuildContext context) {
    routeController.fetchRoute(places); // Fetch route on screen load
    if (places.isEmpty) {
      return Scaffold(
        body: Center(child: Text("No places found!")),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text("Optimized Route")),
      body: Obx(() => routeController.isLoading.value
          ? Center(child: CircularProgressIndicator())
          : FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(double.parse(places[0]['lat']!),
                    double.parse(places[0]['lng']!)),
                initialZoom: 12,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                // 🔹 Move PolylineLayer above TileLayer
                if (routeController.routePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: routeController.routePoints,
                        color: Colors.blue,
                        strokeWidth: 4.0,
                      ),
                    ],
                  ),
                MarkerLayer(
                  rotate: true,
                  markers: places.asMap().entries.map((entry) {
                    int index = entry.key + 1; // Get index (starting from 1)
                    Map<String, String> place = entry.value;

                    return Marker(
                      width: 60,
                      height: 40,
                      point: LatLng(double.parse(place['lat']!),
                          double.parse(place['lng']!)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              "$index", // Show index number
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(
                              width: 4), // Spacing between number and marker
                          GestureDetector(
                            onTap: () {
                              Get.snackbar(
                                "Location #$index", // Title with index
                                place['name'] ?? "Unknown Place", // Message
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.black54,
                                colorText: Colors.white,
                              );
                            },
                            child: Icon(Icons.location_on,
                                color: Colors.red, size: 30),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                )
              ],
            )),
    );
  }
}
