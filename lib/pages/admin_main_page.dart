import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelance_order/pages/admin_general_page.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../prefabs/colors.dart';
import '../prefabs/tools.dart';
import '../prefabs/admin_tools.dart';
import 'admin_add_worker_page.dart';
import 'worker_main_page.dart';
import 'admin_about_worker_page.dart';

class AdminsMainPage extends StatefulWidget {
  const AdminsMainPage({super.key});

  @override
  State<AdminsMainPage> createState() => _AdminsMainPageState();
}

class _AdminsMainPageState extends State<AdminsMainPage> {
  void _onWorkerNamePressed(String name) {
    if (name == "") {
      Get.to(() => AdminAddWorkerPage());
    } else {
      Get.to(() => AdminAboutWorkerPage(name: name));
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, BoxConstraints constraints) {
      return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Container(
              margin: EdgeInsets.all(4.w),
              width: constraints.maxWidth - 8.w,
              child: Column(
                children: [
                  getFirstLineWidgets(),
                  SizedBox(height: 4.h),
                  getSecondLineWidgets(),
                  SizedBox(height: 4.h),
                  ...getWorkersWidget(),
                  SizedBox(height: 4.h),
                  getBottomLineWidgets(),
                  // SizedBox(height: 4.h),
                  // FloatingActionButton(onPressed: () {
                  //   Get.to(const WorkersMainPage());
                  // }),
                  // SizedBox(height: 4.h),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget getFirstLineWidgets() {
    return Row(
      children: [
        SizedBox(width: 80.w, child: getText("Название фирмы")),
        getText("10:32", align: TextAlign.center, fontWeight: FontWeight.bold),
        Expanded(
            child: getText("Август 2022",
                bgColor: todayColor,
                fontColor: Colors.white,
                align: TextAlign.center)),
        getText("Установки", align: TextAlign.center, onPressed: () {}),
        getText("Общие", align: TextAlign.center, onPressed: () {
          Get.to(() => (AdminGeneralPage()));
        }),
        getText("Qaz / Rus / Eng", align: TextAlign.center),
      ],
    );
  }

  Widget getSecondLineWidgets() {
    return Row(
      children: [
        SizedBox(width: 80.w, child: getText("Название отдела")),
        getRect(Colors.white, text: '11'),
        getRect(Colors.white, text: '12'),
        getRect(Colors.white, text: '13'),
        getRect(Colors.white, text: '14'),
        getRect(Colors.white, text: '15'),
        SizedBox(
          width: 48.h + 12.w,
          child: Text(
            "16",
            style: TextStyle(
              color: todayColor,
              fontWeight: FontWeight.bold,
              fontSize: 23.h,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        getRect(Colors.white, text: '11'),
        getRect(Colors.white, text: '12'),
        getRect(Colors.white, text: '13'),
        getRect(Colors.white, text: '14'),
        getRect(Colors.white, text: '15'),
        Expanded(
          child: getText("Результаты месяца",
              align: TextAlign.right,
              bgColor: bgColor,
              fontWeight: FontWeight.bold),
        )
      ],
    );
  }

  List<Widget> getWorkersWidget() {
    List<Widget> a = [];
    var rabotniki = [
      "Сериков",
      "Жунусов",
      "Даирбаев",
      "Кантаиров",
      "Ахметжанов",
      "Майоров",
      "Майоров",
      "",
    ];
    for (final e in rabotniki) {
      a.add(getWorkerLineWidget(e));
      a.add(SizedBox(height: 1.h));
    }
    return a;
  }

  Widget getWorkerLineWidget(String name) {
    return Row(
      children: [
        SizedBox(
          width: 80.w,
          child: getText(name, onPressed: () => _onWorkerNamePressed(name)),
        ),
        getRect(name != "" ? begOffColor : noAssignmentColor),
        getRect(name != "" ? onTimeColor : noAssignmentColor),
        getRect(name != "" ? validReasonColor : noAssignmentColor),
        getRect(name != "" ? lateColor : noAssignmentColor),
        getRect(name != "" ? workingDayColor : noAssignmentColor),
        SizedBox(
          width: 48.h + 12.w,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              getRect(onTimeColor, confirmation: true),
              getRect(workingDayColor),
            ],
          ),
        ),
        getRect(name != "" ? begOffColor : noAssignmentColor),
        getRect(name != "" ? onTimeColor : noAssignmentColor),
        getRect(name != "" ? validReasonColor : noAssignmentColor),
        getRect(name != "" ? lateColor : noAssignmentColor),
        getRect(name != "" ? workingDayColor : noAssignmentColor),
        SizedBox(
          width: 7.w,
        ),
        getRect(workingDayColor, text: "24", fontColor: Colors.white),
        getRect(truancyColor, text: "2", fontColor: Colors.white),
        Expanded(
          child: getRect(lateColor, text: "1205"),
        )
      ],
    );
  }

  Widget getBottomLineWidgets() {
    return Row(
      children: [
        getButton(() {}, Icons.arrow_upward_rounded, Icons.man_outlined),
        const Expanded(child: SizedBox()),
        getMainMenuButton(enabled: false),
        SizedBox(width: 4.w),
        getGoBackButton(),
        const Expanded(child: SizedBox()),
        getButton(() {}, Icons.man_outlined, Icons.arrow_downward_rounded),
      ],
    );
  }

  Widget getButton(onPressed, IconData firstIcon, IconData secondIcon) {
    return Container(
      width: 74.w,
      height: 32.h,
      margin: EdgeInsets.only(left: 3.w, right: 3.w),
      decoration: BoxDecoration(
        border: Border.all(color: greyColor),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              firstIcon,
              color: greyColor,
            ),
            Icon(
              secondIcon,
              color: greyColor,
            )
          ],
        ),
      ),
    );
  }
}
