import 'package:flutter/material.dart' hide Image;
import 'package:flutter_processing/flutter_processing.dart';
import 'package:flutter_processing_example/_processing_demo_sketch_display.dart';

class HackingDemo extends StatefulWidget {
  const HackingDemo({
    Key? key,
    required this.sketchDemoController,
  }) : super(key: key);

  final SketchDemoController sketchDemoController;

  @override
  _HackingDemoState createState() => _HackingDemoState();
}

class _HackingDemoState extends State<HackingDemo> {
  late PImage _loadedImage;

  Sketch createSketch() {
    return Sketch.simple(
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

        await s.loadPixels();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ProcessingDemo(
      createSketch: createSketch,
      sketchDemoController: widget.sketchDemoController,
    );
  }
}
