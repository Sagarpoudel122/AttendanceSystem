import 'dart:convert';

import 'package:attendance/library/constant.dart';
import 'package:collection/collection.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_villains/villain.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TakeAttendanceScreen extends StatefulWidget {
  List<dynamic> decodedCourse;
  Map<String, dynamic> groupedByProgram;
  List<String> semester = List<String>();

  TakeAttendanceScreen({this.decodedCourse}) {
    groupedByProgram =
        groupBy(this.decodedCourse, (obj) => obj['program_name']);
  }
  @override
  _TakeAttendanceScreenState createState() => _TakeAttendanceScreenState();
}

class _TakeAttendanceScreenState extends State<TakeAttendanceScreen> {
  PageController pagecontroller = PageController();
  String attendance = 'P';
  double width = 0.85;
  double height = 0.60;
  Future studentList;
  bool isLoading = false;
  var state;

  List<Student> students = List<Student>();
  Map<int, Map<String, String>> result = Map<int, Map<String, String>>();
  var decodedStudent;
  void onAttendance(int studentId, String selected, int semesterId, int id) {
    if (state == 'Update') {
      setState(() {
        result[studentId] = {
          "studentId": studentId.toString(),
          "value": selected,
          "id": id.toString(),
          "semesterid": semesterId.toString()
        };
      });
    } else {
      setState(() {
        result[studentId] = {
          "studentId": studentId.toString(),
          "value": selected,
          "semesterid": semesterId.toString()
        };
      });
    }
  }

  saveAttendance() {
    if (students.length == result.length) {
      if (students.length > 0) {
        var client = http.Client();

        var url = serverUrl + 'api/saveAttendance/';
        String body = json.encode(result.values.toList());

        setState(() {
          isLoading = true;
        });
        SharedPreferences.getInstance().then((SharedPreferences _prefs) {
          var _userInfo = _prefs.getString("userInfo");
          int userId = json.decode(_userInfo)['user_id'];
          client.post(
            url,
            body: {
              "data": body,
              "teacher_id": userId.toString(),
              "state": state
            },
          ).then((http.Response resp) {
            if (resp.statusCode == 200) {
              pagecontroller.animateToPage(
                0,
                duration: const Duration(milliseconds: 1500),
                curve: Curves.easeInOut,
              );
              Flushbar(
                backgroundColor: Colors.lightGreen,
                isDismissible: true,
                title: 'Success',
                message: json.decode(resp.body)['message'],
                icon: Icon(
                  Icons.check,
                  size: 28,
                  color: Colors.white,
                ),
                duration: Duration(seconds: 3),
              )..show(context);
            } else if (resp.statusCode == 500) {
              Flushbar(
                backgroundColor: Colors.redAccent,
                isDismissible: true,
                title: 'Error',
                message: "Database Error",
                icon: Icon(
                  Icons.error_outline,
                  size: 28,
                  color: Colors.white,
                ),
                duration: Duration(seconds: 3),
              )..show(context);
            } else {
              Flushbar(
                backgroundColor: Colors.redAccent,
                isDismissible: true,
                title: 'Error',
                message: 'Uncaught Server Error',
                icon: Icon(
                  Icons.error_outline,
                  size: 28,
                  color: Colors.white,
                ),
                duration: Duration(seconds: 3),
              )..show(context);
            }
            setState(() {
              isLoading = false;
            });
          });
        });
      }
    } else {
      Flushbar(
        backgroundColor: Colors.redAccent,
        isDismissible: true,
        title: 'Error',
        message: 'Some of students attendance is missing',
        icon: Icon(
          Icons.error_outline,
          size: 28,
          color: Colors.white,
        ),
        duration: Duration(seconds: 3),
      )..show(context);
    }
  }

  Future loadStudents(int semesterId) async {
    var client = http.Client();
    var url = serverUrl + 'api/students/' + semesterId.toString();
    http.Response response = await client.get(
      url,
    );

    if (response.statusCode == 200) {
      students.clear();
      var decodedData = json.decode(response.body);
      decodedStudent = decodedData['students'];
      state = decodedData['state'];
      String value = "Present";
      int id;
      print(state);
      decodedStudent.forEach((course) {
        if (state == 'Update') {
          value = course['value'];
          id = course['id'];
        }
        result[course['student_id']] = {
          "studentId": course['student_id'].toString(),
          "value": value,
          "id": id.toString(),
          "semesterid": course['semester_id'].toString()
        };
        students.add(
          Student.fromJson(course, state),
        );
      });

      return students;
    }
  }

  Widget studentWidget() {
    return Container(
      padding: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 0),
      child: Column(children: <Widget>[
        SizedBox(
            height: 50,
            child: Row(
              children: <Widget>[
                IconButton(
                  onPressed: () async {
                    Future.delayed(const Duration(milliseconds: 200), () {
                      setState(() {
                        height = 0.60;
                      });
                    });

                    pagecontroller.animateToPage(
                      1,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                    );
                  },
                  icon: Icon(
                    SimpleLineIcons.getIconData("arrow-left"),
                    color: black,
                    size: 20,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 32.0),
                    child: Text(
                      "Students",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            )),
        Expanded(
            child: FutureBuilder(
          future: studentList,
          builder: (context, asynSnapshot) {
            if (asynSnapshot.hasData) {
              List<Student> data = asynSnapshot.data;
              int itemCount = data?.length ?? 0;
              if (itemCount > 0) {
                return ListView.builder(
                  itemCount: itemCount,
                  itemBuilder: (context, i) {
                    String name = data[i].name;
                    int studentId = data[i].studentId;
                    int semesterId = data[i].semesterId;
                    int id = data[i].id;
                    return Container(
                      height: 100,
                      padding: EdgeInsets.only(top: 10, left: 10),
                      decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey,
                              blurRadius: 5.0,
                            ),
                          ],
                          color: Colors.white,
                          borderRadius: new BorderRadius.only(
                              topLeft: const Radius.circular(10.0),
                              bottomLeft: const Radius.circular(10.0),
                              bottomRight: const Radius.circular(10.0),
                              topRight: const Radius.circular(10.0))),

                      // color: Colors.red,

                      margin: EdgeInsets.only(bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(bottom: 0),
                            child: Text(
                              name,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                              child: RadioButtonGroup(
                                  itemBuilder: (radio, label, i) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 15),
                                      child: Column(
                                        children: <Widget>[
                                          SizedBox(
                                            height: 40,
                                            // width: 30,
                                            child: radio,
                                          ),
                                          label
                                        ],
                                      ),
                                    );
                                  },
                                  orientation:
                                      GroupedButtonsOrientation.HORIZONTAL,
                                  picked: result[studentId]['value'],
                                  labels: <String>[
                                    "Present",
                                    "Absent",
                                    "On Leave",
                                    "Late",
                                  ],
                                  onSelected: (String selected) => onAttendance(
                                      studentId, selected, semesterId, id)))
                        ],
                      ),
                    );
                  },
                );
              } else {
                return Center(
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "No Students Found in this semester",
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 17),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Please setup Students Profile if missing ",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15),
                        )
                      ],
                    ),
                  ),
                );
              }
            } else {
              return Center(
                child: Container(
                  height: 50,
                  width: 50,
                  child: CircularProgressIndicator(),
                ),
              );
            }
          },
        )),
        Divider(
          color: Colors.grey,
        ),
        Container(
          alignment: Alignment.bottomCenter,
          child: FloatingActionButton(
            tooltip: "Save",
            backgroundColor: Colors.redAccent,
            elevation: 0,
            onPressed: () {
              if (!isLoading) {
                saveAttendance();
              }
            },
            child: isLoading
                ? CircularProgressIndicator(
                    backgroundColor: white,
                    strokeWidth: 2,
                  )
                : Icon(Icons.save),
          ),
        ),
        SizedBox(height: 5),
      ]),
    );
  }

  Widget semesterPage() {
    return Column(
      children: <Widget>[
        SizedBox(
            height: 50,
            child: Row(
              children: <Widget>[
                IconButton(
                  onPressed: () {
                    pagecontroller.animateToPage(
                      0,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                    );
                  },
                  icon: Icon(
                    SimpleLineIcons.getIconData("arrow-left"),
                    color: black,
                    size: 20,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 32.0),
                    child: Text(
                      "Semesters",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            )),
        Expanded(
          child: ListView.separated(
            separatorBuilder: (context, index) => Divider(
              indent: 10,
              endIndent: 10,
              height: 2,
              color: Colors.grey,
            ),
            itemCount: widget.semester?.length ?? 0,
            itemBuilder: (context, i) {
              List<String> semArray = widget.semester[i].split('-');
              // var data = widget.groupedByProgram[program[i]];
              return InkWell(
                onTap: () {
                  setState(() {
                    height = 0.80;
                    width = 0.9;
                    studentList = loadStudents(int.parse(semArray[1]));
                  });
                  result.clear();

                  pagecontroller.animateToPage(
                    2,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                },
                child: ListTile(
                  dense: false,
                  isThreeLine: false,
                  // contentPadding: EdgeInsets.all(0),
                  title: Text(semArray[0].toString()),
                  trailing: Icon(
                    Icons.arrow_right,
                    size: 30,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget programsPage() {
    List<String> program = widget.groupedByProgram.keys.toList();
    return Column(
      children: <Widget>[
        ListTile(
          // leading: SizedBox(),
          title: Text(
            "Program",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            textAlign: TextAlign.center,
          ),
        ),

        Expanded(
          child: ListView.separated(
            separatorBuilder: (context, index) => Divider(
              // indent: 10,
              // endIndent: 10,
              height: 0,
              color: Colors.grey,
            ),
            itemCount: program?.length ?? 0,
            itemBuilder: (context, i) {
              return InkWell(
                onTap: () {
                  var data = widget.groupedByProgram[program[i]];
                  setState(() {
                    widget.semester = groupBy(
                        data,
                        (obj) =>
                            obj['sem'].toString() +
                            "-" +
                            obj['semester_id'].toString()).keys.toList();
                  });
                  pagecontroller.animateToPage(
                    1,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                },
                child: ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  title: Text(program[i]),
                  trailing: Icon(
                    Icons.arrow_right,
                    size: 30,
                  ),
                ),
              );
            },
          ),
        ),
        // SizedBox(height: 100)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Stack(
        children: <Widget>[
          ClipPath(
            clipper: WaveClipperTwo(),
            child: Container(
                height: 250,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [primaryColor, primaryColor])),
                // color: Color(0xFFF55C20),
                child: null),
          ),
          Villain(
            villainAnimation: VillainAnimation.fromTop(
              // relativeOffset: 0.4,
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
                      SimpleLineIcons.getIconData("arrow-left"),
                      color: white,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  Text(
                    "Take Attendance",
                    style: TextStyle(color: white, fontSize: 20.0),
                  ),
                  SizedBox(
                    width: 30,
                  ),
                ],
              ),
            ),
          ),
          Center(
            child: AnimatedContainer(
              decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 5.0,
                    ),
                  ],
                  color: Colors.white,
                  borderRadius: new BorderRadius.only(
                      topLeft: const Radius.circular(40.0),
                      bottomLeft: const Radius.circular(40.0),
                      bottomRight: const Radius.circular(40.0),
                      topRight: const Radius.circular(40.0))),
              margin: EdgeInsets.only(top: 100, bottom: 15),
              width: MediaQuery.of(context).size.width * width,
              duration: Duration(seconds: 1),
              height: MediaQuery.of(context).size.height * height,
              child: PageView(
                dragStartBehavior: DragStartBehavior.down,
                controller: pagecontroller,
                physics: NeverScrollableScrollPhysics(),
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.all(10),
                    // color: primaryColor,
                    child: programsPage(),
                  ),
                  Container(
                    margin: EdgeInsets.all(10),
                    height: 100,
                    width: 100,
                    child: semesterPage(),
                  ),
                  Stack(
                    children: <Widget>[
                      studentWidget(),
                      isLoading
                          ? Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              bottom: 70,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: new BorderRadius.only(
                                      topLeft: const Radius.circular(40.0),
                                      // bottomLeft: const Radius.circular(40.0),
                                      // bottomRight: const Radius.circular(40.0),
                                      topRight: const Radius.circular(40.0)),
                                  color: Color.fromRGBO(0, 0, 0, 0.5),
                                ),
                                height:
                                    MediaQuery.of(context).size.height * height,
                                width:
                                    MediaQuery.of(context).size.height * width,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    CircularProgressIndicator(
                                      backgroundColor: white,
                                      strokeWidth: 2,
                                      // valueColor: primaryColor,
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      "Loading.....",
                                      style: TextStyle(
                                          color: white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Container()
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }
}

class Student {
  final String name;
  final int studentId;
  final int semesterId;
  final int id;
  Student({this.name, this.studentId, this.semesterId, this.id = 0});
  factory Student.fromJson(Map<String, dynamic> json, String state) {
    if (state == 'Update') {
      return Student(
          studentId: json['student_id'],
          name: json['name'],
          id: json['id'],
          semesterId: json['semester_id']);
    } else {
      return Student(
          studentId: json['student_id'],
          name: json['name'],
          semesterId: json['semester_id']);
    }
  }
}
