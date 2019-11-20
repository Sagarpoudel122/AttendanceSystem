import 'dart:convert';

import 'package:attendance/components/ViewAttendance/Chart.dart';
import 'package:attendance/components/ViewAttendance/DetailAttendance.dart';
import 'package:attendance/library/constant.dart';
import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_villains/villain.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:charts_flutter/flutter.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class ViewAttendanceScreen extends StatefulWidget {
  List<dynamic> decodedCourse;
  Map<String, dynamic> groupedByProgram;
  List<String> semester = List<String>();

  ViewAttendanceScreen({this.decodedCourse}) {
    groupedByProgram =
        groupBy(this.decodedCourse, (obj) => obj['program_name']);
  }

  @override
  _ViewAttendanceScreenState createState() => _ViewAttendanceScreenState();
}

class _ViewAttendanceScreenState extends State<ViewAttendanceScreen>
    with TickerProviderStateMixin {
  static DateTime selectedDate = DateTime.now();
  String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
  int semesterId;
  double width = 0.85;
  double height = 0.80;
  PageController pagecontroller = PageController();
  Future loadedAttendance;
  Map<dynamic, dynamic> attendanceGroupedBy;
  var attendanceCountGroupedBy;
  List<ViewAttendanceChart> chartData = List<ViewAttendanceChart>();
  TabController _tabController;
  List<Tab> tabList = List();
  List<charts.Series<ViewAttendanceChart, String>> seriesData =
      List<charts.Series<ViewAttendanceChart, String>>();

  @override
  void initState() {
    tabList.add(new Tab(
      text: 'Overall',
    ));
    tabList.add(new Tab(
      text: 'Detail',
    ));
    this._tabController =
        new TabController(vsync: this, length: tabList.length, initialIndex: 0);
    super.initState();
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      String localformatted = DateFormat('yyyy-MM-dd').format(picked);
      setState(() {
        selectedDate = picked;
        formattedDate = localformatted;
        loadedAttendance = loadAttendance(localformatted);
      });
    }
  }

  var client = http.Client();

  Future<dynamic> loadAttendance(String date) async {
    var url = serverUrl + 'api/getAttendanceBySemester/';

    var response = await client.post(
      url,
      body: {
        "date": date,
        "semester_id": semesterId.toString(),
      },
    );
    if (response.statusCode == 200) {
      var data = json.decode(response.body)['data'];
      chartData.clear(); //Clear old chartData to avoid Duplicate

      if (data.length > 0) {
        attendanceGroupedBy = groupBy(data, (obj) => obj['value']);
        attendanceGroupedBy.forEach((k, v) {
          chartData.add(ViewAttendanceChart(value: k, count: v.length));
        });
        List<charts.Series<ViewAttendanceChart, String>> seriesData =
            List<charts.Series<ViewAttendanceChart, String>>();

        seriesData.add(
          charts.Series(
            domainFn: (ViewAttendanceChart pollution, _) => pollution.value,
            measureFn: (ViewAttendanceChart pollution, _) => pollution.count,
            id: '2018',
            data: chartData,
            fillPatternFn: (_, __) => charts.FillPatternType.solid,
            labelAccessorFn: (ViewAttendanceChart row, _) =>
                '${row.value}: ${row.count}',
          ),
        );
        return {"data": data, "chartData": seriesData};
      } else {
        return {"data": [], "chartData": []};
      }
    } else {
      return {"data": [], "chartData": []};
    }
  }

  Future loadChartData(List<ViewAttendanceChart> chartData) async {
    List<charts.Series<ViewAttendanceChart, String>> seriesData =
        List<charts.Series<ViewAttendanceChart, String>>();

    await seriesData.add(
      charts.Series(
        domainFn: (ViewAttendanceChart pollution, _) => pollution.value,
        measureFn: (ViewAttendanceChart pollution, _) => pollution.count,
        id: '2018',
        data: chartData,
        fillPatternFn: (_, __) => charts.FillPatternType.solid,
        labelAccessorFn: (ViewAttendanceChart row, _) =>
            '${row.value}: ${row.count}',
      ),
    );
    return seriesData;
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
                  DateTime tmpSelected = DateTime.now();
                  String tmpformattedDate =
                      DateFormat('yyyy-MM-dd').format(tmpSelected);

                  semesterId = int.parse(semArray[1]);
                  setState(() {
                    height = 0.80;
                    width = 0.9;
                    selectedDate = tmpSelected;
                    this.formattedDate = tmpformattedDate;
                    loadedAttendance = loadAttendance(tmpformattedDate);
                  });

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
                    "View Attendance",
                    style: TextStyle(color: white, fontSize: 20.0),
                  ),
                  SizedBox(
                    width: 20,
                  )
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
                  Container(
                    margin: EdgeInsets.all(10),
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                            height: 30,
                            child: Row(
                              children: <Widget>[
                                IconButton(
                                  onPressed: () {
                                    pagecontroller.animateToPage(
                                      1,
                                      duration:
                                          const Duration(milliseconds: 400),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                  icon: Icon(
                                    SimpleLineIcons.getIconData("arrow-left"),
                                    color: black,
                                    size: 20,
                                  ),
                                ),
                              ],
                            )),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(
                              height: 20,
                            ),
                            RaisedButton(
                              color: primaryColor,
                              onPressed: () => _selectDate(context),
                              child: Text(
                                'Select a date',
                                style: TextStyle(color: white),
                              ),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(right: 5),
                                  child: Text(
                                    "Current Date",
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                                Text(
                                  formattedDate.toString(),
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                            Divider(
                              color: Colors.grey,
                            ),
                          ],
                        ),
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              Container(
                                height: 38,
                                child: new TabBar(
                                    controller: _tabController,
                                    indicatorColor: primaryColor,
                                    labelStyle: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    labelColor: black,
                                    indicatorSize: TabBarIndicatorSize.tab,
                                    tabs: tabList),
                              ),
                              Expanded(
                                // height: 300.0,
                                child: TabBarView(
                                  controller: _tabController,
                                  children: <Widget>[
                                    Chart(
                                      loadedChartFuture: loadedAttendance,
                                      formattedDate: formattedDate,
                                    ),
                                    DetailAttendance(
                                      loadedAttendance: loadedAttendance,
                                      formattedDate: formattedDate,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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

class ViewAttendanceChart {
  final String value;
  final int count;
  final Color colorValue;

  ViewAttendanceChart({this.value, this.count, this.colorValue});
}
