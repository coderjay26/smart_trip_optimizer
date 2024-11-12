import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:smart_trip_optimizer/view/auth/login_screen.dart';
import 'package:smart_trip_optimizer/view/auth/register_screen.dart';
import 'package:smart_trip_optimizer/view/home_screen.dart';
import 'package:smart_trip_optimizer/view/widgets/screen_redirect.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MainApp());
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
      ],
    );
  }
}
