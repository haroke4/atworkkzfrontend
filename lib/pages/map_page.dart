import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:freelance_order/main.dart';
import 'package:freelance_order/prefabs/admin_tools.dart';
import 'package:freelance_order/prefabs/scaffold_messages.dart';
import 'package:freelance_order/prefabs/tools.dart';
import 'package:get/get.dart';

import '../prefabs/colors.dart';
import '../utils/WorkersBackendAPI.dart';

class MyMapView extends StatefulWidget {
  final imageFile;
  final day;
  final start;

  const MyMapView({
    super.key,
    required this.day,
    required this.imageFile,
    required this.start,
  });

  @override
  State<MyMapView> createState() => _MyMapViewState();
}

class _MyMapViewState extends State<MyMapView> {
  late Widget sendButtonLabel = getText(
    "Отправить фото",
    bgColor: brownColor,
    onPressed: buttonPressed,
  );

  MapController controller = MapController(
    initMapWithUserPosition: true,
  );

  @override
  void initState() {
    super.initState();
  }

  void buttonPressed() async {
    setState(() {
      sendButtonLabel = const SpinKitThreeBounce(
        color: Colors.black,
        size: 25.0,
      );
    });
    GeoPoint geoPoint = await controller.myLocation();
    List<String> geoPos = widget.day['geoposition'].split(" ");
    var lat = double.parse(geoPos[0]);
    var lon = double.parse(geoPos[1]);
    GeoPoint newGeoPoint = GeoPoint(latitude: lat, longitude: lon);
    if (await distance2point(geoPoint, newGeoPoint) < 10) {
      var response = await WorkersBackendAPI.assignPhoto(
        widget.day['id'],
        widget.imageFile,
        start: widget.start,
      );
      if (response.statusCode == 200) {
        showScaffoldMessage(context, "Успешно");
        Get.back(result: 'update');
      } else {
        String answer = "";
        response.stream.transform(utf8.decoder).listen((value) {
          answer += value;
        });
        showScaffoldMessage(context, answer);
      }
    } else {
      showScaffoldMessage(context, "Вы не находитесь в зоне для фото");
    }
    setState(() {
      sendButtonLabel = getText(
        "Отправить фото",
        bgColor: brownColor,
        onPressed: buttonPressed,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                getMap(),
                SizedBox(
                  width: 20.w,
                ),
                Column(
                  children: [
                    sendButtonLabel,
                    SizedBox(height: 10.h),
                    getText(
                      "Мое местоположение",
                      bgColor: Colors.black87,
                      fontColor: Colors.white,
                      onPressed: () async {
                        await controller.currentLocation();
                      },
                    ),
                    SizedBox(height: 10.h),
                    getGoBackButton(padding: 1.w)
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getMap() {
    return Column(
      children: [
        SizedBox(
          height: 4.h,
        ),
        SizedBox(
          width: 200.w,
          height: 300.h,
          child: OSMFlutter(
            controller: controller,
            trackMyPosition: false,
            initZoom: 19,
            minZoomLevel: 2,
            maxZoomLevel: 19,
            stepZoom: 1.0,
            userLocationMarker: UserLocationMaker(
              personMarker: const MarkerIcon(
                icon: Icon(
                  Icons.location_history_rounded,
                  color: Colors.red,
                  size: 48,
                ),
              ),
              directionArrowMarker: const MarkerIcon(
                icon: Icon(
                  Icons.double_arrow,
                  size: 48,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
