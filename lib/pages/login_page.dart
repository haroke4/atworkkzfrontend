import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'enter_phone_page.dart';
import '../prefabs/colors.dart';

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
          "Вход как...",
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
              getLoginAsButtons(Icons.admin_panel_settings_outlined,
                  "Админ", loginAsAdministrator),
              SizedBox(
                width: 50.w,
              ),
              getLoginAsButtons(
                  Icons.person_outline, "Работник", loginAsUser),
            ],
          ),
        ],
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
        child: InkWell(
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
