import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:async_wallpaper/async_wallpaper.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:wallpaperworld/firstimeshow.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
  bool confirmation = false;
  bool wallpaperWaiting = false;
  List<Uri> listImage = List.empty(growable: true);
  final imageUrl1 = "https://picsum.photos/seed/";
  final imageResolution = "/1080/1920/";
  bool showNetworkIssue = false;
  int got = Random().nextInt(1000).toInt();
  bool isIteminListRemvoed = false;

  Future<void> addNewImage(str) async {
    if (kDebugMode && !listImage.contains(Uri.parse(str))) {
      print("Critic-0: Str to replace isn't in listimage.");
      print("Str: $str");
      print("listimage: $listImage");
      print("got: $got");
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
      if (kDebugMode) {
        print("Log Got response code: ${gotResponse.statusCode}");
      }
      if (gotResponse.statusCode != 200) {
        setNetworkIssue();
      }
    } catch (e) {
      setNetworkIssue();
    }
  }

  void setWallpaper() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white, // White background for the dialog
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // Rounded corners
          side: const BorderSide(color: Colors.blue, width: 2), // Blue border
        ),
        title: const Text(
          "Are you sure",
          textAlign: TextAlign.center, // Centered text
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue, // Blue text for title
            fontSize: 20, // Slightly larger font
          ),
        ),
        content: const Icon(
          Icons.question_mark,
          color: Colors.blue, // Blue icon color
          size: 40,
        ),
        actionsAlignment: MainAxisAlignment.center, // Center-align buttons
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white, // White text for button
              backgroundColor: Colors.blue, // Blue background for button
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text("No"),
            onPressed: () {
              confirmation = false;
              Navigator.of(context).pop(); // Close dialog on 'No'
            },
          ),
          const SizedBox(width: 10), // Space between buttons
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white, // White text for button
              backgroundColor: Colors.blue, // Blue background for button
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text("Yes"),
            onPressed: () {
              confirmation = true;
              Navigator.of(context).pop(); // Close dialog on 'Yes'
            },
          ),
        ],
      ),
    );

    // set wallpaper if necessary
    if (!wallpaperWaiting && confirmation) {
      try {
        setState(() {
          wallpaperWaiting = true;
        });

        // Saved with this method.
        await AsyncWallpaper.setWallpaperNative(
          goToHome: true,
          url: listImage.first.toString(),
        );

        setState(() {
          wallpaperWaiting = false;
        });
        Fluttertoast.showToast(
            msg: "Wallpaper set successfully.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.transparent,
            textColor: Colors.blue,
            fontSize: 24.0);
      } catch (e) {
        if (kDebugMode) {
          print("Error: $e");
        }
        setState(() {
          wallpaperWaiting = false;
        });
      }
    }
  }

  // void downloadImage() async {
  //   try {
  //     final imageUrl = listImage.first;
  //     final http.Response response = await http.get(imageUrl);
  //     var directory = await getDownloadsDirectory();
  //     directory ??= await getTemporaryDirectory();
  //     final filename = "${directory.path}/${Random().nextInt(1000)}.png";
  //     final file = File(filename);
  //     await file.writeAsBytes(response.bodyBytes);
  //     print("success: $directory");
  //   } catch (e) {
  //     print("Error:   $e");
  //     return;
  //   }
  // }

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
                        : loading(),
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
              Visibility(
                  visible: wallpaperWaiting,
                  child: Center(child: showLoadingDialog())),
            ],
          ),
        ),
        floatingActionButton: Visibility(
            visible: !showNetworkIssue,
            child: FloatingActionButton(
              backgroundColor: const Color.fromARGB(128, 255, 255, 255),
              onPressed: () => {
                setState(() {
                  setWallpaper();
                })
              },
              child: Icon(
                Icons.wallpaper,
                color: Colors.blue[900],
              ),
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

Widget loading() {
  return CircularProgressIndicator(
    strokeWidth: 6,
    color: Colors.blue[900],
  );
}

Container showLoadingDialog() {
  return Container(
    width: 300, // Set a fixed width for the container
    padding: const EdgeInsets.all(20), // Add padding
    decoration: BoxDecoration(
      color: Colors.white, // White background for the container
      borderRadius: BorderRadius.circular(20), // Rounded corners
      border: Border.all(color: Colors.blue, width: 2), // Blue border
    ),
    child: const Column(
      mainAxisSize: MainAxisSize.min, // Adjust size to content
      children: [
        Text(
          "Setting up Wallpaper...",
          textAlign: TextAlign.center, // Centered text
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue, // Blue text for title
            fontSize: 20, // Slightly larger font
          ),
        ),
        SizedBox(height: 20), // Space between title and loading indicator
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
              Colors.blue), // Blue loading indicator
        ),
        SizedBox(height: 20), // Space between loading indicator and text
        Text(
          "Please wait while we set your wallpaper.",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
      ],
    ),
  );
}
