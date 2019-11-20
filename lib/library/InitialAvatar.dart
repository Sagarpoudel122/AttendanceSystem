import 'package:flutter/material.dart';

import 'constant.dart';

String getInitials(String nameString) {
  if (nameString.isEmpty) return " ";

  List<String> nameArray =
      nameString.replaceAll(new RegExp(r"\s+\b|\b\s"), " ").split(" ");
  String initials = ((nameArray[0])[0] != null ? (nameArray[0])[0] : " ") +
      (nameArray.length == 1 ? " " : (nameArray[nameArray.length - 1])[0]);

  return initials;
}

class InitialAvatar extends StatelessWidget {
  final String nameString;

  const InitialAvatar({Key key, this.nameString}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 40,
      padding: EdgeInsets.only(top: 5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(90), color: primaryColor),
      child: Text(
        getInitials(nameString),
        textAlign: TextAlign.center,
        style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: 1),
      ),
    );
  }
}
