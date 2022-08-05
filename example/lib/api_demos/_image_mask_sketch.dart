import 'package:flutter/material.dart' hide Image;
import 'package:flutter_processing/flutter_processing.dart';
import 'package:flutter_processing_example/_processing_demo_sketch_display.dart';

class ImageMaskSketchDemo extends StatefulWidget {
  const ImageMaskSketchDemo({
    Key? key,
    required this.sketchDemoController,
  }) : super(key: key);

  final SketchDemoController sketchDemoController;

  @override
  _ImageMaskSketchDemoState createState() => _ImageMaskSketchDemoState();
}

class _ImageMaskSketchDemoState extends State<ImageMaskSketchDemo> {
  late PImage _image1;
  late PImage _image2;

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
        s.noLoop();

        print("BEFORE IMAGE 1");
        _image1 = await s.loadImage("assets/coffee.png");
        _image1.resize(width: 500, height: 500);

        print("BEFORE IMAGE 2");
        _image2 = await s.loadImage("assets/mask.jpg");
        _image2.resize(width: _image1.width, height: _image1.height);

        print("MASKING");
        _image1.mask(maskImage: _image2);

        print("DRAWING IMAGE");
        await s.image(image: _image1);
      },
      draw: (s) async {
        print("PAINTING MASK FRAME");
        await s.image(image: _image1);
      },
    );
  }
}
