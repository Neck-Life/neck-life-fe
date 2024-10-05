import 'package:amplitude_flutter/amplitude.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AmplitudeEventManager {

  Future<void> initAmplitude(String? userId) async {
    final Amplitude analytics = Amplitude.getInstance();

    // Initialize SDK
    String amplitudeKey = dotenv.get('AMPLITUDE_KEY');
    // print('amp $amplitude_key');
    analytics.init(amplitudeKey);
    if (userId != null) {
      analytics.setUserId(userId);
    }
    // Log an event
    analytics.logEvent('startup');
  }


  Future<void> viewEvent(String viewName) async {
    await Amplitude.getInstance().logEvent('viewed_$viewName');
    print('viewed_$viewName');
  }

  Future<void> actionEvent(String viewName, String actionName) async {
    await Amplitude.getInstance().logEvent('action_${viewName}_$actionName');
    print('action_${viewName}_$actionName');

  }
}