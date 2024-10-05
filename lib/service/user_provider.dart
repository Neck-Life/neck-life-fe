import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:purchases_flutter/purchases_flutter.dart';

class UserStatus with ChangeNotifier {
  static const String serverAddress = 'http://necklife-prod-1214-env.eba-mtve9iwm.ap-northeast-2.elasticbeanstalk.com/api/v1';
  // static const String serverAddress = 'http://13.125.107.140:8080/api/v1';

  bool _isLogged = false;
  bool _isPremium = false;
  String _accessTokenTemp = '';
  String _refreshTokenTemp = '';
  String _email = '';

  bool get isLogged => _isLogged;
  bool get isPremium => _isPremium;
  String get email => _email;

  UserStatus() {
    init();
  }


  void clearAll() {
    _isLogged = false;
    _isPremium = false;
    _accessTokenTemp = '';
    _refreshTokenTemp = '';
    _email = '';
  }

  void init() async {
    if (_accessTokenTemp == '' || _refreshTokenTemp == '') {
      const storage = FlutterSecureStorage();

      String? accessToken = await storage.read(key: 'accessToken');
      String? refreshToken = await storage.read(key: 'refreshToken');
      String? email = await storage.read(key: 'email');

      _accessTokenTemp = accessToken ?? '';
      _refreshTokenTemp = refreshToken ?? '';
      _email = email ?? '';

      await _initSubscriptionState();

      print('init $_accessTokenTemp $_refreshTokenTemp');
    }
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
      throw Exception('invalid payload');
    }
    return payloadMap;
  }

  // Future<bool> verifyToken() async {
  //   const storage = FlutterSecureStorage();
  //
  //   String? accessToken = await storage.read(key: 'accessToken');
  //   String? refreshToken = await storage.read(key: 'refreshToken');
  //
  //   _accessTokenTemp = accessToken ?? '';
  //   _refreshTokenTemp = refreshToken ?? '';
  //
  //   print('token: $_accessTokenTemp');
  //   if (_accessTokenTemp != '') {
  //     try {
  //       var payload = _parseJwtPayLoad(_accessTokenTemp)['data'];
  //       print(payload);
  //       _isLogged = true;
  //       return true;
  //     } catch (e) {
  //       print(e);
  //       _isLogged = false;
  //       return false;
  //     }
  //   }
  //   _isLogged = false;
  //   return false;
  // }

  // AccessToken과 RefreshToken을 확인하여 처리하는 함수
  Future<bool> checkAndUpdateToken() async {
    const storage = FlutterSecureStorage();
    String? accessToken = await storage.read(key: 'accessToken');
    String? refreshToken = await storage.read(key: 'refreshToken');

    // accessToken ='';
    // refreshToken ='';
    _accessTokenTemp = accessToken ?? '';
    _refreshTokenTemp = refreshToken ?? '';

    if (accessToken != null && !isTokenExpired(accessToken)) {
      // accessToken이 만료되지 않았을 경우
      print('AccessToken 유효');
      print("accessToken: $accessToken");
      print("refreshToken: $refreshToken");

      _isLogged = true;
      return true;
    } else if (refreshToken != null && !isTokenExpired(refreshToken)) {
      // accessToken이 만료되었지만 refreshToken이 유효할 경우
      print('AccessToken 만료, RefreshToken으로 재발급 시도');
      await getRefreshedToken();
      return true;
    } else {
      // 둘 다 만료된 경우 로그아웃
      print('AccessToken과 RefreshToken 모두 만료');

      _isLogged = false;
      return false;
    }
  }

  // JWT 만료 여부 확인
  bool isTokenExpired(String token) {
    try {
      final parts = _parseJwtPayLoad(token);
      final exp = parts['exp'];
      final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return expiryDate.isBefore(DateTime.now());
    } catch (e) {
      return true;
    }
  }

  Future<dynamic> post(String url, dynamic body) async {
    final res = await http.post(
      Uri.parse(url),
      body: jsonEncode(body),
      headers: {"Content-Type": "application/json"},
    );
    return res;
  }

  Future<void> getRefreshedToken() async {
    if (_refreshTokenTemp == '') {
      return;
    }

    print(_refreshTokenTemp);
    final res = await post(
      '$serverAddress/members/token',
      {'refreshToken': _refreshTokenTemp},
    );

    print(res.statusCode);


    if (res.statusCode ~/ 100 == 2) {
      Map<String, dynamic> resData = jsonDecode(res.body);
      _accessTokenTemp = resData['data']['accessToken'];
      _refreshTokenTemp = resData['data']['refreshToken'];

      const storage = FlutterSecureStorage();
      await storage.write(key: 'accessToken', value: _accessTokenTemp);
      await storage.write(key: 'refreshToken', value: _refreshTokenTemp);

      print('토큰 재발급 완료: $_accessTokenTemp');
    } else {
      print('토큰 재발급 실패');
      _accessTokenTemp = '';
      _refreshTokenTemp = '';
      const storage = FlutterSecureStorage();
      await storage.delete(key: 'accessToken');
      await storage.delete(key: 'refreshToken');
      await storage.delete(key: 'email');

      _isLogged = false;
      notifyListeners();

    }
  }

  Future<void> handleLogout(BuildContext context) async {
    _accessTokenTemp = '';
    _refreshTokenTemp = '';

    const storage = FlutterSecureStorage();
    await storage.delete(key: 'accessToken');
    await storage.delete(key: 'refreshToken');
    await storage.delete(key: 'email');

    _isLogged = false;
    notifyListeners();

    Navigator.of(context).pushReplacementNamed('/logout');
  }

  Future<bool> deleteAccount(String deleteReason) async {
    if (_accessTokenTemp == '') {
      return false;
    }
    Map<String, dynamic> body = {'reason': deleteReason};

    final res = await http.delete(
      Uri.parse('$serverAddress/members'),
      body: jsonEncode(body),
      headers: {
        "Content-Type": "application/json",
        HttpHeaders.authorizationHeader: 'Bearer $_accessTokenTemp'
      },
    );

    if (res.statusCode ~/ 100 == 2) {
      cleanAll();
      return true;
    }

    return false;
  }

  void cleanAll() async {
    _accessTokenTemp = '';
    _refreshTokenTemp = '';

    const storage = FlutterSecureStorage();
    await storage.deleteAll();
    // await storage.delete(key: 'accessToken');
    // await storage.delete(key: 'refreshToken');
    // await storage.delete(key: 'memberId');
  }

  Future<void> _initSubscriptionState() async {
    String revenuecat_key = dotenv.get('REVENUECAT_KEY');

    await Purchases.setLogLevel(LogLevel.debug);
    await Purchases.configure(
      PurchasesConfiguration(revenuecat_key)..appUserID = _email,
    );

    await getUserIsPremium();
  }

  Future<bool> getUserIsPremium() async {
    CustomerInfo customerInfo = await Purchases.getCustomerInfo();
    print(customerInfo);
    _isPremium = customerInfo.activeSubscriptions.isNotEmpty;
    notifyListeners();
    return _isPremium;
  }

  void setIsPremium(bool status) {
    _isPremium = status;
    notifyListeners();
  }

  Future<bool> socialLogin(String idToken, String provider) async {
    print('asdfasfsafsfs');
    final res = await post(
        '$serverAddress/members',
        {'code': idToken, 'provider': provider}
    );
    print(res.statusCode);
    print(res.body);
    print(res.statusCode);
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
}
