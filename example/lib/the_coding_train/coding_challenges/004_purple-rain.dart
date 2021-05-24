import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_processing/flutter_processing.dart';
import 'package:flutter_processing_example/_processing_sketch_display.dart';

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

class _HomeScreenState extends ProcessingState<HomeScreen> {
  final _droplets = <Droplet>[];

  @override
  void reassemble() {
    super.reassemble();
    _droplets.clear();
  }

  @override
  int get gifFps => 60;

  @override
  String get gifFilepath => '/Users/matt/Pictures/004_purple_rain.gif';

  @override
  Sketch createSketch() {
    return Sketch.simple(
      setup: (s) async {
        s
          ..size(width: 256, height: 256)
          ..background(color: Color.fromARGB(255, 200, 175, 220));

        for (int i = 0; i < 100; ++i) {
          _droplets.add(
            Droplet(
              x: s.random(s.width),
              y: s.random(-s.height, 0),
              z: s.random(1),
              length: 20,
            ),
          );
        }
      },
      draw: (s) async {
        s.background(color: Color.fromARGB(255, 200, 175, 220));

        for (final droplet in _droplets) {
          droplet
            ..fall(s)
            ..show(s);
        }

        await saveGifFrameIfDesired(s);
      },
    );
  }
}

class Droplet {
  Droplet({
    required this.x,
    required this.y,
    required this.z,
    required this.length,
  });

  double x;
  double y;
  double z;
  double length;

  void fall(Sketch s) {
    y += lerpDouble(8, 20, z)!;

    if (y > s.height) {
      y = 0;
      z = s.random(1);
    }
  }

  void show(Sketch s) {
    final perspectiveLength = lerpDouble(0.2 * length, length, z)!;

    s
      ..stroke(color: Color.fromARGB(255, 128, 43, 226))
      ..line(Offset(x, y), Offset(x, y + perspectiveLength));
  }
}
