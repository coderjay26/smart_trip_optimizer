import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:smart_trip_optimizer/view/auth/login_screen.dart';
import 'package:smart_trip_optimizer/view/auth/register_screen.dart';
import 'package:smart_trip_optimizer/view/choose_travel_mode_screen.dart';
import 'package:smart_trip_optimizer/view/home_screen.dart';
import 'package:smart_trip_optimizer/view/map_screen.dart';
import 'package:smart_trip_optimizer/view/widgets/screen_redirect.dart';
import 'package:smart_trip_optimizer/view/widgets/see_all_screen.dart';
import 'package:smart_trip_optimizer/view/widgets/select_available_time_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  requestPermissionAndTrack();
  runApp(const MainApp());
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
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      ),
      home: const ScreenRedirect(),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/loginScreen', page: () => const LoginScreen()),
        GetPage(name: '/registerScreen', page: () => RegisterScreen()),
        GetPage(name: '/home', page: () => HomeScreen()),
        GetPage(name: '/seeAll', page: () => SeeAllScreen()),
        GetPage(name: '/chooseTravel', page: () => ChooseTravelModeScreen()),
        GetPage(name: '/selectTime', page: () => SelectAvailableTimeScreen()),
        GetPage(
            name: '/map',
            page: () =>
                MapScreen(places: Get.arguments as List<Map<String, String>>))
      ],
    );
  }
}
