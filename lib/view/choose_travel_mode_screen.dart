import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_trip_optimizer/controller/home_controller.dart';

class ChooseTravelModeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    HomeController homeController = Get.find();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Choose Travel Mode',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blueAccent.shade200, Colors.blueAccent.shade700],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TravelModeButton(
                  icon: Icons.directions_walk,
                  label: 'Walking',
                  color: Colors.green),
              TravelModeButton(
                  icon: Icons.directions_bike,
                  label: 'Biking',
                  color: Colors.orange),
              TravelModeButton(
                  icon: Icons.directions_car, label: 'Car', color: Colors.red),
              // TravelModeButton(
              //     icon: Icons.directions_bus,
              //     label: 'Public Transport',
              //     color: Colors.purple),
            ],
          ),
        ),
      ),
    );
  }
}

class TravelModeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const TravelModeButton({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    HomeController homeController = Get.find();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
      child: ElevatedButton.icon(
        onPressed: () {
          homeController.travelMode.value = label.toLowerCase();
          Get.toNamed('/selectTime');
        },
        icon: Icon(icon, size: 28, color: Colors.white),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 5,
        ),
      ),
    );
  }
}
