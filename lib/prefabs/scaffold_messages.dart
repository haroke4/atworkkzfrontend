import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void showScaffoldMessage(context, String message, {time = 1}){
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message, style: TextStyle(fontSize: 20.sp),),
    duration: Duration(seconds: time),
  ));
}