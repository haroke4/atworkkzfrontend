import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:freelance_order/prefabs/admin_tools.dart';
import 'package:freelance_order/prefabs/scaffold_messages.dart';
import 'package:freelance_order/prefabs/tools.dart';
import 'package:get/get.dart';

import '../prefabs/colors.dart';
import '../utils/LocalizerUtil.dart';
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
    Localizer.get('send_photo'),
    bgColor: brownColor,
    onPressed: buttonPressed,
  );
  MapController controller = MapController(
    initMapWithUserPosition: true,
  );
  late GeoPoint workGeoPoint;

  @override
  void initState() {
    super.initState();
    List<String> geoPos = widget.day['geoposition'].split(" ");
    var lat = double.parse(geoPos[0]);
    var lon = double.parse(geoPos[1]);
    workGeoPoint = GeoPoint(latitude: lat, longitude: lon);
  }

  void buttonPressed() async {
    setState(() {
      sendButtonLabel = SpinKitThreeBounce(
        color: Colors.black,
        size: 20.h,
      );
    });
    GeoPoint geoPoint = await controller.myLocation();
    if (await distance2point(geoPoint, workGeoPoint) < 10) {
      var response = await WorkersBackendAPI.assignPhoto(
        widget.day['id'],
        widget.imageFile,
        start: widget.start,
      );
      if (response.statusCode == 200) {
        showScaffoldMessage(context, Localizer.get('success'));
        Get.back(result: 'update');
      } else {
        String answer = "";
        response.stream.transform(utf8.decoder).listen((value) {
          answer += value;
        });
        showScaffoldMessage(context, answer);
      }
    } else {
      showScaffoldMessage(context, Localizer.get('photo_zone'));
    }
    setState(() {
      sendButtonLabel = getText(
        Localizer.get('send_photo'),
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
                      Localizer.get('my_pos'),
                      bgColor: Colors.black45,
                      fontColor: Colors.white,
                      onPressed: () async {
                        await controller.currentLocation();
                      },
                    ),
                    SizedBox(height: 10.h),
                    getText(
                      Localizer.get('wo_pos'),
                      bgColor: Colors.black45,
                      fontColor: Colors.white,
                      onPressed: () async {
                        await controller.addMarker(workGeoPoint);
                        await controller.changeLocation(workGeoPoint);
                        await controller.zoomIn();
                      },
                    ),
                    SizedBox(height: 10.h),
                    getGoBackButton(padding: 1.w, height: 60.h)
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
          height: 550.h,
          child: OSMFlutter(
            controller: controller,
            trackMyPosition: false,
            initZoom: 19,
            minZoomLevel: 2,
            maxZoomLevel: 19,
            stepZoom: 1.0,
          ),
        ),
      ],
    );
  }
}
