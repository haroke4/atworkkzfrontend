import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../pages/admin_main_page.dart';

Widget getMainMenuButton() {
  return SizedBox(
    height: 32.h,
    child: InkWell(
      splashColor: Colors.black26,
      onTap: () {Get.offAll(const AdminsMainPage());},
      child: Image.asset("assets/mainMenuButton.png"),
    ),
  );
}

Widget getGoBackButton() {
  return SizedBox(
    height: 32.h,
    child: InkWell(
      splashColor: Colors.black26,
      onTap: () {Get.back();},
      child: Image.asset("assets/goBackButton.png"),
    ),
  );
}