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

  const AdminAboutWorkerPage({super.key,
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
  var tempValues = {};
  var tempValuesCopy = {};

  //for adjustments
  var _pressedLine = "";

  @override
  void initState() {
    super.initState();
    updateTime();
    setState(() {
      tempValues['start_time'] = getCurrentDayTime('start_time');
      tempValues['end_time'] = getCurrentDayTime('end_time');
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
      scaffoldMessage = "Успешно";
    } else {
      scaffoldMessage = json;
    }
    showScaffoldMessage(context, scaffoldMessage);
  }

  void onButtonConfirmButtonPressed(String data) async {
    showScaffoldMessage(context, "Обработка...");
    var scaffoldMessage = '';
    var response;
    if (data == 'confirmed_start') {
      if (_days[_today - 1]['start_photo'] != null || widget.today > _today) {
        response = await AdminBackendAPI.editDay(
            workerUsername: widget.workerUsername,
            dayId: _days[_today - 1]['id'],
            confirmedStart: true);
      } else {
        scaffoldMessage = "Нельзя подтвердить. Работник не загрузил фото";
      }
    } else {
      if (_days[_today - 1]['end_photo'] != null || widget.today > _today) {
        response = await AdminBackendAPI.editDay(
          workerUsername: widget.workerUsername,
          dayId: _days[_today - 1]['id'],
          confirmedEnd: true,
        );
      } else {
        scaffoldMessage = "Нельзя подтвердить. Работник не загрузил фото";
      }
    }
    if (response != null) {
      if (response.statusCode == 200) {
        updateTime();
        setState(() {
          _days[_today - 1] = jsonDecode(response.body)['message'];
        });
        scaffoldMessage = "Успешно";
      } else {
        scaffoldMessage = jsonDecode(response.body)['message'];
      }
    }
    showScaffoldMessage(context, scaffoldMessage);
  }

  void leftArrow() {
    updateTime();
    if (_today - 1 > 0) {
      setState(() {
        _today -= 1;
        tempValues['start_time'] = getCurrentDayTime('start_time');
        tempValues['end_time'] = getCurrentDayTime('end_time');
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
        tempValues['start_time'] = getCurrentDayTime('start_time');
        tempValues['end_time'] = getCurrentDayTime('end_time');
        tempValues['geoposition'] = _days[_today - 1]['geoposition'];
        tempValues['day_status'] = _days[_today - 1]['day_status'];
        _pressedLine = _days[_today - 1]['day_status'].toString();
      });
    }
  }

  // Adjustments buttons handlers
  void _changeField(String key, String label) async {
    String? x = await Get.to(() =>
        AssignDataPage(
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
    );
    var scaffoldMessage = "";
    if (response.statusCode == 200) {
      updateTime();
      setState(() {
        _days[_today - 1] = jsonDecode(response.body)['message'];
      });
      scaffoldMessage = "Успешно";
    } else {
      scaffoldMessage = jsonDecode(response.body)['message'];
    }
    showScaffoldMessage(context, scaffoldMessage);
  }

  void selectGeoposition() async {
    GeoPoint? p = await showSimplePickerLocation(
      context: context,
      isDismissible: true,
      title: "Выберите местоположение",
      textConfirmPicker: "Выбрать",
      textCancelPicker: "Назад",
      initCurrentUserPosition: true,
      initZoom: 15,
    );
    if (p != null) {
      print("${p.latitude} ${p.longitude}");
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
      showScaffoldMessage(context, "Это первый день месяца");
    }
  }

  void copyButtonPressed() async{
    if (widget.prevWorkerData.isEmpty){
      showScaffoldMessage(context, "Это первый работник в списке");
      return;
    }
    final days = widget.prevWorkerData['last_month']['days'];
    for (int i = _today + 1;i <= widget.currMonthMaxDay; i++){
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
        showScaffoldMessage(context, "Ошибка на дате ${_days[i-1]['date']}: ${jsonDecode(response.body)['message']}");
      }
    }
    showScaffoldMessage(context, "Успешно");
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, BoxConstraints constraints) {
      return Scaffold(
        backgroundColor: Theme
            .of(context)
            .backgroundColor,
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
          "Установки",
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
                  Get.to(() =>
                  (AdminWorkerPhotoPage(
                    name: widget.name,
                    day: _days[_today - 1],
                    companyName: widget.data['company_name'],
                    department: widget.data['department'],
                    monthPenalty: widget.data['penalty_count'],
                    latePricePerMinute: latePricePerMinute,
                    isStart: true,
                  )));
                },
              ),
              SizedBox(height: 4.h),
              getTextWithTime("Явка", getCurrentDayTime('start_time')),
              SizedBox(height: 4.h),
              getTwoTextOneLine(
                'Фото с точки',
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
                  getGoBackButton(),
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
              const Text("Рабочий день")
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
              const Text("Уважительная причина")
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
              const Text("Нерабочий день")
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
              const Text("Отпросился")
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
          SizedBox(height: 4.h),
          getTwoTextOneLine(
              "Сумма месяц", widget.data['penalty_count'].toString(),
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
                Expanded(child: getText("Явка", align: TextAlign.center)),
                Expanded(
                  child: getText(
                    tempValues['start_time'],
                    align: TextAlign.center,
                    onPressed: () => _changeField("start_time", "Явка"),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 4.h,
            ),
            Row(
              children: [
                Expanded(child: getText("Уход", align: TextAlign.center)),
                Expanded(
                  child: getText(
                    tempValues['end_time'],
                    align: TextAlign.center,
                    onPressed: () => _changeField("end_time", "Уход"),
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
                    child: getText("Здесь",
                        align: TextAlign.center, onPressed: selectGeoposition)),
                Expanded(
                    child: getText("Выбрать",
                        align: TextAlign.center, onPressed: selectGeoposition))
              ],
            ),
            SizedBox(
              height: 4.h,
            ),
            Row(
              children: [
                Expanded(
                    child: getText("Повтор",
                        align: TextAlign.center,
                        onPressed: repeatButtonPressed)),
                Expanded(
                    child: getText("Копия",
                        align: TextAlign.center, onPressed: copyButtonPressed))
              ],
            ),
            SizedBox(
              height: 4.h,
            ),
            getText("Сохранить", align: TextAlign.center, onPressed: save),
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
                Get.to(() =>
                (AdminWorkerPhotoPage(
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
            getTextWithTime("Уход", getCurrentDayTime('end_time')),
            SizedBox(height: 4.h),
            getTwoTextOneLine(
              'Фото с точки',
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
      return "$cnt мин * $latePricePerMinute";
    }
    var cnt = _days[_today - 1]["late_minute_count"];
    return "$cnt мин * $latePricePerMinute";
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
        "Подтвержден",
        align: TextAlign.center,
        bgColor: brownColor,
        fontColor: Colors.white,
        fontWeight: FontWeight.bold,
      );
    }
    return getText("Подтвердить",
        align: TextAlign.center,
        bgColor: Colors.red,
        fontColor: Colors.white,
        fontWeight: FontWeight.bold,
        onPressed: () => onButtonConfirmButtonPressed(arg));
  }
}
