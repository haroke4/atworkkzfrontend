import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:freelance_order/pages/admin_general_page.dart';
import 'package:freelance_order/pages/admin_main_page.dart';
import 'package:freelance_order/utils/AdminBackendAPI.dart';
import 'package:freelance_order/utils/WorkersBackendAPI.dart';
import 'package:get/get.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';
import 'worker_main_page.dart';
import '../prefabs/colors.dart';
import '../prefabs/appbar_prefab.dart';

class EnterSMSPage extends StatefulWidget {
  final nextPage;
  final adminUsername;
  final workerUsername;

  const EnterSMSPage(
      {super.key,
      required this.nextPage,
      required this.adminUsername,
      required this.workerUsername});

  @override
  State<EnterSMSPage> createState() => _EnterSMSPageState();
}

class _EnterSMSPageState extends State<EnterSMSPage> {
  String _errorMessage = '';
  final _smsController = TextEditingController();
  late var _nextPage = widget.nextPage;

  void sendAndCheckSMS({fromOnChanged = false}) async {
    if (_smsController.text.length < 4) {
      if (!fromOnChanged) {
        setState(() {
          _errorMessage = 'Введите код';
        });
      }
    } else {
      // send data to server
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Processing'),
        duration: Duration(seconds: 1),
      ));

      var response;
      if (widget.workerUsername != "") {
        response = await WorkersBackendAPI.login(
          widget.adminUsername,
          widget.workerUsername,
          _smsController.text,
        );
      } else {
        // logging in as admin
        response = await AdminBackendAPI.login(
          widget.adminUsername,
          _smsController.text,
        );
      }
      var json = jsonDecode(response.body);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Загрузка...'),
          duration: Duration(seconds: 1),
        ));
        if (widget.workerUsername == "") {
          var response = await AdminBackendAPI.getWorkers();
          if (response.statusCode != 200) {
            _nextPage = AdminGeneralPage();
          }
        }
        Get.offAll(_nextPage);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Ошибка: $json'),
          duration: const Duration(seconds: 1),
        ));
        _smsController.text = "";
      }
    }
    // Check data
  }

  void onNumberButtonPressed(String value) {
    _smsController.text += value;
    if (_smsController.text.length >= 4) {
      sendAndCheckSMS();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: brownColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 40.h),
              Text(
                "Введите присланный код с SMS",
                style: TextStyle(
                  color: Theme.of(context).primaryColorDark,
                  fontSize: 40.h,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20.h),
              Padding(
                padding: EdgeInsets.fromLTRB(110.w, 5.w, 110.w, 5.w),
                child: PinInputTextField(
                  controller: _smsController,
                  pinLength: 4,
                  keyboardType: TextInputType.number,
                  cursor: Cursor(
                    width: 3,
                    height: 20.h,
                    color: Theme.of(context).primaryColorDark,
                    enabled: true,
                  ),
                  decoration: const UnderlineDecoration(
                    colorBuilder:
                        FixedColorBuilder(Color.fromRGBO(201, 60, 42, 1)),
                  ),
                  onChanged: (value) {
                    sendAndCheckSMS(fromOnChanged: true);
                  },
                ),
              ),
              SizedBox(height: 3.h),
              _errorMessage != ''
                  ? Text(
                      _errorMessage,
                      style: TextStyle(color: Theme.of(context).errorColor),
                    )
                  : const SizedBox(),
              SizedBox(height: 10.h),
              getNumbersWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget getNumbersWidget() {
    List<Widget> firstLine = [];
    List<Widget> secondLine = [];
    for (int i = 1; i < 6; i++) {
      firstLine.add(CircleButton(
          onTap: () => onNumberButtonPressed(i.toString()),
          text: i.toString()));
      if (i != 5) {
        firstLine.add(SizedBox(width: 15.w));
      }
    }
    for (int i = 6; i < 10; i++) {
      secondLine.add(CircleButton(
          onTap: () => onNumberButtonPressed(i.toString()),
          text: i.toString()));
      secondLine.add(SizedBox(width: 15.w));
    }
    secondLine.add(
      CircleButton(onTap: () => onNumberButtonPressed("0"), text: "0"),
    );

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: firstLine,
        ),
        SizedBox(height: 10.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: secondLine,
        )
      ],
    );
  }

  Widget getCircleNumberWidget() {
    return CircleButton(
      onTap: () {},
      text: "1",
    );
  }
}

class CircleButton extends StatelessWidget {
  final GestureTapCallback onTap;
  final String text;

  const CircleButton({super.key, required this.onTap, required this.text});

  @override
  Widget build(BuildContext context) {
    double size = 50.0;

    return InkResponse(
      onTap: onTap,
      child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 25.h,
              ),
            ),
          )),
    );
  }
}
