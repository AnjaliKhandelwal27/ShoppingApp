import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';
import 'dart:async';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;

  Future<void> _authentication(
      String email, String password, String urlSegment) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyCrU4N15QVE4GPHqDwZCtCyihLGGlMjeYQ';

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

      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(responseData['expiresIn']),
        ),
      );
      authTimerLogOut();
      notifyListeners();
      final prefs=await SharedPreferences.getInstance();
      final userData=json.encode({'token':_token,'userId':_userId,'expiryDate':_expiryDate.toIso8601String()});
      prefs.setString('userData', userData);
    } catch (error) {
      throw error;
    }
  }

  Future<bool> tryAutoLogIn()async{
    final prefs=await SharedPreferences.getInstance();
    if(!prefs.containsKey('userData'))
       return false;
    final extractedUserData=json.decode(prefs.get('userData') )as Map<String,Object>;
    final expiryDate=DateTime.parse(extractedUserData['expiryDate']);
    if(expiryDate.isBefore(DateTime.now()))
      return false;
    _token=extractedUserData['token'];
    _expiryDate=expiryDate;
    _userId=extractedUserData['userId'];
    notifyListeners();
    authTimerLogOut();
    return true;
  }

  bool get isAuth {
    return token != null;
  }
    String get userId{
    return _userId;
    }

    Future<void> logOut() async{
    _userId=null;
    _expiryDate=null;
    _token=null;
    if(_authTimer!=null){
      _authTimer.cancel();
      _authTimer=null;
    }
    notifyListeners();
    final prefs=await SharedPreferences.getInstance();
    prefs.clear();
    }

    void authTimerLogOut(){
    if(_authTimer!=null)
      _authTimer.cancel();
    final expiryTime=_expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer=Timer(Duration(seconds: expiryTime),logOut);
    }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) return _token;
    return null;
  }

  Future<void> signUp(String email, String password) async {
    return _authentication(email, password, 'signUp');
  }

  Future<void> loginIn(String email, String password) {
    return _authentication(email, password, 'signInWithPassword');

  }
}
