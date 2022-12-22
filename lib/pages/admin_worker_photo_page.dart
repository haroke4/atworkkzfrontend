import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../prefabs/admin_tools.dart';
import '../prefabs/colors.dart';
import '../prefabs/tools.dart';

class AdminWorkerPhotoPage extends StatefulWidget {
  final name;

  const AdminWorkerPhotoPage({super.key, required this.name});

  @override
  State<AdminWorkerPhotoPage> createState() => _AdminWorkerPhotoPageState();
}

class _AdminWorkerPhotoPageState extends State<AdminWorkerPhotoPage> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, BoxConstraints constraints) {
      return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: SafeArea(
          child: Container(
            margin: EdgeInsets.all(4.w),
            child: Row(
              children: [
                getFirstColumn(constraints.maxWidth * 0.25 - 4.w,
                    constraints.maxHeight - 8.w),
                SizedBox(
                  width: constraints.maxWidth * 0.5,
                  height: constraints.maxHeight - 8.w,
                  child: getPhoto(),
                ),
                getLastColumn(constraints.maxWidth * 0.25 - 4.w,
                    constraints.maxHeight - 8.w),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget getFirstColumn(width, height) {
    return SizedBox(
      width: width,
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          getText("Фирма"),
          SizedBox(height: 4.h),
          getText("Отдел"),
          SizedBox(height: 4.h),
          getText(widget.name, bgColor: brownColor, fontColor: Colors.white),
          SizedBox(height: 4.h),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                getText("10:32",
                    align: TextAlign.center, fontWeight: FontWeight.bold),
                SizedBox(height: 4.h),
                getText("Август 2022",
                    bgColor: todayColor,
                    fontColor: Colors.white,
                    fontWeight: FontWeight.bold,
                    align: TextAlign.center),
                getText("16",
                    bgColor: todayColor,
                    fontColor: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22.h,
                    align: TextAlign.center),
                SizedBox(height: 4.h),
                getText("Подтвержден",
                    align: TextAlign.center,
                    bgColor: brownColor,
                    fontColor: Colors.white,
                    fontWeight: FontWeight.bold),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget getLastColumn(width, height) {
    return SizedBox(
      width: width,
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          getText("Atwork.kz", align: TextAlign.center),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                getText("6 мин * 15 = 90 ед", bgColor: lateColor),
                SizedBox(height: 4.h),
                getTwoTextOneLine("Сумма месяц", "1205", bgColor: lateColor),
                SizedBox(height: 20.h),
                getTextWithTime("Явка", "8:30/9:10"),
                SizedBox(height: 4.h),
                getTwoTextOneLine('Фото с точки', '9:16', bgColor: lateColor),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              getMainMenuButton(),
              SizedBox(width: 4.w),
              getGoBackButton(),
            ],
          ),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }
}
