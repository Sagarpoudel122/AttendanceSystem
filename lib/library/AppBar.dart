import 'package:attendance/library/constant.dart';
import 'package:flutter/material.dart';

class MyAppbar extends StatelessWidget implements PreferredSizeWidget {
  double height = 50;
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: white,
      leading: null,
      centerTitle: false,
      elevation: 0,
      title: Text(
        "Nepathya Attendance System",
        style: TextStyle(fontSize: 16, color: black),
      ),
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(height);
}

class MiniAppbar extends StatelessWidget implements PreferredSizeWidget {
  double height = 10;
  @override
  Widget build(BuildContext context) {
    return PreferredSize(
        preferredSize: Size.fromHeight(10.0), // here the desired height
        child: AppBar(
          backgroundColor: white,
          leading: IconButton(
            onPressed: () {
              // Future.delayed(const Duration(milliseconds: 100), () {
              //   setState(() {
              //     height = 0.60;
              //     width = 0.85;
              //   });
              // });
              // pagecontroller.animateToPage(
              //   1,
              //   duration: const Duration(milliseconds: 400),
              //   curve: Curves.easeInOut,
              // );
            },
            icon: Icon(
              Icons.arrow_left,
              color: Colors.black,
            ),
          ),
          centerTitle: false,
          elevation: 0,
          title: Text(
            "Student",
            style: TextStyle(fontSize: 16, color: black),
          ),
        ));
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(height);
}
