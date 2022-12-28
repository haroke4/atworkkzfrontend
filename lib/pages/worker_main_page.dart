import 'dart:convert';
import 'dart:io';
import 'package:freelance_order/prefabs/scaffold_messages.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelance_order/utils/WorkersBackendAPI.dart';
import 'package:image_picker/image_picker.dart';
import '../prefabs/colors.dart';
import '../prefabs/tools.dart';

// TODO: CONNECT TO BACKEND!!!

var SERVER_TIME = "__/__";
var CURRENT_YEARMONTH = "";

class WorkersMainPage extends StatefulWidget {
  const WorkersMainPage({super.key});

  @override
  State<WorkersMainPage> createState() => _WorkersMainPageState();
}

class _WorkersMainPageState extends State<WorkersMainPage> {
  int _today = 1;
  int _initToday = 0;
  var _data = {};
  var _days = [];
  int _currMonthMaxDay = 0;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
    asyncInitState();
  }

  Future<void> asyncInitState() async {
    print('UPDATING');
    showScaffoldMessage(context, "Обновление...");
    var response = await WorkersBackendAPI.getDays();
    if (response.statusCode == 200) {
      updateMonthYear();
      updateTime();
      setState(() {
        _data = jsonDecode(utf8.decode(response.bodyBytes))['message'];
        _days = _data['days'];
        print(_data);
        _today = _data['today'];
        _initToday = _today;
        var curr_date = DateTime.now();
        _currMonthMaxDay =
            DateTime(curr_date.year, curr_date.month + 1, 0).day.toInt();
      });
      showScaffoldMessage(context, "Успешно");
    }
  }

  void updateTime() async {
    var sTime = await getServerTime();
    setState(() {
      SERVER_TIME = sTime;
    });
  }

  void updateMonthYear() {
    setState(() {
      String locale = Localizations.localeOf(context).languageCode;
      DateTime now = DateTime.now();
      var _month = DateFormat.MMM(locale).format(now);
      var _year = DateFormat.y(locale).format(now);
      CURRENT_YEARMONTH = "$_month $_year";
    });
  }

  Future onMakeSelfiePressed({start = true}) async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image == null) return;

    final imageFile = File(image.path);
    await WorkersBackendAPI.assignPhoto(_days[_today - 1]['id'], imageFile,
        start: start);
    asyncInitState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, BoxConstraints constraints) {
      return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: SafeArea(
          child: RefreshIndicator(
            color: brownColor,
            onRefresh: asyncInitState,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Container(
                margin: EdgeInsets.all(4.w),
                child: Column(
                  children: [
                    getFirstLineWidgets(constraints.maxWidth * 0.25 - 4.w),
                    SizedBox(height: 4.h),
                    getSecondLineWidgets(constraints.maxWidth * 0.25 - 4.w),
                    SizedBox(height: 4.h),
                    getThirdLineWidgets(constraints.maxWidth * 0.25 - 4.w),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget getFirstLineWidgets(width) {
    return Row(
      children: [
        SizedBox(
            width: width,
            child: getText(_data.isEmpty ? "Фирма" : _data['name'])),
        getText(SERVER_TIME,
            align: TextAlign.center, fontWeight: FontWeight.bold),
        Expanded(
            child: getText(CURRENT_YEARMONTH,
                bgColor: todayColor,
                fontColor: Colors.white,
                align: TextAlign.center)),
        getText("Qaz / Rus / Eng", align: TextAlign.center),
        getText("Atwork.kz", align: TextAlign.center),
      ],
    );
  }

  Widget getSecondLineWidgets(width) {
    return Row(
      children: [
        SizedBox(
          width: width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              getText(_data.isEmpty ? "Название отдела" : _data['department']),
              SizedBox(height: 4.h),
              getText(_data.isEmpty ? "Имя" : _data['worker_name'],
                  bgColor: brownColor, fontColor: Colors.white),
            ],
          ),
        ),
        getArrowButton(const Icon(Icons.arrow_back), "back", leftArrow),
        const Expanded(child: SizedBox()),
        getDatesWidgets(),
        const Expanded(child: SizedBox()),
        getArrowButton(const Icon(Icons.arrow_forward), "forward", rightArrow),
      ],
    );
  }

  Widget getThirdLineWidgets(width) {
    return Row(
      children: [
        SizedBox(
          width: width,
          child: Column(
            children: [
              () {
                if (_days.isEmpty ||
                    _days[_today - 1]['start_photo'] == null &&
                        _today == _initToday) {
                  return getPhoto(
                    text: "Сделать сэлфи",
                    onTap: onMakeSelfiePressed,
                  );
                } else {
                  return getPhoto(imagePath: _days[_today - 1]['start_photo']);
                }
              }(),
              SizedBox(height: 4.h),
              getTextWithTime("Явка", getCurrentDayTime("start_time")),
              SizedBox(height: 4.h),
              getTwoTextOneLine(
                'Фото с точки',
                getPhotoTime("start_photo_time"),
                bgColor: getBgColor('worker_status_start'),
              ),
            ],
          ),
        ),
        Expanded(child: getMiddleInfoWidgets()),
        SizedBox(
          width: width,
          child: Column(
            children: [
              () {
                if (_days.isEmpty) {
                  return getPhoto(
                    text: "Сделать сэлфи",
                    onTap: () => onMakeSelfiePressed(start: false),
                  );
                }
                if (_days[_today - 1]['end_photo'] == null &&
                    _today == _initToday) {
                  return getPhoto(
                    text: "Сделать сэлфи",
                    onTap: () => onMakeSelfiePressed(start: false),
                  );
                } else {
                  return getPhoto(imagePath: _days[_today - 1]['end_photo']);
                }
              }(),
              SizedBox(height: 4.h),
              getTextWithTime("Уход", getCurrentDayTime("end_time")),
              SizedBox(height: 4.h),
              getTwoTextOneLine(
                'Фото с точки',
                getPhotoTime("end_photo_time"),
                bgColor: getBgColor('worker_status_end'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget getDatesWidgets() {
    return Column(
      children: [
        Row(
          children: [
            getRect(Colors.white, text: getValidatedDay(_today - 5)),
            getRect(Colors.white, text: getValidatedDay(_today - 4)),
            getRect(Colors.white, text: getValidatedDay(_today - 3)),
            getRect(Colors.white, text: getValidatedDay(_today - 2)),
            getRect(Colors.white, text: getValidatedDay(_today - 1)),
            SizedBox(
              width: 48.h + 12.w,
              child: Text(
                "${_today}",
                style: TextStyle(
                  color: todayColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 23.h,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            getRect(Colors.white, text: getValidatedDay(_today + 1)),
            getRect(Colors.white, text: getValidatedDay(_today + 2)),
            getRect(Colors.white, text: getValidatedDay(_today + 3)),
            getRect(Colors.white, text: getValidatedDay(_today + 4)),
            getRect(Colors.white, text: getValidatedDay(_today + 5)),
          ],
        ),
        Row(
          children: [
            getRectByDay(_today - 5),
            getRectByDay(_today - 4),
            getRectByDay(_today - 3),
            getRectByDay(_today - 2),
            getRectByDay(_today - 1),
            SizedBox(
              width: 48.h + 12.w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  getRectByDay(_today, showConfirm: true),
                  getRectByDay(_today, start: false, showConfirm: true),
                ],
              ),
            ),
            getRectByDay(_today + 1, ws: false),
            getRectByDay(_today + 2, ws: false),
            getRectByDay(_today + 3, ws: false),
            getRectByDay(_today + 4, ws: false),
            getRectByDay(_today + 5, ws: false),
          ],
        )
      ],
    );
  }

  Widget getMiddleInfoWidgets() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(children: [getRect(todayColor), Text("Сегодня, явка/уход")]),
              SizedBox(height: 4.h),
              Row(children: [getRect(workingDayColor), Text("Рабочий день")]),
              SizedBox(height: 4.h),
              Row(children: [
                getRect(nonWorkingDayColor),
                Text("Нерабочий день")
              ]),
              SizedBox(height: 4.h),
              Row(children: [
                getRect(noAssignmentColor),
                Text("Нет установок")
              ]),
              SizedBox(height: 4.h),
              Row(children: [getRect(onTimeColor), Text("Вовремя")]),
              SizedBox(height: 4.h),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        getTextSmaller("Премия мес/ед"),
                        SizedBox(height: 4.h),
                        getTextSmaller("Отпросился"),
                      ],
                    ),
                  ),
                  SizedBox(height: 4.h),
                  IntrinsicWidth(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        getTextSmaller(_data['prize'].toString()),
                        SizedBox(height: 4.h),
                        getTextSmaller(_data['beg_off_price'].toString()),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              getPenalty()
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(children: [getRect(lateColor), Text("Опоздание")]),
              SizedBox(height: 4.h),
              Row(children: [getRect(truancyColor), Text("Прогул")]),
              SizedBox(height: 4.h),
              Row(children: [
                getRect(validReasonColor),
                Text("Уважительная причина")
              ]),
              SizedBox(height: 4.h),
              Row(children: [getRect(begOffColor), Text("Отпросился")]),
              SizedBox(height: 4.h),
              Row(children: [
                getRect(confirmationColor, confirmation: true),
                Text("Подтверждение")
              ]),
              SizedBox(height: 4.h),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        getTextSmaller("Цена минуты"),
                        SizedBox(height: 4.h),
                        getTextSmaller("Прогул мин/ед"),
                      ],
                    ),
                  ),
                  SizedBox(height: 4.h),
                  IntrinsicWidth(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        getTextSmaller(_data['late_minute_price'].toString()),
                        SizedBox(height: 4.h),
                        getTextSmaller(
                            "${_data['truancy_minute']}/${_data['truancy_price']}"),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              getTwoTextOneLine(
                "Сумма месяц",
                _data['penalty_count'].toString(),
                bgColor: lateColor,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String getValidatedDay(int curr) {
    if (0 < curr && curr <= _currMonthMaxDay) {
      return curr.toString();
    } else {
      return "";
    }
  }

  Widget getRectByDay(int day, {ws = true, start = true, showConfirm = false}) {
    // ws - is for worker status
    if (getValidatedDay(day) == '' || _days.isEmpty) {
      return getRect(noAssignmentColor);
    } else if (_days[day - 1] == null) {
      return getRect(noAssignmentColor);
    }
    if (ws && start) {
      return getRect(
        getColorByStatus(_days[day - 1]['worker_status_start']),
        confirmation: showConfirm && !_days[day - 1]['confirmed_start'],
      );
    } else if (ws && !start) {
      return getRect(
        getColorByStatus(_days[day - 1]['worker_status_end']),
        confirmation: showConfirm && !_days[day - 1]['confirmed_end'],
      );
    }
    return getRect(getColorByStatus(_days[day - 1]['day_status']));
  }

  String getCurrentDayTime(String key) {
    // key = start_time or end_time
    if (_days.isEmpty) {
      return "__/__";
    }
    String? ans = _days[_today - 1][key];
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

  String getPhotoTime(String key) {
    if (_days.isEmpty) {
      return "__/__";
    }
    var time = _days[_today - 1][key];
    if (time == null) {
      return "__/__";
    }
    final splitted = time.split(":");
    int hour = int.parse(splitted[0]);
    String minute = splitted[1];
    return "$hour:$minute";
  }

  void leftArrow() {
    updateTime();
    if (_today - 1 > 0) {
      setState(() {
        _today -= 1;
      });
    }
  }

  void rightArrow() {
    updateTime();
    if (_today + 1 <= _currMonthMaxDay) {
      setState(() {
        _today++;
      });
    }
  }

  Widget getPenalty({start = true}) {
    if (_days.isEmpty) {
      return getText("");
    }
    var cnt = _days[_today - 1]["late_minute_count"];
    var str = "$cnt мин * ${_data['late_minute_price']} = ";
    return getText("$str${_days[_today - 1]['penalty_count_start']}",
        bgColor: getColorByStatus(_days[_today - 1]['worker_status_start']));
  }

  Color getBgColor(key) {
    return getColorByStatus(
        _days.isEmpty ? null : _days[_today - 1][key]);
  }
}
