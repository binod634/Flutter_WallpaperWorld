import 'dart:developer' as dev;
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:async_wallpaper/async_wallpaper.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:wallpaperworld/firstimeshow.dart';
import 'package:path_provider/path_provider.dart';

/* Don't or Force show that shit working introduction screen */
bool ignoreIntroScreen = false;
bool forceShowIntroScreen = false;
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

// Wallpaper Page.
class MainApp extends StatelessWidget {
  const MainApp({super.key});
  final int nonsense = 1;
  final firstTime = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
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
  bool isIteminListRemvoed = false;

  Future<void> addNewImage(str) async {
    if (!listImage.contains(Uri.parse(str))) {
      dev.log("Critic-0: Str to replace isn't in listimage.");
      dev.log("Str: $str");
      dev.log("listimage: $listImage");
      dev.log("got: $got");
    }
    addToImageList();
    listImage.removeWhere((element) => element.toString() == str);
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
      dev.log("Log Got response code: ${gotResponse.statusCode}");
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
          wallpaperWaiting = true;
        });
        // Saved with this method.
        await AsyncWallpaper.setWallpaperNative(
          goToHome: true,
          url: listImage.first.toString(),
        );
        // await AsyncWallpaper.setWallpaper(
        //     url: listImage.first.toString(), // last image
        //     wallpaperLocation: AsyncWallpaper.HOME_SCREEN,
        //     goToHome: false);
        setState(() {
          wallpaperWaiting = false;
        });
      } catch (e) {
        dev.log("Error: $e");
      }
    }
  }

  void downloadImage() async {
    try {
      final imageUrl = listImage.first;
      final http.Response response = await http.get(imageUrl);
      var directory = await getDownloadsDirectory();
      directory ??= await getTemporaryDirectory();
      final filename = "${directory.path}/${Random().nextInt(1000)}.png";
      final file = File(filename);
      await file.writeAsBytes(response.bodyBytes);
      dev.log("success: $directory");
    } catch (e) {
      dev.log("Error:   $e");
      return;
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
                  key: Key(findImageUri(listImage, i)),
                  onDismissed: (DismissDirection e) => setState(() {
                    addNewImage(findImageUri(listImage, i));
                  }),
                  child: SizedBox(
                    height: double.infinity,
                    child: Image.network(findImageUri(listImage, i),
                        fit: BoxFit.cover, filterQuality: FilterQuality.none,
                        errorBuilder: (context, error, stackTrace) {
                      return const SizedBox();
                    }),
                  ),
                ),
            ],
          ),
        ),
        floatingActionButton: Visibility(
            visible: !showNetworkIssue,
            child: FloatingActionButton(
              backgroundColor: const Color.fromARGB(64, 255, 255, 255),
              onPressed: () => {
                setState(() {
                  setWallpaper();
                })
              },
              child: const Icon(Icons.wallpaper),
            )),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat);
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

String findImageUri(imageist, iteration) {
  return imageist.elementAt(iteration).toString();
}
