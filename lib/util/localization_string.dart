import 'package:easy_localization/easy_localization.dart';

class LS {
  static String tr(String key, [List<dynamic>? args]) {
    return key.tr(args: args?.map((arg) => arg.toString()).toList() ?? []).replaceAll("\\n", "\n");
  }
}