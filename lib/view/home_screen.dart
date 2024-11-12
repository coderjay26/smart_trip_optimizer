import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_trip_optimizer/controller/home_controller.dart';
import 'package:smart_trip_optimizer/model/user_model.dart';

import '../controller/auth_controller.dart';

class HomeScreen extends StatelessWidget {
  final AuthController _authController = Get.find();
  final HomeController _homeController = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: FutureBuilder<UserModel?>(
        future: _homeController.getUserInfo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            var userInfo = snapshot.data;
            if (userInfo != null) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('First Name: ${userInfo.firstName}'),
                    Text('Last Name: ${userInfo.lastName}'),
                    Text('Middle Name: ${userInfo.middleName}'),
                    Text('Address: ${userInfo.address}'),
                    Text('Age: ${userInfo.address}'),
                    Text('Email: ${userInfo.email}'),
                    OutlinedButton(
                        onPressed: () => _authController.logOut(),
                        child: const Text('Logout'))
                  ],
                ),
              );
            } else {
              return const Center(child: Text('User info not found.'));
            }
          } else {
            return const Center(child: Text('No data available.'));
          }
        },
      ),
    );
  }
}
