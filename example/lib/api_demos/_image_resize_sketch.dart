import 'package:flutter/material.dart' hide Image;
import 'package:flutter_processing/flutter_processing.dart';
import 'package:flutter_processing_example/_processing_demo_sketch_display.dart';

class ImageResizeSketchDemo extends StatefulWidget {
  const ImageResizeSketchDemo({
    Key? key,
    required this.sketchDemoController,
  }) : super(key: key);

  final SketchDemoController sketchDemoController;

  @override
  _ImageResizeSketchDemoState createState() => _ImageResizeSketchDemoState();
}

class _ImageResizeSketchDemoState extends State<ImageResizeSketchDemo> {
  late PImage _image1;
  late PImage _image2;
  late PImage _image3;

  @override
  Widget build(BuildContext context) {
    return ProcessingDemo(
      createSketch: createSketch,
      sketchDemoController: widget.sketchDemoController,
    );
  }

  Sketch createSketch() {
    return Sketch.simple(
      setup: (s) async {
        s.size(width: 500, height: 500);
        s.background(color: const Color(0xFFFFFFFF));

        _image1 = await s.loadImage("assets/coffee.png");

        _image2 = await s.loadImage("assets/coffee.png");
        _image2.resize(width: 200);

        _image3 = await s.loadImage("assets/coffee.png");
        _image3.resize(width: 300, height: 150);
      },
      draw: (s) async {
        await s.image(image: _image1);
        await s.image(image: _image2, origin: Offset((s.width - _image2.width).toDouble(), 0));
        await s.image(
            image: _image3,
            origin: Offset((s.width - _image3.width).toDouble(), (s.height - _image3.height).toDouble()));
      },
    );
  }
}
