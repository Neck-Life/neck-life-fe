import 'package:flutter/material.dart';
import 'package:mocksum_flutter/service/user_provider.dart';
import 'package:mocksum_flutter/theme/asset_icon.dart';
import 'package:mocksum_flutter/theme/component/text_default.dart';
import 'package:mocksum_flutter/view/tutorial/page_idx_tile.dart';
import 'package:provider/provider.dart';
// import 'login.dart';
// import 'util/responsive.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'package:mocksum_flutter/view/login/login_view.dart';
import '../../theme/component/button.dart';
import '../../theme/component/person_icon.dart';
import '../../util/responsive.dart';

class Tutorials extends StatefulWidget {
  const Tutorials({super.key});

  @override
  State<StatefulWidget> createState() => _TutorialState();
}

class _TutorialState extends State<Tutorials> {
  int _pageNum = 0;
  final CarouselSliderController _btnController = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    Responsive res = Responsive(context);
    UserStatus userStatus = context.read();
    return Scaffold(
      body: Container(
        width: res.percentWidth(100),
        height: res.percentHeight(100),
        // padding: EdgeInsets.only(left: responsive.percentWidth(7.5)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 65,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PageIdxTile(isNowTap: _pageNum == 0,),
                PageIdxTile(isNowTap: _pageNum == 1,),
                PageIdxTile(isNowTap: _pageNum == 2,),
              ],
            ),
            Container(
              // width: res.percentWidth(15),
              margin: EdgeInsets.only(left: res.percentWidth(7.5), top: res.percentHeight(5)),
              padding: EdgeInsets.symmetric(vertical: res.percentHeight(1), horizontal: res.percentWidth(3)),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: const Color(0xFF236EF3),
                  width: 1
                )
              ),
              child: TextDefault(content: 'Step ${_pageNum+1}', fontSize: 16, isBold: true, fontColor: const Color(0xFF236EF3),),
            ),
            CarouselSlider(
                carouselController: _btnController,
                items: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: res.percentHeight(2),),
                      Container(
                          width: res.deviceWidth,
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(left: res.percentWidth(7.5)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const TextDefault(
                                content: '먼저 에어팟을\n연결해주세요',
                                fontSize: 28,
                                isBold: true,
                                fontColor: Color(0xFF323238),
                              ),
                              SizedBox(height: res.percentHeight(2),),
                              const Row(
                                children: [
                                  AssetIcon('infoCircle', size: 4.5, color: Color(0xFF236EF3),),
                                  SizedBox(width: 5,),
                                  TextDefault(
                                    content: '아래 명시된 기종들만 사용 가능해요',
                                    fontSize: 15,
                                    isBold: false,
                                    fontColor: Color(0xFF236EF3),
                                  ),
                                ],
                              ),
                              const TextDefault(
                                content: 'AirPods Pro, AirPods Max, AirPods(3세대)',
                                fontSize: 15,
                                isBold: false,
                                fontColor: Color(0xFF64646F),
                              ),
                              Container(
                                width: res.percentWidth(50),
                                height: res.percentWidth(50),
                                padding: EdgeInsets.all(res.percentWidth(8)),
                                margin: EdgeInsets.only(left: res.percentWidth(17.5), top: res.percentWidth(15)),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFFFFF),
                                  borderRadius: BorderRadius.circular(res.percentWidth(25)),
                                ),
                                child: Image.asset("assets/airpods.png")
                              )
                            ],
                          )
                      )
                    ]
                  ),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: res.percentHeight(2),),
                        Container(
                            width: res.deviceWidth,
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.only(left: res.percentWidth(7.5)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const TextDefault(
                                  content: '5초 동안 바른 자세를\n유지해주세요',
                                  fontSize: 28,
                                  isBold: true,
                                  fontColor: Color(0xFF323238),
                                ),
                                SizedBox(height: res.percentHeight(2),),
                                const TextDefault(
                                  content: '기준 자세를 측정하기 위한 단계로\n정확한 자세를 판단할 수 있어요.',
                                  fontSize: 15,
                                  isBold: false,
                                  fontColor: Color(0xFF64646F),
                                ),
                                Container(
                                    width: res.percentWidth(50),
                                    height: res.percentWidth(50),
                                    // padding: EdgeInsets.all(res.percentWidth(8)),
                                    margin: EdgeInsets.only(left: res.percentWidth(17.5), top: res.percentWidth(15)),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFFFFF),
                                      borderRadius: BorderRadius.circular(res.percentWidth(25)),
                                    ),
                                    alignment: Alignment.center,
                                    child: const TextDefault(
                                      content: '5',
                                      fontSize: 90,
                                      isBold: false,
                                      fontColor: Colors.black,
                                    )
                                )
                              ],
                            )
                        )
                      ]
                  ),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: res.percentHeight(2),),
                        Container(
                            width: res.deviceWidth,
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.only(left: res.percentWidth(7.5)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const TextDefault(
                                  content: '바른 자세와 함께\n일에 집중해보세요',
                                  fontSize: 28,
                                  isBold: true,
                                  fontColor: Color(0xFF323238),
                                ),
                                SizedBox(height: res.percentHeight(2),),
                                const TextDefault(
                                  content: '무의식적으로 자세가 무너지는 것을\n탐지하면, 알림을 보내 알려드릴게요.',
                                  fontSize: 15,
                                  isBold: false,
                                  fontColor: Color(0xFF64646F),
                                ),
                                Container(
                                    width: res.percentWidth(50),
                                    height: res.percentWidth(50),
                                    // padding: EdgeInsets.all(res.percentWidth(8)),
                                    margin: EdgeInsets.only(left: res.percentWidth(17.5), top: res.percentWidth(15)),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFFFFF),
                                      borderRadius: BorderRadius.circular(res.percentWidth(25)),
                                    ),
                                    alignment: Alignment.center,
                                    child: const PersonIcon(size: 50,)
                                )
                              ],
                            )
                        )
                      ]
                  ),
                ],
                options: CarouselOptions(
                    height: MediaQuery.of(context).size.height*0.7,
                    enableInfiniteScroll: false,
                    autoPlay: false,
                    enlargeCenterPage: false,
                    viewportFraction: 1.0,
                    onPageChanged: (idx, reason) {
                      setState(() {
                        _pageNum = idx;
                      });
                    }
                )
            ),
            // SizedBox(height: res.percentHeight(5),),
            Container(
              padding: EdgeInsets.symmetric(horizontal: res.percentWidth(6)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Button(
                    onPressed: () {
                      if(userStatus.isLogged) {
                        Navigator.of(context).pop();
                      } else {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => const LoginPage()));
                      }
                    },
                    text: _pageNum != 2 ? '튜토리얼 건너뛰기' : '넥라이프 시작하기',
                    backgroundColor: _pageNum != 2 ? const Color(0xFF8991A0) : const Color(0xFF236EF3),
                    color: Colors.white,
                    width: _pageNum != 2 ? res.percentWidth(42) : res.percentWidth(88),
                    padding: res.percentWidth(4),
                  ),
                  _pageNum != 2 ? Button(
                    onPressed: () {
                      if (_pageNum < 2) {
                        _btnController.nextPage(
                            duration: const Duration(
                                milliseconds: 300),
                            curve: Curves.linear);
                        setState(() {
                          _pageNum += 1;
                        });
                      }
                    },
                    text: '다음',
                    backgroundColor: const Color(0xFF236EF3),
                    color: Colors.white,
                    width: res.percentWidth(42),
                    padding: res.percentWidth(4),
                  ) : const SizedBox()
                ],
              ),
            ),
          ],
        ),
      )
    );
  }

}