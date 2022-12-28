import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:freelance_order/pages/worker_main_page.dart';
import 'package:freelance_order/prefabs/scaffold_messages.dart';
import 'package:freelance_order/utils/BackendAPI.dart';
import 'package:freelance_order/utils/WorkersBackendAPI.dart';
import 'package:get/get.dart';
import 'admin_main_page.dart';
import 'enter_sms_page.dart';
import '../prefabs/colors.dart';
import '../prefabs/appbar_prefab.dart';

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
  Widget _buttonLabel = const Text('Отправить код');

  void sendTelNumbers() async {
    // Send data to backend and wait for SMS
    if (_formKey.currentState!.validate()) {
      print(_adminPhoneController.text);
      print(_workerPhoneController.text);
      setState(() {
        _buttonLabel = const SpinKitThreeBounce(
          color: Colors.black,
          size: 25.0,
        );
      });

      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Processing Data')),
      // );
      var adminUsername = _adminPhoneController.text.replaceAll(" ", "");
      var workerUsername = _workerPhoneController.text.replaceAll(" ", "");
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
        showScaffoldMessage(context, "Неправильные номера телефонов");
        setState((){
          _buttonLabel = const Text('Отправить код');
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
              SizedBox(height: 40.h),
              Text(
                "Заполнить",
                style: TextStyle(
                  color: Theme.of(context).primaryColorDark,
                  fontSize: 40.h,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20.h),
              Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    getTelNumberInputField(
                        'Телефонный номер админа', _adminPhoneController),
                    SizedBox(height: 4.h),
                    // Если юзер нажал на кнопку "войти как работник" тогда показываем
                    widget.loginAsWorker
                        ? getTelNumberInputField('Телефонный номер работника',
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
      padding: const EdgeInsets.only(left: 20, top: 5, right: 20, bottom: 5),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: TextFormField(
        controller: controller,
        validator: (String? value) {
          if (value == null || value == '') {
            return 'Поле не может быть пустым';
          }
          if (value.length < 14) {
            // 11 - номер телефона 3 - пробела
            return 'Неправильный номер телефона';
          }

          return null;
        },
        onChanged: (value) {
          _formKey.currentState!.validate();
          if (value.length == 14) {
            FocusScope.of(context).nextFocus();
          }
        },
        decoration: InputDecoration(
          labelText: label,
        ),
        cursorColor: Theme.of(context).primaryColorLight,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(11),
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
      if (counter == 1 || counter == 4 || counter == 7) {
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
