import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

AppBar getAppBar(String text) {
  return AppBar(
    toolbarHeight: 50.h,
    leading: IconButton(
      padding: EdgeInsets.zero,
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () => Get.back(),
    ),
    centerTitle: true,
    title: Text(
      text,
      style: TextStyle(
        color: Colors.white,
        fontSize: 13.w,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
