import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelance_order/prefabs/scaffold_messages.dart';
import 'package:freelance_order/utils/AdminBackendAPI.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
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
  final doingAdjustments;

  const AdminAboutWorkerPage(
      {super.key,
      required this.name,
      required this.workerUsername,
      required this.today,
      required this.currMonthMaxDay,
      required this.data,
      required this.prevWorkerData,
      required this.doingAdjustments});

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
  bool _geopoint = false;
  bool _canEditDayStatus = false;
  TextEditingController startController = TextEditingController();
  TextEditingController leaveController = TextEditingController();

  @override
  void initState() {
    super.initState();
    updateDateTime();
    setState(() {
      _doingAdjustments = widget.doingAdjustments;
      startController.text = getCurrentDayTimeForTemp('start_time');
      leaveController.text = getCurrentDayTimeForTemp('end_time');
      tempValues['geoposition'] = _days[_today - 1]['geoposition'];
      tempValues['day_status'] = _days[_today - 1]['day_status'];
      _pressedLine = _days[_today - 1]['day_status'].toString();
    });
  }

  void updateDateTime() async {
    var dateTime = await getServerDateTime();
    setState(() {
      SERVER_TIME = dateTime["time"];
      CURRENT_YEARMONTH =
          "${Localizer.get(dateTime["month"])} / ${dateTime["year"]}";
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
      updateDateTime();
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
        updateDateTime();
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
    updateDateTime();
    if (_today - 1 > 0) {
      _today--;
      updateTempValues();
    }
  }

  void rightArrow() {
    updateDateTime();
    if (_today + 1 <= widget.currMonthMaxDay) {
      _today++;
      updateTempValues();
    }
  }

  void updateTempValues() {
    setState(() {
      _geopoint = false;
      _canEditDayStatus = widget.today < _today ||
          (widget.today == 1 && _days[_today]['day_status'] == null);
      startController.text = getCurrentDayTimeForTemp('start_time');
      leaveController.text = getCurrentDayTimeForTemp('end_time');
      if (_today - 2 < 0) {
        tempValues['geoposition'] = _days[_today - 1]['geoposition'];
      } else {
        tempValues['geoposition'] = _days[_today - 1]['geoposition'] ??
            _days[_today - 2]['geoposition'];
      }
      tempValues['day_status'] = _days[_today - 1]['day_status'];
      _pressedLine = _days[_today - 1]['day_status'].toString();
    });
  }

  // Adjustments buttons handlers

  void save() async {
    String? defaultGeopos;
    if (_today != 1) {
      defaultGeopos = _days[_today - 1]['geoposition'];
    }
    print(tempValues);
    print(tempValues['day_status']);
    var response = await AdminBackendAPI.editDay(
        workerUsername: widget.workerUsername,
        dayId: _days[_today - 1]['id'],
        startTime: startController.text,
        endTime: leaveController.text,
        geoposition: tempValues['geoposition'] ?? defaultGeopos,
        dayStatus: tempValues['day_status'],
        updateWorkerPenalty: widget.today >= _today);

    var scaffoldMessage = "";
    if (response.statusCode == 200) {
      _result = 'update';
      updateDateTime();
      var _json = jsonDecode(response.body)['message'];
      setState(() {
        _days[_today - 1] = _json;
        _monthPenalty = _json['penalty_count'].toString();
      });
      scaffoldMessage = Localizer.get('success');
    } else {
      var e = jsonDecode(response.body)['message'].toString();
      if (e.startsWith('error_78')) {
        scaffoldMessage = Localizer.get('edit_error');
      } else {
        scaffoldMessage = '${Localizer.get('error')} $e';
      }
    }
    showScaffoldMessage(context, scaffoldMessage);
  }

  Future<dynamic> hereGeoposition() async {
    if (!_geopoint) {
      return;
    }

    Location location = Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    LocationData p = await location.getLocation();
    tempValues['geoposition'] = "${p.latitude} ${p.longitude}";
    showScaffoldMessage(context, Localizer.get('loc_success'));
  }

  void selectGeoposition() async {
    if (!_geopoint) {
      return;
    }
    GeoPoint? p = await showSimplePickerLocation(
      context: context,
      isDismissible: true,
      title: Localizer.get('pick_geo'),
      textConfirmPicker: Localizer.get('pick'),
      textCancelPicker: Localizer.get('back'),
      initCurrentUserPosition: true,
      initZoom: 15,
    );
    if (p != null) {
      tempValues['geoposition'] = "${p.latitude} ${p.longitude}";
      showScaffoldMessage(context, Localizer.get('loc_success'));
    }
  }

  void repeatButtonPressed() {
    if (_today - 1 > 0) {
      setState(() {
        // _today - 2 because _today - 1 = index in massiv of element so -2 prev
        startController.text =
            getCurrentDayTimeForTemp('start_time', day: _today - 2);
        leaveController.text =
            getCurrentDayTimeForTemp('end_time', day: _today - 2);
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
        updateDateTime();
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
                    getFirstLineWidgets(95.w, constraints.maxWidth - 98.w * 2),
                    SizedBox(height: 4.h),
                    getSecondLineWidgets(95.w, constraints.maxWidth - 95.w * 2),
                    SizedBox(height: 4.h),
                    getThirdLineWidgets(95.w, constraints.maxHeight - 133.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget getFirstLineWidgets(width, width2) {
    return Row(
      children: [
        SizedBox(width: width, child: getText(widget.data['company_name'])),
        SizedBox(
          width: width2,
          child: Row(
            children: [
              getText(SERVER_TIME,
                  align: TextAlign.center,
                  fontWeight: FontWeight.bold,
                  minWidth: 40.w),
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
            ],
          ),
        ),
        const Expanded(child: SizedBox()),
        getText("Atwork.kz", align: TextAlign.center),
      ],
    );
  }

  Widget getSecondLineWidgets(width, width2) {
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
        SizedBox(
          width: width2,
          child: getDatesWidgets(),
        ),
      ],
    );
  }

  Widget getThirdLineWidgets(width, height) {
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: width,
            child: Column(
              children: [
                SizedBox(
                  width: width - 10.w,
                  child: getPhoto(
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
                          date: _today,
                          time: getCurrentDayTime('start_time'))));
                    },
                  ),
                ),
                SizedBox(height: 4.h),
                getTextWithTime(Localizer.get('appearance'),
                    getCurrentDayTime('start_time')),
                SizedBox(height: 4.h),
                getTwoTextOneLine(
                  Localizer.get('photo_from_place'),
                  getPhotoTime('start_photo_time'),
                  bgColor: getColorByStatus(
                      _days[_today - 1]['worker_status_start']),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    getArrowButton(
                        const Icon(Icons.arrow_back), "back", leftArrow),
                    const Expanded(child: SizedBox()),
                    getArrowButton(
                        const Icon(Icons.arrow_forward), "forw", rightArrow),
                  ],
                ),
                SizedBox(height: 10.h),
                getMiddleInfoWidgets(),
                Expanded(child: SizedBox()),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    getMainMenuButton(),
                    SizedBox(width: 4.w),
                    getGoBackButton(result: _result),
                  ],
                ),
                SizedBox(height: 10.h),
              ],
            ),
          ),
          getRightInfoWidgets(width),
        ],
      ),
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
        SizedBox(
          height: 4.h,
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
      return Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                color:
                    _pressedLine == 'valid_reason' ? Colors.black26 : bgColor,
                padding: EdgeInsets.only(top: 3.h, bottom: 3.h),
                child: Row(children: [
                  Text(Localizer.get('valid_reason')),
                  getRect(
                    validReasonColor,
                    onTap: () {
                      tempValues['day_status'] = 'valid_reason';
                      setState(() {
                        _pressedLine = 'valid_reason';
                      });
                    },
                  ),
                ]),
              ),
              SizedBox(height: 20.h),
              Container(
                color: _pressedLine == 'beg_off' ? Colors.black26 : bgColor,
                padding: EdgeInsets.only(top: 3.h, bottom: 3.h),
                child: Row(children: [
                  Text(Localizer.get("beg_off_text")),
                  getRect(
                    begOffColor,
                    onTap: () {
                      tempValues['day_status'] = 'beg_off';
                      setState(() {
                        _pressedLine = 'beg_off';
                      });
                    },
                  ),
                ]),
              ),
            ],
          ),
          SizedBox(width: 5.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: _pressedLine == 'working_day' ? Colors.black26 : bgColor,
                padding: EdgeInsets.only(top: 3.h, bottom: 3.h),
                child: Row(children: [
                  getRect(
                    workingDayColor,
                    onTap: () {
                      if (!_canEditDayStatus) {
                        return;
                      }
                      tempValues['day_status'] = 'working_day';
                      setState(() {
                        _pressedLine = 'working_day';
                      });
                    },
                  ),
                  Text(
                    Localizer.get('working_day'),
                    style: TextStyle(
                      color: _canEditDayStatus ? Colors.black : Colors.black54,
                    ),
                  )
                ]),
              ),
              SizedBox(height: 20.h),
              Container(
                color: _pressedLine == 'non_working_day'
                    ? Colors.black26
                    : bgColor,
                padding: EdgeInsets.only(top: 3.h, bottom: 3.h),
                child: Row(children: [
                  getRect(
                    nonWorkingDayColor,
                    onTap: () {
                      if (!_canEditDayStatus) {
                        return;
                      }
                      tempValues['day_status'] = 'non_working_day';
                      setState(() {
                        _pressedLine = 'non_working_day';
                      });
                    },
                  ),
                  Text(
                    Localizer.get('non_working_day'),
                    style: TextStyle(
                      color: _canEditDayStatus ? Colors.black : Colors.black54,
                    ),
                  )
                ]),
              ),
              SizedBox(height: 20.h),
              Container(
                padding: EdgeInsets.only(top: 3.h, bottom: 3.h),
                child: Row(children: [
                  getGeopointButton(),
                  Text(Localizer.get("geopoint"))
                ]),
              ),
            ],
          ),
        ],
      );
    }
    var day = _days[_today - 1];
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              getTwoTextSeperated(
                  getPenalty(), " ${day['penalty_count_start']} ",
                  secondTextBgColor:
                      getColorByStatus(day['worker_status_start'])),
              const Expanded(child: SizedBox()),
              getTwoTextSeperated(
                  getPenalty(start: false), " ${day['penalty_count_end']} ",
                  secondTextBgColor:
                      getColorByStatus(day['worker_status_end'])),
            ],
          ),
          SizedBox(height: 15.h),
          IntrinsicWidth(
            child: Container(
              margin: EdgeInsets.only(left: 3.w, right: 3.w),
              padding: EdgeInsets.fromLTRB(10.w, 4.w, 10.w, 4.w),
              decoration: BoxDecoration(
                color: lateColor,
              ),
              child: Row(
                children: [
                  Text(Localizer.get('sum_month')),
                  SizedBox(width: 5.w),
                  Text(
                    _monthPenalty,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  )
                ],
              ),
            ),
          ),
          SizedBox(height: 15.h),
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
          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  Widget getRightInfoWidgets(width) {
    if (_doingAdjustments) {
      return SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 45.h),
            Row(
              children: [
                Expanded(
                  child: getText(Localizer.get('appearance'),
                      align: TextAlign.center),
                ),
                Expanded(
                  child: getInputTimeField(startController),
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
                  child: getInputTimeField(leaveController),
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
                        align: TextAlign.center,
                        onPressed: hereGeoposition,
                        bgColor: _geopoint ? Colors.white : Colors.white70,
                        fontColor: _geopoint ? Colors.black : Colors.black54)),
                Expanded(
                    child: getText(Localizer.get('pick'),
                        align: TextAlign.center,
                        onPressed: selectGeoposition,
                        bgColor: _geopoint ? Colors.white : Colors.white70,
                        fontColor: _geopoint ? Colors.black : Colors.black54))
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
                    child: getText(
                  Localizer.get('copy'),
                  align: TextAlign.center,
                  onPressed: copyButtonPressed,
                ))
              ],
            ),
            SizedBox(
              height: 4.h,
            ),
            const Expanded(child: SizedBox()),
            getSaveButton(save),
            SizedBox(height: 10.h),
          ],
        ),
      );
    } else {
      return SizedBox(
        width: width,
        child: Column(
          children: [
            SizedBox(
              width: width - 10.w,
              child: getPhoto(
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
                      date: _today,
                      time: getCurrentDayTime('end_time'))));
                },
              ),
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

  String getCurrentDayTimeForTemp(String key, {int? day}) {
    // key = start_time or end_time
    day ??= _today - 1;

    String? ans = _days[day][key];
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

  Widget getGeopointButton() {
    return Container(
      width: 22.h,
      height: 22.h,
      margin: EdgeInsets.only(left: 1.5.w, right: 1.5.w),
      child: Material(
        color: Colors.white,
        child: InkWell(
          splashColor: Colors.black12,
          highlightColor: Colors.black12,
          onTap: () {
            setState(() {
              _geopoint = true;
            });
          },
          child: const Center(
              child: Icon(
            Icons.circle,
            size: 10,
          )),
        ),
      ),
    );
  }
}
