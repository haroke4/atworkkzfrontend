import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../prefabs/colors.dart';
import '../prefabs/tools.dart';

class WorkersMainPage extends StatefulWidget {
  const WorkersMainPage({super.key});

  @override
  State<WorkersMainPage> createState() => _WorkersMainPageState();
}

class _WorkersMainPageState extends State<WorkersMainPage> {
  File? _imageRight;

  Future onMakeSelfiePressed() async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image == null) return;

    final imageTemporary = File(image.path);
    setState(() {
      _imageRight = imageTemporary;
    });

    List<int> imageBytes = imageTemporary.readAsBytesSync();
    String baseImage = base64Encode(imageBytes);
    // upload image to server
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
        getText("Qaz / Rus / Eng", align: TextAlign.center),
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
              getText("Сериков", bgColor: brownColor, fontColor: Colors.white),
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
              getPhoto(),
              SizedBox(height: 4.h),
              getTextWithTime("Явка", "8:30/9:10"),
              SizedBox(height: 4.h),
              getTwoTextOneLine('Фото с точки', '9:16', bgColor: lateColor),
            ],
          ),
        ),
        Expanded(child: getMiddleInfoWidgets()),
        SizedBox(
          width: width,
          child: Column(
            children: [
              getPhoto(text: "Сделать сэлфи", onTap: onMakeSelfiePressed),
              SizedBox(height: 4.h),
              getTextWithTime("Уход", "17:45/19:00"),
              SizedBox(height: 4.h),
              getTwoTextOneLine('Фото с точки', '_ /_', bgColor: Colors.green),
            ],
          ),
        ),
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
            getRect(getOffColor),
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
            getRect(getOffColor),
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
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(children: [getRect(todayColor), Text("Сегодня, явка/уход")]),
              SizedBox(height: 4.h),
              Row(children: [getRect(workingDayColor), Text("Рабочий день")]),
              SizedBox(height: 4.h),
              Row(children: [
                getRect(nonWorkingDayColor),
                Text("Нерабочий день")
              ]),
              SizedBox(height: 4.h),
              Row(children: [
                getRect(noAssignmentColor),
                Text("Нет установок")
              ]),
              SizedBox(height: 4.h),
              Row(children: [getRect(onTimeColor), Text("Вовремя")]),
              SizedBox(height: 4.h),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        getTextSmaller("Премия мес/ед"),
                        SizedBox(height: 4.h),
                        getTextSmaller("Отпросился"),
                      ],
                    ),
                  ),
                  SizedBox(height: 4.h),
                  IntrinsicWidth(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        getTextSmaller("500000"),
                        SizedBox(height: 4.h),
                        getTextSmaller("500"),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              getTextSmaller("6 мин * 15 = 90 ед",
                  bgColor: lateColor, fontColor: Colors.black),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(children: [getRect(lateColor), Text("Опоздание")]),
              SizedBox(height: 4.h),
              Row(children: [getRect(truancyColor), Text("Прогул")]),
              SizedBox(height: 4.h),
              Row(children: [
                getRect(validReasonColor),
                Text("Уважительная причина")
              ]),
              SizedBox(height: 4.h),
              Row(children: [getRect(getOffColor), Text("Отпросился")]),
              SizedBox(height: 4.h),
              Row(children: [
                getRect(confirmationColor, confirmation: true),
                Text("Подтверждение")
              ]),
              SizedBox(height: 4.h),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        getTextSmaller("Цена минуты"),
                        SizedBox(height: 4.h),
                        getTextSmaller("Прогул мин/ед"),
                      ],
                    ),
                  ),
                  SizedBox(height: 4.h),
                  IntrinsicWidth(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        getTextSmaller("15"),
                        SizedBox(height: 4.h),
                        getTextSmaller("65/3000"),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              getTextSmaller("Итог август: 3620",
                  bgColor: lateColor, fontColor: Colors.black),
            ],
          ),
        ),
      ],
    );
  }
}
