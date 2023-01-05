import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../pages/admin_main_page.dart';
import '../utils/LocalizerUtil.dart';
import 'colors.dart';

Widget getMainMenuButton({enabled = true}) {
  return SizedBox(
    height: 32.h,
    child: InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: enabled
          ? () {
              Get.offAll(const AdminsMainPage());
            }
          : () {},
      child: Image.asset("assets/mainMenuButton.png"),
    ),
  );
}

Widget getGoBackButton(
    {double? padding,
    double? height,
    Function? onTap,
    Color? color,
    String? result}) {
  return Material(
    color: color ?? bgColor,
    child: SizedBox(
      height: height ?? 32.h,
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: onTap == null
            ? () {
                if (result == null || result == '') {
                  Get.back();
                } else {
                  Get.back(result: result);
                }
              }
            : () {
                onTap();
              },
        child: Padding(
            padding: EdgeInsets.all(padding ?? 0),
            child: Image.asset("assets/goBackButton.png")),
      ),
    ),
  );
}

Widget getSaveButton(Function onTap){
  return Container(
    constraints: BoxConstraints(minWidth: 20.w),
    margin: EdgeInsets.only(left: 2.w, right: 2.w),
    child: Material(
      color: Colors.white,
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: (){ onTap(); },
        child: Container(
          padding: EdgeInsets.all(4.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/save.png', height: 25.h,),
              Text(Localizer.get('save'),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14.h,
                  ),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget getInputTimeField(controller) {
  return Container(
    constraints: BoxConstraints(minWidth: 20.w),
    margin: EdgeInsets.only(left: 2.w, right: 2.w),
    color: Colors.white,
    child: TextField(
      controller: controller,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.all(4.w),
      ),
      style: TextStyle(fontSize: 14.h),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        TimeInputFormatter(),
        LengthLimitingTextInputFormatter(5)
      ],
    ),
  );
}

class TimeInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String ans = '';
    int counter = 0;

    for (var element in newValue.text.runes) {
      if (counter == 2) {
        ans += ':';
      }
      ans += String.fromCharCode(element);
      counter += 1;
    }

    return TextEditingValue(
      text: ans,
      selection: TextSelection.collapsed(offset: ans.length),
    );
  }
}