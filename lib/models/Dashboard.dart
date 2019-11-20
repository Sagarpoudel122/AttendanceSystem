import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_icons/flutter_icons.dart';

class Dashboard {
  final String title;
  final Icon icon;
  final String routes;

  Dashboard({this.title, this.icon, this.routes});
}

List<Dashboard> dashboardData = [
  Dashboard(
    routes: "courses",
    title: "All Courses",
    icon: Icon(
      SimpleLineIcons.getIconData(
        "graduation",
      ),
      size: 50,
      color: Colors.pink,
    ),
  ),
  Dashboard(
    routes: "takeAttendance",
    title: "Take Attendance",
    icon: Icon(
      FontAwesome5.getIconData(
        "user-check",
        weight: IconWeight.Solid,
      ),
      size: 40,
      color: Colors.pink,
    ),
  ),
  Dashboard(
    routes: "viewAttendance",
    title: "View Attendance",
    icon: Icon(
      Feather.getIconData(
        "eye",
      ),
      size: 50,
      color: Colors.pink,
    ),
  ),
];
