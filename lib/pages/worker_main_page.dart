import 'dart:convert';
import 'dart:io';
import 'package:freelance_order/prefabs/scaffold_messages.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelance_order/utils/WorkersBackendAPI.dart';
import 'package:image_picker/image_picker.dart';
import '../prefabs/colors.dart';
import '../prefabs/tools.dart';
import '../utils/LocalizerUtil.dart';
import 'map_page.dart';


var SERVER_TIME = "__/__";
var CURRENT_YEARMONTH = "";
var THIS_MONTH_ACTIVE = false;

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
    _update();
  }

  Future<void> asyncInitState() async {
    showScaffoldMessage(context, Localizer.get('processing'));
    await _update();
  }

  Future<void> _update() async {
    var response = await WorkersBackendAPI.getDays();
    if (response.statusCode == 200) {
      updateMonthYear();
      updateTime();
      setState(() {
        _data = jsonDecode(utf8.decode(response.bodyBytes))['message'];
        _days = _data['days'];
        THIS_MONTH_ACTIVE = _data['this_month_active'];
        _today = _data['today'];
        _initToday = _today;
        var curr_date = DateTime.now();
        _currMonthMaxDay =
            DateTime(curr_date.year, curr_date.month + 1, 0).day.toInt();
      });
      showScaffoldMessage(context, Localizer.get('success'));
      if (!THIS_MONTH_ACTIVE) {
        showScaffoldMessage(context, Localizer.get('atten'), time: 2);
      }
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
      DateTime now = DateTime.now();
      CURRENT_YEARMONTH = "${Localizer.get(now.month.toString())} ${now.year}";
    });
  }

  Future onMakeSelfiePressed({start = true}) async {
    if (!THIS_MONTH_ACTIVE) {
      showScaffoldMessage(context, Localizer.get('atten'), time: 2);
      return;
    }
    if (_days[_today - 1]['geoposition'] == null) {
      showScaffoldMessage(context, Localizer.get('no_geo_pos'));
      return;
    }
    if (start) {
      if (_days[_today - 1]['start_time'] == null) {
        showScaffoldMessage(context, Localizer.get('no_appea_time'));
        return;
      }
    } else {
      if (_days[_today - 1]['end_time'] == null) {
        showScaffoldMessage(context, Localizer.get('no_leave_time'));
        return;
      } else if (_days[_today - 1]['start_photo'] == null) {
        showScaffoldMessage(context, Localizer.get('first_send'));
        return;
      }
    }

    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image == null) return;

    final imageFile = File(image.path);
    String aboba = await Get.to(
      () => MyMapView(
        day: _days[_today - 1],
        imageFile: imageFile,
        start: start,
      ),
    );
    if (aboba == 'update') {
      asyncInitState();
    }
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
            child: getText(
                _data.isEmpty ? Localizer.get('company_name') : _data['name'])),
        getText(SERVER_TIME,
            align: TextAlign.center, fontWeight: FontWeight.bold),
        Expanded(
            child: getText(CURRENT_YEARMONTH,
                bgColor: todayColor,
                fontColor: Colors.white,
                align: TextAlign.center)),
        getText("Қаз / Рус / Eng",
            align: TextAlign.center,
            onPressed: () => setState(() {
                  Localizer.changeLanguage();
                  updateMonthYear();
                })),
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
              getText(_data.isEmpty
                  ? Localizer.get('department')
                  : _data['department']),
              SizedBox(height: 4.h),
              getText(
                  _data.isEmpty ? Localizer.get('name') : _data['worker_name'],
                  bgColor: brownColor,
                  fontColor: Colors.white),
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
                    text: Localizer.get('make_photo'),
                    onTap: onMakeSelfiePressed,
                  );
                } else {
                  return getPhoto(imagePath: _days[_today - 1]['start_photo']);
                }
              }(),
              SizedBox(height: 4.h),
              getTextWithTime(
                  Localizer.get('appearance'), getCurrentDayTime("start_time")),
              SizedBox(height: 4.h),
              getTwoTextOneLine(
                Localizer.get('photo_from_place'),
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
                if (_days.isEmpty ||
                    _days[_today - 1]['end_photo'] == null &&
                        _today == _initToday) {
                  return getPhoto(
                    text: Localizer.get('make_photo'),
                    onTap: () => onMakeSelfiePressed(start: false),
                  );
                } else {
                  return getPhoto(imagePath: _days[_today - 1]['end_photo']);
                }
              }(),
              SizedBox(height: 4.h),
              getTextWithTime(
                  Localizer.get('leave'), getCurrentDayTime("end_time")),
              SizedBox(height: 4.h),
              getTwoTextOneLine(
                Localizer.get('photo_from_place'),
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
                Text(Localizer.get('non_working_day'))
              ]),
              SizedBox(height: 4.h),
              Row(children: [
                getRect(noAssignmentColor),
                Text(Localizer.get('no_ass'))
              ]),
              SizedBox(height: 4.h),
              Row(children: [getRect(onTimeColor), Text(Localizer.get('on_'))]),
              SizedBox(height: 4.h),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        getTextSmaller(Localizer.get('prize')),
                        SizedBox(height: 4.h),
                        getTextSmaller(Localizer.get('beg_off_text')),
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
              Row(children: [getRect(lateColor), Text(Localizer.get('late'))]),
              SizedBox(height: 4.h),
              Row(children: [getRect(truancyColor), Text(Localizer.get('tr'))]),
              SizedBox(height: 4.h),
              Row(children: [
                getRect(validReasonColor),
                Text(Localizer.get('valid_reason'))
              ]),
              SizedBox(height: 4.h),
              Row(children: [
                getRect(begOffColor),
                Text(Localizer.get('beg_off_text'))
              ]),
              SizedBox(height: 4.h),
              Row(children: [
                getRect(confirmationColor, confirmation: true),
                Text(Localizer.get('con'))
              ]),
              SizedBox(height: 4.h),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        getTextSmaller(Localizer.get('min_p')),
                        SizedBox(height: 4.h),
                        getTextSmaller(Localizer.get('tru_min')),
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
                Localizer.get('sum_month'),
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
    String ans2 = '';
    if (key == 'start_time') {
      print(_data);
      var _hour = int.parse(ans.split(':')[0]);
      var _minute = int.parse(ans.split(':')[1]);

      var _d_hour = int.parse((_data['postponement_minute'] ~/ 60).toString());
      var _hour2 = _hour + _d_hour;
      var _minute2 = _minute + _data['postponement_minute'] - 60 * _d_hour;
      var _d_hour2 = int.parse((_minute2 ~/ 60).toString());
      _hour2 += _d_hour2;
      _minute2 -= 60 * _d_hour2;
      ans2 = "${_hour2}:${_minute2 < 10 ? 0 : ""}$_minute2";

      _d_hour = int.parse((_data['before_minute'] ~/ 60).toString());
      _hour -= _d_hour;
      _minute -= int.parse((_data['before_minute'] - 60 * _d_hour).toString());

      if (_minute < 0){
        _minute += 60;
        _hour -= 1;
      }
      ans = "$_hour:${_minute < 10 ? 0 : ''}$_minute";
    } else {
      var _hour = int.parse(ans.split(':')[0]);
      var _minute = int.parse(ans.split(':')[1]);
      var _d_hour = int.parse((_data['after_minute'] ~/ 60).toString());
      var _hour2 = _d_hour + _hour;
      var _minute2 = int.parse((_data['after_minute'] - 60 * _d_hour).toString()) + _minute;
      var _d_hour2 = int.parse((_minute2 ~/ 60).toString());
      _hour2 += _d_hour2;
      _minute2 -= 60 * _d_hour2;
      ans2 = "$_hour2:${_minute2 < 10 ? 0 : ""}$_minute2";
      ans = "$_hour:${_minute < 10 ? 0 : ''}$_minute";
    }

    return '$ans/$ans2';
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
    var str =
        '$cnt ${Localizer.get('minute')} * ${_data['late_minute_price']} = ';
    return getText("$str${_days[_today - 1]['penalty_count_start']}",
        bgColor: getColorByStatus(_days[_today - 1]['worker_status_start']));
  }

  Color getBgColor(key) {
    return getColorByStatus(_days.isEmpty ? null : _days[_today - 1][key]);
  }
}
