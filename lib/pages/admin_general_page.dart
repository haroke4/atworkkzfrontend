import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:freelance_order/pages/admin_main_page.dart';
import 'package:freelance_order/pages/tariffs_page.dart';
import 'package:freelance_order/utils/AdminBackendAPI.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../prefabs/admin_tools.dart';
import '../prefabs/colors.dart';
import '../prefabs/scaffold_messages.dart';
import '../prefabs/tools.dart';
import 'assign_data_page.dart';
import 'change_password_page.dart';

class AdminGeneralPage extends StatefulWidget {
  const AdminGeneralPage({super.key});

  @override
  State<AdminGeneralPage> createState() => _AdminGeneralPageState();
}

class _AdminGeneralPageState extends State<AdminGeneralPage> {
  late Widget _saveButtonLabel = getSaveText();
  // Scrolling workers

  late var _data;
  late final _registering;
  final _loading = true;

  @override
  void initState() {
    var data = Get.arguments[0];
    if (data != null) {
      _registering = false;
      _data = data;
    } else {
      _registering = true;
      _data = {};
      _data['name'] = 'Имя компании';
      _data['department'] = 'Отдел компании';
      _data['truancy_price'] = "Введите";
      _data['prize'] = 'Введите';
      _data['beg_off_price'] = 'Введите';
      _data['before_minute'] = 'Введите';
      _data['mail'] = 'Введите';
      _data['postponement_minute'] = 'Введите';
      _data['truancy_minute'] = 'Введите';
      _data['late_minute_price'] = 'Введите';
      _data['after_minute'] = 'Введите';
    }
    super.initState();
  }

  void _onSavePressed() async {
    if (_registering) {
      setState(() {
        _saveButtonLabel = const SpinKitThreeBounce(
          color: Colors.black,
          size: 25.0,
        );
      });
      var response = await AdminBackendAPI.createCompany(
        name: _data['name'],
        department: _data['department'],
        pinCode: '0000',
        mail: _data['mail'],
        truancyPrice: _data['truancy_price'],
        prize: _data['prize'],
        begOffPrice: _data['beg_off_price'],
        beforeMinute: _data['before_minute'],
        postponementMinute: _data['postponement_minute'],
        truancyMinute: _data['truancy_minute'],
        lateMinutePrice: _data['late_minute_price'],
        afterMinute: _data['after_minute'],
      );
      if (response.statusCode == 201) {
        showScaffoldMessage(context, "Компания создана");
        Get.offAll(const AdminsMainPage());
        return null;
      } else {
        showScaffoldMessage(context, "Некоторые поля введены неверно");
      }
      setState(() {
        _saveButtonLabel = getSaveText();
      });
    } else {
       var response = await AdminBackendAPI.editCompany(
        name: _data['name'].toString(),
        department: _data['department'].toString(),
        mail: _data['mail'].toString(),
        truancyPrice: _data['truancy_price'].toString(),
        prize: _data['prize'].toString(),
        begOffPrice: _data['beg_off_price'].toString(),
        beforeMinute: _data['before_minute'].toString(),
        postponementMinute: _data['postponement_minute'].toString(),
        truancyMinute: _data['truancy_minute'].toString(),
        lateMinutePrice: _data['late_minute_price'].toString(),
        afterMinute: _data['after_minute'].toString(),
      );
       if (response.statusCode == 200){
         showScaffoldMessage(context, "Успешно. Обновите страницу");
         Get.back(result: 'update');
       }
       else{
         showScaffoldMessage(context, jsonDecode(response.body));
       }

    }
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
                          onPressed: () => _changeField(
                              "department", "Отдел компании",
                              text: true),
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
            _data["name"],
            onPressed: () => _changeField("name", "Фирма", text: true),
          ),
        ),
        getText(SERVER_TIME, align: TextAlign.center, fontWeight: FontWeight.bold),
        Expanded(
            child: getText(CURRENT_YEARMONTH,
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
                FloatingActionButton.extended(
                  label: _saveButtonLabel,
                  onPressed: _onSavePressed,
                  backgroundColor: Colors.white,
                  extendedPadding: EdgeInsets.fromLTRB(2.w, 4.h, 2.w, 4.h),
                  disabledElevation: 0,
                ),
                SizedBox(
                  width: 5.w,
                ),
                getGoBackButton(padding: 1.w, color: Colors.white),
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
                  _data["truancy_price"].toString(),
                  onPressed: () => _changeField("truancy_price", "Прогул цена"),
                ),
                SizedBox(height: 4.h),
                getText(
                  _data["prize"].toString(),
                  onPressed: () => _changeField("prize", "Премия"),
                ),
                SizedBox(height: 4.h),
                getText(
                  _data["beg_off_price"].toString(),
                  onPressed: () =>
                      _changeField("beg_off_price", "Отпросился цена"),
                ),
                SizedBox(height: 4.h),
                getText(
                  _data["before_minute"].toString(),
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
                      _data["postponement_minute"].toString(),
                      onPressed: () => _changeField(
                          "postponement_minute", "Отсрочка минуты"),
                    ),
                    SizedBox(height: 4.h),
                    getText(
                      _data["truancy_minute"].toString(),
                      onPressed: () =>
                          _changeField("truancy_minute", "Прогул минуты"),
                    ),
                    SizedBox(height: 4.h),
                    getText(
                      _data["late_minute_price"].toString(),
                      onPressed: () => _changeField(
                        "late_minute_price",
                        "Штраф за опоздание на минуту",
                      ),
                    ),
                    SizedBox(height: 4.h),
                    getText(
                      _data["after_minute"].toString(),
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

Widget getSaveText() {
  return Padding(
    padding: EdgeInsets.fromLTRB(2.w, 4.h, 2.w, 4.h),
    child: Text(
      "Сохранить",
      style: TextStyle(
        color: Colors.black,
        fontSize: 14.h,
      ),
    ),
  );
}
