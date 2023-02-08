import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:freelance_order/utils/AdminBackendAPI.dart';
import 'package:intl/intl.dart';
import 'package:timer_builder/timer_builder.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/BackendAPI.dart';
import '../utils/LocalizerUtil.dart';
import 'colors.dart';

class ServerTime {
  static DateTime time = DateTime(2022);
  static String yearMonth = '';

  static Future<void> updateDateTime() async {
    var dt = await BackendAPI.getServerDateTime();
    ServerTime.yearMonth = "${Localizer.get(dt.month)} / ${dt.year}";
    ServerTime.time = dt;
  }

  static Widget getServerTimeWidget({bool adder = false}) {
    return TimerBuilder.periodic(
      const Duration(seconds: 1),
      builder: (context) {
        if (adder) {
          ServerTime.time = ServerTime.time.add(const Duration(seconds: 1));
        }
        DateFormat formatter = DateFormat('HH:mm');
        return getText(formatter.format(ServerTime.time),
            align: TextAlign.center, fontWeight: FontWeight.bold);
      },
    );
  }
}

Widget __getOnlyText(
    text, fontColor, overflow, align, weight, fontSize, minWidth) {
  return Container(
    constraints: BoxConstraints(minWidth: minWidth),
    padding: EdgeInsets.all(4.w),
    child: Text(
      text,
      style: TextStyle(
        color: fontColor,
        fontSize: fontSize,
        fontWeight: weight,
      ),
      textAlign: align,
      maxLines: 1,
      softWrap: false,
      overflow: overflow,
    ),
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
  bool rounded = false,
  double? fontSize,
  VoidCallback? onPressed,
  VoidCallback? onLongPress,
}) {
  fontSize = fontSize ?? 20.sp;
  var textW;
  if (onPressed != null) {
    textW = InkWell(
      splashColor: Colors.black26,
      onTap: onPressed,
      onLongPress: onLongPress,
      child: __getOnlyText(
          text, fontColor, overflow, align, fontWeight, fontSize, minWidth),
    );
  } else {
    textW = __getOnlyText(
        text, fontColor, overflow, align, fontWeight, fontSize, minWidth);
  }

  return Container(
    margin: EdgeInsets.only(left: 2.w, right: 2.w),
    child: Material(
      borderRadius: BorderRadius.circular(rounded ? 5 : 0),
      color: bgColor,
      child: textW,
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
                  Image.network(
                    headers: headers,
                    AdminBackendAPI.getImageUrl(imagePath),
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) return child;
                      return SpinKitThreeBounce(
                        color: Colors.black,
                        size: 20.h,
                      );
                    },
                  ),
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
                  height: 200.h,
                ),
                Text(
                  text,
                  style: TextStyle(fontSize: 20.sp),
                ),
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
          style: TextStyle(fontSize: 20.sp),
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
      child: Text(
        timeText,
        style: TextStyle(color: Colors.white, fontSize: 20.sp),
      ),
    ),
  ]);
}

Widget getTwoTextOneLine(firstText, secondText,
    {bgColor = Colors.white, expanded = true, double? margin}) {
  margin = margin ?? 3.w;
  var firstTextWidget = Text(firstText, style: TextStyle(fontSize: 20.sp));
  return Container(
    margin: EdgeInsets.only(left: margin, right: margin),
    padding: EdgeInsets.all(4.w),
    decoration: BoxDecoration(
      color: bgColor,
    ),
    child: Row(
      children: [
        expanded ? Expanded(child: firstTextWidget) : firstTextWidget,
        Text(
          secondText,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp),
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
  context,
  Color color, {
  String text = "",
  String secText = "",
  bool confirmation = false,
  bool wBorder = false,
  bool rounded = true,
  Color fontColor = Colors.black,
  double? width,
  double? height,
  Function? onTap,
}) {
  var border = wBorder ? Border.all(color: Colors.black, width: 0.5) : Border();
  width = width ?? 52.h;
  height = height ?? width;
  Widget secTWidget = Padding(
    padding: EdgeInsets.only(top: height / 1.8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          secText,
          style: TextStyle(fontSize: 14.sp),
        )
      ],
    ),
  );
  return Container(
    width: width,
    height: height,
    margin: EdgeInsets.only(left: 0.8.w, right: 0.8.w),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(rounded ? 5 : 0),
        border: border,
        color: color,
      ),
      child: onTap == null
          ? Center(
              child: (text == "" && confirmation)
                  ? Image.asset(
                      "assets/confirmation.png",
                      height: 20.sp,
                    )
                  : Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          text,
                          softWrap: false,
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          style: TextStyle(color: fontColor, fontSize: 22.sp),
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

Widget getZhumystaKzText() {
  return getText("Zhumysta.kz", align: TextAlign.center, onPressed: () {
    launchUrl(
      Uri.parse("https://Zhumysta.kz"),
      mode: LaunchMode.externalApplication,
    );
  });
}

String getNameOfWeek(day) {
  return Localizer.get(DateFormat('EE').format(DateTime(
    ServerTime.time.year,
    ServerTime.time.month,
    day,
  )));
}
