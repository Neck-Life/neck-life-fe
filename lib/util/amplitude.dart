import 'package:amplitude_flutter/amplitude.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AmplitudeEventManager {

  Future<void> initAmplitude(String? userId) async {
    final Amplitude analytics = Amplitude.getInstance();

    // Initialize SDK
    String amplitude_key = dotenv.get('AMPLITUDE_KEY');
    analytics.init(amplitude_key);
    if (userId != null) {
      analytics.setUserId(userId);
    }
    // Log an event
    analytics.logEvent('startup');
  }


  Future<void> viewEvent(String viewName) async {
    Amplitude.getInstance().logEvent('viewed_$viewName');
  }

  Future<void> actionEvent(String viewName, String actionName) async {
    Amplitude.getInstance().logEvent('action_${viewName}_$actionName');
  }
}