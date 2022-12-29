import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:freelance_order/utils/AdminBackendAPI.dart';
import 'package:get/get.dart';
import '../utils/BackendAPI.dart';
import 'colors.dart';

Future<String> getServerTime() async {
  String time = await BackendAPI.getServerTime();
  final splitted = time.split(":");
  int hour = int.parse(splitted[0]);
  return "$hour:${splitted[1]}";
}

Widget __getOnlyText(
    text, fontColor, overflow, align, weight, fontSize, minWidth) {
  return Container(
    constraints: BoxConstraints(minWidth: minWidth),
    padding: EdgeInsets.all(4.w),
    child: Text(text,
        style: TextStyle(
          color: fontColor,
          fontSize: fontSize,
          fontWeight: weight,
        ),
        textAlign: align,
        overflow: overflow),
  );
}

Widget getText(
  String text, {
  Color bgColor = Colors.white,
  Color fontColor = Colors.black,
  TextOverflow overflow = TextOverflow.ellipsis,
  TextAlign align = TextAlign.left,
  FontWeight fontWeight = FontWeight.normal,
  double minWidth = 0,
  double? fontSize,
  Function? onPressed,
}) {
  fontSize = fontSize ?? 14.h;
  var textW;
  if (onPressed != null) {
    textW = InkWell(
      splashColor: Colors.black26,
      onTap: () {
        onPressed();
      },
      child: __getOnlyText(
        text,
        fontColor,
        overflow,
        align,
        fontWeight,
        fontSize,
        minWidth,
      ),
    );
  } else {
    textW = __getOnlyText(
      text,
      fontColor,
      overflow,
      align,
      fontWeight,
      fontSize,
      minWidth,
    );
  }

  return Container(
    margin: EdgeInsets.only(left: 2.w, right: 2.w),
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
      overflow: TextOverflow.visible,
    ),
  );
}

Widget getPhoto({text = "", Function? onTap, String? imagePath}) {
  return Container(
    margin: EdgeInsets.only(left: 3.w, right: 3.w),
    child: AspectRatio(
      aspectRatio: 1 / 1,
      child: () {
        if (imagePath != null) {
          return Material(
            color: const Color.fromRGBO(223, 223, 223, 1),
            child: InkWell(
              onTap: () {
                if (onTap != null) onTap();
              },
              splashColor: Colors.black26,
              child: Column(
                children: [
                  SizedBox(height: 20.h),
                  Image.network(
                    headers: headers,
                    AdminBackendAPI.getImageUrl(imagePath),
                    height: 140.h,
                    fit: BoxFit.cover,
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) return child;
                      return SpinKitThreeBounce(
                        color: Colors.black,
                        size: 20.h,
                      );
                    },
                  ),
                  Text(text),
                ],
              ),
            ),
          );
        } else if (text != "") {
          return InkWell(
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
          );
        } else {
          return Image.asset('assets/icon.png', fit: BoxFit.cover);
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

Widget getTwoTextSeperated(
  firstText,
  secondText, {
  firstExpanded = false,
  firstTextBgColor = Colors.white,
  secondTextBgColor = Colors.white,
}) {
  return Row(
    children: [
      firstExpanded
          ? Expanded(
              child: getText(firstText,
                  bgColor: firstTextBgColor, overflow: TextOverflow.visible))
          : getText(firstText,
              bgColor: firstTextBgColor, overflow: TextOverflow.visible),
      IntrinsicWidth(
          child: getText(secondText,
              bgColor: secondTextBgColor, overflow: TextOverflow.visible)),
    ],
  );
}

Widget getArrowButton(Icon icon, String heroTag, onPressed) {
  return Container(
    margin: EdgeInsets.only(left: 2.w, right: 2.w),
    child: FloatingActionButton.extended(
      onPressed: onPressed,
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
    Color fontColor = Colors.black,
    Function? onTap}) {
  return Container(
    width: 22.h,
    height: 22.h,
    margin: EdgeInsets.only(left: 1.5.w, right: 1.5.w),
    child: Material(
      color: color,
      child: onTap == null
          ? Center(
              child: (text == "" && confirmation)
                  ? Image.asset(
                      "assets/confirmation.png",
                      height: 13.h,
                    )
                  : Text(text, style: TextStyle(color: fontColor)),
            )
          : InkWell(
              splashColor: Colors.black12,
              highlightColor: Colors.black12,
              onTap: () {
                onTap();
              },
            ),
    ),
  );
}
