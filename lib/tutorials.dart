import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:mocksum_flutter/util/user_provider.dart';
import 'package:provider/provider.dart';
import 'login.dart';
import 'util/responsive.dart';
import 'package:carousel_slider/carousel_slider.dart';

class Tutorials extends StatefulWidget {
  const Tutorials({super.key});

  @override
  State<StatefulWidget> createState() => _TutorialState();
}

class _TutorialState extends State<Tutorials> {
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  int _pageNum = 0;
  final CarouselController _btnController = CarouselController();

  @override
  void initState() {
    super.initState();
    // 페이지가 로드될 때 이벤트 로깅
    analytics.logTutorialBegin();
  }


  @override
  void dispose() {
    super.dispose();
    // 페이지가 닫힐 때 이벤트 로깅
    analytics.logTutorialComplete();
  }

  @override
  Widget build(BuildContext context) {
    Responsive responsive = Responsive(context);
    UserStatus userStatus = Provider.of(context);
    return Scaffold(
      body: SingleChildScrollView(
          child: Container(
            width: responsive.percentWidth(100),
            height: responsive.percentHeight(100),
            // padding: EdgeInsets.only(left: responsive.percentWidth(7.5)),
            child: Column(
              children: [
                CarouselSlider(
                    carouselController: _btnController,
                    items: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        // mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: responsive.percentHeight(7.5),),
                          Center(
                              child: Text(
                                '에어팟 하나만으로\n바른 자세를 유지해보세요',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: responsive.fontSize(28),
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                          ),
                          SizedBox(height: responsive.percentHeight(5)),
                          Container(
                            width: responsive.deviceWidth,
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.only(left: responsive.percentWidth(10)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'STEP 1',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: responsive.fontSize(24),
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                                Text(
                                  '에어팟을 연결해주세요',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: responsive.fontSize(24),
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: responsive.percentHeight(1)),
                                Text(
                                  '잘 연결된 경우 아래처럼 화면이 바뀔거예요',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: responsive.fontSize(16),
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w200,
                                  ),
                                ),
                                Image.asset("assets/tutorial1.png"),
                                const SizedBox(height: 30),
                                Text(
                                  '주의) 아래 명시된 모델만 사용 가능해요',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: responsive.fontSize(16),
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w200,
                                  ),
                                ),
                                Text(
                                  '- AirPods Pro',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: responsive.fontSize(20),
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w200,
                                  ),
                                ),
                                Text(
                                  '- AirPods Max',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: responsive.fontSize(20),
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w200,
                                  ),
                                ),
                                Text(
                                  '- AirPods (3세대)',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: responsive.fontSize(20),
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w200,
                                  ),
                                ),
                              ],
                            )
                          )
                        ],
                      ),
                      Container(
                        width: responsive.percentWidth(85),
                        padding: EdgeInsets.only(top: responsive.percentHeight(7.5)),
                        child: Column(
                          children: [
                            Column( // page 2
                              crossAxisAlignment: CrossAxisAlignment.start,
                              // mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: responsive.percentHeight(5),),
                                Text(
                                  'STEP 2',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: responsive.fontSize(24),
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                                Text(
                                  '측정의 기준이 될 바른 자세를\n알려주세요',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: responsive.fontSize(24),
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: responsive.percentHeight(1)),
                                Text(
                                  '\'목숨\' 서비스는 처음 측정해주신 바른\n자세를 기준으로 자세의 변화를 감지하여\n사용자의 자세를 판단해요.',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: responsive.fontSize(19),
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w200,
                                  ),
                                ),
                                SizedBox(height: responsive.percentHeight(2)),
                                Text(
                                  '\'거북목 탐지 시작\' 버튼을 눌러주세요.',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: responsive.fontSize(20),
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w200,
                                  ),
                                ),
                                Image.asset("assets/tutorial2.png"),
                                SizedBox(height: responsive.percentHeight(3)),
                                Text(
                                  '등장하는 페이지에서 \'기준 자세 측정\' \n버튼을 누른 후, 5초 동안 바른 자세를\n유지해주세요.',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: responsive.fontSize(19),
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w200,
                                  ),
                                ),
                                Center(
                                  child: Image.asset("assets/tutorial3.png"),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                      Container(
                        width: responsive.deviceWidth,
                        padding: EdgeInsets.only(left: responsive.percentWidth(7.5), top: responsive.percentHeight(7.5)),
                        child: Column( // page 2
                          crossAxisAlignment: CrossAxisAlignment.start,
                          // mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: responsive.percentHeight(5),),
                            Text(
                              'STEP 3',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: responsive.fontSize(24),
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            Text(
                              '바른 자세와 함께 일에\n집중해보세요',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: responsive.fontSize(24),
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: responsive.percentHeight(2)),
                            Text(
                              '바른 자세 측정이 끝나면 자동으로\n메인 페이지로 돌아가고,\n자세 탐지가 시작됩니다.',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: responsive.fontSize(20),
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w200,
                              ),
                            ),
                            SizedBox(height: responsive.percentHeight(2)),
                            Text(
                              '이제부터는 핸드폰을 내려놓고,\n일에 집중해보세요!',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: responsive.fontSize(20),
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w200,
                              ),
                            ),
                            SizedBox(height: responsive.percentHeight(2)),
                            Text(
                              '무의식적으로 자세가 무너지는 것을\n탐지하면, 알림을 보내 알려드릴게요',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: responsive.fontSize(20),
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w200,
                              ),
                            ),
                            Center( // 왜 이게 없으면 오른쪽으로 쏠리지
                              child: Container(),
                            )
                          ],
                        ),
                      ),
                    ],
                    options: CarouselOptions(
                        height: MediaQuery.of(context).size.height*0.8,
                        enableInfiniteScroll: false,
                        autoPlay: false,
                        enlargeCenterPage: false,
                        viewportFraction: 1.0
                    )
                ),
                SizedBox(height: responsive.percentHeight(5),),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                      onPressed: () {
                        if (_pageNum > 0) {
                          _btnController.previousPage(
                              duration: const Duration(
                                  milliseconds: 300),
                              curve: Curves.linear);
                          setState(() {
                            _pageNum -= 1;
                          });
                        }
                      },
                      child: Text(
                        '< 이전',
                        style: TextStyle(
                          color: _pageNum > 0 ? Colors.black : Colors.grey,
                          fontSize: responsive.fontSize(15),
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextButton(
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
                      child: Text(
                        '다음 >',
                        style: TextStyle(
                          color: _pageNum < 2 ? Colors.black : Colors.grey,
                          fontSize: responsive.fontSize(15),
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  ],
                ),
                TextButton(
                    onPressed: () {
                      // if(userStatus.isLogged) {
                        Navigator.of(context).pop();
                      // } else {
                      //   Navigator.push(context,
                      //       MaterialPageRoute(builder: (context) => const LoginPage()));
                      // }
                    },
                    child: const Text('튜토리얼 끝내기')
                )
              ],
            ),
          )
      ),
    );
  }

}