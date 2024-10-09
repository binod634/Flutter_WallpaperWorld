// Introduction Page after opening App.
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:wallpaperworld/main.dart';

class FirstTimeShow extends StatelessWidget {
  const FirstTimeShow({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AnimatedSplashScreen(
          splash: "assets/elephant.png",
          splashIconSize: 256, // Large size.
          backgroundColor: Colors.white,
          splashTransition: SplashTransition.fadeTransition,
          nextScreen: const FirstTimeState()),
    );
  }
}

class FirstTimeState extends StatefulWidget {
  const FirstTimeState({super.key});

  @override
  State<StatefulWidget> createState() => FirstTimeStateImpl();
}

class FirstTimeStateImpl extends State<FirstTimeState> {
  final introPages = <PageViewModel>[
    PageViewModel(
        title: "How to use Wallpaper App ?",
        image: Image.asset(
          'assets/teacher.gif',
          height: 200,
        ),
        body:
            "This introduction page is designed to help you effectively use this application. Hope it helps.",
        decoration: const PageDecoration(pageColor: Colors.white)),
    PageViewModel(
        title: "How To navigate between Wallpapers ?",
        image: Image.asset(
          'assets/flutter_04.png',
          width: double.infinity,
          height: 250,
        ),
        body:
            "You can swipe Left or Right to get new Wallpaper. Swiping from either side does the same. so, feel free to use as you like.",
        decoration: const PageDecoration(pageColor: Colors.white)),
    PageViewModel(
        title: "How to setup wallpaper",
        image: Image.asset(
          'assets/flutter_03.png',
          height: 200,
        ),
        body: "Click on bottom icon to get a setup wizard and click confirm.",
        decoration: const PageDecoration(pageColor: Colors.white)),
  ];
  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: introPages,
      dotsDecorator: DotsDecorator(
        size: const Size.square(10.0),
        activeSize: const Size(30.0, 10.0),
        activeColor: Colors.white,
        color: Colors.black26,
        spacing: const EdgeInsets.symmetric(horizontal: 3.0),
        activeShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
      ),
      showSkipButton: true,
      skip: const Text("Skip"),
      showNextButton: true,
      next: const Text("Next"),
      done: const Icon(Icons.check),
      globalBackgroundColor: Colors.white,
      curve: Curves.elasticInOut,
      onDone: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const MainApp()));
      },
    );
  }
}
