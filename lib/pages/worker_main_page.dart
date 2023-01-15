import 'dart:convert';
import 'dart:io';
import 'package:freelance_order/utils/BackendAPI.dart';
import 'package:intl/intl.dart';
import 'package:freelance_order/prefabs/scaffold_messages.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelance_order/utils/WorkersBackendAPI.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../prefabs/colors.dart';
import '../prefabs/tools.dart';
import '../utils/LocalizerUtil.dart';
import 'map_page.dart';

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
      await ServerTime.updateDateTime();
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

  Future onMakeSelfiePressed({start = true}) async {
    var cameraStatus = await Permission.camera.status;
    if (!cameraStatus.isGranted) {
      await Permission.camera.request();
    }

    if (!THIS_MONTH_ACTIVE) {
      showScaffoldMessage(context, Localizer.get('atten'), time: 2);
      return;
    }
    if (_days[_today - 1]['geoposition'] == null) {
      showScaffoldMessage(context, Localizer.get('no_geo_pos'));
      return;
    }
    if (_days[_today - 1]['day_status'] != 'working_day') {
      showScaffoldMessage(context, Localizer.get('today_not_w_d'));
      return;
    }

    if (start) {
      if (_days[_today - 1]['start_time'] == null) {
        showScaffoldMessage(context, Localizer.get('no_appea_time'));
        return;
      }
      // Checking time
      await ServerTime.updateDateTime();

      //Checking if user in time duration
      var time = ServerTime.time.hour * 60 + ServerTime.time.minute;
      var a = _getHoursAndMinutesStart();
      if (a![0] * 60 + a[1] > time || time > a[2] * 60 + a[3]) {
        showScaffoldMessage(context, Localizer.get('photo_time_er'));
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

      //Checking if user in time duration
      var time = ServerTime.time.hour * 60 + ServerTime.time.minute;
      var a = _getHoursAndMinutesEnd();
      if (a![0] * 60 + a[1] > time || time > a[2] * 60 + a[3]) {
        showScaffoldMessage(context, Localizer.get('photo_time_er'));
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
        Expanded(
          child: ServerTime.getServerTimeWidget(adder: true),
        ),
        IntrinsicWidth(
          child: getText(ServerTime.yearMonth,
              bgColor: todayColor,
              fontColor: Colors.white,
              align: TextAlign.center,
              minWidth: 70.w),
        ),
        Expanded(child: getText("Atwork.kz", align: TextAlign.center)),
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
                "$_today",
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
        SizedBox(height: 3.h),
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
              Row(children: [
                getRect(todayColor),
                textM(Localizer.get('today_appear_leave'))
              ]),
              SizedBox(height: 4.h),
              Row(children: [
                getRect(workingDayColor),
                textM(Localizer.get('working_day'))
              ]),
              SizedBox(height: 4.h),
              Row(children: [
                getRect(nonWorkingDayColor),
                textM(Localizer.get('non_working_day'))
              ]),
              SizedBox(height: 4.h),
              Row(children: [
                getRect(noAssignmentColor),
                textM(Localizer.get('no_ass'))
              ]),
              SizedBox(height: 4.h),
              Row(children: [
                getRect(onTimeColor),
                textM(Localizer.get('on_'))
              ]),
              SizedBox(height: 4.h),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        getTextSmaller(Localizer.get('prize_w')),
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
              Row(children: [getRect(lateColor), textM(Localizer.get('late'))]),
              SizedBox(height: 4.h),
              Row(children: [
                getRect(truancyColor),
                textM(Localizer.get('tr'))
              ]),
              SizedBox(height: 4.h),
              Row(children: [
                getRect(validReasonColor),
                textM(Localizer.get('valid_reason'))
              ]),
              SizedBox(height: 4.h),
              Row(children: [
                getRect(begOffColor),
                textM(Localizer.get('beg_off_text'))
              ]),
              SizedBox(height: 4.h),
              Row(children: [
                getRect(confirmationColor, confirmation: true),
                textM(Localizer.get('con'))
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
                '${Localizer.get('itog')} ${ServerTime.yearMonth.split("/")[0]}:',
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
    String ans2 = '';

    if (ans == null) {
      return "__/__";
    }

    var a = key == 'start_time'
        ? _getHoursAndMinutesStart()
        : _getHoursAndMinutesEnd();

    ans = "${a![0]}:${a[1] < 10 ? 0 : ''}${a[1]}";
    ans2 = "${a[2]}:${a[3] < 10 ? 0 : ''}${a[3]}";

    return '$ans/$ans2';
  }

  List<int>? _getHoursAndMinutesStart() {
    // Returns time duration for start of day

    String? time = _days[_today - 1]['start_time'];

    if (time == null) {
      return null;
    }
    DateTime dateTime = DateTime.parse(time);
    int beforeMinutes = _data['before_minute'];
    int postponementMinutes = _data['postponement_minute'];
    DateTime preTime = dateTime.subtract(Duration(minutes: beforeMinutes));
    DateTime afterTime = dateTime.add(Duration(minutes: postponementMinutes));

    return [preTime.hour, preTime.minute, afterTime.hour, afterTime.minute];
  }

  List<int>? _getHoursAndMinutesEnd() {
    String? time = _days[_today - 1]['end_time'];
    if (time == null) {
      return null;
    }

    DateTime dateTime = DateTime.parse(time);
    int afterMinutes = _data['after_minute'];
    DateTime afterTime = dateTime.add(Duration(minutes: afterMinutes));

    return [dateTime.hour, dateTime.minute, afterTime.hour, afterTime.minute];
  }

  String getPhotoTime(String key) {
    if (_days.isEmpty) {
      return "__/__";
    }

    var time = _days[_today - 1][key];
    if (time == null) {
      return "__/__";
    }

    DateTime dateTime = DateTime.parse(time);
    DateFormat formatter = DateFormat('HH:mm');
    return formatter.format(dateTime);
  }

  void leftArrow() {
    if (_today - 1 > 0) {
      setState(() {
        _today -= 1;
      });
    }
  }

  void rightArrow() {
    if (_today + 1 <= _currMonthMaxDay) {
      setState(() {
        _today++;
      });
    }
  }

  String getSystemTime() {
    var now = DateTime.now();
    return DateFormat("H:m:s").format(now);
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

  Widget textM(String text) {
    // Text for midle info widgets
    return Expanded(
      child: Text(
        text,
        overflow: TextOverflow.fade,
        maxLines: 1,
        softWrap: false,
      ),
    );
  }
}
