import 'dart:convert';

import 'package:attendance/library/constant.dart';
import 'package:attendance/models/Courses.dart';

import 'package:attendance/models/Dashboard.dart';
import 'package:attendance/screens/CoursesScreen.dart';
import 'package:attendance/screens/HidenDrawer.dart';
import 'package:attendance/screens/TakeAttendanceScreen.dart';
import 'package:attendance/screens/ViewAttendanceScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_villains/villain.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';

import '../library/constant.dart';

class DashboardScreen extends DrawerContent {
  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  List<Courses> coursesList = List<Courses>();
  Future<List<Courses>> courses;
  List<dynamic> decodedCourse = List<dynamic>();
  @override
  void initState() {
    super.initState();
    courses = loadCoursesList();
  }

  Future<List<Courses>> loadCoursesList() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    var _token = _prefs.getString("token") ?? "";
    var _userInfo = _prefs.getString("userInfo") ?? "";
    int userId = json.decode(_userInfo)['user_id'];
    var client = http.Client();
    var url = serverUrl + 'api/courses/' + userId.toString();
    http.Response response =
        await client.get(url, headers: {"authorization": _token});
    if (response.statusCode == 200) {
      decodedCourse.clear();
      coursesList.clear();
      decodedCourse = json.decode(response.body)['courses'];
      decodedCourse.forEach((course) {
        coursesList.add(Courses.fromJson(course));
      });
      return coursesList;
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Stack(
        children: <Widget>[
          ClipPath(
            clipper: OvalBottomBorderClipper(),
            child: Container(
                height: 250,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [primaryColor, primaryColor])),
                child: null),
          ),
          Villain(
            villainAnimation: VillainAnimation.fromTop(
              from: Duration(milliseconds: 200),
              to: Duration(milliseconds: 400),
            ),
            child: Container(
              margin: EdgeInsets.only(top: 35),
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                      AntDesign.getIconData("menu-unfold"),
                      color: white,
                    ),
                    onPressed: widget.onMenuPressed,
                  ),
                  Text(
                    "Dashboard",
                    style: TextStyle(color: white, fontSize: 20.0),
                  ),
                  CircleAvatar(
                    backgroundColor: white,
                    minRadius: 25,
                    child: Image(
                      height: 30,
                      fit: BoxFit.scaleDown,
                      image: NetworkImage(
                        'https://www.pngarts.com/files/3/Cool-Avatar-Transparent-Image.png',
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Villain(
            villainAnimation: VillainAnimation.fromTop(
              from: Duration(milliseconds: 300),
              to: Duration(milliseconds: 600),
            ),
            child: Center(
              child: Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width * 0.9,
                margin: EdgeInsets.only(top: 80),
                child: Column(
                  children: <Widget>[
                    Container(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: GridView.builder(
                        physics: BouncingScrollPhysics(),
                        itemCount: dashboardData.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2),
                        itemBuilder: (BuildContext context, int index) {
                          return InkWell(
                            onTap: () {
                              var screen;

                              if (dashboardData[index].routes == 'courses') {
                                screen = CoursesScreen(courses: courses);
                              } else if (dashboardData[index].routes ==
                                  'viewAttendance') {
                                screen = ViewAttendanceScreen(
                                  decodedCourse: decodedCourse,
                                );
                              } else if (dashboardData[index].routes ==
                                  'takeAttendance') {
                                screen = TakeAttendanceScreen(
                                    decodedCourse: decodedCourse);
                              } else {
                                screen = CoursesScreen(courses: courses);
                              }
                              Navigator.push(
                                  context,
                                  PageTransition(
                                      type: PageTransitionType.rightToLeft,
                                      child: screen));
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10),
                              decoration: BoxDecoration(
                                  color: white,
                                  shape: BoxShape
                                      .rectangle, // BoxShape.circle or BoxShape.retangle
                                  //color: const Color(0xFF66BB6A),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey,
                                      blurRadius: 1.0,
                                    ),
                                  ]),
                              height: 100,
                              width: 100,
                              child: Center(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    dashboardData[index].icon,
                                    Text(
                                      dashboardData[index].title,
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: black,
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
