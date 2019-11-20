import 'package:attendance/screens/DashboardScreen.dart';
import 'package:attendance/screens/LoginScreen.dart';
import 'package:attendance/screens/MainWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_villains/villains/villains.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'library/constant.dart';

Future<bool> checkIfAuthenticated() async {
  try {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    var _token = _prefs.getString("token") ?? "";
    var _userInfo = _prefs.getString("userInfo") ?? "";

    if (_token.length > 0 && _userInfo.length > 0) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    print(e);
  }
}

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      navigatorObservers: [new VillainTransitionObserver()],
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        backgroundColor: white,
        primarySwatch: Colors.blue,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      routes: {
        '/login': (context) => LoginScreen(),
      },
      home: FutureBuilder<bool>(
          future: checkIfAuthenticated(),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (snapshot.hasData) {
              bool user = snapshot.data;
              return user ? MainWidget() : LoginScreen();
            }
            return LoginScreen();
          }),
    );
  }
}
