import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;


class UserStatus with ChangeNotifier {
  static const String serverAddress = 'https://necklife.shop/api/v1';

  bool _isLogged = false;
  String _accessTokenTemp = '';
  String _refreshTokenTemp = '';

  bool get isLogged => _isLogged;

  UserStatus() {
    init();
  }

  void init() async {
    if (_accessTokenTemp == '' || _refreshTokenTemp == '') {
      const storage = FlutterSecureStorage();

      String? accessToken = await storage.read(key: 'accessToken');
      String? refreshToken = await storage.read(key: 'refreshToken');

      _accessTokenTemp = accessToken ?? '';
      _refreshTokenTemp = refreshToken ?? '';
      print('init $_accessTokenTemp $_refreshTokenTemp');
    }
    // jwt parsing을 통한 로그인 체크
  }

  void setIsLogged(bool isLogged) {
    _isLogged = isLogged;
    notifyListeners();
  }

  String _decodeBase64(String str) {
    String output = str.replaceAll('-', '+').replaceAll('_', '/');

    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw Exception('Illegal base64url string!"');
    }

    return utf8.decode(base64Url.decode(output));
  }

  Map<dynamic, dynamic> _parseJwtPayLoad(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('invalid token');
    }

    final payload = _decodeBase64(parts[1]);
    print(payload);
    final payloadMap = json.decode(payload);
    print(payloadMap);
    if (payloadMap is! Map<dynamic, dynamic>) {
      print('asdfasdfasdf');
      throw Exception('invalid payload');
    }
    return payloadMap;
  }

  Future<bool> verifyToken() async {
    const storage = FlutterSecureStorage();

    String? accessToken = await storage.read(key: 'accessToken');
    String? refreshToken = await storage.read(key: 'refreshToken');

    _accessTokenTemp = accessToken ?? '';
    _refreshTokenTemp = refreshToken ?? '';

    print('token: $_accessTokenTemp');
    if (_accessTokenTemp != '') {
      try {
        var payload = _parseJwtPayLoad(_accessTokenTemp)['data'];
        print(payload);
        _isLogged = true;
        return true;
      } catch (e) {
        print(e);
        _isLogged = false;
        return false;
      }
    }
    _isLogged = false;
    return false;
  }

  Future<dynamic> post(String url, dynamic body) async {
    final res = await http.post(
      Uri.parse(url),
      body: jsonEncode(body),
      headers: {"Content-Type": "application/json"},
    );
    return res;
  }

  Future<bool> deleteAccount() async {
    print(_accessTokenTemp);
    if (_accessTokenTemp == '') {
      return false;
    }

    final res = await http.delete(
      Uri.parse('$serverAddress/members'),
      headers: {
        "Content-Type": "application/json",
        HttpHeaders.authorizationHeader: 'Bearer $_accessTokenTemp'
      },
    );
    print(res.statusCode);
    if (res.statusCode ~/ 100 == 2) {
      return true;
    }

    return false;
  }

  Future<bool> socialLogin(String idToken, String provider) async {
    final res = await post(
        '$serverAddress/members',
        {'code': idToken, 'provider': provider}
    );
    print(res.statusCode);
    print(res.body);
    Map<String, dynamic> resData = jsonDecode(res.body);
    if (res.statusCode ~/ 100 == 2) {
      _isLogged = true;
      notifyListeners();

      _accessTokenTemp = resData['data']['accessToken'];
      _refreshTokenTemp = resData['data']['refreshToken'];

      const storage = FlutterSecureStorage();
      await storage.write(key: 'accessToken', value: resData['data']['accessToken']);
      await storage.write(key: 'refreshToken', value: resData['data']['refreshToken']);
      await storage.write(key: 'email', value: resData['data']['email'].toString());
      await storage.write(key: 'provider', value: resData['data']['provider'].toString());

      return true;
    }

    return false;
  }


  Future<dynamic> getRefreshedToken() async {
    if (_refreshTokenTemp == '') {
      return null;
    }

    final res = await post(
        '$serverAddress/members/token',
        {'refreshToken': _refreshTokenTemp}
    );

    Map<String, dynamic> resData = jsonDecode(res.boby);
    if (res.statusCode ~/ 100 == 2) {
      _accessTokenTemp = resData['data']['accessToken'];
      _refreshTokenTemp = resData['data']['refreshToken'];
    }

    const storage = FlutterSecureStorage();
    await storage.write(key: 'accessToken', value: _accessTokenTemp);
    await storage.write(key: 'refreshToken', value: _refreshTokenTemp);

  }

  void cleanAll() async {
    _accessTokenTemp = '';
    _refreshTokenTemp = '';

    const storage = FlutterSecureStorage();
    await storage.write(key: 'accessToken', value: '');
    await storage.write(key: 'refreshToken', value: '');
    await storage.write(key: 'memberId', value: '');
  }
}
