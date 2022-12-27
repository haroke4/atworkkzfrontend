import 'package:flutter/material.dart';

void showScaffoldMessage(context, String message){
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message),
    duration: const Duration(seconds: 1),
  ));
}