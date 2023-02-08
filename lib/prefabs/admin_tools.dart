import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../pages/admin_main_page.dart';
import '../utils/LocalizerUtil.dart';
import 'colors.dart';

Widget getMainMenuButton({enabled = true}) {
  return SizedBox(
    height: 50.h,
    child: InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: enabled
          ? () {
              Get.offAll(const AdminsMainPage());
            }
          : () {},
      child: Image.asset("assets/mainMenuButton.png"),
    ),
  );
}

Widget getGoBackButton(
    {double? padding,
    double? height,
    Function? onTap,
    Color? color,
    String? result}) {
  return Material(
    color: color ?? bgColor,
    child: SizedBox(
      height: height ?? 50.h,
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: onTap == null
            ? () {
                if (result == null || result == '') {
                  Get.back();
                } else {
                  Get.back(result: result);
                }
              }
            : () {
                onTap();
              },
        child: Padding(
            padding: EdgeInsets.all(padding ?? 0),
            child: Image.asset("assets/goBackButton.png")),
      ),
    ),
  );
}

Widget getSaveButton(Function onTap) {
  return Container(
    constraints: BoxConstraints(minWidth: 20.w),
    margin: EdgeInsets.only(left: 2.w, right: 2.w),
    child: Material(
      color: Colors.white,
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          onTap();
        },
        child: Container(
          padding: EdgeInsets.all(4.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/save.png',
                height: 42.h,
              ),
              Text(Localizer.get('save'),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 22.sp,
                  ),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget getInputTimeField(controller) {
  return Container(
    constraints: BoxConstraints(minWidth: 20.w),
    margin: EdgeInsets.only(left: 2.w, right: 2.w),
    color: Colors.white,
    child: TextField(
      controller: controller,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.all(4.w),
      ),
      cursorWidth: 1,
      cursorColor: Colors.black,
      style: TextStyle(fontSize: 20.sp),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        TimeInputFormatter(),
        LengthLimitingTextInputFormatter(5)
      ],
    ),
  );
}

class TimeInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String ans = '';
    int counter = 0;
    for (var element in newValue.text.runes) {
      if (counter == 2) {
        if (int.parse(ans.substring(0, 2)) > 24) {
          ans = '24';
        }
        ans += ':';
      }
      ans += String.fromCharCode(element);
      if (counter == 3) {
        if (int.parse(ans.substring(3, 5)) > 60) {
          ans = '${ans.substring(0, 3)}60';
        }
      }
      counter += 1;
    }

    return TextEditingValue(
      text: ans,
      selection: TextSelection.collapsed(offset: ans.length),
    );
  }
}

Future<GeoPoint?> LocationPicker({
  required BuildContext context,
  required String textConfirmPicker,
  required String textCancelPicker,
  required String title,
  Widget? titleWidget,
  TextStyle? titleStyle,
  EdgeInsets contentPadding = EdgeInsets.zero,
  double radius = 0.0,
  GeoPoint? initPosition,
  double stepZoom = 1,
  double initZoom = 2,
  double minZoomLevel = 2,
  double maxZoomLevel = 18,
  bool isDismissible = false,
  bool initCurrentUserPosition = true,
}) async {
  assert(titleWidget == null);
  assert((initCurrentUserPosition && initPosition == null) ||
      !initCurrentUserPosition && initPosition != null);
  final MapController controller = MapController(
    initMapWithUserPosition: initCurrentUserPosition,
    initPosition: initPosition,
  );

  GeoPoint? point = await showDialog(
    context: context,
    builder: (ctx) {
      return WillPopScope(
        onWillPop: () async {
          return isDismissible;
        },
        child: SizedBox(
          height: MediaQuery.of(context).size.height / 1.1,
          width: MediaQuery.of(context).size.width / 1.2,
          child: AlertDialog(
            title: Text(title, style: TextStyle(fontSize: 30.sp)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(radius),
              ),
            ),
            contentPadding: contentPadding,
            content: SizedBox(
              height: MediaQuery.of(context).size.width / 1.1,
              width: MediaQuery.of(context).size.width / 1.2,
              child: OSMFlutter(
                controller: controller,
                isPicker: true,
                stepZoom: stepZoom,
                initZoom: initZoom,
                minZoomLevel: minZoomLevel,
                maxZoomLevel: maxZoomLevel,
              ),
            ),
            actionsPadding: EdgeInsets.only(right: 10.w),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  textCancelPicker,
                  style: TextStyle(
                    fontSize: 20.sp,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  final p = await controller
                      .getCurrentPositionAdvancedPositionPicker();
                  await controller.cancelAdvancedPositionPicker();
                  Navigator.pop(ctx, p);
                },
                child: Text(
                  textConfirmPicker,
                  style: TextStyle(
                    fontSize: 20.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  return point;
}
