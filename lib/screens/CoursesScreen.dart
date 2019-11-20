import 'package:attendance/library/constant.dart';
import 'package:attendance/models/Courses.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_villains/villains/villains.dart';

class CoursesScreen extends StatefulWidget {
  final Future<List<Courses>> courses;
  CoursesScreen({this.courses});

  _CoursesScreenState createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  @override
  void initState() {
    super.initState();
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
                    "Courses",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: white, fontSize: 20.0),
                  ),
                  SizedBox(
                    width: 50,
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
                  margin: EdgeInsets.only(top: 100),
                  width: MediaQuery.of(context).size.width * 0.85,
                  duration: Duration(seconds: 1),
                  height: MediaQuery.of(context).size.height * 0.60,
                  child: FutureBuilder(
                    future: widget.courses,
                    builder: (context, projectSnap) {
                      if (projectSnap.hasData) {
                        return ListView.separated(
                          separatorBuilder: (context, index) => Divider(
                            indent: 10,
                            endIndent: 10,
                            height: 2,
                            color: Colors.grey,
                          ),
                          physics: BouncingScrollPhysics(),
                          itemCount: projectSnap.data.length,
                          itemBuilder: (context, i) {
                            return Container(
                              alignment: Alignment.center,
                              height: 60,
                              margin: EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                title: Text(projectSnap.data[i].courseName),
                                subtitle: Text(projectSnap.data[i].program +
                                    '(' +
                                    projectSnap.data[i].sem +
                                    ')'),
                              ),
                            );
                          },
                        );
                      } else {
                        return Container(
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                    },
                  ))),
        ],
      ),
    ));
  }
}
