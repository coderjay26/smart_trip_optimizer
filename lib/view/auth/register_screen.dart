import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_trip_optimizer/controller/auth_controller.dart';

import '../../constant/text_cons.dart';

class RegisterScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>(); // GlobalKey for form validation
  final AuthController _authController =
      Get.find(); // Initialize AuthController

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              color: StyleConst.body_color,
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Text(
                      TextCons.login_header,
                      style: StyleConst.auth_header,
                    ),
                    const Text(
                      TextCons.sign_in_sub_header,
                      style: StyleConst.auth_sub_header,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32.0),
                    TextFormField(
                      controller: _authController.fullNameController,
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        fillColor: StyleConst.auth_text_field_color,
                        filled: true,
                        labelStyle: const TextStyle(
                          color: Colors.grey,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                            color: StyleConst.auth_text_field_color,
                            width: 1.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                            color: Colors.grey,
                            width: 2.0,
                          ),
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name'; 
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _authController.emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        fillColor: StyleConst.auth_text_field_color,
                        filled: true,
                        labelStyle: const TextStyle(
                          color: Colors.grey,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                            color: StyleConst.auth_text_field_color,
                            width: 1.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                            color: Colors.grey,
                            width: 2.0,
                          ),
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an email';
                        }
                        if (!RegExp(
                                r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$")
                            .hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    // TextFormField(
                    //   controller: _authController.firstNameController,
                    //   decoration: InputDecoration(
                    //     labelText: 'First Name',
                    //     fillColor: StyleConst.auth_text_field_color,
                    //     filled: true,
                    //     labelStyle: const TextStyle(
                    //       color: Colors.grey,
                    //     ),
                    //     enabledBorder: OutlineInputBorder(
                    //       borderRadius: BorderRadius.circular(8.0),
                    //       borderSide: const BorderSide(
                    //         color: StyleConst.auth_text_field_color,
                    //         width: 1.0,
                    //       ),
                    //     ),
                    //     focusedBorder: OutlineInputBorder(
                    //       borderRadius: BorderRadius.circular(8.0),
                    //       borderSide: const BorderSide(
                    //         color: Colors.grey,
                    //         width: 2.0,
                    //       ),
                    //     ),
                    //   ),
                    //   style: const TextStyle(
                    //     color: Colors.black,
                    //   ),
                    //   validator: (value) {
                    //     if (value == null || value.isEmpty) {
                    //       return 'Please enter an first name';
                    //     }
                    //     return null;
                    //   },
                    // ),
                    // const SizedBox(height: 16.0),
                    // TextFormField(
                    //   controller: _authController.middleNameController,
                    //   decoration: InputDecoration(
                    //     labelText: 'Middle Name',
                    //     fillColor: StyleConst.auth_text_field_color,
                    //     filled: true,
                    //     labelStyle: const TextStyle(
                    //       color: Colors.grey,
                    //     ),
                    //     enabledBorder: OutlineInputBorder(
                    //       borderRadius: BorderRadius.circular(8.0),
                    //       borderSide: const BorderSide(
                    //         color: StyleConst.auth_text_field_color,
                    //         width: 1.0,
                    //       ),
                    //     ),
                    //     focusedBorder: OutlineInputBorder(
                    //       borderRadius: BorderRadius.circular(8.0),
                    //       borderSide: const BorderSide(
                    //         color: Colors.grey,
                    //         width: 2.0,
                    //       ),
                    //     ),
                    //   ),
                    //   style: const TextStyle(
                    //     color: Colors.black,
                    //   ),
                    //   validator: (value) {
                    //     if (value == null || value.isEmpty) {
                    //       return 'Please enter an middle name';
                    //     }
                    //     return null;
                    //   },
                    // ),
                    // const SizedBox(height: 16.0),
                    // TextFormField(
                    //   controller: _authController.lastNameController,
                    //   decoration: InputDecoration(
                    //     labelText: 'Last Name',
                    //     fillColor: StyleConst.auth_text_field_color,
                    //     filled: true,
                    //     labelStyle: const TextStyle(
                    //       color: Colors.grey,
                    //     ),
                    //     enabledBorder: OutlineInputBorder(
                    //       borderRadius: BorderRadius.circular(8.0),
                    //       borderSide: const BorderSide(
                    //         color: StyleConst.auth_text_field_color,
                    //         width: 1.0,
                    //       ),
                    //     ),
                    //     focusedBorder: OutlineInputBorder(
                    //       borderRadius: BorderRadius.circular(8.0),
                    //       borderSide: const BorderSide(
                    //         color: Colors.grey,
                    //         width: 2.0,
                    //       ),
                    //     ),
                    //   ),
                    //   style: const TextStyle(
                    //     color: Colors.black,
                    //   ),
                    //   validator: (value) {
                    //     if (value == null || value.isEmpty) {
                    //       return 'Please enter an last name';
                    //     }
                    //     return null;
                    //   },
                    // ),
                    // const SizedBox(height: 16.0),
                    // TextFormField(
                    //   controller: _authController.addressController,
                    //   decoration: InputDecoration(
                    //     labelText: 'Address',
                    //     fillColor: StyleConst.auth_text_field_color,
                    //     filled: true,
                    //     labelStyle: const TextStyle(
                    //       color: Colors.grey,
                    //     ),
                    //     enabledBorder: OutlineInputBorder(
                    //       borderRadius: BorderRadius.circular(8.0),
                    //       borderSide: const BorderSide(
                    //         color: StyleConst.auth_text_field_color,
                    //         width: 1.0,
                    //       ),
                    //     ),
                    //     focusedBorder: OutlineInputBorder(
                    //       borderRadius: BorderRadius.circular(8.0),
                    //       borderSide: const BorderSide(
                    //         color: Colors.grey,
                    //         width: 2.0,
                    //       ),
                    //     ),
                    //   ),
                    //   style: const TextStyle(
                    //     color: Colors.black,
                    //   ),
                    //   validator: (value) {
                    //     if (value == null || value.isEmpty) {
                    //       return 'Please enter an address';
                    //     }
                    //     return null;
                    //   },
                    // ),
                    // const SizedBox(height: 16.0),
                    // TextFormField(
                    //   controller: _authController.ageController,
                    //   keyboardType: TextInputType.number,
                    //   decoration: InputDecoration(
                    //     labelText: 'Age',
                    //     fillColor: StyleConst.auth_text_field_color,
                    //     filled: true,
                    //     labelStyle: const TextStyle(
                    //       color: Colors.grey,
                    //     ),
                    //     enabledBorder: OutlineInputBorder(
                    //       borderRadius: BorderRadius.circular(8.0),
                    //       borderSide: const BorderSide(
                    //         color: StyleConst.auth_text_field_color,
                    //         width: 1.0,
                    //       ),
                    //     ),
                    //     focusedBorder: OutlineInputBorder(
                    //       borderRadius: BorderRadius.circular(8.0),
                    //       borderSide: const BorderSide(
                    //         color: Colors.grey,
                    //         width: 2.0,
                    //       ),
                    //     ),
                    //   ),
                    //   style: const TextStyle(
                    //     color: Colors.black,
                    //   ),
                    //   validator: (value) {
                    //     if (value == null || value.isEmpty) {
                    //       return 'Please enter an age';
                    //     }
                    //     return null;
                    //   },
                    // ),
                    // const SizedBox(height: 16.0),
                    Obx(
                      () => TextFormField(
                        controller: _authController.passwordController,
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: !_authController.isPasswordVisible.value,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          fillColor: StyleConst.auth_text_field_color,
                          filled: true,
                          labelStyle: const TextStyle(
                            color: Colors.grey,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                              color: StyleConst.auth_text_field_color,
                              width: 1.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                              color: Colors.grey,
                              width: 2.0,
                            ),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _authController.isPasswordVisible.value
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              // Toggle password visibility
                              _authController.isPasswordVisible.value =
                                  !_authController.isPasswordVisible.value;
                            },
                          ),
                        ),
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          if (value.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          return null;
                        },
                      ),
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Password must be 8 character ',
                          style: StyleConst.auth_text_style,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Obx(() {
                            // Show a loading indicator while the account is being created
                            if (_authController.isLoading.value) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else {
                              return ElevatedButton(
                                style: StyleConst.auth_button_style,
                                onPressed: () {
                                  if (_formKey.currentState?.validate() ??
                                      false) {
                                    String email =
                                        _authController.emailController.text;
                                    String password =
                                        _authController.passwordController.text;
                                    _authController.createAccount(
                                        email, password);
                                  }
                                },
                                child: const Text('Create Account'),
                              );
                            }
                          }),
                        ),
                      ],
                    ),
                    Obx(() {
                      // Display error messages
                      if (_authController.errorMessage.value.isNotEmpty) {
                        return Text(
                          _authController.errorMessage.value,
                          style: const TextStyle(color: Colors.red),
                        );
                      }
                      return Container();
                    }),
                    const SizedBox(height: 14.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account? ',
                          style: StyleConst.auth_text_style,
                        ),
                        InkWell(
                          onTap: () async {
                            Get.offAndToNamed('/registerScreen');
                          },
                          child: const Text(
                            'Sign in',
                            style: TextStyle(
                              fontSize: 14.0,
                              color: StyleConst.auth_second_color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    const Text(
                      'Or connect ',
                      style: StyleConst.auth_text_style,
                    ),
                    const SizedBox(height: 80.0),
                    InkWell(
                      onTap: () {
                        Get.snackbar(
                          'Opppsss!',
                          'Please pay more to use this feature!',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                      child: Image.asset(
                        'assets/images/social.png',
                        height: 40.0,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
