import 'dart:ui';

import 'package:flutter/material.dart';

Color bgColor = const Color.fromRGBO(230, 230, 230, 1);
Color brownColor = const Color.fromRGBO(166, 138, 106, 1);
Color greyColor = Colors.black45;

Color todayColor = const Color.fromRGBO(0, 146, 202, 1);
Color workingDayColor = const Color.fromRGBO(169, 146, 114, 1);
Color nonWorkingDayColor = const Color.fromRGBO(255, 255, 255, 1);
Color noAssignmentColor = const Color.fromRGBO(201, 200, 200, 1.0);
Color onTimeColor = const Color.fromRGBO(25, 182, 63, 1);
Color lateColor = const Color.fromRGBO(249, 133, 60, 1);
Color truancyColor = const Color.fromRGBO(49, 49, 49, 1.0);
Color validReasonColor = const Color.fromRGBO(122, 149, 209, 1);
Color begOffColor = const Color.fromRGBO(181, 71, 175, 1);
Color confirmationColor = const Color.fromRGBO(245, 246, 247, 1);

Color pickedLineColor = const Color.fromRGBO(220, 216, 216, 1.0);


Color getColorByStatus(String? status) {
  if (status == "working_day") {
    return workingDayColor;
  }
  else if (status == "non_working_day"){
    return nonWorkingDayColor;
  }
  else if (status == "late") {
    return lateColor;
  }
  else if(status == "truancy"){
    return truancyColor;
  }
  else if(status == "on_time"){
    return onTimeColor;
  }
  else if(status == "beg_off"){
    return begOffColor;
  }
  else if(status == "valid_reason"){
    return validReasonColor;
  }
  return noAssignmentColor;
}
