import 'dart:convert';

import 'package:attendance/library/constant.dart';
import 'package:attendance/screens/DashboardScreen.dart';
import 'package:attendance/screens/SettingScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'HidenDrawer.dart';

class MainWidget extends StatefulWidget {
  MainWidget({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MainWidgetState createState() => _MainWidgetState();
}

class _MainWidgetState extends State<MainWidget> with TickerProviderStateMixin {
  HiddenDrawerController _drawerController;
  String fullname = ".........";

  Future<SharedPreferences> loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs;
  }

  logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("userInfo");
    prefs.remove("token");
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
  }

  @override
  void initState() {
    super.initState();

    loadUserInfo().then((onValue) {
      var decoded = json.decode(onValue.getString("userInfo"));
      setState(() {
        fullname =
            decoded['name'].length > 0 ? decoded['name'] : decoded['username'];
      });
    });
    _drawerController = HiddenDrawerController(
      initialPage: DashboardScreen(),
      items: [
        DrawerItem(
          text: Text(
            'Dashboard',
            style: TextStyle(
                color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
          ),
          icon: Icon(
            SimpleLineIcons.getIconData("home"),
            color: white,
            size: 22,
          ),
          page: DashboardScreen(),
        ),
        DrawerItem(
          text: Text(
            'Settings',
            style: TextStyle(
                color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
          ),
          icon: Icon(
            SimpleLineIcons.getIconData("settings"),
            color: white,
            size: 22,
          ),
          page: SettingScreen(),
        ),
        DrawerItem(
          onPressed: () {
            logout();
          },
          text: Text(
            'Logout',
            style: TextStyle(
                color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
          ),
          icon: Icon(
            SimpleLineIcons.getIconData("logout"),
            color: white,
            size: 22,
          ),
          page: DrawerContent(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HiddenDrawer(
        controller: _drawerController,
        header: Align(
          alignment: Alignment.topLeft,
          child: Column(
            children: <Widget>[
              Container(
                // height: 75,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.red, width: 1)),
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                width: MediaQuery.of(context).size.width * 0.6,
                child: ClipOval(
                  child: Image(
                    fit: BoxFit.contain,
                    image: NetworkImage(
                      'https://www.pngarts.com/files/3/Cool-Avatar-Transparent-Image.png',
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 6,
              ),
              Text(
                fullname,
                style: TextStyle(color: Colors.white, fontSize: 20),
              )
            ],
          ),
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Colors.deepPurple[500], Colors.purple[500], Colors.purple],
            tileMode: TileMode.repeated,
          ),
        ),
      ),
    );
  }
}
