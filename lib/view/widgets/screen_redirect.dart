import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/auth_controller.dart';
import '../auth/login_screen.dart';
import '../home_screen.dart';

class ScreenRedirect extends StatelessWidget {
  const ScreenRedirect({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize AuthController
    final authController = Get.put(AuthController());

    // Check if the user is logged in
    return Obx(() {
      if (authController.user.value != null) {
        // If user is logged in, navigate to the home screen
        return HomeScreen();
      } else {
        // If user is not logged in, navigate to the login screen
        return LoginScreen();
      }
    });
  }
}
