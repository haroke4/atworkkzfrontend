import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelance_order/pages/tariffs_page.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../prefabs/admin_tools.dart';
import '../prefabs/colors.dart';
import '../prefabs/tools.dart';
import 'assign_data_page.dart';
import 'change_password_page.dart';

class AdminGeneralPage extends StatefulWidget {
  const AdminGeneralPage({super.key});

  @override
  State<AdminGeneralPage> createState() => _AdminGeneralPageState();
}

class _AdminGeneralPageState extends State<AdminGeneralPage> {
  var _data = {};

  @override
  void initState() {
    super.initState();
    _data['company'] = 'Company';
    _data['department'] = 'Department of the company';
    //Getting data from server
    _data['truancy_price'] = "3000";
    _data['prize'] = '5000';
    _data['beg_off_price'] = '5000';
    _data['before_minute'] = '35';
    _data['mail'] = "example@gmail.com";
    _data['postponement_minute'] = '10';
    _data['truancy_minute'] = '65';
    _data['late_minute_price'] = '15';
    _data['after_minute'] = '65';
  }

  void _onSavePressed() async {
    Get.back();
  }

  void _changeField(String key, String label, {bool text = false}) async {
    String? x = await Get.to(() => AssignDataPage(
          text: label,
          inputtingText: text,
        ));
    if (x != null && x != "") {
      setState(() {
        _data[key] = x;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, BoxConstraints constraints) {
      return Scaffold(
        backgroundColor: brownColor,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Container(
              margin: EdgeInsets.all(4.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  getFirstLineWidgets(constraints.maxWidth * 0.25 - 4.w),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      SizedBox(
                        width: constraints.maxWidth * 0.3 - 4.w,
                        child: getText(
                          _data['department'],
                          onPressed: () =>
                              _changeField("department", "Отдел компании", text: true),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30.h),
                  getMiddleLineWidgets(),
                  SizedBox(height: 30.h),
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
        SizedBox(
          width: width,
          child: getText(
            _data["company"],
            onPressed: () =>
                _changeField("company", "Фирма", text: true),
          ),
        ),
        getText("10:32", align: TextAlign.center, fontWeight: FontWeight.bold),
        Expanded(
            child: getText("Август 2022",
                bgColor: todayColor,
                fontColor: Colors.white,
                align: TextAlign.center)),
        getText(
          "Тарифы",
          align: TextAlign.center,
          onPressed: () => (Get.to(() => const TariffsPage())),
        ),
        getText("Общие", fontColor: Colors.white, bgColor: brownColor),
        getText("Atwork.kz", align: TextAlign.center),
      ],
    );
  }

  Widget getMiddleLineWidgets() {
    return Row(
      children: [
        getFirstColumn(),
        const Expanded(child: SizedBox()),
        Column(
          children: [
            Image.asset(
              "assets/icon.png",
              height: 150.h,
            ),
            SizedBox(
              height: 30.h,
            ),
            Row(
              children: [
                getText(
                  "Сохранить      ",
                  onPressed: _onSavePressed,
                  align: TextAlign.center,
                ),
                getGoBackButton(padding: 1.w),
              ],
            )
          ],
        ),
        const Expanded(child: SizedBox()),
        getLastColumn(),
      ],
    );
  }

  Widget getFirstColumn() {
    return IntrinsicWidth(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                getText("Прогул цена"),
                SizedBox(height: 4.h),
                getText("Премия"),
                SizedBox(height: 4.h),
                getText("Отпросился"),
                SizedBox(height: 4.h),
                getText("До мин"),
                SizedBox(height: 4.h),
                getText("Почта"),
              ],
            ),
          ),
          IntrinsicWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                getText(
                  _data["truancy_price"],
                  onPressed: () => _changeField("truancy_price", "Прогул цена"),
                ),
                SizedBox(height: 4.h),
                getText(
                  _data["prize"],
                  onPressed: () => _changeField("prize", "Премия"),
                ),
                SizedBox(height: 4.h),
                getText(
                  _data["beg_off_price"],
                  onPressed: () => _changeField("beg_off_price", "Прогул цена"),
                ),
                SizedBox(height: 4.h),
                getText(
                  _data["before_minute"],
                  onPressed: () => _changeField("before_minute", "До мин"),
                ),
                SizedBox(height: 4.h),
                Container(
                  constraints: BoxConstraints(maxWidth: 80.w),
                  child: getText(
                    _data["mail"],
                    onPressed: () => _changeField("mail", "Почта", text: true),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget getLastColumn() {
    return IntrinsicWidth(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    getText("Отсрочка мин"),
                    SizedBox(height: 4.h),
                    getText("Прогул мин"),
                    SizedBox(height: 4.h),
                    getText("Минута цена"),
                    SizedBox(height: 4.h),
                    getText("После мин"),
                  ],
                ),
              ),
              IntrinsicWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    getText(
                      _data["postponement_minute"],
                      onPressed: () => _changeField(
                          "postponement_minute", "Отсрочка минуты"),
                    ),
                    SizedBox(height: 4.h),
                    getText(
                      _data["truancy_minute"],
                      onPressed: () =>
                          _changeField("truancy_minute", "Прогул минуты"),
                    ),
                    SizedBox(height: 4.h),
                    getText(
                      _data["late_minute_price"],
                      onPressed: () => _changeField(
                        "late_minute_price",
                        "Штраф за опоздание на минуту",
                      ),
                    ),
                    SizedBox(height: 4.h),
                    getText(
                      _data["after_minute"],
                      minWidth: 25.w,
                      onPressed: () => _changeField(
                        "after_minute",
                        "После минуты",
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          SizedBox(height: 4.h),
          getText(
            "Сменить пароль/опечаток",
            onPressed: () => (Get.to(() => const ChangePasswordPage())),
          ),
        ],
      ),
    );
  }
}
