import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:freelance_order/utils/AdminBackendAPI.dart';
import 'package:get/get.dart';
import '../utils/BackendAPI.dart';
import 'colors.dart';

Future<dynamic> getServerDateTime() async {
  var response = await BackendAPI.getServerDateTime();
  String time = response['time'];
  List<String> date = response['date'].split('-');

  final splitted = time.split(":");
  int hour = int.parse(splitted[0]);
  return {
    "time": "$hour:${splitted[1]}",
    "month": int.parse(date[1]),
    "year": int.parse(date[0])
  };
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
        maxLines: 1,
        softWrap: false,
        overflow: overflow),
  );
}

Widget getText(
  String text, {
  Color bgColor = Colors.white,
  Color fontColor = Colors.black,
  TextOverflow overflow = TextOverflow.fade,
  TextAlign align = TextAlign.left,
  FontWeight fontWeight = FontWeight.normal,
  double minWidth = 0,
  double? fontSize,
  VoidCallback? onPressed,
  VoidCallback? onLongPress,
}) {
  fontSize = fontSize ?? 12.h;
  var textW;
  if (onPressed != null) {
    textW = InkWell(
      splashColor: Colors.black26,
      onTap: onPressed,
      onLongPress: onLongPress,
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
    {Color bgColor = Colors.white,
    Color fontColor = Colors.black,
    TextOverflow overflow = TextOverflow.fade,
    Function? onPressed,
    Function? onLongPress}) {
  return Container(
    margin: EdgeInsets.only(left: 2.w, right: 2.w),
    padding: EdgeInsets.all(3.w),
    decoration: BoxDecoration(
      color: bgColor,
    ),
    child: onPressed == null
        ? Text(
            text,
            style: TextStyle(
              color: fontColor,
              fontSize: 14.h,
            ),
            maxLines: 1,
            softWrap: false,
            overflow: overflow,
          )
        : InkWell(
            onTap: () {
              onPressed();
            },
            onLongPress: () {
              onLongPress!();
            },
            child: Text(
              text,
              style: TextStyle(
                color: fontColor,
                fontSize: 14.h,
              ),
              maxLines: 1,
              softWrap: false,
              overflow: overflow,
            ),
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
                    height: 120.h,
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
      elevation: 4,
      shape: const CircleBorder(),
    ),
  );
}

Widget getRect(
  Color color, {
  String text = "",
  String secText = "",
  bool confirmation = false,
  Color fontColor = Colors.black,
  double? width,
  double? height,
  Function? onTap,
}) {
  width = width ?? 26.h;
  height = height ?? width;
  Widget secTWidget = Padding(
    padding: EdgeInsets.only(top: height / 1.5),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          secText,
          style: const TextStyle(fontSize: 7),
        )
      ],
    ),
  );
  return Container(
    width: width,
    height: height,
    margin: EdgeInsets.only(left: 1.w, right: 1.w),
    child: Material(
      borderRadius: BorderRadius.circular(5),
      color: color,
      child: onTap == null
          ? Center(
              child: (text == "" && confirmation)
                  ? Image.asset(
                      "assets/confirmation.png",
                      height: 13.h,
                    )
                  : Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          text,
                          style: TextStyle(color: fontColor, fontSize: 12),
                        ),
                        secText == "" ? const SizedBox(height: 0) : secTWidget,
                      ],
                    ),
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
