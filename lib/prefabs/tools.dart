import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'colors.dart';

Widget __getOnlyText(text, fontColor, overflow, align, weight) {
  return Container(
    padding: EdgeInsets.all(4.w),
    child: Text(text,
        style: TextStyle(
          color: fontColor,
          fontSize: 14.h,
          fontWeight: weight,
        ),
        textAlign: align,
        overflow: overflow),
  );
}

Widget getText(String text,
    {Color bgColor = Colors.white,
    Color fontColor = Colors.black,
    TextOverflow overflow = TextOverflow.ellipsis,
    TextAlign align = TextAlign.left,
    FontWeight fontWeight = FontWeight.normal,
    Function? onPressed}) {
  var textW;
  if (onPressed != null) {
    textW = InkWell(
        splashColor: Colors.black26,
        onTap: () {
          onPressed();
        },
        child: __getOnlyText(text, fontColor, overflow, align, fontWeight));
  } else {
    textW = __getOnlyText(text, fontColor, overflow, align, fontWeight);
  }

  return Container(
    margin: EdgeInsets.only(left: 3.w, right: 3.w),
    child: Material(
      color: bgColor,
      child: textW,
    ),
  );
}

Widget getTextSmaller(String text,
    {Color bgColor = Colors.white, Color fontColor = Colors.black}) {
  return Container(
    margin: EdgeInsets.only(left: 2.w, right: 2.w),
    padding: EdgeInsets.all(4.w),
    decoration: BoxDecoration(
      color: bgColor,
    ),
    child: Text(
      text,
      style: TextStyle(
        color: fontColor,
        fontSize: 12.h,
      ),
      overflow: TextOverflow.ellipsis,
    ),
  );
}

Widget getPhoto({text = "", Function? onTap}) {
  return Container(
    margin: EdgeInsets.only(left: 3.w, right: 3.w),
    child: AspectRatio(
      aspectRatio: 1 / 1,
      child: () {
        if (text != "") {
          return Material(
            color: const Color.fromRGBO(223, 223, 223, 1),
            child: InkWell(
              onTap: () {
                onTap!();
              },
              splashColor: Colors.black26,
              child: Column(
                children: [
                  SizedBox(height: 20.h),
                  Image.asset(
                    'assets/icon.png',
                    fit: BoxFit.cover,
                    height: 105.h,
                  ),
                  Text(text),
                ],
              ),
            ),
          );
        }
        // else if(imageRight != null){
        //   return Image.file(imageRight!);
        // }
        else {
          return Image.asset(
            'assets/Untitled.png',
            fit: BoxFit.cover,
          );
        }
      }(),
    ),
  );
}

Widget getTextWithTime(String text, String timeText) {
  return Row(children: [
    Expanded(
      child: Container(
        margin: EdgeInsets.only(left: 3.w),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: brownColor, width: 2),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 13.h),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ),
    Container(
      margin: EdgeInsets.only(right: 3.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: brownColor,
        border: Border.all(color: brownColor, width: 2),
      ),
      child:
          Text(timeText, style: TextStyle(color: Colors.white, fontSize: 13.h)),
    ),
  ]);
}

Widget getTwoTextOneLine(firstText, secondText,
    {bgColor = Colors.white, expanded = true}) {
  return Container(
    margin: EdgeInsets.only(left: 3.w, right: 3.w),
    padding: EdgeInsets.all(4.w),
    decoration: BoxDecoration(
      color: bgColor,
    ),
    child: Row(
      children: [
        expanded ? Expanded(child: Text(firstText)) : Text(firstText),
        Text(
          secondText,
          style: const TextStyle(fontWeight: FontWeight.bold),
        )
      ],
    ),
  );
}

Widget getArrowButton(Icon icon, String heroTag) {
  return Container(
    margin: EdgeInsets.only(left: 2.w, right: 2.w),
    child: FloatingActionButton.extended(
      onPressed: () {},
      heroTag: heroTag,
      label: icon,
      foregroundColor: Colors.black,
      backgroundColor: Colors.white,
      shape: const CircleBorder(),
    ),
  );
}

Widget getRect(Color color,
    {String text = "",
    bool confirmation = false,
    Color fontColor = Colors.black}) {
  return Container(
    width: 22.h,
    height: 22.h,
    margin: EdgeInsets.only(left: 1.5.w, right: 1.5.w),
    decoration: BoxDecoration(color: color),
    child: Center(
      child: (text == "" && confirmation)
          ? Image.asset(
        "assets/confirmation.png",
        height: 13.h,
      )
          : Text(text, style: TextStyle(color: fontColor)),
    ),
  );
}