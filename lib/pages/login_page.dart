import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelance_order/utils/LocalizerUtil.dart';
import 'package:get/get.dart';
import 'package:location/location.dart' as Loc;
import 'package:permission_handler/permission_handler.dart';
import '../prefabs/tools.dart';
import 'enter_phone_page.dart';
import '../prefabs/colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  @override
  void initState(){
    super.initState();
    asyncInitState();
  }

  void asyncInitState() async{
    var calendar = await Permission.calendar.status;
    var camera = await Permission.camera.status;
    var contact = await Permission.contacts.status;

    var location =  Loc.Location();
    var geopos = await location.hasPermission() == Loc.PermissionStatus.granted;

    if(calendar.isGranted && camera.isGranted && contact.isGranted && geopos){
      return;
    }
    if (!geopos){
      await location.requestPermission();
    }
    if (!calendar.isGranted) {
      Permission.calendar.request();
    }

    if (!camera.isGranted) {
      Permission.camera.request();
    }

    if (!contact.isGranted) {
      Permission.contacts.request();
    }

    asyncInitState();
}


  void loginAsAdministrator() {
    Get.to(const EnterPhonePage(loginAsWorker: false));
  }

  void loginAsUser() {
    Get.to(const EnterPhonePage(loginAsWorker: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: brownColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            Localizer.get('login_as'),
            style: TextStyle(
              color: Theme.of(context).primaryColorDark,
              fontSize: 40.h,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              getLoginAsButtons(
                  Image.asset(
                    "assets/admin.png",
                    height: 140.h,
                  ),
                  Localizer.get('admin'),
                  loginAsAdministrator),
              SizedBox(
                width: 50.w,
              ),
              getLoginAsButtons(
                  Image.asset(
                    "assets/worker.png",
                    height: 140.h,
                  ),
                  Localizer.get('worker'),
                  loginAsUser),
            ],
          ),
          SizedBox(height: 20.h),
          getText("Қаз / Рус / Eng",
              align: TextAlign.center,
              fontSize: 14,
              onPressed: () => setState(() {
                Localizer.changeLanguage();
              })),
        ],
      ),
    );
  }

  Widget getLoginAsButtons(Image image, String text, var _onPressed) {
    return Container(
      // тени
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
              color: Colors.black26,
              blurRadius: 20,
              spreadRadius: 0.1,
              blurStyle: BlurStyle.normal),
        ],
      ),

      child: Material(
        color: Colors.white,
        child: InkWell(
          splashColor: Colors.black26,
          onTap: _onPressed,
          child: Padding(
            padding: EdgeInsets.all(6.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                image,
                const SizedBox(
                  height: 6,
                ),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 20,
                    color: Theme.of(context).primaryColorDark,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
