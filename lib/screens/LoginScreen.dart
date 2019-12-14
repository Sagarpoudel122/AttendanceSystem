import 'dart:convert';

import 'package:attendance/library/constant.dart';
import 'package:attendance/screens/MainWidget.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_villains/villain.dart';
import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isRemember = false;
  String _email = "";
  String _password = "";
  bool isLoading = false;
  bool obscureText = true;
  final formKey = GlobalKey<FormState>();
  TextEditingController _controllerUsername, _controllerPassword;

  @override
  initState() {
    super.initState();
  }

  void toggleObscureText() {
    setState(() {
      obscureText = !obscureText;
    });
  }

  Future handleLogin() async {
    final form = formKey.currentState;

    if (form.validate()) {
      setState(() {
        isLoading = true;
      });
      var client = http.Client();
      var url = serverUrl + 'auth/login';

      try {
        var body = {'email': _email, 'password': _password};
        http.Response response = await client.post(url, body: body);
        int statusCode = response.statusCode;
        setState(() {
          isLoading = false;
        });

        if (statusCode == 200) {
          Navigator.pushReplacement(
            context,
            PageTransition(
                type: PageTransitionType.rightToLeft, child: MainWidget()),
          );
          var decodedData = json.decode(response.body);
          SharedPreferences.getInstance().then((prefs) {
            String _token = decodedData['token'];
            String _userInfo = json.encode(decodedData['user']);

            prefs.setString("token", _token);
            prefs.setString("userInfo", _userInfo);
          });
        } else if (statusCode == 401) {
          Flushbar(
            backgroundColor: Colors.redAccent,
            isDismissible: true,
            title: 'Error',
            message: 'Username or Password doesnt match',
            icon: Icon(
              Icons.error_outline,
              size: 28,
              color: Colors.white,
            ),
            duration: Duration(seconds: 3),
          )..show(context);
        } else if (statusCode == 400) {
        } else {
          Flushbar(
            backgroundColor: Colors.redAccent,
            isDismissible: true,
            title: 'Error',
            message: 'Server Error',
            icon: Icon(
              Icons.error_outline,
              size: 28,
              color: Colors.white,
            ),
            // leftBarIndicatorColor: Colors.blue.shade300,
            duration: Duration(seconds: 3),
          )..show(context);
        }
      } on Exception catch (_) {
        setState(() {
          isLoading = false;
        });
        Flushbar(
          backgroundColor: Colors.redAccent,
          isDismissible: true,
          title: 'Error',
          message: 'UnIdentified Server Error',
          icon: Icon(
            Icons.error_outline,
            size: 28,
            color: Colors.white,
          ),
          // leftBarIndicatorColor: Colors.blue.shade300,
          duration: Duration(seconds: 3),
        )..show(context);
      } finally {
        client.close();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var assetsImage = new AssetImage(
        'assets/images/icon.png'); //<- Creates an object that fetches an image.
    var image = new Image(
        image: assetsImage,
        height: 65,
        width: 65,
        fit: BoxFit.cover); //<- Creates a widget that displays an image.

    double totalWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      // bottomSheet: ,
      body: Stack(
        children: <Widget>[
          ClipPath(
            clipper: DiagonalPathClipperOne(),
            child: Container(
              height: 250,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [primaryColor, primaryColor])),
              // color: Color(0xFFF55C20),
              child: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircleAvatar(
                      minRadius: 35,
                      backgroundColor: Colors.transparent,
                      child: image),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Attendance System",
                    style: TextStyle(
                        color: white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              )),
            ),
          ),
          Villain(
            villainAnimation: VillainAnimation.fromBottom(
              relativeOffset: 0.4,
              from: Duration(milliseconds: 200),
              to: Duration(milliseconds: 400),
            ),
            child: Center(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  height: 380,
                  width: totalWidth * 0.90,
                  padding: EdgeInsets.symmetric(vertical: 25, horizontal: 15),
                  margin: EdgeInsets.only(top: 200),
                  decoration: BoxDecoration(
                    color: white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(bottom: 25),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  style: BorderStyle.solid,
                                  color: primaryColor,
                                  width: 2.0,
                                ),
                              ),
                            ),
                            child: const Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                "Login To Continue  ",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 18),
                          child: TextFormField(
                            onChanged: (val) => _email = val,
                            controller: _controllerUsername,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Username field is required';
                              }
                              return null;
                            },
                            autocorrect: false,
                            style: TextStyle(fontSize: 14),
                            decoration: new InputDecoration(
                              focusColor: primaryColor,
                              hoverColor: primaryColor,

                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12.0, horizontal: 10),
                              // filled: true,
                              fillColor: Colors.white,
                              border: new OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: new BorderSide(
                                      color: Color.fromRGBO(33, 33, 33, 0.8))),
                              hintText: "Enter your Username",
                              prefixIcon: Icon(
                                SimpleLineIcons.getIconData("envelope"),
                                color: primaryColor,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: TextFormField(
                            controller: _controllerPassword,
                            onChanged: (val) => _password = val,
                            obscureText: obscureText,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Password field is required';
                              }
                              return null;
                            },
                            style: TextStyle(fontSize: 14),
                            decoration: new InputDecoration(
                              suffixIcon: obscureText
                                  ? IconButton(
                                      onPressed: toggleObscureText,
                                      icon: Icon(
                                        Entypo.getIconData("eye"),
                                        color: primaryColor,
                                        size: 18,
                                      ),
                                    )
                                  : IconButton(
                                      onPressed: toggleObscureText,
                                      icon: Icon(
                                        Entypo.getIconData("eye-with-line"),
                                        color: primaryColor,
                                        size: 18,
                                      ),
                                    ),
                              focusColor: primaryColor,
                              hoverColor: Colors.red,

                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12.0, horizontal: 10),
                              // filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: new BorderSide(
                                      color: const Color.fromRGBO(
                                          33, 33, 33, 0.8))),
                              hintText: "Enter your Password",
                              prefixIcon: Icon(
                                SimpleLineIcons.getIconData("lock"),
                                color: primaryColor,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Checkbox(
                                    value: this.isRemember,
                                    onChanged: (bool value) {
                                      setState(() {
                                        this.isRemember = value;
                                      });
                                    },
                                  ),
                                  Text("Remember Me")
                                ],
                              ),
                              FlatButton(
                                onPressed: () => {},
                                child: Text("Forget Password"),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          width: totalWidth * 0.65,
                          height: 40,
                          child: RaisedButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(15.0),
                            ),
                            onPressed: () => {this.handleLogin()},
                            color: primaryColor,
                            child: isLoading
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      const Text(
                                        "Loading....",
                                        style: TextStyle(
                                            color: white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      Padding(
                                          padding:
                                              const EdgeInsets.only(left: 4),
                                          child: SizedBox(
                                            child: CircularProgressIndicator(
                                              backgroundColor: white,
                                            ),
                                            height: 20.0,
                                            width: 20.0,
                                          ))
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      const Text(
                                        "Login",
                                        style: TextStyle(
                                            color: white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 4),
                                        child: Icon(
                                          SimpleLineIcons.getIconData("login"),
                                          color: white,
                                        ),
                                      )
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
