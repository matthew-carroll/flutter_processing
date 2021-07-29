import 'package:flutter/material.dart';
import 'package:flutter_processing/flutter_processing.dart';
import 'package:flutter_processing_example/main_perlin_noise_demo.dart';

import '../../_processing_sketch_display.dart';

void main() {
  runApp(GifMakerApp());
}

class GifMakerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GIF Maker',
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
  @override
  String get gifFilepath => '/Users/matt/Pictures/perline-noise.gif';

  @override
  Sketch createSketch() {
    return GifSketch(this);
  }
}

class GifSketch extends PerlinNoiseDemoSketch {
  GifSketch(ProcessingState processingState)
      : _processingState = processingState,
        super(width: 512, height: 512, animateZIndex: true);

  final ProcessingState _processingState;

  @override
  Future<void> draw() async {
    await super.draw();

    await _processingState.saveGifFrameIfDesired(this);
  }
}
