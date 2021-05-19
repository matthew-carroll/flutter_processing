import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_processing/flutter_processing.dart';

void main() {
  runApp(FlutterProcessingExampleApp());
}

class FlutterProcessingExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Random Walker',
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
  late int x;
  late int y;

  @override
  void reassemble() {
    super.reassemble();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow,
      body: Center(
        child: Processing(
          sketch: Sketch.simple(
            setup: (s) async {
              s
                ..size(width: 400, height: 400)
                ..background(color: Color(0xFF444444));

              x = (s.width / 2).round();
              y = (s.height / 2).round();
            },
            draw: (s) async {
              s
                ..noStroke()
                ..fill(color: Colors.white)
                ..circle(center: Offset(x.toDouble(), y.toDouble()), diameter: 4);

              final randomDirection = Random().nextInt(4);
              switch (randomDirection) {
                case 0:
                  x += 1;
                  break;
                case 1:
                  x -= 1;
                  break;
                case 2:
                  y += 1;
                  break;
                case 3:
                  y -= 1;
                  break;
              }
            },
          ),
        ),
      ),
    );
  }
}
