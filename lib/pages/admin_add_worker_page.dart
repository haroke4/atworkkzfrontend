import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelance_order/prefabs/scaffold_messages.dart';
import 'package:freelance_order/prefabs/tools.dart';
import 'package:freelance_order/utils/AdminBackendAPI.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/LocalizerUtil.dart';
import '../prefabs/colors.dart';

class AdminAddWorkerPage extends StatefulWidget {
  final String? displayName;
  final String? username;

  const AdminAddWorkerPage({super.key, this.displayName, this.username});

  @override
  State<AdminAddWorkerPage> createState() => _AdminAddWorkerPageState();
}

class _AdminAddWorkerPageState extends State<AdminAddWorkerPage> {
  String _workerInfo = "";
  String _displayUsername = "";
  String _usernameWorker = "";

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    _workerInfo = widget.displayName != null
        ? "${widget.displayName}"
        : ""; // split it into 2 parameter
  }

  void _addContactPressed() async {
    var status = await Permission.contacts.status;
    if (status.isGranted) {
      final contact = await FlutterContacts.openExternalPick();
      if (contact == null) {
        return;
      }
      setState(() {
        _displayUsername = contact.displayName;
        _usernameWorker = contact.phones[0].number;
        _usernameWorker = _usernameWorker.replaceAll(RegExp(r'[^0-9]'),'');
        if (!_usernameWorker.startsWith("7")) {
          _usernameWorker = '7${_usernameWorker.substring(
            1,
          )}';
        }
        _workerInfo = _displayUsername;
      });
    } else {
      await Permission.contacts.request();
    }
  }

  void _yesPressed() async {
    showScaffoldMessage(context, Localizer.get('processing'));
    var response;
    if (widget.username != null && widget.displayName != null) {
      response = await AdminBackendAPI.replaceWorker(
          oldWorkerUsername: widget.username.toString(),
          newWorkerUsername: _usernameWorker,
          newWorkerDisplayName: _displayUsername);
    } else {
      response = await AdminBackendAPI.registerWorker(
          displayName: _displayUsername, username: _usernameWorker);
    }
    if (response.statusCode == 200) {
      if (widget.username != null) {
        showScaffoldMessage(context, Localizer.get('ok_worker_replace'), time: 3);
      }
      Get.back(result: "update");
    } else {
      showScaffoldMessage(context, Localizer.get('already_exists'), time: 2);
    }
  }

  void _noPressed() async {
    _addContactPressed();
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
                  Localizer.get('pick_worker'),
                  style: TextStyle(
                    color: Theme.of(context).primaryColorDark,
                    fontSize: 72.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  Localizer.get('name_con_book'),
                  style: TextStyle(
                    color: Theme.of(context).primaryColorDark,
                    fontSize: 45.sp,
                    overflow: TextOverflow.visible,
                  ),
                ),
                SizedBox(height: 40.h),
                getText(
                  _workerInfo == "" ? " " * 50 : _workerInfo,
                  fontSize: 40.sp,
                  onPressed: _addContactPressed,
                ),
                SizedBox(height: 40.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_workerInfo != '') ...[
                      getText(
                        Localizer.get('yes'),
                        fontSize: 38.sp,
                        onPressed: _yesPressed,
                      ),
                      getText(
                        Localizer.get('no'),
                        fontSize: 38.sp,
                        onPressed: _noPressed,
                      )
                    ],
                    getText(Localizer.get('back'),
                        fontSize: 38.sp,
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
