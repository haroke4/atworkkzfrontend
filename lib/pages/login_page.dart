import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'enter_phone_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
    print("Login page");
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.bottom]);
  }

  void loginAsAdministrator() {
    Get.to(const EnterPhonePage(), arguments: ['admin']);
  }

  void loginAsUser() {
    Get.to(const EnterPhonePage(), arguments: ['worker']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            getLoginAsButtons(
                Icons.person_outline, "Войти как работник", loginAsUser),
            SizedBox(
              width: 50.h,
            ),
            getLoginAsButtons(Icons.admin_panel_settings_outlined,
                "Войти как администратор", loginAsAdministrator),
          ],
        ),
      ),
    );
  }

  Widget getLoginAsButtons(IconData icon, String text, var _onPressed) {
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
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          splashColor: Colors.black26,
          onTap: _onPressed,
          child: Padding(
            padding: EdgeInsets.all(10.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 70.w,
                  color: Theme.of(context).primaryColorDark,
                ),
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
