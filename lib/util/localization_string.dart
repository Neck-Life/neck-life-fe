
import 'package:easy_localization/easy_localization.dart';

class LS {
  static String tr(String key) {
    return key.tr().replaceAll("\\n", "\n");
  }
}