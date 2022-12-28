import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelance_order/pages/admin_general_page.dart';
import 'package:freelance_order/pages/enter_sms_page.dart';
import 'package:freelance_order/prefabs/scaffold_messages.dart';
import 'package:freelance_order/utils/AdminBackendAPI.dart';
import 'package:freelance_order/utils/BackendAPI.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../prefabs/colors.dart';
import '../prefabs/tools.dart';
import '../prefabs/admin_tools.dart';
import 'admin_add_worker_page.dart';
import 'enter_code_page.dart';
import 'map_page.dart';
import 'worker_main_page.dart';
import 'admin_about_worker_page.dart';

var CURRENT_YEARMONTH = "";
var SERVER_TIME = "__/__";

class AdminsMainPage extends StatefulWidget {
  const AdminsMainPage({super.key});

  @override
  State<AdminsMainPage> createState() => _AdminsMainPageState();
}

class _AdminsMainPageState extends State<AdminsMainPage> {
  var _updateDays = {}; //list of id of days which need sent to server
  var _data = {};

  bool _doingAdjustments = false;
  bool _loading = true;

  int _today = 0;
  int _currMonthMaxDay = 0;
  String _month = "";
  String _year = "";

  int _startIndex = 0;


  @override
  void initState() {
    super.initState();
    asyncInitState();
    initializeDateFormatting();
  }

  Future<void> asyncInitState() async {
    print('UPDATING');
    var response = await AdminBackendAPI.getWorkers();
    if (response.statusCode == 200) {
      updateMonthYear();
      updateTime();
      setState(() {
        _data = jsonDecode(utf8.decode(response.bodyBytes))['message'];
        print(_data);
        _loading = false;
        _today = _data['today'];
        var curr_date = DateTime.now();
        _currMonthMaxDay =
            DateTime(curr_date.year, curr_date.month + 1, 0).day.toInt();
      });
      showScaffoldMessage(context, "Загружено");
    } else {
      showScaffoldMessage(
          context, "Что то пошло не так... Перезапустите приложение");
    }
    return;
  }

  void updateTime() async {
    var sTime = await getServerTime();
    setState(() {
      SERVER_TIME = sTime;
    });
  }

  void updateMonthYear() {
    setState(() {
      String locale = Localizations
          .localeOf(context)
          .languageCode;
      DateTime now = DateTime.now();
      _month = DateFormat.MMM(locale).format(now);
      _year = DateFormat.y(locale).format(now);
      CURRENT_YEARMONTH = "$_month $_year";
    });
  }

  // Future<void> updateTime() async {
  //   await Future.delayed(Duration(seconds: 60 - _second));
  //   _second = 0;
  //   setState(() {
  //     _minute++;
  //     if (_minute == 60) {
  //       _hour++;
  //       _minute = 0;
  //       if (_hour == 24) {
  //         _hour = 0;
  //         _loading = true;
  //         showScaffoldMessage(context, "Загрузка...");
  //         asyncInitState();
  //       }
  //     }
  //   });
  //   _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
  //     setState(() {
  //       _minute++;
  //       if (_minute == 60) {
  //         _hour++;
  //         _minute = 0;
  //         if (_hour == 24) {
  //           _hour = 0;
  //           _loading = true;
  //           showScaffoldMessage(context, "Загрузка...");
  //           asyncInitState();
  //         }
  //       }
  //     });
  //   });
  // }

  void _onWorkerNamePressed(String displayName, String username, var data,
      var prevWorkerData) async {
    String? ans;
    if (username == "") {
      ans = await Get.to(() => const AdminAddWorkerPage());
    } else if (_doingAdjustments) {
      ans = await Get.to(
            () =>
            AdminAddWorkerPage(
              displayName: displayName,
              username: username,
            ),
      );
    } else {
      data['company_name'] = _data['name'];
      data['department'] = _data['department'];
      data['late_minute_price'] = _data['late_minute_price'];
      // print(da);
      // print(_data);
      ans = await Get.to(
            () =>
            AdminAboutWorkerPage(
              name: displayName,
              workerUsername: username,
              today: _today,
              currMonthMaxDay: _currMonthMaxDay,
              data: data,
              prevWorkerData: prevWorkerData,
            ),
      );
    }

    if (ans == 'update') {
      setState(() {
        _loading = true;
        _startIndex = 0;
      });
      showScaffoldMessage(context, "Загрузка...");
      await asyncInitState();
    }
  }

  void _adjustmentButtonPressed() async {
    if (_doingAdjustments) {
      // sending saved data to server!
      _updateDays.forEach((dayId, value) async {
        await AdminBackendAPI.editDay(
            workerUsername: value['username'],
            dayId: dayId,
            dayStatus: value['day_status']);
      });
      _updateDays.clear();
    }
    setState(() {
      _doingAdjustments = !_doingAdjustments;
    });
  }

  void onRectPressed(day, username) {
    if (!_doingAdjustments) {
      return;
    }
    setState(() {
      day['day_status'] = day['day_status'] == 'working_day'
          ? 'non_working_day'
          : 'working_day';
    });
    _updateDays[day['id']] = {
      'username': username,
      'day_status': day['day_status']
    };
  }

  void nextListOW() {
    //nextListOfWorkers
    if (_data['company_max_workers'] > _startIndex + 8) {
      setState(() {
        _startIndex += 8;
      });
      return;
    }

    showScaffoldMessage(context, "Конец списка работников");

  }

  void prevListOW() {
    //prevListOfWorkers
    if (_startIndex - 8 >= 0) {
      setState(() {
        _startIndex -= 8;
      });
      return;
    }
    showScaffoldMessage(context, "Начало списка работников");
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, BoxConstraints constraints) {
      return Scaffold(
        backgroundColor: Theme
            .of(context)
            .backgroundColor,
        body: AbsorbPointer(
          absorbing: _loading,
          child: SafeArea(
            child: RefreshIndicator(
              color: brownColor,
              onRefresh: asyncInitState,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(
                  margin: EdgeInsets.all(4.w),
                  width: constraints.maxWidth - 8.w,
                  child: Column(
                    children: [
                      getFirstLineWidgets(),
                      SizedBox(height: 4.h),
                      getSecondLineWidgets(),
                      SizedBox(height: 4.h),
                      ...getWorkersWidget(),
                      SizedBox(height: 4.h),
                      getBottomLineWidgets(),
                      SizedBox(height: 4.h),
                      FloatingActionButton(onPressed: () {}),
                      SizedBox(height: 4.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget getFirstLineWidgets() {
    return Row(
      children: [
        SizedBox(
            width: 80.w,
            child: getText(
              _data.isEmpty ? "Название фирмы" : _data['name'],
            )),
        getText(
          SERVER_TIME,
          align: TextAlign.center,
          fontWeight: FontWeight.bold,
        ),
        Expanded(
            child: getText(CURRENT_YEARMONTH,
                bgColor: todayColor,
                fontColor: Colors.white,
                align: TextAlign.center)),
        getText(
          "Установки",
          align: TextAlign.center,
          bgColor: _doingAdjustments ? brownColor : Colors.white,
          onPressed: _adjustmentButtonPressed,
        ),
        getText("Общие", align: TextAlign.center, onPressed: () {
          Get.to(
                () => (const EnterCodePage(nextPage: AdminGeneralPage())),
            arguments: [_data],
          );
        }),
        getText("Qaz / Rus / Eng", align: TextAlign.center),
      ],
    );
  }

  Widget getSecondLineWidgets() {
    return Row(
      children: [
        SizedBox(
          width: 80.w,
          child: getText(
            _data.isEmpty ? "Название отдела" : _data['department'],
          ),
        ),
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
        Expanded(
          child: getText("Результаты месяца",
              align: TextAlign.right,
              bgColor: bgColor,
              fontWeight: FontWeight.bold),
        )
      ],
    );
  }

  List<Widget> getWorkersWidget() {
    if (_loading) {
      return [];
    }
    List<Widget> a = [];
    if (_data == {}) {
      return [];
    }
    var workers = (_data['workers'] ?? []);
    workers = List.from(workers);
    var _length = workers.length;

    for (int i = 0; i <= _data['company_max_workers'] - _length; i++) {
      workers.add({"display_name": "", "username": ""});
    }
    for (int i = _startIndex; i < _startIndex + 8; i++) {
      final e = workers[i];
      if (i > 0) {
        a.add(getWorkerLineWidget(
          e['display_name'],
          e['username'],
          e['last_month'],
          workers[i - 1],
        ));
      } else {
        a.add(getWorkerLineWidget(
          e['display_name'],
          e['username'],
          e['last_month'],
          {},
        ));
      }
      a.add(SizedBox(height: 1.h));
    }

    return a;
  }

  Widget getWorkerLineWidget(String name, String username, var data, var prv) {
    final days = data == null ? null : data['days'];
    // int _workingDayCount=0;
    // int _truancyCount=0;
    // for (var day in days){
    //   if (day['day_status'] == 'working_day'){
    //     _workingDayCount++;
    //   }
    //   if (day['worker_status_start'] == 'truancy'){
    //     _truancyCount++;
    //   }
    // }
    // data['workind_day_count'] = 0
    var truancy_day_count = "0";
    var working_day_count = "0";
    var prize = _data['prize'];
    var prizeColor = Colors.white;

    if (data != null) {
      truancy_day_count = data['truancy_day_count'].toString();
      working_day_count = data['working_day_count'].toString();
      prize = (_data['prize'] - data['penalty_count']).toString();
      prizeColor = data['penalty_count'] == 0 ? onTimeColor : lateColor;
    }

    return Row(
      children: [
        SizedBox(
          width: 80.w,
          child: getText(name,
              onPressed: () => _onWorkerNamePressed(name, username, data, prv)),
        ),
        getRectByDay(_today - 5, days),
        getRectByDay(_today - 4, days),
        getRectByDay(_today - 3, days),
        getRectByDay(_today - 2, days),
        getRectByDay(_today - 1, days),
        SizedBox(
          width: 48.h + 12.w,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              getRectByDay(_today, days, showConfirm: true),
              getRectByDay(_today, days, start: false, showConfirm: true),
            ],
          ),
        ),
        getRectByDay(_today + 1, days,
            ws: false, onTap: () => onRectPressed(days[_today], username)),
        getRectByDay(_today + 2, days,
            ws: false, onTap: () => onRectPressed(days[_today + 1], username)),
        getRectByDay(_today + 3, days,
            ws: false, onTap: () => onRectPressed(days[_today + 2], username)),
        getRectByDay(_today + 4, days,
            ws: false, onTap: () => onRectPressed(days[_today + 3], username)),
        getRectByDay(_today + 5, days,
            ws: false, onTap: () => onRectPressed(days[_today + 4], username)),
        SizedBox(
          width: 7.w,
        ),
        getRect(
          workingDayColor,
          text: working_day_count,
          fontColor: Colors.white,
        ),
        getRect(
          truancyColor,
          text: truancy_day_count,
          fontColor: Colors.white,
        ),
        Expanded(
          child: getRect(prizeColor, text: prize.toString()),
        )
      ],
    );
  }


  Widget getBottomLineWidgets() {
    return Row(
      children: [
        getButton(prevListOW, Icons.arrow_upward_rounded, Icons.man_outlined),
        const Expanded(child: SizedBox()),
        getMainMenuButton(enabled: false),
        SizedBox(width: 4.w),
        getGoBackButton(),
        const Expanded(child: SizedBox()),
        getButton(nextListOW, Icons.man_outlined, Icons.arrow_downward_rounded),
      ],
    );
  }

  Widget getButton(onPressed, IconData firstIcon, IconData secondIcon) {
    return Container(
      width: 74.w,
      height: 32.h,
      margin: EdgeInsets.only(left: 3.w, right: 3.w),
      decoration: BoxDecoration(
        border: Border.all(color: greyColor),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              firstIcon,
              color: greyColor,
            ),
            Icon(
              secondIcon,
              color: greyColor,
            )
          ],
        ),
      ),
    );
  }

  String getValidatedDay(int curr) {
    if (0 < curr && curr <= _currMonthMaxDay) {
      return curr.toString();
    } else {
      return "";
    }
  }

  Widget getRectByDay(int day, days,
      {ws = true, start = true, showConfirm = false, Function? onTap}) {
    // ws - is for worker status

    if (days == null || getValidatedDay(day) == '' || days.isEmpty) {
      return getRect(noAssignmentColor);
    } else if (days[day - 1] == null) {
      return getRect(noAssignmentColor);
    }
    if (ws && start) {
      return getRect(
        getColorByStatus(days[day - 1]['worker_status_start']),
        confirmation: showConfirm && !days[day - 1]['confirmed_start'],
      );
    } else if (ws && !start) {
      return getRect(
        getColorByStatus(days[day - 1]['worker_status_end']),
        confirmation: showConfirm && !days[day - 1]['confirmed_end'],
      );
    }
    return getRect(getColorByStatus(days[day - 1]['day_status']), onTap: onTap);
  }
}