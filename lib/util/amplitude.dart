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

  Future<void> actionEvent(String viewName, String actionName, [int? property, int? property2]) async {
    if (actionName == 'enddetection') {
      await Amplitude.getInstance().logEvent('action_${viewName}_$actionName', eventProperties: {'usedTime': property, 'alarmCount': property2});
      return;
    }
    await Amplitude.getInstance().logEvent('action_${viewName}_$actionName');
    // print('action_${viewName}_$actionName');

  }
}