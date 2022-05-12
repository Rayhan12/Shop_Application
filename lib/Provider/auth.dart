import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_application/Models/httpException.dart';

class Auth with ChangeNotifier {
  String token;
  DateTime _expireTime;
  String _userId;
  Timer _authTimer;

  bool get isAuth {
    return token != null;
  }

  String get userId
  {
    return _userId;
}
  String getToken() {
    if (token != null &&
        _userId != null &&
        _expireTime.isAfter(DateTime.now())) {
      return token;
    }
    return null;
  }

  Future<void> authBord(String email, String password, String segment) async {
    var url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$segment?key=AIzaSyDLNbjDsvRCA3vfqxVA_-BHDiK1J9SoDIo');
    try {
      final response = await http.post(url,
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true,
          }));

      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      token = responseData['idToken'];
      _userId = responseData['localId'];
      _expireTime = DateTime.now().add(Duration(seconds: int.parse(responseData['expiresIn'])));
      autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token' : token,
        'userId' : _userId,
        'expireTime' : _expireTime.toIso8601String()
      });
      prefs.setString("userData", userData);


    } catch (error) {
      throw error;
    }
  }

  Future<bool> autoLogin() async
  {
    final prefs =  await SharedPreferences.getInstance();
    if(!prefs.containsKey('userData')) return false;

    final userData = json.decode(prefs.getString("userData")) as Map<String , Object>;
    var time = DateTime.parse(userData['expireTime']);

    if(time.isBefore(DateTime.now())) return false;

    token = userData['token'];
    _userId = userData['userId'];
    _expireTime = time;
    notifyListeners();
    autoLogout();
    return true;

  }

  Future<void> userSignUp(String email, String password) async {
    return authBord(email, password, 'signUp');
  }

  Future<void> userLogin(String email, String password) async {
    return authBord(email, password, 'signInWithPassword');
  }
  void logout()
  {
    _userId = null;
    _expireTime = null;
    token = null;
    if(_authTimer !=null)
      {
        _authTimer.cancel();
        _authTimer = null;
      }
    notifyListeners();
  }

  void autoLogout()
  {
    if(_authTimer !=null) _authTimer.cancel();
    final timerData = _expireTime.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timerData) , logout);
  }

}
