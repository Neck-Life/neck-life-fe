import 'package:flutter/material.dart';
import 'package:mocksum_flutter/util/responsive.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:mocksum_flutter/view/home/banner/survey_banner.dart';

class BannerCarousel extends StatelessWidget {

  const BannerCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    Responsive res = Responsive(context);
    return Container(
      padding: const EdgeInsets.only(top: 20),
      width: 320,
      child: CarouselSlider(
          items: const [
            SurveyBanner()
          ],
          options: CarouselOptions(
            height: 50,
            enableInfiniteScroll: true,
            // autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            viewportFraction: 1.0,
          )
      ),
    );
  }

}
