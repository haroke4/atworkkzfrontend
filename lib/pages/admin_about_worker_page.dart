import 'dart:convert';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelance_order/prefabs/scaffold_messages.dart';
import 'package:freelance_order/utils/AdminBackendAPI.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import '../prefabs/admin_tools.dart';
import '../prefabs/colors.dart';
import '../prefabs/tools.dart';
import '../utils/LocalizerUtil.dart';
import 'admin_worker_photo_page.dart';

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
  int _year = 2022;
  int _month = 1;

  late final int _latePricePerMinute = widget.data['late_minute_price'];
  late int _today = widget.today;
  late final _days = widget.data['days'];
  late var _monthPenalty = widget.data['penalty_count'].toString();

  //for adjustment
  final _tempValues = {};
  var _pressedLine = "";
  var _result = '';
  bool _geopoint = false;
  bool _canEditDayStatus = false;
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    setState(() {
      _doingAdjustments = widget.doingAdjustments;
      _startController.text = getTimeForTempValues('start_time');
      _endController.text = getTimeForTempValues('end_time');
      _tempValues['geoposition'] = _days[_today - 1]['geoposition'];
      _tempValues['day_status'] = _days[_today - 1]['day_status'];
      _pressedLine = _days[_today - 1]['day_status'].toString();
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
      ServerTime.updateDateTime();
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
    if (_today - 1 > 0) {
      _today--;
      update_tempValues();
    }
  }

  void rightArrow() {
    if (_today + 1 <= widget.currMonthMaxDay) {
      _today++;
      update_tempValues();
    }
  }

  void update_tempValues() {
    setState(() {
      _geopoint = false;
      _canEditDayStatus = widget.today < _today ||
          (widget.today == 1 && _days[_today]['day_status'] == null);
      _startController.text = getTimeForTempValues('start_time');
      _endController.text = getTimeForTempValues('end_time');
      _tempValues['geoposition'] = _days[_today - 1]['geoposition'];
      _tempValues['day_status'] = _days[_today - 1]['day_status'];
      _pressedLine = _days[_today - 1]['day_status'].toString();
    });
  }

  // Adjustments buttons handlers

  void save() async {
    String? defaultGeopos;
    if (_today != 1) {
      defaultGeopos = _days[_today - 2]['geoposition'];
    }

    var startTime;
    var endTime;
    if (_startController.text == '__/__' || _startController.text.length != 5) {
      startTime = null;
    } else {
      startTime = '${_days[_today - 1]['date']} ${_startController.text}';
    }
    if (_endController.text == '__/__' || _endController.text.length != 5) {
      endTime = null;
    } else {
      endTime = '${_days[_today - 1]['date']} ${_endController.text}';
    }

    var response = await AdminBackendAPI.editDay(
        workerUsername: widget.workerUsername,
        dayId: _days[_today - 1]['id'],
        startTime: startTime,
        endTime: endTime,
        geoposition: _tempValues['geoposition'] ?? defaultGeopos,
        dayStatus: _tempValues['day_status'],
        updateWorkerPenalty: widget.today >= _today);

    var scaffoldMessage = "";
    if (response.statusCode == 200) {
      _result = 'update';
      var json = jsonDecode(response.body)['message'];
      setState(() {
        _days[_today - 1] = json;
        _monthPenalty = json['penalty_count'].toString();
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
    _tempValues['geoposition'] = "${p.latitude} ${p.longitude}";
    showScaffoldMessage(context, Localizer.get('loc_success'));
  }

  void selectGeoposition() async {
    if (!_geopoint) {
      return;
    }
    GeoPoint? p = await LocationPicker(
      context: context,
      isDismissible: true,
      title: Localizer.get('pick_geo'),
      textConfirmPicker: Localizer.get('pick'),
      textCancelPicker: Localizer.get('back'),
      initCurrentUserPosition: true,
      initZoom: 15,
    );
    if (p != null) {
      _tempValues['geoposition'] = "${p.latitude} ${p.longitude}";
      showScaffoldMessage(context, Localizer.get('loc_success'));
    }
  }

  void repeatButtonPressed() {
    if (_today - 1 > 0) {
      setState(() {
        // _today - 2 because _today - 1 = index in massiv of element so -2 prev
        _startController.text =
            getTimeForTempValues('start_time', day: _today - 2);
        _endController.text = getTimeForTempValues('end_time', day: _today - 2);
        _tempValues['geoposition'] = _days[_today - 2]['geoposition'];
        _tempValues['day_status'] = _days[_today - 2]['day_status'];
        _pressedLine = _days[_today - 2]['day_status'].toString();
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
        _result = 'update';
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
                    getFirstLineWidgets(90.w, constraints.maxWidth - 90.w * 2),
                    SizedBox(height: 8.h),
                    getSecondLineWidgets(90.w, constraints.maxWidth - 90.w * 2),
                    SizedBox(height: 8.h),
                    getThirdLineWidgets(90.w),
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
              ServerTime.getServerTimeWidget(),
              Expanded(
                  child: getText(ServerTime.yearMonth,
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
        getZhumystaKzText(),
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
              SizedBox(height: 8.h),
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

  Widget getThirdLineWidgets(width) {
    return IntrinsicHeight(
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
                          latePricePerMinute: _latePricePerMinute,
                          isStart: true,
                          date: _today,
                          time: getTime('start_time'))));
                    },
                  ),
                ),
                SizedBox(height: 8.h),
                getTextWithTime(
                    Localizer.get('appearance'), getTime('start_time')),
                SizedBox(height: 8.h),
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
                SizedBox(
                  height: 80.sp,
                  child: Row(
                    children: [
                      getArrowButton(
                        const Icon(Icons.arrow_back),
                        "back",
                        leftArrow,
                      ),
                      const Expanded(child: SizedBox()),
                      getArrowButton(
                        const Icon(Icons.arrow_forward),
                        "forw",
                        rightArrow,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                getMiddleInfoWidgets(),
                const Expanded(child: SizedBox()),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    getMainMenuButton(),
                    SizedBox(width: 4.w),
                    getGoBackButton(result: _result),
                  ],
                ),
                SizedBox(
                  height: 40.h,
                )
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            getRect(
              context,
              Colors.white,
              text: getValidatedDay(_today - 5),
              secText: getNameOfWeek(_today - 5),
            ),
            getRect(
              context,
              Colors.white,
              text: getValidatedDay(_today - 4),
              secText: getNameOfWeek(_today - 4),
            ),
            getRect(
              context,
              Colors.white,
              text: getValidatedDay(_today - 3),
              secText: getNameOfWeek(_today - 3),
            ),
            getRect(
              context,
              Colors.white,
              text: getValidatedDay(_today - 2),
              secText: getNameOfWeek(_today - 2),
            ),
            getRect(
              context,
              Colors.white,
              text: getValidatedDay(_today - 1),
              secText: getNameOfWeek(_today - 1),
            ),
            SizedBox(
              width: 104.h + 4.w,
              child: Text(
                "${_today}",
                style: TextStyle(
                  color: todayColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 30.sp,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            getRect(
              context,
              Colors.white,
              text: getValidatedDay(_today + 1),
              secText: getNameOfWeek(_today + 1),
            ),
            getRect(
              context,
              Colors.white,
              text: getValidatedDay(_today + 2),
              secText: getNameOfWeek(_today + 2),
            ),
            getRect(
              context,
              Colors.white,
              text: getValidatedDay(_today + 3),
              secText: getNameOfWeek(_today + 3),
            ),
            getRect(
              context,
              Colors.white,
              text: getValidatedDay(_today + 4),
              secText: getNameOfWeek(_today + 4),
            ),
            getRect(
              context,
              Colors.white,
              text: getValidatedDay(_today + 5),
              secText: getNameOfWeek(_today + 5),
            ),
          ],
        ),
        SizedBox(
          height: 8.h,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            getRectByDay(_today - 5, ws: _today - 5 <= widget.today),
            getRectByDay(_today - 4, ws: _today - 4 <= widget.today),
            getRectByDay(_today - 3, ws: _today - 3 <= widget.today),
            getRectByDay(_today - 2, ws: _today - 2 <= widget.today),
            getRectByDay(_today - 1, ws: _today - 1 <= widget.today),
            SizedBox(
              width: 104.h + 4.w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  getRectByDay(_today, ws: _today <= widget.today),
                  getRectByDay(_today,
                      start: false, ws: _today <= widget.today),
                ],
              ),
            ),
            getRectByDay(_today + 1, ws: _today + 1 <= widget.today),
            getRectByDay(_today + 2, ws: _today + 2 <= widget.today),
            getRectByDay(_today + 3, ws: _today + 3 <= widget.today),
            getRectByDay(_today + 4, ws: _today + 4 <= widget.today),
            getRectByDay(_today + 5, ws: _today + 5 <= widget.today),
          ],
        )
      ],
    );
  }

  Widget getMiddleInfoWidgets() {
    if (_doingAdjustments) {
      return Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                getSingleMiddleInfoWidget('valid_reason', r: false),
                SizedBox(height: 20.h),
                getSingleMiddleInfoWidget('beg_off_text', r: false)
              ],
            ),
          ),
          SizedBox(width: 5.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                getSingleMiddleInfoWidget('working_day',
                    canEditDayStatus: _canEditDayStatus),
                SizedBox(height: 20.h),
                getSingleMiddleInfoWidget('non_working_day',
                    canEditDayStatus: _canEditDayStatus),
                SizedBox(height: 20.h),
                Container(
                  padding: EdgeInsets.only(top: 3.h, bottom: 3.h),
                  child: Row(children: [
                    getGeopointButton(),
                    Text(
                      Localizer.get("geopoint"),
                      style: TextStyle(fontSize: 20.sp),
                    )
                  ]),
                ),
              ],
            ),
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
                  Text(
                    Localizer.get('sum_month'),
                    style: TextStyle(fontSize: 20.sp),
                  ),
                  SizedBox(width: 5.w),
                  Text(
                    _monthPenalty,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 15.h),
          Row(
            children: [
              const Expanded(child: SizedBox()),
              getConfirmationButton(day['confirmed_start'], 'confirmed_start'),
              const Expanded(child: SizedBox()),
              getConfirmationButton(day['confirmed_end'], 'confirmed_end'),
              const Expanded(child: SizedBox()),
            ],
          ),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }

  Widget getSingleMiddleInfoWidget(key, {canEditDayStatus = true, r = true}) {
    // r = reversed
    var colorByKey = {
      "non_working_day": nonWorkingDayColor,
      "working_day": workingDayColor,
      "valid_reason": validReasonColor,
      "beg_off_text": begOffColor,
    };
    return Container(
      color: _pressedLine == key ? Colors.black26 : bgColor,
      padding: EdgeInsets.only(top: 3.h, bottom: 3.h),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          r == true
              ? getRect(
                  context,
                  colorByKey[key]!,
                  onTap: () {
                    if (!canEditDayStatus) {
                      return;
                    }
                    _tempValues['day_status'] = key;
                    setState(() {
                      _pressedLine = key;
                    });
                  },
                )
              : const SizedBox(width: 0),
          Expanded(
            child: Text(
              Localizer.get(key),
              textAlign: r == true ? TextAlign.start : TextAlign.end,
              style: TextStyle(
                  color: canEditDayStatus ? Colors.black : Colors.black54,
                  fontSize: 20.sp),
            ),
          ),
          r != true
              ? getRect(
                  context,
                  colorByKey[key]!,
                  onTap: () {
                    if (!canEditDayStatus) {
                      return;
                    }
                    _tempValues['day_status'] = key;
                    setState(() {
                      _pressedLine = key;
                    });
                  },
                )
              : const SizedBox(),
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
            const Expanded(child: SizedBox()),
            const Expanded(child: SizedBox()),
            const Expanded(child: SizedBox()),
            const Expanded(child: SizedBox()),
            const Expanded(child: SizedBox()),
            Row(
              children: [
                Expanded(
                  child: getText(Localizer.get('appearance'),
                      align: TextAlign.center),
                ),
                Expanded(
                  child: getInputTimeField(_startController),
                )
              ],
            ),
            SizedBox(
              height: 8.h,
            ),
            Row(
              children: [
                Expanded(
                    child: getText(Localizer.get('leave'),
                        align: TextAlign.center)),
                Expanded(
                  child: getInputTimeField(_endController),
                )
              ],
            ),
            SizedBox(
              height: 8.h,
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
              height: 8.h,
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
              height: 8.h,
            ),
            const Expanded(child: SizedBox()),
            getSaveButton(save),
            SizedBox(
              height: 40.h,
            )
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
                      latePricePerMinute: _latePricePerMinute,
                      isStart: false,
                      date: _today,
                      time: getTime('end_time'))));
                },
              ),
            ),
            SizedBox(height: 8.h),
            getTextWithTime(Localizer.get('leave'), getTime('end_time')),
            SizedBox(height: 8.h),
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
      return "$cnt ${Localizer.get('minute')} * $_latePricePerMinute";
    }
    var cnt = _days[_today - 1]["late_minute_count"];
    return "$cnt ${Localizer.get('minute')} * $_latePricePerMinute";
  }

  String getPhotoTime(String key) {
    var time = _days[_today - 1][key];
    if (time == null) {
      return "__/__";
    }
    DateTime dateTime = DateTime.parse(time);
    DateFormat formatter = DateFormat('HH:mm');
    return formatter.format(dateTime);
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
      return getRect(context, noAssignmentColor);
    } else if (_days[day - 1] == null) {
      // day starts from 1 but indexes from 0
      return getRect(context, noAssignmentColor);
    }
    if (ws && start) {
      return getRect(
          context, getColorByStatus(_days[day - 1]['worker_status_start']),
          confirmation: _days[day - 1]['confirmed_start'] && day == _today);
    } else if (ws && !start) {
      return getRect(
        context,
        getColorByStatus(_days[day - 1]['worker_status_end']),
        confirmation: _days[day - 1]['confirmed_end'] && day == _today,
      );
    }
    return getRect(context, getColorByStatus(_days[day - 1]['day_status']));
  }

  String getTime(String key) {
    // get time for appear time widget
    // key = start_time or end_time
    if (_days.isEmpty) {
      return "__/__";
    }
    String? time = _days[_today - 1][key];
    if (time == null) {
      return "__/__";
    }
    DateTime dateTime = DateTime.parse(time);
    DateFormat formatter = DateFormat('HH:mm');
    if (key == 'start_time') {
      int beforeMinutes = widget.data['before_minute'];
      int postponementMinutes = widget.data['postponement_minute'];
      DateTime preTime = dateTime.subtract(Duration(minutes: beforeMinutes));
      DateTime afterTime = dateTime.add(Duration(minutes: postponementMinutes));
      return '${formatter.format(preTime)}/${formatter.format(afterTime)}';
    }
    int afterMinutes = widget.data['after_minute'];
    DateTime afterTime = dateTime.add(Duration(minutes: afterMinutes));
    return '${formatter.format(dateTime)}/${formatter.format(afterTime)}';
  }

  String getTimeForTempValues(String key, {int? day}) {
    // Time for tempValues (editing fields)
    // key = start_time or end_time
    day ??= _today - 1;

    String? time = _days[day][key];
    if (time == null) {
      return "__/__";
    }

    DateTime dateTime = DateTime.parse(time);
    DateFormat formatter = DateFormat('HH:mm');
    return formatter.format(dateTime);
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
      width: 48.h,
      height: 48.h,
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

  String getNameOfWeek(day) {
    return Localizer.get(DateFormat('EE').format(DateTime(_year, _month, day)));
  }
}
