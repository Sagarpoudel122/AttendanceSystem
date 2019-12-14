import 'package:attendance/screens/LoginScreen.dart';
import 'package:attendance/screens/MainWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_villains/villains/villains.dart';

import 'library/Authentication.dart';
import 'library/constant.dart';

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
            return CircularProgressIndicator();
          }),
    );
  }
}
