import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_translate/flutter_translate.dart';

const kTitleStyle = TextStyle(
  fontFamily: 'CM Sans Serif',
  fontSize: 26.0,
  height: 1.5,
);

const kSubtitleStyle = TextStyle(
  fontSize: 18.0,
  height: 1.2,
);

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  OnboardingScreenState createState() => OnboardingScreenState();
}

class OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  final _slidesContent = [
    {
      'title': 'slides.title0',
      'description': 'slides.description0',
      'image': 'assets/images/onboarding0.png'
    },
    {
      'title': 'slides.title1',
      'description': 'slides.description1',
      'image': 'assets/images/onboarding1.png'
    },
    {
      'title': 'slides.title2',
      'description': 'slides.description2',
      'image': 'assets/images/onboarding2.png'
    },
  ];

  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < _slidesContent.length; i++) {
      list.add(i == _currentPage ? _indicator(true) : _indicator(false));
    }
    return list;
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      height: 8.0,
      width: isActive ? 24.0 : 16.0,
      decoration: BoxDecoration(
        color: isActive
            ? Theme.of(context).primaryColor
            : Theme.of(context).primaryColorLight,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        iconTheme: IconThemeData(
          color: Theme.of(context).primaryColor,
        ),
        backgroundColor: Colors.transparent,
        title: GestureDetector(
          child: Text(
            translate('slides.skip'),
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
          onPanDown: (_) {
            Navigator.of(context).pushNamed('/');
          },
        ),
      ),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              fit: FlexFit.tight,
              child: _slides(context),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _buildPageIndicator(),
              ),
            ),
            Container(
              color: Theme.of(context).primaryColorDark,
              height: 70,
              width: double.infinity,
              child: _next(context),
            ),
          ],
        ),
      ),
      bottomSheet: _next(context),
    );
  }

  Widget _slides(BuildContext context) {
    return PageView(
      physics: const ClampingScrollPhysics(),
      controller: _pageController,
      onPageChanged: (int page) {
        setState(() {
          _currentPage = page;
        });
      },
      children: <Widget>[
        for (var slide in _slidesContent)
          ListView(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Center(
                      child: Image(
                        image: AssetImage(
                          slide['image']!,
                        ),
                        height: 200,
                        width: 200,
                      ),
                    ),
                    const SizedBox(height: 30.0),
                    Text(
                      translate(slide['title']!),
                      style: kTitleStyle,
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      translate(slide['description']!),
                      style: kSubtitleStyle,
                    ),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _next(BuildContext context) {
    String text = 'next';
    if (_currentPage == _slidesContent.length - 1) {
      text = 'slides.get_started';
    }

    return GestureDetector(
      onPanDown: (_) {
        if (_currentPage == _slidesContent.length - 1) {
          Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
        } else {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 500),
            curve: Curves.ease,
          );
        }
      },
      child: Container(
        height: 70.0,
        width: double.infinity,
        color: Theme.of(context).primaryColorDark,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 0.0),
            child: Text(
              translate(text),
              style: const TextStyle(
                fontSize: 20.0,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
