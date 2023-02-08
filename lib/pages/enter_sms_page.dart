import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelance_order/pages/admin_general_page.dart';
import 'package:freelance_order/utils/AdminBackendAPI.dart';
import 'package:freelance_order/utils/LocalizerUtil.dart';
import 'package:freelance_order/utils/WorkersBackendAPI.dart';
import 'package:get/get.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../prefabs/scaffold_messages.dart';
import '../prefabs/colors.dart';

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
  late SharedPreferences sharedPrefs;
  String _errorMessage = '';
  final _smsController = TextEditingController();
  late var _nextPage = widget.nextPage;

  @override
  void initState() {
    super.initState();
    initSharedPrefs();
  }

  void initSharedPrefs() async {
    sharedPrefs = await SharedPreferences.getInstance();
  }

  void sendAndCheckSMS({fromOnChanged = false}) async {
    if (_smsController.text.length < 4) {
      if (!fromOnChanged) {
        setState(() {
          _errorMessage = Localizer.get('enter_code');
        });
      }
    } else {
      // send data to server
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(Localizer.get('processing')),
        duration: const Duration(seconds: 1),
      ));

      var response;
      bool isWorker = widget.workerUsername.length > 5;
      if (isWorker) {
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
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(Localizer.get('loading')),
          duration: const Duration(seconds: 1),
        ));

        if (!isWorker) {
          // if admin does not set up company
          var response = await AdminBackendAPI.getWorkers();
          if (response.statusCode != 200) {
            _nextPage = AdminGeneralPage();
          }
        }
        final jsonResponse = jsonDecode(response.body);
        sharedPrefs.setString('account_type', isWorker ? "worker" : "admin");
        sharedPrefs.setString('token', jsonResponse['token']);
        sharedPrefs.setString('code', _smsController.text);
        Get.offAll(_nextPage);
      } else {
        showScaffoldMessage(context, Localizer.get('invalid_phone_or_code'));
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(child: SizedBox()),
            Text(
              Localizer.get('enter_sent_sms_come'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).primaryColorDark,
                fontSize: 65.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Expanded(child: SizedBox()),
            Padding(
              padding: EdgeInsets.fromLTRB(110.w, 0.w, 110.w, 0),
              child: PinInputTextField(
                controller: _smsController,
                pinLength: 4,
                keyboardType: TextInputType.number,
                cursor: Cursor(
                  width: 1,
                  height: 40.h,
                  color: Theme.of(context).primaryColorDark,
                  enabled: true,
                ),
                decoration: UnderlineDecoration(
                  colorBuilder: const
                      FixedColorBuilder(Color.fromRGBO(201, 60, 42, 1)),
                  textStyle: TextStyle(fontSize: 35.sp, color: Colors.black),
                ),
                onChanged: (value) {
                  sendAndCheckSMS(fromOnChanged: true);
                },
              ),
            ),
            SizedBox(height: 15.h),
            _errorMessage != ''
                ? Text(
                    _errorMessage,
                    style: TextStyle(color: Theme.of(context).errorColor),
                  )
                : const SizedBox(),
            SizedBox(height: 10.h),
            getNumbersWidget(),
            const Expanded(child: SizedBox()),
            const Expanded(child: SizedBox()),
            const Expanded(child: SizedBox()),
            const Expanded(child: SizedBox()),
          ],
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
        SizedBox(height: 20.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: secondLine,
        )
      ],
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
                fontSize: 35.sp,
              ),
            ),
          )),
    );
  }
}
