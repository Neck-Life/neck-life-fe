import 'package:url_launcher/url_launcher.dart';


class OpenUrlHelper {
  final Uri _ToSUrl = Uri.parse('https://cheerful-guardian-073.notion.site/Term-of-service-a040519dd560492c95ecf320c857c66a');
  final Uri _PPUrl = Uri.parse('https://cheerful-guardian-073.notion.site/Privacy-Policy-f50f241b48d44e74a4ffe9bbc9f87dcf?pvs=4');

  Future<void> openTermOfService() async {
    if (!await launchUrl(_ToSUrl)) {
      throw Exception('Could not launch');
    }
  }

  Future<void> openPrivacyPolicy() async {
    if (!await launchUrl(_PPUrl)) {
      throw Exception('Could not launch');
    }
  }

  Future<void> openUrl(String url) async {
    Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch');
    }
  }

}