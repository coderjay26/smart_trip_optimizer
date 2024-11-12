import 'package:flutter/material.dart';

class TextCons {
  static const login = 'Login';
  static const login_header = 'Sign in now';
  static const sign_in_sub_header = 'Please sign in to continue using our app';
  static const sign_up_sub_header =
      'Please fill the details and create account';
}

class StyleConst {
  static const auth_header = TextStyle(
    color: Color(0XFF1B1E28),
    fontSize: 26.0,
    fontWeight: FontWeight.w700,
  );
  static const auth_sub_header = TextStyle(
    color: Color(0XFF7D848D),
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
  );
  static ButtonStyle auth_button_style = ElevatedButton.styleFrom(
    backgroundColor: Color(0XFF24BAEC),
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
    minimumSize: Size(200, 50),
    maximumSize: Size(200, 50),
  );
  static const auth_text_style = TextStyle(
    color: Color(0XFF707B81),
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
  );
  static const auth_text_field_color = Color(0XFFE5E5E5);
  static const body_color = Color(0XFFF7F7F9);
  static const auth_second_color = Color(0XFFFF7029);
}
