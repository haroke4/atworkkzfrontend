import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelance_order/prefabs/admin_tools.dart';
import 'package:freelance_order/prefabs/scaffold_messages.dart';
import 'package:freelance_order/utils/AdminBackendAPI.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/LocalizerUtil.dart';
import '../prefabs/colors.dart';

class TariffsPage extends StatefulWidget {
  final tariffsData;

  const TariffsPage({super.key, required this.tariffsData});

  @override
  State<TariffsPage> createState() => _TariffsPageState();
}

class _TariffsPageState extends State<TariffsPage> {
  void selectTariff(String tariff) async{
    showScaffoldMessage(context, Localizer.get('processing'));
    var response = await AdminBackendAPI.extendPlan(tariff);
    if(response.statusCode == 200){
      final jsonResponse = jsonDecode(response.body);
      final url = jsonResponse['message'];
      var aboba = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      await Future.delayed(Duration(milliseconds: 100));
      while (WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
        await Future.delayed(Duration(milliseconds: 100));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: brownColor,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: SafeArea(
          child: Container(
            margin: EdgeInsets.fromLTRB(20.w, 5.h, 20.w, 2.h),
            child: Column(
              children: [
                Text(
                  Localizer.get('choose_plan'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28.h,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10.h),
                Table(
                  border: TableBorder.all(
                    color: Colors.black,
                    width: 2.h,
                    style: BorderStyle.solid,
                  ),
                  children: [..._getTableElements()],
                ),
                SizedBox(height: 5.h),
                getGoBackButton(padding: 2.w)
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<TableRow> _getTableElements() {
    return [
      TableRow(
        children: [
          text(Localizer.get('amount_worker')),
          text(Localizer.get('3_m')),
          text(Localizer.get('6_m')),
          text(Localizer.get('12_m')),
        ],
      ),
      TableRow(
        children: [
          text("8", big: true),
          button('8worker_3month'),
          button('8worker_6month'),
          button('8worker_12month'),
        ],
      ),
      TableRow(
        children: [
          text("16", big: true),
          button('16worker_3month'),
          button('16worker_6month'),
          button('16worker_12month'),
        ],
      ),
      TableRow(
        children: [
          text("32", big: true),
          button('32worker_3month'),
          button('32worker_6month'),
          button('32worker_12month'),
        ],
      ),
      TableRow(
        children: [
          text("80", big: true),
          button('80worker_3month'),
          button('80worker_6month'),
          button('80worker_12month'),
        ],
      ),
    ];
  }

  Widget text(String _text, {bool big = false}) {
    return Padding(
      padding: EdgeInsets.only(top: 10.h, bottom: 10.h),
      child: Text(
        _text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: big ? 24.h : 18.h,
          fontWeight: big ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget button(String tariffName) {
    int price = widget.tariffsData
        .where((item) => item['name'] == tariffName)
        .toList()[0]['price'];

    //Modifying text
    String _text = price.toString();
    _text = _text.split('').reversed.join();
    _text = _text.replaceAllMapped(
      RegExp(r".{3}"),
      (match) => "${match.group(0)} ",
    );
    //reverse it again here
    _text = _text.split('').reversed.join();
    _text += " ₸";

    return Container(
      margin: EdgeInsets.all(8.h),
      child: Material(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          onTap: () {
            selectTariff(tariffName);
          },
          splashColor: Colors.black26,
          child: Padding(
            padding: EdgeInsets.only(left: 6.w, right: 6.w),
            child: text(_text),
          ),
        ),
      ),
    );
  }

  Widget spacer() {
    return SizedBox(height: 4.h);
  }
}
