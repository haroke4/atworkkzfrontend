import 'package:flutter/material.dart';

void showScaffoldMessage(context, String message, {time = 1}){
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message),
    duration: Duration(seconds: time),
  ));
}