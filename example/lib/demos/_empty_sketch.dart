import 'package:flutter/material.dart' hide Image;
import 'package:flutter_processing/flutter_processing.dart';
import 'package:flutter_processing_example/_processing_demo_sketch_display.dart';

class EmptySketchDemo extends StatefulWidget {
  const EmptySketchDemo({
    Key? key,
    required this.sketchDemoController,
  }) : super(key: key);

  final SketchDemoController sketchDemoController;

  @override
  _EmptySketchDemoState createState() => _EmptySketchDemoState();
}

class _EmptySketchDemoState extends State<EmptySketchDemo> {
  late PImage _image1;
  late PImage _image2;
  late PImage _image3;

  Sketch createSketch() {
    return Sketch.simple(
      setup: (s) async {
        s.size(width: 500, height: 500);
        s.background(color: const Color(0xFFFFFFFF));

        _image1 = await s.loadImage("assets/coffee.png");
        _image2 = await s.loadImage("assets/audio-mixer.png");
        _image3 = _image1.copy();

        _image1.blend(
          _image1,
          sourceRect: Rect.fromLTRB(_image1.width.toDouble() / 2, 0,
              _image1.width.toDouble(), _image1.height.toDouble() / 2),
          destRect: Rect.fromLTRB(_image1.width.toDouble() / 2, 0,
              _image1.width.toDouble(), _image1.height.toDouble() / 2),
          mode: SketchBlendMode.add,
        );
        _image1.blend(
          _image2,
          sourceRect: Rect.fromLTRB(
            _image1.width.toDouble() / 2,
            _image1.height.toDouble() / 2,
            _image1.width.toDouble(),
            _image1.height.toDouble(),
          ),
          destRect: Rect.fromLTRB(
            _image1.width.toDouble() / 2,
            _image1.height.toDouble() / 2,
            _image1.width.toDouble(),
            _image1.height.toDouble(),
          ),
          mode: SketchBlendMode.screen,
        );
        _image1.blend(
          _image2,
          sourceRect: Rect.fromLTRB(
            0,
            _image1.height.toDouble() / 2,
            _image1.width.toDouble() / 2,
            _image1.height.toDouble(),
          ),
          destRect: Rect.fromLTRB(
            0,
            0,
            _image1.width.toDouble() / 2,
            _image1.height.toDouble() / 2,
          ),
          mode: SketchBlendMode.screen,
        );

        // _image3.filter(ImageFilter.threshold, 0.5);
        // _image3.filter(ImageFilter.gray);
        // _image3.filter(ImageFilter.invert);
        // _image3.filter(ImageFilter.posterize, 4);
        _image3.filter(ImageFilter.erode);
        // _image3.filter(ImageFilter.dilate);
      },
      draw: (s) async {
        await s.pImage(image: _image1);
        await s.pImage(image: _image3, origin: Offset(_image3.width + 10, 0));
        // await s.pImage(image: _image2, origin: Offset(200, 200));
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
