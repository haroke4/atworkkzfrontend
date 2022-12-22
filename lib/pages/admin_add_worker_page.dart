import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:freelance_order/pages/worker_main_page.dart';
import 'package:freelance_order/prefabs/tools.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'admin_main_page.dart';
import 'enter_sms_page.dart';
import '../prefabs/colors.dart';
import 'package:http/http.dart';

class AdminAddWorkerPage extends StatefulWidget {
  const AdminAddWorkerPage({super.key});

  @override
  State<AdminAddWorkerPage> createState() => _AdminAddWorkerPageState();
}

class _AdminAddWorkerPageState extends State<AdminAddWorkerPage> {
  String _workerInfo = "";

  void _addContactPressed() async {
    var status = await Permission.contacts.status;
    if (status.isGranted) {
      final contact = await FlutterContacts.openExternalPick();
      setState(() {
        _workerInfo = "${contact!.displayName}   ${contact.phones[0].number}";
      });
    } else {
      await Permission.contacts.request();
    }
  }

  void _yesPressed() async {
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, BoxConstraints constraints) {
      return Scaffold(
        backgroundColor: brownColor,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: constraints.maxWidth),
                SizedBox(height: 40.h),
                Text(
                  _workerInfo == ""
                      ? "Выберите работника"
                      : "Работник выбран верно?",
                  style: TextStyle(
                    color: Theme.of(context).primaryColorDark,
                    fontSize: 40.h,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_workerInfo != "") ...[
                  SizedBox(height: 5.h),
                  Text(
                    "Имя записан как в телефонной книжке",
                    style: TextStyle(
                      color: Theme.of(context).primaryColorDark,
                      fontSize: 25.h,
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ],
                SizedBox(height: 20.h),
                getText(
                  _workerInfo == "" ? " " * 50 : _workerInfo,
                  fontSize: 25.h,
                  fontWeight: FontWeight.bold,
                  onPressed: _addContactPressed,
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_workerInfo != "") ...[
                      getText(
                        "Да",
                        fontSize: 20.h,
                        fontWeight: FontWeight.bold,
                        onPressed: _yesPressed,
                      ),
                      getText(
                        "Нет",
                        fontSize: 20.h,
                        fontWeight: FontWeight.bold,
                        onPressed: _addContactPressed,
                      )
                    ],
                    getText("Назад",
                        fontSize: 20.h,
                        fontWeight: FontWeight.bold,
                        onPressed: () => Get.back()),
                  ],
                ),
                SizedBox(
                  height: 40.h,
                )
              ],
            ),
          ),
        ),
      );
    });
  }
}
