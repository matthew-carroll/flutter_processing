import 'dart:ui';

import 'package:flutter/material.dart' hide Image;
import 'package:flutter_processing/flutter_processing.dart';

void main() {
  runApp(FlutterProcessingExampleApp());
}

class FlutterProcessingExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Processing Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Image _loadedImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow,
      body: Center(
        child: Processing(
          sketch: Sketch.simple(
            setup: (s) async {
              s.size(width: 500, height: 500);

              _loadedImage = await s.loadImage('assets/audio-mixer.png');
            },
            draw: (s) async {
              s.image(
                image: _loadedImage,
              );

              final subImage = await s.getRegion(
                x: 0,
                y: 0,
                width: (s.width / 2).round(),
                height: (s.height / 2).round(),
              );
              // s.image(image: subImage, origin: Offset(s.width / 2, s.height / 2));

              await s.loadPixels();

              for (int col = 0; col < 400; ++col) {
                for (int row = 0; row < 400; ++row) {
                  s.set(x: col, y: row, color: Color(0xFF00FF00));
                }
              }
              await s.setRegion(image: subImage);

              await s.updatePixels();

              final pixelColor = await s.get(s.mouseX, s.mouseY);
              s
                // ..noStroke()
                ..fill(color: pixelColor)
                ..circle(
                  center: Offset(s.mouseX + 50, s.mouseY + 50),
                  diameter: 100,
                );
            },
          ),
        ),
      ),
    );
  }
}
