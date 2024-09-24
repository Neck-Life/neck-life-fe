import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:purchases_flutter/purchases_flutter.dart';


class UserStatus with ChangeNotifier {
  static const String serverAddress = 'http://necklife-prod-1214-env.eba-mtve9iwm.ap-northeast-2.elasticbeanstalk.com/api/v1';

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

  void init() async {
    if (_accessTokenTemp == '' || _refreshTokenTemp == '') {
      const storage = FlutterSecureStorage();

      // await storage.write(key: 'accessToken', value: _accessTokenTemp);

      String? accessToken = await storage.read(key: 'accessToken');
      String? refreshToken = await storage.read(key: 'refreshToken');
      String? email = await storage.read(key: 'email');
      // print(accessToken);

      _accessTokenTemp = accessToken ?? '';
      _refreshTokenTemp = refreshToken ?? '';
      _email = email ?? '';

      await _initSubscriptionState();
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
    // print(payload);
    final payloadMap = json.decode(payload);
    // print(payloadMap);
    if (payloadMap is! Map<dynamic, dynamic>) {
      // print('asdfasdfasdf');
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

    // print('token: $_accessTokenTemp');
    if (_accessTokenTemp != '') {
      try {
        var payload = _parseJwtPayLoad(_accessTokenTemp)['data'];
        // print(payload);
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

  Future<bool> deleteAccount(String deleteReason) async {
    // print(_accessTokenTemp);
    if (_accessTokenTemp == '') {
      return false;
    }
    Map<String, dynamic> body = {'withDrawReason': deleteReason};

    // print(deleteReason);
    final res = await http.delete(
      Uri.parse('$serverAddress/members'),
      body: jsonEncode(body),
      headers: {
        "Content-Type": "application/json",
        HttpHeaders.authorizationHeader: 'Bearer $_accessTokenTemp'
      },
    );
    // print(res.statusCode);
    if (res.statusCode ~/ 100 == 2) {
      // cleanAll();
      return true;
    }

    return false;
  }

  Future<bool> socialLogin(String idToken, String provider) async {
    final res = await post(
        '$serverAddress/members',
        {'code': idToken, 'provider': provider}
    );
    // print(res.statusCode);
    // print(res.body);
    // print(res.statusCode);
    Map<String, dynamic> resData = jsonDecode(res.body);
    if (res.statusCode ~/ 100 == 2) {
      _isLogged = true;
      notifyListeners();

      _accessTokenTemp = resData['data']['accessToken'];
      _refreshTokenTemp = resData['data']['refreshToken'];
      print(_accessTokenTemp);
      print(resData['data']['accessToken']);

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

  Future<void> _initSubscriptionState() async {
    String revenuecat_key = dotenv.get('REVENUECAT_KEY');

    await Purchases.setLogLevel(LogLevel.debug);
    await Purchases.configure(
      PurchasesConfiguration(revenuecat_key)
        ..appUserID = _email
    );

    await getUserIsPremium();
  }

  Future<bool> getUserIsPremium() async {
    CustomerInfo customerInfo = await Purchases.getCustomerInfo();
    // print(customerInfo);
    _isPremium =  customerInfo.entitlements.all['necklife']!.isActive;
    notifyListeners();
    return _isPremium;
  }

  void setIsPremium(bool status) {
    _isPremium = status;
    notifyListeners();
  }
}
