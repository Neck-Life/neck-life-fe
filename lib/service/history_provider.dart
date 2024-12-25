import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:mocksum_flutter/service/user_provider.dart';

import '../main.dart';

class HistoryStatus {
  // static const String serverAddress = 'http://necklife-prod-1214-env.eba-mtve9iwm.ap-northeast-2.elasticbeanstalk.com/api/v1';
  // static const String serverAddressV3 = 'http://necklife-prod-1214-env.eba-mtve9iwm.ap-northeast-2.elasticbeanstalk.com/api/v3';
  static const String serverAddress = 'http://43.202.171.144:5000/api/v1'; // 마이그레이션서버
  static const String serverAddressV3 = 'http://43.202.171.144:5000/api/v3'; //마이그레이션서버 v3

  // static const String serverAddress = 'http://43.200.200.34/api/v1';
  // static const String serverAddressV3 = 'http://43.200.200.34/api/v3';

  static var dio = Dio();


  static Future<void> postMeasuredPoseData(dynamic pitchLog,dynamic forwardLog,dynamic tiltLog, dynamic rawData  ) async {
    // const storage = FlutterSecureStorage();

    print('postMeasuredPoseData');
    String? accessToken = await storage.read(key: 'accessToken');
    String? refreshToken = await storage.read(key: 'refreshToken');

    print('history post');
    print({'pitchLog': pitchLog});

    // print({'pitch': [pitchLog['pitch']] , 'forward': [forwardLog['forward']], 'tilt': [tiltLog['tilt']], 'rawData': rawData});




    try {
      // print(poseHistory);
      if (accessToken == null || UserStatus.isTokenExpired(accessToken)) {
        Response res = await dio.post(
            '$serverAddress/members/token', data: {'refreshToken': refreshToken});

        if (res.statusCode! ~/ 100 == 2) {
          accessToken = res.data['data']['accessToken'];
          refreshToken = res.data['data']['refreshToken'];

          await storage.write(key: 'accessToken', value: accessToken);
          await storage.write(key: 'refreshToken', value: refreshToken);
        } else{
          throw Exception();
        }
      }

      if (accessToken != null && accessToken != '') {
        dio.options.headers["authorization"] = "bearer $accessToken";
      }



      print({'pitch': [pitchLog['pitch']] ,'rawData': rawData, 'forward': [forwardLog['forward']], 'tilt': [tiltLog['tilt']]});
      // todo 데이터 전송방식이 바뀌어서 안보내졌을때 캐시에 저장하는거 수정되어야 함
      Response res = await dio.post(
          '$serverAddressV3/history', data: {'pitch': [pitchLog['pitch']] ,'rawData': rawData, 'forward': [forwardLog['forward']], 'tilt': [tiltLog['tilt']]});

      print(res.data);
      if (res.data['code'] == 'success') {
        print('success');
        return;
      } else {
        throw Exception();
      }
    } on Exception catch (e){
      print(e);

      //  todo 데이터 형식 바뀜  pitch
      // String? dataNotPostedPitch = await storage.read(key: 'dataNotPostedPitch');
      // dataNotPostedPitch ??= '[]';
      //
      //
      // List<dynamic> dataNotPostedPitchList = json.decode(dataNotPostedPitch);
      // dataNotPostedPitchList.add(pitchLog['pitch']);
      // // print(dataNotPostedList);
      // await storage.write(key: 'dataNotPostedPitch', value: json.encode(dataNotPostedPitchList));
      //
      //
      // //forward
      // String? dataNotPostedForward = await storage.read(key: 'dataNotPostedForward');
      // dataNotPostedForward ??= '[]';
      //
      //
      //
      // List<dynamic> dataNotPostedForwardList = json.decode(dataNotPostedForward);
      // dataNotPostedForwardList.add(forwardLog['forward']);
      // // print(dataNotPostedList);
      // await storage.write(key: 'dataNotPostedForward', value: json.encode(dataNotPostedForwardList));
      //
      //
      // //tilt
      // String? dataNotPostedTilt = await storage.read(key: 'dataNotPostedTilt');
      // dataNotPostedTilt ??= '[]';
      //
      //
      //
      // List<dynamic> dataNotPostedTiltList = json.decode(dataNotPostedTilt);
      // dataNotPostedTiltList.add(tiltLog['tilt']);
      // // print(dataNotPostedList);
      // await storage.write(key: 'dataNotPostedTilt', value: json.encode(dataNotPostedTiltList));
      //
      // //raw
      // String? dataNotPostedRaw = await storage.read(key: 'dataNotPostedRaw');
      // dataNotPostedRaw ??= '[]';
      //
      //
      //
      // List<dynamic> dataNotPostedRawList = json.decode(dataNotPostedRaw);
      // dataNotPostedRawList.add(rawData);
      // // print(dataNotPostedList);
      // await storage.write(key: 'dataNotPostedRaw', value: json.encode(dataNotPostedRawList));




    }
  }

  static Future<void> postDataNotPosted() async {
    // const storage = FlutterSecureStorage();

    // print('post not posted');
    String? accessToken = await storage.read(key: 'accessToken');
    if (accessToken != null && accessToken != '') {
      dio.options.headers["authorization"] = "bearer $accessToken";
    }

    String? dataNotPostedPitch = await storage.read(key: 'dataNotPostedPitch');
    String? dataNotPostedForward = await storage.read(key: 'dataNotPostedForward');
    String? dataNotPostedTilt = await storage.read(key: 'dataNotPostedTilt');
    String? dataNotPostedRaw = await storage.read(key: 'dataNotPostedRaw');
    if (dataNotPostedPitch == null || dataNotPostedPitch == '[]' || dataNotPostedForward == null || dataNotPostedForward == '[]' || dataNotPostedTilt == null || dataNotPostedTilt == '[]' || dataNotPostedRaw == null || dataNotPostedRaw == '[]') {
      return;
    }


    try {
      Response res = await dio.post(
          '$serverAddressV3/history', data: {'pitch': json.decode(dataNotPostedPitch), 'forward': json.decode(dataNotPostedForward), 'tilt': json.decode(dataNotPostedTilt), 'rawData': json.decode(dataNotPostedRaw)});
      if (res.data['code'] == 'success') {
        // print('success');
        // print('sened $dataNotPosted');
        await storage.write(key: 'dataNotPostedPitch', value: '[]');
        await storage.write(key: 'dataNotPostedForward', value: '[]');
        await storage.write(key: 'dataNotPostedTilt', value: '[]');
        await storage.write(key: 'dataNotPostedRaw', value: '[]');


        return;
      } else {
        throw Exception();
      }
    } on Exception {
      print('adsfasffsdfdsfsd');
      return;
    }
  }

  static Future<bool> sendFeedback(String content, String? email) async {
    try {
      print('feedback $content');
      Response res = await dio.post(
          '$serverAddress/members/inquiry',
          data: {"title": email ?? 'none', "content": content}
      );
      print('feedback start');
      print(res.data);
      if (res.data['code'] == 'success') {
        print('feedback sended');
        return true;
      }
      throw Exception();
    } on Exception {
      print('feedback send fail');
      return false;
    }
  }

//   Future<List<Map<String, dynamic>> _getUserGoals() {
//     try {
//       Response res = await dio.get('$serverAddress/goal');
//       if (res.data['code'] == 'success') {
//
//       }
//     }
// }
}
