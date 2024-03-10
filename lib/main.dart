import 'dart:developer' as dev;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:async_wallpaper/async_wallpaper.dart';
import 'package:flutter/services.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

/* Don't or Force show that shit working introduction screen */
bool ignoreIntroScreen = false;
bool forceShowIntroScreen = true;
bool isFirstTime = true;

/* Ping test url */
String pingUrl = "https://www.google.com/";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences shred = await SharedPreferences.getInstance();
  final isFirstTime = shred.getBool('isFirstTime') ?? true;

  if ((isFirstTime || forceShowIntroScreen) && !ignoreIntroScreen) {
    runApp(const FirstTimeShow());
    shred.setBool('isFirstTime', false);
  } else {
    runApp(const MainApp());
  }
}

// Introduction Page after opening App.
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
        decoration: PageDecoration(pageColor: Colors.lightBlue[100])),
    PageViewModel(
        title: "How to use Wallpaper App ?",
        image: Image.asset(
          'assets/teacher.gif',
          height: 200,
        ),
        body:
            "This introduction page is designed to help you effectively use this application. Hope it helps.",
        decoration: PageDecoration(pageColor: Colors.lightBlue[100])),
    PageViewModel(
        title: "How to use Wallpaper App ?",
        image: Image.asset(
          'assets/teacher.gif',
          height: 200,
        ),
        body:
            "This introduction page is designed to help you effectively use this application. Hope it helps.",
        decoration: PageDecoration(pageColor: Colors.lightBlue[100])),
  ];
  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: introPages,
      dotsDecorator: DotsDecorator(
        size: const Size.square(10.0),
        activeSize: const Size(30.0, 10.0),
        activeColor: Colors.cyanAccent[600],
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
      globalBackgroundColor: Colors.lightBlue[100],
      curve: Curves.elasticInOut,
      onDone: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const MainApp()));
      },
    );
  }
}

// Wallpaper Page.
class MainApp extends StatelessWidget {
  const MainApp({super.key});
  final int nonsense = 1;
  final firstTime = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        // TODO: remove 'forceShowIntroScreen' as unnecessary for production.
        home: isFirstTime && !forceShowIntroScreen
            ? AnimatedSplashScreen(
                splash: "assets/elephant.png",
                splashIconSize: 256, // Large size.
                backgroundColor: Colors.white,
                nextScreen: const AppState(),
              )
            : const AppState());
  }
}

class AppState extends StatefulWidget {
  const AppState({super.key});

  @override
  State<StatefulWidget> createState() => SecondFullCheck();
}

class SecondFullCheck extends State<AppState> {
  final int bufferSize = 10;
  bool showConfirmDialog = false;
  bool wallpaperWaiting = false;
  List<Uri> listImage = List.empty(growable: true);
  final imageUrl1 = "https://picsum.photos/seed/";
  final imageResolution = "/1080/1920/";
  bool showNetworkIssue = false;
  int got = Random().nextInt(1000).toInt();
  int index = 0;
  bool isIteminListRemvoed = false;

  Future<void> addNewImage(str) async {
    addToImageList();
    if (listImage.contains(str)) {
      listImage.removeWhere((element) => element == str);
      isIteminListRemvoed = true;
    } else {
      isIteminListRemvoed = false;
    }
    setState(() {
      if (!isIteminListRemvoed) index++;
    });
  }

  void addToImageList() {
    listImage.add(Uri.parse("$imageUrl1${got++}$imageResolution"));
  }

  Future<void> createImageBuffer() async {
    // ignore: unused_local_variable
    for (var num in Iterable.generate(bufferSize)) {
      addToImageList();
    }
  }

  void setNetworkIssue() {
    setState(() {
      showNetworkIssue = true;
    });
  }

  Future<void> checkInternetIssueAfterDelay() async {
    try {
      http.Response gotResponse = await http.get(Uri.parse(pingUrl));
      dev.log("Got response code: ${gotResponse.statusCode}");
      if (gotResponse.statusCode != 200) {
        setNetworkIssue();
      }
    } catch (e) {
      setNetworkIssue();
    }
  }

  void setWallpaper() async {
    if (!wallpaperWaiting) {
      try {
        setState(() {
          showConfirmDialog = false;
          wallpaperWaiting = true;
        });
        // Saved with this method.
        await AsyncWallpaper.setWallpaper(
            url: listImage.elementAt(index).toString(), // last image
            wallpaperLocation: AsyncWallpaper.HOME_SCREEN,
            goToHome: false);
        setState(() {
          wallpaperWaiting = false;
        });
      } on PlatformException {
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 50,
                  height: 50,
                  child: showNetworkIssue
                      ? const Icon(
                          Icons
                              .signal_wifi_statusbar_connected_no_internet_4_sharp,
                          size: 50,
                        )
                      : const CircularProgressIndicator(),
                ),
                const SizedBox(
                  height: 25,
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Visibility(
                      visible: showNetworkIssue,
                      child: const Text(
                        "Offline status detected.\nKindly verify your internet connection.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ))
              ],
            )),
            for (var i = 9; i >= 0; i--)
              Dismissible(
                key: Key(findImageUri(listImage, index, i)),
                onDismissed: (DismissDirection e) => setState(() {
                  addNewImage(findImageUri(listImage, index, i));
                }),
                child: SizedBox(
                  height: double.infinity,
                  child: Image.network(findImageUri(listImage, index, i),
                      fit: BoxFit.cover, filterQuality: FilterQuality.none,
                      errorBuilder: (context, error, stackTrace) {
                    return const SizedBox();
                  }),
                ),
              ),

            // Alert dialog to confirm
            Visibility(
              visible: showConfirmDialog,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 04, vertical: 04),
                child: AlertDialog(
                  title: const Text(
                    "Set it as wallpaper ?",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  icon: Image.network(listImage.elementAt(index).toString()),
                  actions: [
                    TextButton(
                      onPressed: setWallpaper,
                      child: const Text("Confirm"),
                    ),
                    TextButton(
                      onPressed: () => setState(() {
                        showConfirmDialog = false;
                      }),
                      child: const Text("Cancel"),
                    ),
                  ],
                ),
              ),
            ),

            // Processing widget when setting up wallpaper.
            Visibility(
                visible: wallpaperWaiting,
                child: const Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Setting up wallpaper...",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )
                  ],
                ))),
          ],
        ),
      ),
      floatingActionButton: Visibility(
          visible: !showNetworkIssue,
          child: FloatingActionButton(
            backgroundColor: const Color.fromARGB(64, 255, 255, 255),
            onPressed: () => {
              setState(() {
                showConfirmDialog = true;
              })
            },
            child: const Icon(Icons.wallpaper),
          )),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  @override
  void initState() {
    super.initState();
    checkInternetIssueAfterDelay();
    createImageBuffer();
  }
}

Image wallimage(String imageUrl) {
  return Image.network(imageUrl, fit: BoxFit.fitHeight);
}

String findImageUri(imageist, index, iteration) {
  return imageist.elementAt(index + iteration).toString();
}
