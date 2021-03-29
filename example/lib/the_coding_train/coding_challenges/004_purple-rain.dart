import 'dart:ui';

import 'package:flutter/material.dart';
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
  final _droplets = <Droplet>[];

  @override
  void reassemble() {
    super.reassemble();
    _droplets.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow,
      body: Center(
        child: Processing(
          sketch: Sketch.simple(
            setup: (s) {
              final width = 640;
              final height = 360;

              s
                ..size(width: width, height: height)
                ..background(color: Color.fromARGB(255, 200, 175, 220));

              for (int i = 0; i < 100; ++i) {
                _droplets.add(
                  Droplet(
                    x: s.random(width),
                    y: s.random(-height, 0),
                    z: s.random(1),
                    length: 20,
                  ),
                );
              }
            },
            draw: (s) {
              for (final droplet in _droplets) {
                droplet
                  ..fall(s)
                  ..show(s);
              }
            },
          ),
        ),
      ),
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
