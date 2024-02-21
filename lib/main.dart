import 'dart:math';

import 'package:flutter/material.dart';
import 'package:async_wallpaper/async_wallpaper.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  final int nonsense = 1;

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: AppState());
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
  int got = Random().nextInt(1000).toInt();
  int index = 0;

  Future<void> addNewImage() async {
    addToImageList();
    setState(() {
      index++;
    });
  }

  void addToImageList() {
    listImage.add(Uri.parse("$imageUrl1${got++}$imageResolution"));
  }

  Future<void> createImageBuffer() async {
    // ignore: unused_local_variable
    for (var num in [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]) {
      addToImageList();
    }
  }

  void directionalSwipe(DismissDirection direction) {
    if (direction == DismissDirection.startToEnd ||
        direction == DismissDirection.endToStart) {
      addNewImage();
    }
  }

  void setWallpaper() async {
    if (!wallpaperWaiting) {
      try {
        setState(() {
          wallpaperWaiting = true;
        });
        await AsyncWallpaper.setWallpaper(
            url: listImage.elementAt(index).toString(), // last image
            wallpaperLocation: AsyncWallpaper.BOTH_SCREENS,
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
            const Center(
                child: SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(),
            )),
            for (var i = 9; i >= 0; i--)
              Dismissible(
                key: Key((index + i).toString()),
                onDismissed: (DismissDirection e) => setState(() {
                  addNewImage();
                }),
                child: SizedBox(
                  height: double.infinity,
                  child: Image.network(
                    listImage.elementAt(index + i).toString(),
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.none,
                  ),
                ),
              ),

            // TODO: remove this.
            Visibility(
              visible: false,
              child: Center(
                child: Container(
                  color: Colors.lightBlue,
                  alignment: Alignment.center,
                  height: 400,
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: const Text("data"),
                ),
              ),
            ),

            // TODO: working...
            Visibility(
              visible: showConfirmDialog,
              child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: const AlertDialog(
                    title: Text("Set this as Wallpaper ?"),
                    actions: [
                      FilledButton(onPressed: null, child: Text("Confirm")),
                      FilledButton(onPressed: null, child: Text("Cancel"))
                    ],
                  )),
            ),

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
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(64, 255, 255, 255),
        onPressed: setWallpaper,
        child: const Icon(Icons.wallpaper),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  @override
  void initState() {
    super.initState();
    createImageBuffer();
  }
}

Image wallimage(String imageUrl) {
  return Image.network(imageUrl, fit: BoxFit.fitHeight);
}
