import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelance_order/utils/AdminBackendAPI.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../prefabs/admin_tools.dart';
import '../prefabs/colors.dart';
import '../prefabs/tools.dart';
import '../utils/BackendAPI.dart';
import '../utils/LocalizerUtil.dart';
import 'admin_main_page.dart';

class AdminWorkerPhotoPage extends StatefulWidget {
  final name;
  final companyName;
  final department;
  final monthPenalty;
  final day;
  final latePricePerMinute;
  final bool isStart;

  const AdminWorkerPhotoPage(
      {super.key,
      required this.name,
      required this.companyName,
      required this.department,
      required this.day,
      required this.monthPenalty,
      required this.latePricePerMinute,
      required this.isStart});

  @override
  State<AdminWorkerPhotoPage> createState() => _AdminWorkerPhotoPageState();
}

class _AdminWorkerPhotoPageState extends State<AdminWorkerPhotoPage> {
  late final _day = widget.day;
  late final _isStart = widget.isStart;

  @override
  void initState() {
    super.initState();
    updateTime();
  }

  void updateTime() async {
    var sTime = await getServerTime();
    setState(() {
      SERVER_TIME = sTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, BoxConstraints constraints) {
      return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: SafeArea(
          child: Container(
            margin: EdgeInsets.all(4.w),
            child: Row(
              children: [
                getFirstColumn(constraints.maxWidth * 0.25 - 4.w,
                    constraints.maxHeight - 8.w),
                SizedBox(
                  width: constraints.maxWidth * 0.5,
                  height: constraints.maxHeight - 8.w,
                  child: AspectRatio(
                    aspectRatio: 1 / 1,
                    child: Image.network(
                      headers: headers,
                      AdminBackendAPI.getImageUrl(
                          _day[_isStart ? 'start_photo' : 'end_photo']),
                    ),
                  ),
                ),
                getLastColumn(constraints.maxWidth * 0.25 - 4.w,
                    constraints.maxHeight - 8.w),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget getFirstColumn(width, height) {
    return SizedBox(
      width: width,
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          getText(widget.companyName),
          SizedBox(height: 4.h),
          getText(widget.department),
          SizedBox(height: 4.h),
          getText(widget.name, bgColor: brownColor, fontColor: Colors.white),
          SizedBox(height: 4.h),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                getText(SERVER_TIME,
                    align: TextAlign.center, fontWeight: FontWeight.bold),
                SizedBox(height: 4.h),
                getText(CURRENT_YEARMONTH,
                    bgColor: todayColor,
                    fontColor: Colors.white,
                    fontWeight: FontWeight.bold,
                    align: TextAlign.center),
                getText("16",
                    bgColor: todayColor,
                    fontColor: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22.h,
                    align: TextAlign.center),
                SizedBox(height: 4.h),
                getConfirmationButton(widget.isStart
                    ? _day['confirmed_start']
                    : _day['confirmed_end']),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget getLastColumn(width, height) {
    return SizedBox(
      width: width,
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          getText("Atwork.kz", align: TextAlign.center),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                getFirstLine(),
                SizedBox(height: 4.h),
                getTwoTextOneLine(
                    Localizer.get('sum_month'), "${widget.monthPenalty}",
                    bgColor: lateColor),
                SizedBox(height: 20.h),
                getThirdLine(),
                SizedBox(height: 4.h),
                getPhotoTime(),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              getMainMenuButton(),
              SizedBox(width: 4.w),
              getGoBackButton(),
            ],
          ),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  Widget getConfirmationButton(bool data) {
    if (data) {
      return getText(
        Localizer.get('confirmed'),
        align: TextAlign.center,
        bgColor: brownColor,
        fontColor: Colors.white,
        fontWeight: FontWeight.bold,
      );
    }
    return getText(Localizer.get('not_confirmed'),
        align: TextAlign.center,
        bgColor: Colors.red,
        fontColor: Colors.white,
        fontWeight: FontWeight.bold);
  }

  Widget getFirstLine() {
    if (_isStart) {
      return getTwoTextSeperated(
        getPenalty(),
        " ${_day['penalty_count_end']} ",
        secondTextBgColor: getColorByStatus(_day['worker_status_end']),
        firstExpanded: true,
      );
    }
    return getTwoTextSeperated(
      getPenalty(),
      " ${_day['penalty_count_start']} ",
      secondTextBgColor: getColorByStatus(_day['worker_status_start']),
      firstExpanded: true,
    );
  }

  String getPenalty() {
    if (_isStart) {
      var cnt = _day["late_minute_count"];
      return "$cnt * ${widget.latePricePerMinute}";
    }
    var cnt = _day["late_minute_count"];
    return "$cnt * ${widget.latePricePerMinute}";
  }

  Widget getThirdLine() {
    if (_isStart) {
      return getTextWithTime(
          Localizer.get('appearance'), getCurrentDayTime('start_time'));
    }
    return getTextWithTime(
        Localizer.get('leave'), getCurrentDayTime('end_time'));
  }

  Widget getPhotoTime() {
    var label;
    var key = _isStart ? 'worker_status_start' : 'worker_status_end';
    if (_isStart) {
      label = getCurrentDayTime('start_photo_time') ?? '__/__';
    } else {
      label = getCurrentDayTime('end_photo_time') ?? '__/__';
    }

    return getTwoTextOneLine(Localizer.get('photo_from_place'), label,
        bgColor: getColorByStatus(_day[key]));
  }

  String getCurrentDayTime(String key) {
    // key = start_time or end_time
    String? ans = _day[key];
    if (ans == null) {
      return "__/__";
    }
    if (ans.startsWith("0")) {
      ans = ans.substring(1, 5);
    } else {
      ans = ans.substring(0, 5);
    }
    return ans;
  }
}
