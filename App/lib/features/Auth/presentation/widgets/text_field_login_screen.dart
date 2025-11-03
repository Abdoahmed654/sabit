import 'package:flutter/material.dart';

class TextFieldLoginScreen extends StatelessWidget {
   TextFieldLoginScreen({super.key,required this.labelText,required this.hintText});
  String labelText ;
  String hintText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: OutlineInputBorder()
      )
    );
  }
}