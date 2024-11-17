import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_trip_optimizer/model/user_model.dart';

class AuthController extends GetxController {
  var user = Rxn<User>();
  var email = ''.obs;
  var password = ''.obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var isPasswordVisible = false.obs;
  var isPasswordVisibleInLogin = false.obs;
  final formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController middleNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  @override
  void onInit() {
    user.value = FirebaseAuth.instance.currentUser;
    super.onInit();
  }

  Future<void> login() async {
    if (formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email.value,
          password: password.value,
        );

        User? user = userCredential.user;
        if (user != null && user.emailVerified) {
          Get.offAndToNamed('/home');
        } else {
          Get.snackbar(
            "Email Not Verified",
            "Please verify your email before logging in.",
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } catch (e) {
        Get.snackbar(
          "Login Error",
          e.toString(),
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  Future<void> createAccount(String email, String password) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;
      if (user != null) {
        await user.updateDisplayName(fullNameController.text);

        UserModel userModel = UserModel(
            // firstName: firstNameController.text,
            // middleName: middleNameController.text,
            // lastName: lastNameController.text,
            fullName: fullNameController.text,
            age: ageController.text,
            address: addressController.text,
            email: emailController.text);

        await userModel.saveInfo(user.uid);
        await user.sendEmailVerification();
        Get.snackbar('Success', 'Account Created! Please verify your email.',
            snackPosition: SnackPosition.BOTTOM);
      }

      Get.offAllNamed('/loginScreen');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        errorMessage.value = 'Email already in use';
      } else if (e.code == 'weak-password') {
        errorMessage.value = 'Password is too weak';
      } else {
        errorMessage.value = 'Error: ${e.message}';
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logOut() async {
    await FirebaseAuth.instance.signOut();
    user.value = null;
  }
}
