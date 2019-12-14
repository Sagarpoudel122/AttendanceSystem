import 'package:shared_preferences/shared_preferences.dart';

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
    return false;
  }
}
