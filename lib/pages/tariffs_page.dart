import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:freelance_order/pages/admin_main_page.dart';
import 'package:freelance_order/prefabs/admin_tools.dart';
import 'package:freelance_order/prefabs/tools.dart';
import 'package:get/get.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';
import '../utils/LocalizerUtil.dart';
import 'worker_main_page.dart';
import '../prefabs/colors.dart';
import '../prefabs/appbar_prefab.dart';

class TariffsPage extends StatefulWidget {
  const TariffsPage({super.key});

  @override
  State<TariffsPage> createState() => _TariffsPageState();
}

class _TariffsPageState extends State<TariffsPage> {
  void buy(int price){
    print("Price: $price");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: brownColor,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: SafeArea(
          child: Container(
            margin: EdgeInsets.fromLTRB(40.w, 40.h, 40.w, 40.h),
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
          button(10000),
          button(15000),
          button(25000),
        ],
      ),
      TableRow(
        children: [
          text("16", big: true),
          button(15000),
          button(20000),
          button(35000),
        ],
      ),
      TableRow(
        children: [
          text("32", big: true),
          button(20000),
          button(30000),
          button(50000),
        ],
      ),
      TableRow(
        children: [
          text("80", big: true),
          button(40000),
          button(70000),
          button(120000),
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

  Widget button(int price) {
    //reverse _text
    String _text = price.toString();
    _text = _text.split('').reversed.join();
    _text =  _text.replaceAllMapped(RegExp(r".{3}"), (match) => "${match.group(0)} ",);
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
            buy(price);
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
