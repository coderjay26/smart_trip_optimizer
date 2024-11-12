import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../model/user_model.dart';

class HomeController extends GetxController {
  FirebaseAuth _auth = FirebaseAuth.instance;
  Rx<User?> firebaseUser = Rx<User?>(null);

  @override
  void onInit() {
    super.onInit();
    firebaseUser.bindStream(_auth.authStateChanges());
  }

  Future<UserModel?> getUserInfo() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userInfoSnapshot = await FirebaseFirestore.instance
            .collection('User')
            .doc(user.uid)
            .get();

        if (userInfoSnapshot.exists) {
          return UserModel.fromMap(
              userInfoSnapshot.data() as Map<String, dynamic>);
        } else {
          print("User info not found!");
          Get.offAndToNamed('/registerScreen');
          return null;
        }
      } else {
        print("No user is logged in!");
        Get.offAndToNamed('/loginScreen');
        return null;
      }
    } catch (e) {
      print("Error getting user info: $e");
      return null;
    }
  }
}
