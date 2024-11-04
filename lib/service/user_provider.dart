import 'dart:async';
import 'dart:ui';
import 'package:dio/dio.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:purchases_flutter/purchases_flutter.dart';

class UserStatus with ChangeNotifier {
  static const String serverAddress = 'http://necklife-prod-1214-env.eba-mtve9iwm.ap-northeast-2.elasticbeanstalk.com/api/v1';
  // static const String serverAddress = 'http://43.200.200.34/api/v1';
  final Dio dio = Dio();
  // late String currentTimeZone;
  final String language = Platform.localeName ;
  // final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;



  static bool sIsLogged = false;
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
    sIsLogged = false;
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

      // print('init $_accessTokenTemp $_refreshTokenTemp');
    }
  }

  void setIsLogged(bool isLogged) {
    _isLogged = isLogged;
    sIsLogged = isLogged;
    notifyListeners();
    print('setislogged $isLogged');
  }

  static String _decodeBase64(String str) {
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

  static Map<dynamic, dynamic> _parseJwtPayLoad(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('invalid token');
    }

    final payload = _decodeBase64(parts[1]);
    // print(payload);
    final payloadMap = json.decode(payload);
    // print(payloadMap);
    if (payloadMap is! Map<dynamic, dynamic>) {
      throw Exception('invalid payload');
    }
    return payloadMap;
  }

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
      // print('AccessToken 유효');
      // print("accessToken: $accessToken");
      // print("refreshToken: $refreshToken");

      _isLogged = true;
      sIsLogged = true;
      return true;
    } else if (refreshToken != null && !isTokenExpired(refreshToken)) {
      // accessToken이 만료되었지만 refreshToken이 유효할 경우
      // print('AccessToken 만료, RefreshToken으로 재발급 시도');
      await getRefreshedToken();
      return true;
    } else {
      // 둘 다 만료된 경우 로그아웃
      // print('AccessToken과 RefreshToken 모두 만료');

      _accessTokenTemp = '';
      _refreshTokenTemp = '';
      const storage = FlutterSecureStorage();
      await storage.delete(key: 'accessToken');
      await storage.delete(key: 'refreshToken');
      await storage.delete(key: 'email');

      _isLogged = false;
      sIsLogged = false;
      return false;
    }
  }

  // JWT 만료 여부 확인
  static bool isTokenExpired(String token) {
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


    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();

    if (_refreshTokenTemp == '') {
      return;
    }

    // print(_refreshTokenTemp);
    final res = await post(
      '$serverAddress/members/token',
      {'refreshToken': _refreshTokenTemp,
        'timeZone': currentTimeZone,
        'language' : language},
    );

    // print(res.statusCode);


    if (res.statusCode ~/ 100 == 2) {
      Map<String, dynamic> resData = jsonDecode(res.body);
      _accessTokenTemp = resData['data']['accessToken'];
      _refreshTokenTemp = resData['data']['refreshToken'];

      const storage = FlutterSecureStorage();
      await storage.write(key: 'accessToken', value: _accessTokenTemp);
      await storage.write(key: 'refreshToken', value: _refreshTokenTemp);

      // postFcmToken(storage);

      // print('토큰 재발급 완료: $_accessTokenTemp');
    } else {
      // print('토큰 재발급 실패');
      _accessTokenTemp = '';
      _refreshTokenTemp = '';
      const storage = FlutterSecureStorage();
      await storage.delete(key: 'accessToken');
      await storage.delete(key: 'refreshToken');
      await storage.delete(key: 'email');

      _isLogged = false;
      sIsLogged = false;
      notifyListeners();
    }
  }

  Future<void> getRefreshedTokenStatic(String refreshToken) async {
    if (refreshToken == '') {
      return;
    }
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();

    // print(_refreshTokenTemp);
    final res = await post(
      '$serverAddress/members/token',
      {'refreshToken': _refreshTokenTemp,
        'timeZone': currentTimeZone,
        'language' : language
      },
    );

    // print(res.statusCode);


    if (res.statusCode ~/ 100 == 2) {
      Map<String, dynamic> resData = jsonDecode(res.body);
      _accessTokenTemp = resData['data']['accessToken'];
      _refreshTokenTemp = resData['data']['refreshToken'];

      const storage = FlutterSecureStorage();
      await storage.write(key: 'accessToken', value: _accessTokenTemp);
      await storage.write(key: 'refreshToken', value: _refreshTokenTemp);

      // print('토큰 재발급 완료: $_accessTokenTemp');
    } else {
      // print('토큰 재발급 실패');
      _accessTokenTemp = '';
      _refreshTokenTemp = '';
      const storage = FlutterSecureStorage();
      await storage.delete(key: 'accessToken');
      await storage.delete(key: 'refreshToken');
      await storage.delete(key: 'email');

      _isLogged = false;
      sIsLogged = false;
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
    sIsLogged = false;
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
    _isLogged = false;
    sIsLogged = false;
    _isPremium = false;
    _email = '';

    const storage = FlutterSecureStorage();
    // await storage.deleteAll();
    await storage.delete(key: 'accessToken');
    await storage.delete(key: 'refreshToken');
    await storage.delete(key: 'memberId');
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
    // print(customerInfo);
    _isPremium = customerInfo.activeSubscriptions.isNotEmpty;
    notifyListeners();
    return _isPremium;
  }

  void setIsPremium(bool status) {
    _isPremium = status;
    notifyListeners();
  }

  Future<bool> socialLogin(String idToken, String provider) async {
    // await getTimeZone();
    // print('asdfasfsafsfs');
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();

    final res = await post(
        '$serverAddress/members',
        {'code': idToken, 'provider': provider,
          'timeZone': currentTimeZone, 'language' : language
        }
    );




    // print(res.statusCode);
    print(res.body);
    // print(res.statusCode);
    Map<String, dynamic> resData = jsonDecode(res.body);
    if (res.statusCode ~/ 100 == 2) {
      _isLogged = true;
      sIsLogged = true;

      _accessTokenTemp = resData['data']['accessToken'];
      _refreshTokenTemp = resData['data']['refreshToken'];
      _email = resData['data']['email'].toString();
      _initSubscriptionState();
      // notifyListeners();
      // print('login noti');

      const storage = FlutterSecureStorage();
      await storage.write(key: 'accessToken', value: resData['data']['accessToken']);
      await storage.write(key: 'refreshToken', value: resData['data']['refreshToken']);
      await storage.write(key: 'email', value: resData['data']['email'].toString());
      await storage.write(key: 'provider', value: resData['data']['provider'].toString());


      // await postFcmToken(storage);

      return true;
    }

    return false;
  }

  // Future<void> postFcmToken(FlutterSecureStorage storage) async {
  //   String? fcmToken =await _firebaseMessaging.getToken();
  //
  //   print("fcmtoken $fcmToken");
  //   if (fcmToken != null) {
  //     try {
  //       // 헤더 설정
  //       dio.options.headers = {
  //         'Content-Type': 'application/json',
  //       };
  //       if (_accessTokenTemp != null && _accessTokenTemp.isNotEmpty) {
  //         dio.options.headers['authorization'] = 'Bearer $_accessTokenTemp';
  //       } else {
  //         print("accessToken이 없습니다. 인증이 필요합니다.");
  //       }
  //
  //       // 서버로 FCM 토큰 전송
  //       final response = await dio.post(
  //         '$serverAddress/members/fcm',
  //         data: {'fcmToken': fcmToken},
  //       );
  //
  //       if (response.statusCode == 200) {
  //         print("FCM 토큰이 서버에 성공적으로 전송되었습니다.");
  //       } else {
  //         print("FCM 토큰 전송 실패: ${response.statusCode}");
  //       }
  //     } catch (e) {
  //       print("FCM 토큰 전송 중 오류 발생: $e");
  //     }
  //   }
  // }

  // Future<String> getTimeZone() async {
  //   currentTimeZone = await FlutterTimezone.getLocalTimezone();
  //   print('Current Time Zone: $currentTimeZone');
  //
  //   return currentTimeZone;
  // }

}