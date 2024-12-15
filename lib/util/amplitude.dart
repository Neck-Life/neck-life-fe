import 'dart:developer';

import 'package:amplitude_flutter/amplitude.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AmplitudeEventManager {

  Future<void> initAmplitude() async {
    final Amplitude analytics = Amplitude.getInstance();

    // Initialize SDK
    String amplitudeKey = dotenv.get('AMPLITUDE_KEY');
    // print('amp $amplitude_key');
    analytics.init(amplitudeKey);

    // Log an event
    analytics.logEvent('startup');
  }

  Future<void> setUserID(String? userid) async {
    if (userid != null) {
      await Amplitude.getInstance().setUserId(userid);
    }
  }


  Future<void> viewEvent(String viewName) async {
    await Amplitude.getInstance().logEvent('viewed_$viewName');
    // print('viewed_$viewName');
  }

  Future<void> actionEvent(String viewName, String actionName, [dynamic property, dynamic property2, Map<String, dynamic>? additionalInfo]) async {
    try {
      if (actionName == 'enddetection') {
        await Amplitude.getInstance().logEvent('action_${viewName}_$actionName',
            eventProperties: {'usedTime': property, 'alarmCount': property2});
        return;
      }
      else if (actionName == 'startdetection') {
        await Amplitude.getInstance().logEvent('action_${viewName}_$actionName',
            eventProperties: {
              'settedTime': property,
              'alarmCount': property2,
              ...?additionalInfo
            });
        return;
      }
      else if (actionName == 'set_goal') {
        await Amplitude.getInstance().logEvent('action_${viewName}_$actionName',
            eventProperties: {'goaltype': property, 'setted_value': property2});
      }
      else {
        await Amplitude.getInstance().logEvent(
            'action_${viewName}_$actionName');
      }
      // print('action_${viewName}_$actionName');
    } on Exception catch (e) {
      log('$e');
    }
  }
}