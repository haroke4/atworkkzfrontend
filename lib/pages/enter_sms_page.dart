import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';
import '../prefabs/appbar_prefab.dart';


class EnterSMSPage extends StatefulWidget {
  const EnterSMSPage({super.key});

  @override
  State<EnterSMSPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<EnterSMSPage> {
  Widget _buttonLabel = const Text('Войти');
  String _errorMessage = '';
  final _smsController = TextEditingController();

  void sendAndCheckSMS() {
    setState(() {
      _buttonLabel = const SpinKitThreeBounce(
        color: Colors.white,
        size: 25.0,
      );
      _errorMessage = _smsController.text.length < 3 ? 'Введите код' : '';
    });
    // Check data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: getAppBar('Введите код из SMS'),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20.h),
              Padding(
                padding: EdgeInsets.fromLTRB(110.w, 5.w, 110.w, 5.w),
                child: PinInputTextField(
                  controller: _smsController,
                  pinLength: 4,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    if (value.length == 4) {
                      FocusManager.instance.primaryFocus?.unfocus();
                      sendAndCheckSMS();
                    }
                  },
                  cursor: Cursor(
                    width: 1,
                    color: Theme.of(context).primaryColorDark,
                    enabled: true,
                  ),
                  decoration: UnderlineDecoration(
                    colorBuilder:
                        FixedColorBuilder(Theme.of(context).primaryColorDark),
                  ),
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

              FloatingActionButton.extended(
                onPressed: sendAndCheckSMS,
                elevation: 0,
                backgroundColor: Theme.of(context).primaryColorDark,
                heroTag: "1",
                label: _buttonLabel,
                icon: const Icon(Icons.login),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
