import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:freelance_order/pages/admin_main_page.dart';
import 'package:freelance_order/prefabs/admin_tools.dart';
import 'package:freelance_order/prefabs/tools.dart';
import 'package:get/get.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';
import 'worker_main_page.dart';
import '../prefabs/colors.dart';
import '../prefabs/appbar_prefab.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  String _errorMessage = '';
  String _buttonLabel = 'Дальше';
  bool _enteringNewPassword = false;
  final _textController = TextEditingController();

  void _sendAndCheckSMS() {
    if (_textController.text.length < 4) {
      setState(() {});
      _errorMessage = 'Введите код';
    } else {
      // send data to server

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Успешно'),
          duration: Duration(seconds: 1),
        ),
      );

      Get.back();
    }
    // Check data
  }

  void _onNextPressed() {
    //Check if password valid
    if (_enteringNewPassword) {
      // send new pass to server
      Get.back();
    } else {
      setState(() {
        if (_textController.text == "0000") {
          _enteringNewPassword = true;
          _textController.text = "";
          _buttonLabel = "Сменить пароль";
        } else {
          _errorMessage = "Неправильный пароль";
        }
      });
    }
  }

  void _onNumberButtonPressed(String value) {
    _textController.text += value;
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
                _enteringNewPassword
                    ? "Введите новый пароль"
                    : 'Введите текущий пароль',
                style: TextStyle(
                  color: Theme.of(context).primaryColorDark,
                  fontSize: 35.h,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(110.w, 5.w, 110.w, 5.w),
                child: TextField(
                  controller: _textController,
                  style: TextStyle(fontSize: 20.h, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  cursorColor: Colors.black,
                  cursorWidth: 1.w,
                  decoration: InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 5.h)),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 5.h)),
                  ),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
              SizedBox(height: 15.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  getGoBackButton(padding: 2.w, height: 36.h, color: Colors.white),
                  SizedBox(width: 5.w),
                  getText(_buttonLabel, onPressed: _onNextPressed),
                ],
              ),
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
          onTap: () => _onNumberButtonPressed(i.toString()),
          text: i.toString()));
      if (i != 5) {
        firstLine.add(SizedBox(width: 15.w));
      }
    }
    for (int i = 6; i < 10; i++) {
      secondLine.add(CircleButton(
          onTap: () => _onNumberButtonPressed(i.toString()),
          text: i.toString()));
      secondLine.add(SizedBox(width: 15.w));
    }
    secondLine.add(
      CircleButton(onTap: () => _onNumberButtonPressed("0"), text: "0"),
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
