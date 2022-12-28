import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:freelance_order/pages/worker_main_page.dart';
import 'package:freelance_order/prefabs/scaffold_messages.dart';
import 'package:freelance_order/prefabs/tools.dart';
import 'package:freelance_order/utils/AdminBackendAPI.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'admin_main_page.dart';
import 'enter_sms_page.dart';
import '../prefabs/colors.dart';
import 'package:http/http.dart';

class AdminAddWorkerPage extends StatefulWidget {
  final String? displayName;
  final String? username;

  const AdminAddWorkerPage({super.key, this.displayName, this.username});

  @override
  State<AdminAddWorkerPage> createState() => _AdminAddWorkerPageState();
}

class _AdminAddWorkerPageState extends State<AdminAddWorkerPage> {
  String _workerInfo = "";
  bool deleteWorker = false;
  String _displayUsername = "";
  String _usernameWorker = "";

  @override
  void initState() {
    deleteWorker = widget.username != null && widget.displayName != null;
    super.initState();

    _workerInfo = widget.displayName != null
        ? "${widget.displayName} ${widget.username}"
        : ""; // split it into 2 parameter
  }

  void _addContactPressed() async {
    var status = await Permission.contacts.status;
    if (status.isGranted) {
      final contact = await FlutterContacts.openExternalPick();
      setState(() {
        _workerInfo = "${contact!.displayName} ${contact.phones[0].number}";
        _displayUsername = contact.displayName;
        _usernameWorker = contact.phones[0].number.replaceAll(" ", "");
        _usernameWorker = _usernameWorker.replaceAll("+", "");
        print(_usernameWorker);
      });
    } else {
      await Permission.contacts.request();
    }
  }

  void _yesPressed() async {
    showScaffoldMessage(context, "Обработка");
    var response;
    if (deleteWorker) {
      response  = await AdminBackendAPI.deleteWorker(
          workerUsername: widget.username.toString());
    } else {
      response = await AdminBackendAPI.registerWorker(
          displayName: _displayUsername, username: _usernameWorker);
    }
    if (response.statusCode == 200){
      Get.back(result: "update");
    }
    else{
      showScaffoldMessage(context, response.body);
    }
  }

  void _noPressed() async {
    if (deleteWorker) {
      Get.back();
    } else {
      _addContactPressed();
    }
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
                  deleteWorker ? "Удалить работника? " : "Выберите работника",
                  style: TextStyle(
                    color: Theme.of(context).primaryColorDark,
                    fontSize: 40.h,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!deleteWorker) ...[
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
                  onPressed: deleteWorker ? () {} : _addContactPressed,
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_workerInfo != '') ...[
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
                        onPressed: _noPressed,
                      )
                    ],
                    if (!deleteWorker) ...[
                      getText("Назад",
                          fontSize: 20.h,
                          fontWeight: FontWeight.bold,
                          onPressed: () => Get.back()),
                    ]
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
