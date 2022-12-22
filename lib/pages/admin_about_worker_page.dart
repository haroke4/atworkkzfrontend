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
import 'admin_worker_photo_page.dart';

class AdminAboutWorkerPage extends StatefulWidget {
  final name;

  const AdminAboutWorkerPage({super.key, required this.name});

  @override
  State<AdminAboutWorkerPage> createState() => _AdminAboutWorkerPageState();
}

class _AdminAboutWorkerPageState extends State<AdminAboutWorkerPage> {
  File? _imageRight;
  String _name = "";
  bool _doingAdjustments = false;

  @override
  void initState() {
    super.initState();
    _name = widget.name;
  }

  void onAdjustmentsPressed() {
    setState(() {
      _doingAdjustments = !_doingAdjustments;
    });
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
              child: Column(
                children: [
                  getFirstLineWidgets(constraints.maxWidth * 0.25 - 4.w),
                  SizedBox(height: 4.h),
                  getSecondLineWidgets(constraints.maxWidth * 0.25 - 4.w),
                  SizedBox(height: 4.h),
                  getThirdLineWidgets(constraints.maxWidth * 0.25 - 4.w),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget getFirstLineWidgets(width) {
    return Row(
      children: [
        SizedBox(width: width, child: getText("Фирма")),
        getText("10:32", align: TextAlign.center, fontWeight: FontWeight.bold),
        Expanded(
            child: getText("Август 2022",
                bgColor: todayColor,
                fontColor: Colors.white,
                align: TextAlign.center)),
        getText(
          "Установки",
          align: TextAlign.center,
          onPressed: onAdjustmentsPressed,
          bgColor: _doingAdjustments ? brownColor : Colors.white,
        ),
        getText("Atwork.kz", align: TextAlign.center),
      ],
    );
  }

  Widget getSecondLineWidgets(width) {
    return Row(
      children: [
        SizedBox(
          width: width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              getText("Отдел"),
              SizedBox(height: 4.h),
              getText(widget.name,
                  bgColor: brownColor, fontColor: Colors.white),
            ],
          ),
        ),
        getArrowButton(const Icon(Icons.arrow_back), "back"),
        const Expanded(child: SizedBox()),
        getDatesWidgets(),
        const Expanded(child: SizedBox()),
        getArrowButton(const Icon(Icons.arrow_forward), "forward"),
      ],
    );
  }

  Widget getThirdLineWidgets(width) {
    return Row(
      children: [
        SizedBox(
          width: width,
          child: Column(
            children: [
              getPhoto(onTap: () {
                Get.to(() => (AdminWorkerPhotoPage(
                      name: widget.name,
                    )));
              }),
              SizedBox(height: 4.h),
              getTextWithTime("Явка", "8:30/9:10"),
              SizedBox(height: 4.h),
              getTwoTextOneLine('Фото с точки', '9:16', bgColor: lateColor),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              getMiddleInfoWidgets(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  getMainMenuButton(),
                  SizedBox(width: 4.w),
                  getGoBackButton(),
                ],
              ),
            ],
          ),
        ),
        getLeftInfoWidgets(width),
      ],
    );
  }

  Widget getDatesWidgets() {
    return Column(
      children: [
        Row(
          children: [
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
          ],
        ),
        Row(
          children: [
            getRect(begOffColor),
            getRect(onTimeColor),
            getRect(validReasonColor),
            getRect(lateColor),
            getRect(workingDayColor),
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
            getRect(begOffColor),
            getRect(onTimeColor),
            getRect(validReasonColor),
            getRect(lateColor),
            getRect(workingDayColor),
          ],
        )
      ],
    );
  }

  Widget getMiddleInfoWidgets() {
    if (_doingAdjustments) {
      return Column(
        children: [
          Row(children: [getRect(workingDayColor), Text("Рабочий день")]),
          SizedBox(height: 4.h),
          Row(children: [
            getRect(validReasonColor),
            Text("Уважительная причина")
          ]),
          SizedBox(height: 4.h),
          Row(children: [getRect(nonWorkingDayColor), Text("Нерабочий день")]),
          SizedBox(height: 4.h),
          Row(children: [getRect(begOffColor), Text("Отпросился")]),
        ],
      );
    }
    return Container(
      margin: EdgeInsets.only(left: 10.w, right: 10.w),
      child: Column(
        children: [
          Row(
            children: [
              getTwoTextSeperated("6 мин * 15", " 90 ",
                  secondTextBgColor: lateColor),
              const Expanded(child: SizedBox()),
              getTwoTextSeperated("_ мин * 15", "...", secondTextBgColor: Colors.black12),
            ],
          ),
          SizedBox(height: 4.h),
          getTwoTextOneLine("Сумма месяц", "1205", bgColor: lateColor),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: getText("Подтвержден",
                    align: TextAlign.center,
                    bgColor: brownColor,
                    fontColor: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: getText("Подтвердить",
                    align: TextAlign.center,
                    bgColor: Colors.red,
                    fontColor: Colors.white,
                    fontWeight: FontWeight.bold,
                    onPressed: () {}),
              ),
            ],
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget getLeftInfoWidgets(width) {
    if (_doingAdjustments) {
      return SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(child: getText("Явка", align: TextAlign.center)),
                Expanded(child: getText("9:00", align: TextAlign.center))
              ],
            ),
            SizedBox(
              height: 4.h,
            ),
            Row(
              children: [
                Expanded(child: getText("Уход", align: TextAlign.center)),
                Expanded(child: getText("19:00", align: TextAlign.center))
              ],
            ),
            SizedBox(
              height: 4.h,
            ),
            Row(
              children: [
                Expanded(child: getText("Здесь", align: TextAlign.center)),
                Expanded(child: getText("Выбрать", align: TextAlign.center))
              ],
            ),
            SizedBox(
              height: 4.h,
            ),
            Row(
              children: [
                Expanded(child: getText("Повтор", align: TextAlign.center)),
                Expanded(child: getText("Копия", align: TextAlign.center))
              ],
            ),
            SizedBox(
              height: 4.h,
            ),
            getText("Сохранить", align: TextAlign.center),
          ],
        ),
      );
    } else {
      return SizedBox(
        width: width,
        child: Column(
          children: [
            getPhoto(text: " ", onTap: () {}),
            SizedBox(height: 4.h),
            getTextWithTime("Уход", "17:45/19:00"),
            SizedBox(height: 4.h),
            getTwoTextOneLine('Фото с точки', '_ /_', bgColor: Colors.green),
          ],
        ),
      );
    }
  }
}
