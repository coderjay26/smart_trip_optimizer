import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../choose_destination_screen.dart';

class SelectAvailableTimeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Select Available Time',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple.shade200, Colors.deepPurple.shade700],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AvailableTimeButton(label: '2 Hours', color: Colors.blue),
              AvailableTimeButton(label: '4 Hours', color: Colors.orange),
              AvailableTimeButton(label: 'Full Day', color: Colors.red),
            ],
          ),
        ),
      ),
    );
  }
}

class AvailableTimeButton extends StatelessWidget {
  final String label;
  final Color color;

  const AvailableTimeButton({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: ElevatedButton(
        onPressed: () {
          Get.to(() => ChooseDestinationsScreen());
        },
        child: Text(
          label,
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
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
