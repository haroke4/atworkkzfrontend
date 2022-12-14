import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'enter_sms_page.dart';
import '../prefabs/appbar_prefab.dart';

class EnterPhonePage extends StatefulWidget {
  const EnterPhonePage({super.key});

  @override
  State<EnterPhonePage> createState() => _EnterPhonePageState();
}

class _EnterPhonePageState extends State<EnterPhonePage> {
  final _formKey = GlobalKey<FormState>();
  final _adminPhoneController = TextEditingController();
  final _workerPhoneController = TextEditingController();
  Widget _buttonLabel = const Text('Отправить код');
  late final _loginAsWorker;

  @override
  void initState() {
    super.initState();
    _loginAsWorker = Get.arguments[0] == 'worker';
  }

  void sendTelNumbers() {
    // Send data to backend and wait for SMS
    if (_formKey.currentState!.validate()) {
      print(_adminPhoneController.text);
      print(_workerPhoneController.text);
      setState(() {
        _buttonLabel = const SpinKitThreeBounce(
          color: Colors.white,
          size: 25.0,
        );
      });

      //Send data to backend

      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Processing Data')),
      // );
      Get.to(const EnterSMSPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: getAppBar("Заполнить"),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 10.h),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    getTelNumberInputField(
                        'Номер телефона администратора', _adminPhoneController),
                    // Если юзер нажал на кнопку "войти как работник" тогда показываем
                    _loginAsWorker
                        ? getTelNumberInputField(
                            'Номер телефона работника', _workerPhoneController)
                        : const SizedBox(height: 0),
                  ],
                ),
              ),
              SizedBox(height: 4.h),
              FloatingActionButton.extended(
                onPressed: sendTelNumbers,
                elevation: 0,
                backgroundColor: Theme.of(context).primaryColorDark,
                heroTag: "1",
                label: _buttonLabel,
                icon: const Icon(Icons.send_rounded),
              ),
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget getTelNumberInputField(
      String label, TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.all(5.w),
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
        },
        decoration: InputDecoration(
          labelText: label,
        ),
        cursorColor: Theme.of(context).primaryColorDark,
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
