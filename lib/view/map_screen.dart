import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:smart_trip_optimizer/controller/map_controller.dart';

class MapScreen extends StatelessWidget {
  final List<Map<String, String>> places;
  final MapXController routeController = Get.put(MapXController());
  MapController mapController = MapController();
  MapScreen({required this.places});

  @override
  Widget build(BuildContext context) {
    routeController.fetchRoute(places);
    ever<LatLng?>(routeController.userLocation, (LatLng? newLoc) {
      if (newLoc != null) {
        double adjustedHeading = routeController.heading.value;
        mapController.moveAndRotate(newLoc, 19, adjustedHeading);
      }
    });
    return Scaffold(
      appBar: AppBar(title: Text("Optimized Route")),
      body: Obx(() {
        if (routeController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        LatLng? userLoc = routeController.userLocation.value;
        List<Map<String, String>> filteredPlaces = places;
        List<LatLng> filteredRoutePoints =
            List.from(routeController.routePoints);

        if (userLoc != null) {
          const double thresholdDistance = 10.0;
          Distance distance = Distance();

          filteredPlaces = places.where((place) {
            LatLng placeLatLng = LatLng(
              double.parse(place['lat']!),
              double.parse(place['lng']!),
            );
            double meterDistance = distance.as(
              LengthUnit.Meter,
              userLoc,
              placeLatLng,
            );
            return meterDistance > thresholdDistance;
          }).toList();

          filteredRoutePoints.removeWhere((point) {
            double meterDistance = distance.as(
              LengthUnit.Meter,
              userLoc,
              point,
            );
            return meterDistance < thresholdDistance;
          });
        }

        return Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              color: Colors.blue,
              child: Obx(() => Text(
                    routeController.currentInstruction.value.isNotEmpty
                        ? routeController.currentInstruction.value
                        : "Follow the route",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  )),
            ),
            Expanded(
              flex: 3,
              child: FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  initialCenter: LatLng(
                    double.parse(places[0]['lat']!),
                    double.parse(places[0]['lng']!),
                  ),
                  initialZoom: 15,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: ['a', 'b', 'c'],
                  ),
                  if (filteredRoutePoints.isNotEmpty)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: filteredRoutePoints,
                          color: Colors.blue,
                          strokeWidth: 4.0,
                        ),
                      ],
                    ),
                  MarkerLayer(
                    rotate: true,
                    markers: filteredPlaces.asMap().entries.map((entry) {
                      int index = entry.key + 1;
                      Map<String, String> place = entry.value;

                      return Marker(
                        width: 60,
                        height: 40,
                        point: LatLng(
                          double.parse(place['lat']!),
                          double.parse(place['lng']!),
                        ),
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
                                "$index",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(width: 4),
                            GestureDetector(
                              onTap: () {
                                Get.snackbar(
                                  "Location #$index",
                                  place['name'] ?? "Unknown Place",
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.black54,
                                  colorText: Colors.white,
                                );
                              },
                              child: Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 30,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  if (userLoc != null)
                    MarkerLayer(
                      rotate: true,
                      markers: [
                        Marker(
                          width: 40,
                          height: 40,
                          point: userLoc,
                          child: Image.asset('assets/images/image.png'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            Obx(() => routeController.instructions.isNotEmpty
                ? Expanded(
                    flex: 1,
                    child: ListView.builder(
                      itemCount: routeController.instructions.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue,
                            child: Text('${index + 1}',
                                style: TextStyle(color: Colors.white)),
                          ),
                          title: Text(routeController.instructions[index]),
                        );
                      },
                    ),
                  )
                : Container())
          ],
        );
      }),
    );
  }
}

class ImageMarker extends StatelessWidget {
  final String imagePath;

  const ImageMarker({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class PinMarker extends StatelessWidget {
  final String imagePath;

  const PinMarker({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}
