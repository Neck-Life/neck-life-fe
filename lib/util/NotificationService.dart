// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
//
// class NotificationService {
//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
//   final Dio dio = Dio();
//   final storage = FlutterSecureStorage(); // Flutter Secure Storage 인스턴스 생성
//
//
//   // static const String serverAddress = 'http://43.200.200.34/api/v1';
//   // static const String serverAddressV3 = 'http://43.200.200.34/api/v3';
//
//
//   static const String serverAddress = 'http://necklife-prod-1214-env.eba-mtve9iwm.ap-northeast-2.elasticbeanstalk.com/api/v1';
//
//   // FirebaseMessaging 초기화 및 FCM 토큰 전송
//   Future<void> initFirebaseMessaging() async {
//     // FCM 토큰 가져오기
//     String? fcmToken = await _firebaseMessaging.getToken();
//
//
//     if (fcmToken != null) {
//       print("FCM Token: $fcmToken");
//       await sendTokenToServer(fcmToken); // 서버로 FCM 토큰 전송
//     }
//
//     NotificationSettings settings = await _firebaseMessaging.requestPermission(
//       alert: true,
//       sound: true,
//     );
//
//     // 권한 상태 확인
//     if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//       print('User granted permission');
//     } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
//       print('User granted provisional permission');
//     } else {
//       print('User declined or has not accepted permission');
//     }
//
//
//     // 토큰이 갱신될 때마다 서버로 전송
//     FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
//       sendTokenToServer(newToken);
//       storage.write(key: 'fcmToken', value: newToken);
//     });
//   }
//
//   // FCM 토큰을 서버로 전송하는 메서드
//   Future<void> sendTokenToServer(String fcmToken) async {
//     try {
//       // 스토리지에서 accessToken 가져오기
//       String? accessToken = await storage.read(key: 'accessToken');
//
//       // accessToken이 존재하면 Authorization 헤더에 추가
//       if (accessToken != null && accessToken.isNotEmpty) {
//         dio.options.headers["authorization"] = "Bearer $accessToken";
//       } else {
//         print("accessToken이 없습니다. 인증이 필요합니다.");
//
//
//
//         return;
//       }
//
//       // 서버로 FCM 토큰 전송
//       final response = await dio.post(
//         'https://$serverAddress/members/fcm',
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