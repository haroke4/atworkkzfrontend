import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../pages/admin_main_page.dart';
import 'colors.dart';

Widget getMainMenuButton({enabled = true}) {
  return SizedBox(
    height: 32.h,
    child: InkWell(
      splashColor: Colors.black26,
      onTap: enabled
          ? () {
              Get.offAll(const AdminsMainPage());
            }
          : () {},
      child: Image.asset("assets/mainMenuButton.png"),
    ),
  );
}

Widget getGoBackButton({double? padding, double? height, Function? onTap, Color? color}) {
  return Material(
    color: color ?? bgColor,
    child: SizedBox(
      height: height ?? 32.h,
      child: InkWell(
        splashColor: Colors.black26,
        onTap: onTap == null
            ? () {
                Get.back();
              }
            : () {
                onTap();
              },
        child: Padding(
            padding: EdgeInsets.all(padding ?? 0),
            child: Image.asset("assets/goBackButton.png")),
      ),
    ),
  );
}
