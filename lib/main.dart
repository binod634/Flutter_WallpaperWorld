import 'package:flutter/material.dart';

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
  final imageUrl = "https://picsum.photos/1080/1920/";
  int index = 0;

  List<Image> listImage = List.empty(growable: true);
  Future<void> addNewImage() async {
    listImage.add(wallimage("$imageUrl?nonsense=$index"));
    setState(() {
      index++;
    });
  }

  Future<void> createImageBuffer() async {
    for (var num in [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]) {
      listImage.add(wallimage("$imageUrl?nonsenseBuff=$num"));
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
            for (var i = 9; i > -1; i--)
              SizedBox(
                height: double.infinity,
                child: listImage.elementAt(index + i),
              ),
            // SizedBox(
            //   height: double.infinity,
            //   child: listImage.elementAt(index + 9),
            // ),
            // SizedBox(
            //   height: double.infinity,
            //   child: listImage.elementAt(index + 8),
            // ),
            // SizedBox(
            //   height: double.infinity,
            //   child: listImage.elementAt(index + 7),
            // ),
            // SizedBox(
            //   height: double.infinity,
            //   child: listImage.elementAt(index + 6),
            // ),
            // SizedBox(
            //   height: double.infinity,
            //   child: listImage.elementAt(index + 5),
            // ),
            // SizedBox(
            //   height: double.infinity,
            //   child: listImage.elementAt(index + 4),
            // ),
            // SizedBox(
            //   height: double.infinity,
            //   child: listImage.elementAt(index + 3),
            // ),
            // SizedBox(
            //   height: double.infinity,
            //   child: listImage.elementAt(index + 2),
            // ),
            // SizedBox(
            //   height: double.infinity,
            //   child: listImage.elementAt(index + 1),
            // ),
            // SizedBox(
            //   height: double.infinity,
            //   child: listImage.elementAt(index),
            // ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(64, 255, 255, 255),
        onPressed: addNewImage,
        child: const Icon(Icons.replay_outlined),
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
