import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mocksum_flutter/service/user_provider.dart';
import 'package:mocksum_flutter/theme/component/white_container.dart';
import 'package:mocksum_flutter/util/responsive.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:gsheets/gsheets.dart';
import 'package:provider/provider.dart';

import '../../../../theme/asset_icon.dart';
import '../../../../theme/component/button.dart';
import '../../../../theme/component/text_default.dart';
import '../../../../theme/popup.dart';
import '../../../../util/localization_string.dart';

class Survey extends StatefulWidget {
  const Survey({super.key});

  @override
  State<StatefulWidget> createState() => _SurveyState();
}

class _SurveyState extends State<Survey> {

  double _saticfaction = 5;
  final _editController = TextEditingController();

  final sheetId = '1QGJPIxu-wdwWsqQgjC4xjUgfjfIDG-v6kPyr1zuSFKQ';
  final sheetName = 'NeckLife-cs';

  static final credentials =
  {
    "type": "service_account",
    "project_id": "necklife-gsheet",
    "private_key_id": dotenv.get('GSHEET_ID'),
    "private_key": dotenv.get('GSHEET_KEY'),
    "client_email": "necklife-gsheet@necklife-gsheet.iam.gserviceaccount.com",
    "client_id": "110947472625244469504",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/necklife-gsheet%40necklife-gsheet.iam.gserviceaccount.com",
    "universe_domain": "googleapis.com"
  };

  final sheet = GSheets(credentials);
  Worksheet? _worksheet;

  @override
  void initState() {
    super.initState();
    gsheetInit();
  }


  Future<void> gsheetInit() async {
    final ss = await sheet.spreadsheet(sheetId);
    _worksheet = ss.worksheetByTitle(sheetName);
    _worksheet ??= await ss.addWorksheet(sheetName);
  }

  void _openErrorPopUp() {
    showDialog(context: context, builder: (ctx) {
      return CustomPopUp(text: LS.tr('login_view.login_error'));
    });
  }

  void _openSuccessPopUp() {
    showDialog(context: context, builder: (ctx) {
      return CustomPopUp(
        text: 'survey.popup'.tr(),
        onClick: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
      );
    });
  }

  Future<void> insert(String email) async {
    context.loaderOverlay.show();
    await _worksheet!.values.appendRow(fromColumn: 1, [email, _saticfaction, _editController.text]);
    context.loaderOverlay.hide();
  }

  @override
  Widget build(BuildContext context) {
    Responsive res = Responsive(context);
    UserStatus userStatus = Provider.of(context);

    return LoaderOverlay(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: AppBar(
              backgroundColor: const Color(0xFFF4F4F7),
              title:TextDefault(
                content: 'survey.title'.tr(),
                fontSize: 16,
                isBold: false,
                fontColor: const Color(0xFF64646F),
              ),
              centerTitle: true,
              leading: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const AssetIcon('arrowBack', color: Color(0xFF8991A0), size: 6,)
              )
          ),
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SizedBox(
            width: res.deviceWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: res.percentHeight(2)),
                WhiteContainer(
                  // margin: EdgeInsets.only(left: res.percentWidth(5)),
                  width: 87.5,
                  padding: EdgeInsets.symmetric(horizontal: res.percentWidth(5), vertical: res.percentHeight(2.5)),
                  radius: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextDefault(content: 'survey.txt1'.tr(), fontSize: 18, isBold: true),
                      SizedBox(height: res.percentHeight(0.5),),
                      TextDefault(
                        content: LS.tr('survey.desc1'),
                        fontSize: 13,
                        isBold: false,
                        fontColor: const Color(0xFF8991A0),
                      ),
                      SizedBox(height: res.percentHeight(2),),
                      SliderTheme(
                        data: SliderThemeData(
                            activeTrackColor: const Color(0xFF3077F4),
                            inactiveTrackColor: const Color(0xFFE5E5EB),
                            thumbColor: const Color(0xFF3077F4),
                            overlayShape: SliderComponentShape.noOverlay
                        ),
                        child: Slider(
                            value: _saticfaction,
                            max: 10,
                            min: 1,
                            divisions: 9,
                            onChanged: (double? value) {
                              setState(() {
                                _saticfaction = value!;
                              });
                            }
                        ),
                      ),
                      SizedBox(height: res.percentHeight(1),),
                      SizedBox(
                        width: res.percentWidth(85),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextDefault(content: "survey.min".tr(), fontSize: 13, isBold: false, fontColor: _saticfaction == 0 ? const Color(0xFF3077F4) : const Color(0xFF8991A0),),
                            // TextDefault(content: "setting_subpages.alarm_setting.alarm_setting_view.alarm_sensitive_middle".tr(), fontSize: 13, isBold: false, fontColor: _saticfaction == 1 ? const Color(0xFF3077F4) : const Color(0xFF8991A0),),
                            TextDefault(content: "survey.max".tr(), fontSize: 13, isBold: false, fontColor: _saticfaction == 2 ? const Color(0xFF3077F4) : const Color(0xFF8991A0),)
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: res.percentHeight(3),),
                WhiteContainer(
                  width: 87.5,
                  padding: EdgeInsets.symmetric(horizontal: res.percentWidth(5), vertical: res.percentHeight(2.5)),
                  radius: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextDefault(content: 'survey.ex_txt'.tr(), fontSize: 18, isBold: true),
                      SizedBox(height: res.percentHeight(2),),
                      TextField(
                        // scrollPadding: EdgeInsets.only(
                        //     bottom: MediaQuery.of(context).viewInsets.bottom),
                        maxLines: 5,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0xFFE5E5EB),
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(15)
                            ),
                            enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0xFFE5E5EB),
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(15)
                            ),
                            fillColor: const Color(0xFFF4F4F7),
                            filled: true
                        ),
                        controller: _editController,
                      )
                    ],
                  ),
                ),
                SizedBox(height: res.percentHeight(3),),
                Button(
                  onPressed: () async {
                    try {
                      if (_worksheet != null) {
                        await insert(userStatus.email);
                        print('fuck');
                        _openSuccessPopUp();
                      } else {
                        throw Exception();
                      }
                    } catch (e) {
                      print(e);
                      _openErrorPopUp();
                    }
                  },
                  text: 'survey.send'.tr(),
                  backgroundColor: const Color(0xFF236EF3),
                  color: Colors.white,
                  width: res.percentWidth(85),
                  padding: res.percentWidth(4),
                ),
                SizedBox(height: res.percentHeight(5),)
              ],
            ),
          ),
        ),
      )
    );
  }
}