import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelance_order/pages/admin_general_page.dart';
import 'package:freelance_order/prefabs/scaffold_messages.dart';
import 'package:freelance_order/utils/AdminBackendAPI.dart';
import 'package:get/get.dart';
import '../prefabs/colors.dart';
import '../prefabs/tools.dart';
import 'package:intl/intl.dart';
import '../utils/LocalizerUtil.dart';
import 'admin_add_worker_page.dart';
import 'enter_code_page.dart';
import 'admin_about_worker_page.dart';

var THIS_MONTH_ACTIVE = false;

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
  int _month = 1;
  int _year = 2022;
  int _currMonthMaxDay = 0;
  double rectSize = 12.h + 6.w;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    _update();
    initializeDateFormatting();
  }

  Future<void> _update() async {
    var response = await AdminBackendAPI.getWorkers();
    if (response.statusCode == 200) {
      await ServerTime.updateDateTime();
      setState(() {
        _data = jsonDecode(utf8.decode(response.bodyBytes))['message'];

        THIS_MONTH_ACTIVE = _data['this_month_active'];
        if (!THIS_MONTH_ACTIVE) {
          if (_data['month_left'] == 0) {
            showScaffoldMessage(context, Localizer.get('ATTENTION_CANT'),
                time: 8);
          } else {
            showScaffoldMessage(context, Localizer.get('ATTENTION'), time: 8);
          }
        }
        _loading = false;
        _today = _data['today'];
        var curr_date = DateTime.now();
        _currMonthMaxDay =
            DateTime(curr_date.year, curr_date.month + 1, 0).day.toInt();
      });
      showScaffoldMessage(context, Localizer.get('loaded'));
    } else {
      showScaffoldMessage(context, Localizer.get('error_restart_app'));
    }
    return;
  }

  void _onWorkerNamePressed(
      String displayName, String username, var data, var prevWorkerData,
      {longPress = false}) async {
    String? ans;

    if (longPress && _doingAdjustments) {
      if (username == "") {
        ans = await Get.to(() => const AdminAddWorkerPage());
      } else {
        ans = await Get.to(
          () => AdminAddWorkerPage(
            displayName: displayName,
            username: username,
          ),
        );
      }
    } else {
      if (!THIS_MONTH_ACTIVE) {
        showScaffoldMessage(context, Localizer.get('atten'), time: 2);
        return;
      }
      if (data == null) {
        return;
      }
      data['postponement_minute'] = _data['postponement_minute'];
      data['before_minute'] = _data['before_minute'];
      data['after_minute'] = _data['after_minute'];
      data['company_name'] = _data['name'];
      data['department'] = _data['department'];
      data['late_minute_price'] = _data['late_minute_price'];

      ans = await Get.to(
        () => AdminAboutWorkerPage(
          name: displayName,
          workerUsername: username,
          today: _today,
          currMonthMaxDay: _currMonthMaxDay,
          data: data,
          prevWorkerData: prevWorkerData,
          doingAdjustments: _doingAdjustments,
        ),
      );
    }

    if (ans == 'update') {
      setState(() {
        _loading = true;
      });
      showScaffoldMessage(context, Localizer.get('loading'));
      await _update();
    }
  }

  void _adjustmentButtonPressed() async {
    if (_doingAdjustments) {
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, BoxConstraints constraints) {
      return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: AbsorbPointer(
          absorbing: _loading,
          child: SafeArea(
            child: RefreshIndicator(
              color: brownColor,
              onRefresh: _update,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(
                  margin: EdgeInsets.all(4.w),
                  width: constraints.maxWidth - 8.w,
                  child: Column(
                    children: [
                      getFirstLineWidgets(),
                      SizedBox(height: 8.h),
                      getSecondLineWidgets(),
                      SizedBox(height: 8.h),
                      ...getWorkersWidget(),
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
            width: 92.w,
            child: getText(
              _data.isEmpty ? Localizer.get('company_name') : _data['name'],
            )),
        ServerTime.getServerTimeWidget(adder: true),
        Expanded(
          child: getText(
            ServerTime.yearMonth,
            bgColor: todayColor,
            fontColor: Colors.white,
            align: TextAlign.center,
            fontWeight: FontWeight.bold,
          ),
        ),
        getText(
          Localizer.get('adjustments'),
          align: TextAlign.center,
          bgColor: _doingAdjustments ? brownColor : Colors.white,
          onPressed: _adjustmentButtonPressed,
        ),
        getText(Localizer.get('general'), align: TextAlign.center,
            onPressed: () {
          Get.to(
            () => (EnterCodePage(nextPage: const AdminGeneralPage())),
            arguments: [_data],
          );
        }),
      ],
    );
  }

  Widget getSecondLineWidgets() {
    return Row(
      children: [
        SizedBox(
          width: 92.w,
          child: getText(
            _data.isEmpty ? Localizer.get('department') : _data['department'],
          ),
        ),
        SizedBox(
          width: 2.w,
        ),
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
            "$_today",
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
        Expanded(
          child: getText(Localizer.get('month_results'),
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
    if (_data == {}) {
      return [];
    }
    List<Widget> a = [];

    var workers = (_data['workers'] ?? []);
    workers = List.from(workers);
    var _length = workers.length;

    for (int i = 0; i < _data['company_max_workers'] - _length; i++) {
      workers.add({"display_name": "", "username": ""});
    }
    for (int i = 0; i < workers.length; i++) {
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
      a.add(SizedBox(height: 4.h));
    }

    return a;
  }

  Widget getWorkerLineWidget(String name, String username, var data, var prv) {
    final days = data == null ? null : data['days'];

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
          width: 92.w,
          child: getText(name,
              onPressed: () => _onWorkerNamePressed(name, username, data, prv),
              onLongPress: () => _onWorkerNamePressed(name, username, data, prv,
                  longPress: true)),
        ),
        SizedBox(
          width: 2.w,
        ),
        getRectByDay(_today - 5, days),
        getRectByDay(_today - 4, days),
        getRectByDay(_today - 3, days),
        getRectByDay(_today - 2, days),
        getRectByDay(_today - 1, days),
        SizedBox(
          width: 104.h + 4.w,
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
          width: 2.w,
        ),
        getRect(context, workingDayColor,
            text: working_day_count, fontColor: Colors.white),
        getRect(context, truancyColor,
            text: truancy_day_count, fontColor: Colors.white),
        Expanded(
          child: getRect(context, prizeColor, text: prize.toString()),
        )
      ],
    );
  }

  Widget getButton(onPressed, Image image) {
    return Container(
      width: 90.w,
      height: 32.h,
      margin: EdgeInsets.only(left: 3.w, right: 3.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: greyColor),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: InkWell(
          onTap: onPressed,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          child: image),
    );
  }

  String getValidatedDay(int curr) {
    if (0 < curr && curr <= _currMonthMaxDay) {
      return curr.toString();
    } else {
      return "";
    }
  }

  Widget getRectByDay(
    int day,
    days, {
    ws = true,
    start = true,
    showConfirm = false,
    Function? onTap,
  }) {
    // ws - is for worker status

    if (days == null || getValidatedDay(day) == '' || days.isEmpty) {
      return getRect(context, noAssignmentColor);
    } else if (days[day - 1] == null) {
      return getRect(context, noAssignmentColor);
    }
    if (ws && start) {
      return getRect(
          context, getColorByStatus(days[day - 1]['worker_status_start']),
          confirmation: showConfirm && !days[day - 1]['confirmed_start']);
    } else if (ws && !start) {
      return getRect(
          context, getColorByStatus(days[day - 1]['worker_status_end']),
          confirmation: showConfirm && !days[day - 1]['confirmed_end']);
    }
    return getRect(context, getColorByStatus(days[day - 1]['day_status']),
        onTap: onTap);
  }

  String getNameOfWeek(day) {
    return Localizer.get(DateFormat('EE').format(DateTime(_year, _month, day)));
  }
}
