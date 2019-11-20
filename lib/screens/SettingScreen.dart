import 'package:attendance/library/constant.dart';
import 'package:attendance/screens/HidenDrawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_villains/villain.dart';

class SettingScreen extends DrawerContent {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
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
                      "Settings",
                      style: TextStyle(color: white, fontSize: 20.0),
                    ),
                    Container()
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
