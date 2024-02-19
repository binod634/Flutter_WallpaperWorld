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
  final imageUrl = "https://picsum.photos/1080/1920/";
  int index = 0;

  List<Uri> listImage = List.empty(growable: true);
  Future<void> addNewImage() async {
    listImage.add(Uri.parse("$imageUrl?nonsense=$index"));
    setState(() {
      index++;
    });
  }

  Future<void> createImageBuffer() async {
    for (var num in [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]) {
      listImage.add(Uri.parse("$imageUrl?nonsenseBuff=$num"));
    }
  }

  void directionalSwipe(DismissDirection direction) {
    if (direction == DismissDirection.startToEnd ||
        direction == DismissDirection.endToStart) {
      addNewImage();
    }
  }

  void setWallpaper() async {
    try {
      await AsyncWallpaper.setWallpaper(
          url: listImage.elementAt(index).toString(), // last image
          wallpaperLocation: AsyncWallpaper.BOTH_SCREENS,
          goToHome: true);
    } on PlatformException {
      return;
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
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),

            // TODO: remove this.
            Visibility(
              visible: false,
              child: Center(
                child: Container(
                  color: Colors.white,
                  alignment: Alignment.center,
                  height: 400,
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: const Text("data"),
                ),
              ),
            )
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
