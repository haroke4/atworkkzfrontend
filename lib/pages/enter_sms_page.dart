import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:freelance_order/pages/admin_main_page.dart';
import 'package:get/get.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';
import 'worker_main_page.dart';
import '../prefabs/colors.dart';
import '../prefabs/appbar_prefab.dart';

class EnterSMSPage extends StatefulWidget {
  final nextPage;
  const EnterSMSPage({super.key, required this.nextPage});

  @override
  State<EnterSMSPage> createState() => _EnterSMSPageState();
}

class _EnterSMSPageState extends State<EnterSMSPage> {
  String _errorMessage = '';
  final _smsController = TextEditingController();

  void sendAndCheckSMS() {
    if (_smsController.text.length < 4) {
      setState(() {});
      _errorMessage = 'Введите код';
    } else {
      // send data to server

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Успешно'), duration: Duration(seconds: 1),),
      );

      Get.offAll(widget.nextPage);
    }
    // Check data
  }

  void onNumberButtonPressed(String value) {
    _smsController.text += value;
    if (_smsController.text.length >= 4){
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
