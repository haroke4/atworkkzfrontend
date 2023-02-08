import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelance_order/prefabs/admin_tools.dart';
import 'package:get/get.dart';
import '../prefabs/colors.dart';

class AssignDataPage extends StatefulWidget {
  final String text;
  final bool inputtingText;

  const AssignDataPage(
      {super.key, required this.text, this.inputtingText = false});

  @override
  State<AssignDataPage> createState() => _AssignDataPageState();
}

class _AssignDataPageState extends State<AssignDataPage> {
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  void _onNumberButtonPressed(String value) {
    _textController.text += value;
  }

  void _onGoBackPressed() {
    // SendDataBack
    Get.back(result: _textController.text);
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
                widget.text,
                style: TextStyle(
                  color: Theme.of(context).primaryColorDark,
                  fontSize: 57.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(110.w, 10.h, 110.w, 10.w),
                child: TextField(
                  controller: _textController,
                  style:
                      TextStyle(fontSize: 32.sp, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  cursorColor: Colors.black,
                  cursorWidth: 1.w,
                  autofocus: widget.inputtingText,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(bottom: -18.h),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 5.h)),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 5.h)),
                  ),
                  inputFormatters: [
                    if (!widget.inputtingText)
                      FilteringTextInputFormatter.digitsOnly,
                  ],
                ),
              ),
              SizedBox(height: 3.h),
              if (!widget.inputtingText) ...[
                SizedBox(height: 10.h),
                getNumbersWidget(),
              ],
              SizedBox(height: 30.h),
              getGoBackButton(
                  padding: 2.w, height: 70.h, onTap: _onGoBackPressed),
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
        SizedBox(height: 22.h),
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
