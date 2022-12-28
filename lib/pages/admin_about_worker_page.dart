import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelance_order/prefabs/scaffold_messages.dart';
import 'package:freelance_order/utils/AdminBackendAPI.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../prefabs/admin_tools.dart';
import '../prefabs/colors.dart';
import '../prefabs/tools.dart';
import '../utils/LocalizerUtil.dart';
import 'admin_main_page.dart';
import 'admin_worker_photo_page.dart';
import 'assign_data_page.dart';

class AdminAboutWorkerPage extends StatefulWidget {
  final name;
  final workerUsername;
  final today;
  final currMonthMaxDay;
  final data;
  final prevWorkerData;

  const AdminAboutWorkerPage(
      {super.key,
      required this.name,
      required this.workerUsername,
      required this.today,
      required this.currMonthMaxDay,
      required this.data,
      required this.prevWorkerData});

  @override
  State<AdminAboutWorkerPage> createState() => _AdminAboutWorkerPageState();
}

class _AdminAboutWorkerPageState extends State<AdminAboutWorkerPage> {
  bool _doingAdjustments = false;
  late int latePricePerMinute = widget.data['late_minute_price'];
  late int _today = widget.today;
  late final _days = widget.data['days'];
  late var _monthPenalty = widget.data['penalty_count'].toString();

  //for adjustment
  var tempValues = {};
  var _pressedLine = "";
  var _result = '';

  @override
  void initState() {
    super.initState();
    updateTime();
    setState(() {
      tempValues['start_time'] = getCurrentDayTimeForTemp('start_time');
      tempValues['end_time'] = getCurrentDayTimeForTemp('end_time');
      tempValues['geoposition'] = _days[_today - 1]['geoposition'];
      tempValues['day_status'] = _days[_today - 1]['day_status'];
      _pressedLine = _days[_today - 1]['day_status'].toString();
    });
  }

  void updateTime() async {
    var sTime = await getServerTime();
    setState(() {
      SERVER_TIME = sTime;
    });
  }

  void onAdjustmentsPressed() {
    setState(() {
      _doingAdjustments = !_doingAdjustments;
    });
  }

  Future<void> update() async {
    var scaffoldMessage = '';
    var response = await AdminBackendAPI.editDay(
        workerUsername: widget.workerUsername, dayId: _days[_today - 1]['id']);
    var json = jsonDecode(response.body);
    if (response.statusCode == 200) {
      updateTime();
      setState(() {
        _days[_today - 1] = json['message'];
      });
      scaffoldMessage = Localizer.get('success');
    } else {
      scaffoldMessage = json;
    }
    showScaffoldMessage(context, scaffoldMessage);
  }

  void onButtonConfirmButtonPressed(String data) async {
    _result = 'update';
    showScaffoldMessage(context, Localizer.get('processing'));
    var scaffoldMessage = '';
    var response;
    if (data == 'confirmed_start') {
      if (_days[_today - 1]['start_photo'] != null || widget.today > _today) {
        response = await AdminBackendAPI.editDay(
            workerUsername: widget.workerUsername,
            dayId: _days[_today - 1]['id'],
            confirmedStart: true);
      } else {
        scaffoldMessage = Localizer.get('cant_confirm_worker');
      }
    } else {
      if (_days[_today - 1]['end_photo'] != null || widget.today > _today) {
        response = await AdminBackendAPI.editDay(
          workerUsername: widget.workerUsername,
          dayId: _days[_today - 1]['id'],
          confirmedEnd: true,
        );
      } else {
        scaffoldMessage = Localizer.get('cant_confirm_worker');
      }
    }
    if (response != null) {
      if (response.statusCode == 200) {
        updateTime();
        setState(() {
          _days[_today - 1] = jsonDecode(response.body)['message'];
        });
        scaffoldMessage = Localizer.get('success');
      } else {
        scaffoldMessage = (jsonDecode(response.body)['message']).toString();
      }
    }
    showScaffoldMessage(context, scaffoldMessage);
  }

  void leftArrow() {
    updateTime();
    if (_today - 1 > 0) {
      setState(() {
        _today -= 1;
        tempValues['start_time'] = getCurrentDayTimeForTemp('start_time');
        tempValues['end_time'] = getCurrentDayTimeForTemp('end_time');
        tempValues['geoposition'] = _days[_today - 1]['geoposition'];
        tempValues['day_status'] = _days[_today - 1]['day_status'];
        _pressedLine = _days[_today - 1]['day_status'].toString();
      });
    }
  }

  void rightArrow() {
    updateTime();
    if (_today + 1 <= widget.currMonthMaxDay) {
      setState(() {
        _today++;
        tempValues['start_time'] = getCurrentDayTimeForTemp('start_time');
        tempValues['end_time'] = getCurrentDayTimeForTemp('end_time');
        tempValues['geoposition'] = _days[_today - 1]['geoposition'];
        tempValues['day_status'] = _days[_today - 1]['day_status'];
        _pressedLine = _days[_today - 1]['day_status'].toString();
      });
    }
  }

  // Adjustments buttons handlers
  void _changeField(String key, String label) async {
    String? x = await Get.to(() => AssignDataPage(
          text: label,
          inputtingTime: true,
        ));
    if (x != null && x != "") {
      setState(() {
        tempValues[key] = x;
      });
    }
  }

  void save() async {
    var response = await AdminBackendAPI.editDay(
        workerUsername: widget.workerUsername,
        dayId: _days[_today - 1]['id'],
        startTime: tempValues['start_time'],
        endTime: tempValues['end_time'],
        geoposition: tempValues['geoposition'],
        dayStatus: tempValues['day_status'],
        updateWorkerPenalty: widget.today >= _today,
        today: widget.today == _today);
    var scaffoldMessage = "";
    if (response.statusCode == 200) {
      _result = 'update';
      updateTime();
      var _json = jsonDecode(response.body)['message'];
      setState(() {
        _days[_today - 1] = _json;
        _monthPenalty = _json['penalty_count'].toString();
      });
      scaffoldMessage = Localizer.get('success');
    } else {
      scaffoldMessage = (jsonDecode(response.body)['message']).toString();
    }
    showScaffoldMessage(context, scaffoldMessage);
  }

  void selectGeoposition() async {
    GeoPoint? p = await showSimplePickerLocation(
      context: context,
      isDismissible: true,
      title: Localizer.get('pick_geo'),
      textConfirmPicker: Localizer.get('pick'),
      textCancelPicker: Localizer.get('back'),
      initCurrentUserPosition: true,
      initZoom: 17,
    );
    if (p != null) {
      tempValues['geoposition'] = "${p.latitude} ${p.longitude}";
    }
  }

  void repeatButtonPressed() {
    if (_today - 1 > 0) {
      setState(() {
        // _today - 2 because _today - 1 = index in massiv of element so -2 prev
        tempValues['start_time'] = _days[_today - 2]['start_time'];
        tempValues['end_time'] = _days[_today - 2]['end_time'];
        tempValues['geoposition'] = _days[_today - 2]['geoposition'];
        tempValues['day_status'] = _days[_today - 2]['day_status'];
        _pressedLine = _days[_today - 2]['day_status'];
      });
    } else {
      showScaffoldMessage(context, Localizer.get('first_day_of_month'));
    }
  }

  void copyButtonPressed() async {
    if (widget.prevWorkerData.isEmpty) {
      showScaffoldMessage(context, Localizer.get('first_worker_in_list'));
      return;
    }
    final days = widget.prevWorkerData['last_month']['days'];
    for (int i = _today + 1; i <= widget.currMonthMaxDay; i++) {
      var response = await AdminBackendAPI.editDay(
        workerUsername: widget.workerUsername,
        dayId: _days[i - 1]['id'],
        startTime: days[i - 1]['start_time'],
        endTime: days[i - 1]['end_time'],
        geoposition: days[i - 1]['geoposition'],
        dayStatus: days[i - 1]['day_status'],
        updateWorkerPenalty: false,
      );
      if (response.statusCode == 200) {
        updateTime();
        setState(() {
          _days[i - 1] = jsonDecode(response.body)['message'];
        });
      } else {
        showScaffoldMessage(context,
            "${Localizer.get('error_on_date')} ${_days[i - 1]['date']}: ${jsonDecode(response.body)['message']}");
      }
    }
    showScaffoldMessage(context, Localizer.get('success'));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, BoxConstraints constraints) {
      return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: update,
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
        SizedBox(width: width, child: getText(widget.data['company_name'])),
        getText(SERVER_TIME,
            align: TextAlign.center, fontWeight: FontWeight.bold),
        Expanded(
            child: getText(CURRENT_YEARMONTH,
                bgColor: todayColor,
                fontColor: Colors.white,
                align: TextAlign.center)),
        getText(
          Localizer.get('adjustments'),
          align: TextAlign.center,
          onPressed: onAdjustmentsPressed,
          bgColor: _doingAdjustments ? brownColor : Colors.white,
        ),
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
              getText(widget.data['department']),
              SizedBox(height: 4.h),
              getText(widget.name,
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
              getPhoto(
                imagePath: _days[_today - 1]['start_photo'],
                onTap: () {
                  Get.to(() => (AdminWorkerPhotoPage(
                        name: widget.name,
                        day: _days[_today - 1],
                        companyName: widget.data['company_name'],
                        department: widget.data['department'],
                        monthPenalty: _monthPenalty,
                        latePricePerMinute: latePricePerMinute,
                        isStart: true,
                      )));
                },
              ),
              SizedBox(height: 4.h),
              getTextWithTime(
                  Localizer.get('appearance'), getCurrentDayTime('start_time')),
              SizedBox(height: 4.h),
              getTwoTextOneLine(
                Localizer.get('photo_from_place'),
                getPhotoTime('start_photo_time'),
                bgColor:
                    getColorByStatus(_days[_today - 1]['worker_status_start']),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              getMiddleInfoWidgets(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  getMainMenuButton(),
                  SizedBox(width: 4.w),
                  getGoBackButton(result: _result),
                ],
              ),
            ],
          ),
        ),
        getLeftInfoWidgets(width),
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
                  getRectByDay(_today),
                  getRectByDay(_today, start: false),
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
    if (_doingAdjustments) {
      return Column(
        children: [
          Container(
            color: _pressedLine == 'working_day' ? Colors.black26 : bgColor,
            padding: EdgeInsets.only(top: 3.h, bottom: 3.h),
            child: Row(children: [
              getRect(
                workingDayColor,
                onTap: () {
                  tempValues['day_status'] = 'working_day';
                  setState(() {
                    _pressedLine = 'working_day';
                  });
                },
              ),
              Text(Localizer.get('working_day'))
            ]),
          ),
          SizedBox(height: 4.h),
          Container(
            color: _pressedLine == 'valid_reason' ? Colors.black26 : bgColor,
            padding: EdgeInsets.only(top: 3.h, bottom: 3.h),
            child: Row(children: [
              getRect(
                validReasonColor,
                onTap: () {
                  tempValues['day_status'] = 'valid_reason';
                  setState(() {
                    _pressedLine = 'valid_reason';
                  });
                },
              ),
              Text(Localizer.get('valid_reason'))
            ]),
          ),
          SizedBox(height: 4.h),
          Container(
            color: _pressedLine == 'non_working_day' ? Colors.black26 : bgColor,
            padding: EdgeInsets.only(top: 3.h, bottom: 3.h),
            child: Row(children: [
              getRect(
                nonWorkingDayColor,
                onTap: () {
                  tempValues['day_status'] = 'non_working_day';
                  setState(() {
                    _pressedLine = 'non_working_day';
                  });
                },
              ),
              Text(Localizer.get('non_working_day'))
            ]),
          ),
          SizedBox(height: 4.h),
          Container(
            color: _pressedLine == 'beg_off' ? Colors.black26 : bgColor,
            padding: EdgeInsets.only(top: 3.h, bottom: 3.h),
            child: Row(children: [
              getRect(
                begOffColor,
                onTap: () {
                  tempValues['day_status'] = 'beg_off';
                  setState(() {
                    _pressedLine = 'beg_off';
                  });
                },
              ),
              Text(Localizer.get("beg_off_text"))
            ]),
          ),
        ],
      );
    }
    var day = _days[_today - 1];
    return Container(
      margin: EdgeInsets.only(left: 10.w, right: 10.w),
      child: Column(
        children: [
          getTwoTextSeperated(getPenalty(), " ${day['penalty_count_start']} ",
              secondTextBgColor: getColorByStatus(day['worker_status_start']),
              firstExpanded: true),
          SizedBox(height: 4.h),
          getTwoTextSeperated(
              getPenalty(start: false), " ${day['penalty_count_end']} ",
              secondTextBgColor: getColorByStatus(day['worker_status_end']),
              firstExpanded: true),
          SizedBox(height: 4.h),
          getTwoTextOneLine(Localizer.get('sum_month'), _monthPenalty,
              bgColor: lateColor),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: getConfirmationButton(
                    day['confirmed_start'], 'confirmed_start'),
              ),
              Expanded(
                child: getConfirmationButton(
                    day['confirmed_end'], 'confirmed_end'),
              )
            ],
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget getLeftInfoWidgets(width) {
    if (_doingAdjustments) {
      return SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: getText(Localizer.get('appearance'),
                      align: TextAlign.center),
                ),
                Expanded(
                  child: getText(
                    tempValues['start_time'],
                    align: TextAlign.center,
                    onPressed: () => _changeField(
                      "start_time",
                      Localizer.get('appearance'),
                    ),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 4.h,
            ),
            Row(
              children: [
                Expanded(
                    child: getText(Localizer.get('leave'),
                        align: TextAlign.center)),
                Expanded(
                  child: getText(
                    tempValues['end_time'],
                    align: TextAlign.center,
                    onPressed: () =>
                        _changeField("end_time", Localizer.get('leave')),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 4.h,
            ),
            Row(
              children: [
                Expanded(
                    child: getText(Localizer.get('here'),
                        align: TextAlign.center, onPressed: selectGeoposition)),
                Expanded(
                    child: getText(Localizer.get('pick'),
                        align: TextAlign.center, onPressed: selectGeoposition))
              ],
            ),
            SizedBox(
              height: 4.h,
            ),
            Row(
              children: [
                Expanded(
                    child: getText(Localizer.get('repeat'),
                        align: TextAlign.center,
                        onPressed: repeatButtonPressed)),
                Expanded(
                    child: getText(Localizer.get('copy'),
                        align: TextAlign.center, onPressed: copyButtonPressed))
              ],
            ),
            SizedBox(
              height: 4.h,
            ),
            getText(Localizer.get('save'),
                align: TextAlign.center, onPressed: save),
          ],
        ),
      );
    } else {
      return SizedBox(
        width: width,
        child: Column(
          children: [
            getPhoto(
              imagePath: _days[_today - 1]['end_photo'],
              onTap: () {
                Get.to(() => (AdminWorkerPhotoPage(
                      name: widget.name,
                      day: _days[_today - 1],
                      department: widget.data['department'],
                      companyName: widget.data['company_name'],
                      monthPenalty: widget.data['penalty_count'],
                      latePricePerMinute: latePricePerMinute,
                      isStart: false,
                    )));
              },
            ),
            SizedBox(height: 4.h),
            getTextWithTime(
                Localizer.get('leave'), getCurrentDayTime('end_time')),
            SizedBox(height: 4.h),
            getTwoTextOneLine(
              Localizer.get('photo_from_place'),
              getPhotoTime('end_photo_time'),
              bgColor: getColorByStatus(_days[_today - 1]['worker_status_end']),
            ),
          ],
        ),
      );
    }
  }

  String getPenalty({start = true}) {
    if (start) {
      var cnt = _days[_today - 1]["late_minute_count"];
      return "$cnt ${Localizer.get('minute')} * $latePricePerMinute";
    }
    var cnt = _days[_today - 1]["late_minute_count"];
    return "$cnt ${Localizer.get('minute')} * $latePricePerMinute";
  }

  String getPhotoTime(String key) {
    var time = _days[_today - 1][key];
    if (time == null) {
      return "__/__";
    }
    final splitted = time.split(":");
    int hour = int.parse(splitted[0]);
    String minute = splitted[1];
    return "$hour:$minute";
  }

  String getValidatedDay(int curr) {
    if (0 < curr && curr <= widget.currMonthMaxDay) {
      return curr.toString();
    } else {
      return "";
    }
  }

  Widget getRectByDay(int day, {ws = true, start = true}) {
    // ws - is for worker status

    if (getValidatedDay(day) == '' || _days.isEmpty) {
      return getRect(noAssignmentColor);
    } else if (_days[day - 1] == null) {
      // day starts from 1 but indexes from 0
      return getRect(noAssignmentColor);
    }
    if (ws && start) {
      return getRect(
        getColorByStatus(_days[day - 1]['worker_status_start']),
      );
    } else if (ws && !start) {
      return getRect(getColorByStatus(_days[day - 1]['worker_status_end']));
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
    var _data = widget.data;
    if (key == 'start_time') {
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

      if (_minute < 0) {
        _minute += 60;
        _hour -= 1;
      }
      ans = "$_hour:${_minute < 10 ? 0 : ''}$_minute";
    } else {
      var _hour = int.parse(ans.split(':')[0]);
      var _minute = int.parse(ans.split(':')[1]);
      var _d_hour = int.parse((_data['after_minute'] ~/ 60).toString());
      var _hour2 = _d_hour + _hour;
      var _minute2 =
          int.parse((_data['after_minute'] - 60 * _d_hour).toString()) +
              _minute;
      var _d_hour2 = int.parse((_minute2 ~/ 60).toString());
      _hour2 += _d_hour2;
      _minute2 -= 60 * _d_hour2;

      ans2 = "$_hour2:${_minute2 < 10 ? 0 : ""}$_minute2";
      ans = "$_hour:${_minute < 10 ? 0 : ''}$_minute";
    }

    return '$ans/$ans2';
  }

  String getCurrentDayTimeForTemp(String key) {
    // key = start_time or end_time
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

  Widget getConfirmationButton(bool data, String arg) {
    if (data) {
      return getText(
        Localizer.get('confirmed'),
        align: TextAlign.center,
        bgColor: brownColor,
        fontColor: Colors.white,
        fontWeight: FontWeight.bold,
      );
    }
    return getText(Localizer.get('confirm'),
        align: TextAlign.center,
        bgColor: Colors.red,
        fontColor: Colors.white,
        fontWeight: FontWeight.bold,
        onPressed: () => onButtonConfirmButtonPressed(arg));
  }
}
