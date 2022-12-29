import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:freelance_order/pages/admin_main_page.dart';
import 'package:freelance_order/prefabs/admin_tools.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';
import '../prefabs/scaffold_messages.dart';
import '../utils/AdminBackendAPI.dart';
import '../utils/LocalizerUtil.dart';
import 'worker_main_page.dart';
import '../prefabs/colors.dart';
import '../prefabs/appbar_prefab.dart';

class EnterCodePage extends StatefulWidget {
  final nextPage;
  var code;
  EnterCodePage({super.key, required this.nextPage, this.code=""});

  @override
  State<EnterCodePage> createState() => _EnterCodePageState();
}

class _EnterCodePageState extends State<EnterCodePage> {
  final LocalAuthentication _auth = LocalAuthentication();
  String _errorMessage = '';
  final _smsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _onFingerprintPressed();
  }

  void _checkCode({fromOnChanged = false}) async {
    if (_smsController.text.length < 4) {
      if (!fromOnChanged) {
        setState(() {
          _errorMessage = Localizer.get('enter_code');
        });
      }
    } else {
      // send data to server
      if(widget.code != ""){
        print(widget.code);
        if (_smsController.text == widget.code){
          showScaffoldMessage(context, Localizer.get('success'));
          Get.off(widget.nextPage, arguments: Get.arguments);
        }
        else {
          showScaffoldMessage(context, Localizer.get('incorrect_code'));
          _smsController.text = "";
        }
      }
      else {
        if (await AdminBackendAPI.checkPinCode(_smsController.text)) {
          showScaffoldMessage(context, Localizer.get('success'));
          Get.off(widget.nextPage, arguments: Get.arguments);
        }
        else {
          showScaffoldMessage(context, Localizer.get('incorrect_code'));
          _smsController.text = "";
        }
      }
    }
    // Check data
  }

  void _onNumberButtonPressed(String value) {
    _smsController.text += value;
    if (_smsController.text.length >= 4) {
      _checkCode();
    }
  }

  void _onFingerprintPressed() async {
    final List<BiometricType> availableBiometrics =
        await _auth.getAvailableBiometrics();
    if (availableBiometrics.isNotEmpty) {
      try {
        final bool didAuthenticate = await _auth.authenticate(
          localizedReason: Localizer.get('pls_cumin'),
          options: const AuthenticationOptions(biometricOnly: true),
        );
        if (didAuthenticate) {
          Get.off(widget.nextPage, arguments: Get.arguments);
        }
      } on PlatformException {}
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
                Localizer.get('type_code'),
                style: TextStyle(
                  color: Theme.of(context).primaryColorDark,
                  fontSize: 20.h,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20.h),
              Padding(
                padding: EdgeInsets.fromLTRB(110.w, 5.w, 110.w, 5.w),
                child: PinInputTextField(
                  controller: _smsController,
                  pinLength: 4,
                  keyboardType: TextInputType.number,
                  cursor: Cursor(
                    width: 3,
                    height: 20.h,
                    color: Theme.of(context).primaryColorDark,
                    enabled: true,
                  ),
                  decoration: const UnderlineDecoration(
                    colorBuilder:
                        FixedColorBuilder(Color.fromRGBO(201, 60, 42, 1)),
                  ),
                  onChanged: (value) {
                    _checkCode(fromOnChanged: true);
                  },
                ),
              ),
              SizedBox(height: 3.h),
              _errorMessage != ''
                  ? Text(
                      _errorMessage,
                      style: TextStyle(color: Theme.of(context).errorColor),
                    )
                  : const SizedBox(),
              SizedBox(height: 10.h),
              Row(
                children: [
                  SizedBox(width: 10.w),
                  getFingerprintButton(),
                  const Expanded(child: SizedBox()),
                  getNumbersWidget(),
                  const Expanded(child: SizedBox()),
                  getGoBackButton(padding: 2.w, height: 44.h),
                  SizedBox(width: 10.w),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getFingerprintButton() {
    return Material(
      color: Colors.white,
      child: InkWell(
        splashColor: Colors.black26,
        onTap: _onFingerprintPressed,
        child: Padding(
          padding: EdgeInsets.all(2.h),
          child: Icon(
            Icons.fingerprint,
            size: 20.w,
          ),
        ),
      ),
    );
  }

  Widget getNumbersWidget() {
    List<Widget> firstLine = [];
    List<Widget> secondLine = [];
    for (int i = 1; i < 6; i++) {
      firstLine.add(CircleButton(
          onTap: () => _onNumberButtonPressed(i.toString()),
          text: i.toString()));
      if (i != 5) {
        firstLine.add(SizedBox(width: 15.w));
      }
    }
    for (int i = 6; i < 10; i++) {
      secondLine.add(CircleButton(
          onTap: () => _onNumberButtonPressed(i.toString()),
          text: i.toString()));
      secondLine.add(SizedBox(width: 15.w));
    }
    secondLine.add(
      CircleButton(onTap: () => _onNumberButtonPressed("0"), text: "0"),
    );

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: firstLine,
        ),
        SizedBox(height: 10.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: secondLine,
        )
      ],
    );
  }

}

class CircleButton extends StatelessWidget {
  final GestureTapCallback onTap;
  final String text;

  const CircleButton({super.key, required this.onTap, required this.text});

  @override
  Widget build(BuildContext context) {
    double size = 50.0;

    return InkResponse(
      onTap: onTap,
      child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 25.h,
              ),
            ),
          )),
    );
  }
}
