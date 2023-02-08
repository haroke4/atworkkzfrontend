import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:freelance_order/pages/worker_main_page.dart';
import 'package:freelance_order/prefabs/scaffold_messages.dart';
import 'package:freelance_order/utils/BackendAPI.dart';
import 'package:get/get.dart';
import '../utils/LocalizerUtil.dart';
import 'admin_main_page.dart';
import 'enter_sms_page.dart';
import '../prefabs/colors.dart';

class EnterPhonePage extends StatefulWidget {
  final bool loginAsWorker;

  const EnterPhonePage({super.key, required this.loginAsWorker});

  @override
  State<EnterPhonePage> createState() => _EnterPhonePageState();
}

class _EnterPhonePageState extends State<EnterPhonePage> {
  final _formKey = GlobalKey<FormState>();
  final _adminPhoneController = TextEditingController();
  final _workerPhoneController = TextEditingController();
  Widget _buttonLabel = Text(
    Localizer.get('send_code'),
    style: TextStyle(fontSize: 25.sp, fontWeight: FontWeight.bold),
  );

  @override
  void initState(){
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  void sendTelNumbers() async {
    // Send data to backend and wait for SMS
    if (_formKey.currentState!.validate()) {
      setState(() {
        _buttonLabel = SpinKitThreeBounce(
          color: Colors.black,
          size: 40.sp,
        );
      });

      var adminUsername = "7${_adminPhoneController.text.replaceAll(" ", "")}";
      var workerUsername =
          "7${_workerPhoneController.text.replaceAll(" ", "")}";
      var response;
      if (widget.loginAsWorker) {
        response = await BackendAPI.sendSms(workerUsername);
      } else {
        try {
          await BackendAPI.registerAsAdmin(adminUsername);
        } on Exception {}

        response = await BackendAPI.sendSms(adminUsername);
      }
      if (response.statusCode == 200) {
        setState(() {
          _buttonLabel = Text(
            Localizer.get('send_code'),
            style: TextStyle(fontSize: 25.sp, fontWeight: FontWeight.bold),
          );
        });
        Get.to(
          () => EnterSMSPage(
            nextPage: widget.loginAsWorker
                ? const WorkersMainPage()
                : const AdminsMainPage(),
            adminUsername: adminUsername,
            workerUsername: workerUsername,
          ),
        );
      } else {
        showScaffoldMessage(context, Localizer.get('invalid_phone'));
        setState(() {
          _buttonLabel = Text(
            Localizer.get('send_code'),
            style: TextStyle(fontSize: 25.sp, fontWeight: FontWeight.bold),
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: brownColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 30.h),
              Text(
                Localizer.get("fill"),
                style: TextStyle(
                  color: Theme.of(context).primaryColorDark,
                  fontSize: 70.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 25.h),
              Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    getTelNumberInputField(
                        Localizer.get('phone_admin'), _adminPhoneController),
                    SizedBox(height: 7.h),
                    // Если юзер нажал на кнопку "войти как работник" тогда показываем
                    widget.loginAsWorker
                        ? getTelNumberInputField(Localizer.get('phone_worker'),
                            _workerPhoneController)
                        : const SizedBox(height: 0),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              FloatingActionButton.extended(
                onPressed: sendTelNumbers,
                label: _buttonLabel,
                foregroundColor: Theme.of(context).primaryColorDark,
                heroTag: "1",
                elevation: 0,
                backgroundColor: Theme.of(context).primaryColorLight,
                shape: const BeveledRectangleBorder(
                    borderRadius: BorderRadius.zero),
              ),
              SizedBox(
                height: 40.h,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget getTelNumberInputField(
      String label, TextEditingController controller) {
    return Container(
      margin: EdgeInsets.only(left: 50.w, right: 50.w),
      padding: EdgeInsets.only(left: 10.w, top: 10.h, right: 10.w, bottom: 10.h),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: TextFormField(
        controller: controller,
        validator: (String? value) {
          if (value == null || value == '') {
            return Localizer.get('field_cannot_be_empty');
          }
          if (value.length < 12) {
            // 11 - номер телефона 3 - пробела
            return Localizer.get('invalid_phone');
          }

          return null;
        },
        onChanged: (value) {
          _formKey.currentState!.validate();
          if (value.length == 12) {
            FocusScope.of(context).nextFocus();
          }
        },
        style: TextStyle(
          fontSize: 25.sp,
        ),
        decoration: InputDecoration(
          labelText: label,
          prefixText: '+7 ',
          hintStyle: TextStyle(fontSize: 25.sp),
          labelStyle: TextStyle(fontSize: 25.sp, color: Colors.black54),
          errorStyle: TextStyle(fontSize: 17.sp),
          contentPadding: EdgeInsets.fromLTRB(2.w, 10.h, 2.w, 10.h),

        ),
        cursorWidth: 1,
        cursorColor: Theme.of(context).primaryColorDark,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(10),
          TelNumberFormatter(),
        ],
      ),
    );
  }
}

class TelNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String ans = '';
    int counter = 0;

    for (var element in newValue.text.runes) {
      if (counter == 3 || counter == 6) {
        ans += ' ';
      }
      ans += String.fromCharCode(element);
      counter += 1;
    }

    return TextEditingValue(
      text: ans,
      selection: TextSelection.collapsed(offset: ans.length),
    );
  }
}
