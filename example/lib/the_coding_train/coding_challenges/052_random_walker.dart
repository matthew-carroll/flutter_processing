import 'dart:math';

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
      title: 'Random Walker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CodingTrainRandomWalkerScreen(),
    );
  }
}

class CodingTrainRandomWalkerScreen extends StatefulWidget {
  @override
  _CodingTrainRandomWalkerScreenState createState() => _CodingTrainRandomWalkerScreenState();
}

class _CodingTrainRandomWalkerScreenState extends ProcessingState<CodingTrainRandomWalkerScreen> {
  late int x;
  late int y;

  @override
  int get gifFps => 30;

  @override
  String get gifFilepath => '/Users/matt/Pictures/052_random_walker.gif';

  @override
  Sketch createSketch() {
    return Sketch.simple(
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

        await saveGifFrameIfDesired(s);
      },
    );
  }
}
