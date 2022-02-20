import 'package:flutter/material.dart' hide Image;
import 'package:flutter_processing/flutter_processing.dart';
import 'package:flutter_processing_example/_processing_demo_sketch_display.dart';

class PImageBlendModesSketchDemo extends StatefulWidget {
  const PImageBlendModesSketchDemo({
    Key? key,
    required this.sketchDemoController,
  }) : super(key: key);

  final SketchDemoController sketchDemoController;

  @override
  _PImageBlendModesSketchDemoState createState() => _PImageBlendModesSketchDemoState();
}

class _PImageBlendModesSketchDemoState extends State<PImageBlendModesSketchDemo> {
  late PImage _canvasImage;

  late PImage _bottomImage;
  late PImage _topImage;

  late PImage _blendImage;
  late PImage _addImage;
  late PImage _subtractImage;
  late PImage _darkestImage;
  late PImage _lightestImage;
  late PImage _differenceImage;
  late PImage _exclusionImage;
  late PImage _multiplyImage;
  late PImage _screenImage;
  late PImage _overlayImage;
  late PImage _hardLightImage;
  late PImage _softLightImage;
  late PImage _dodgeImage;
  late PImage _burnImage;

  Sketch createSketch() {
    return Sketch.simple(
      setup: (s) async {
        s.size(width: 1400, height: 400);
        s.background(color: const Color(0xFFFFFFFF));

        _canvasImage = PImage.empty(1400, 400, ImageFileFormat.png);

        _bottomImage = (await s.loadImage("assets/coffee.png")).copy(Rect.fromLTWH(0, 0, 200, 200));
        _topImage = (await s.loadImage("assets/gradient.png")).copy(Rect.fromLTWH(0, 0, 200, 200));

        final copyRect = Rect.fromLTWH(0, 0, 200, 200);

        _blendImage = _bottomImage.copy()
          ..blend(
            _topImage,
            sourceRect: copyRect,
            destRect: copyRect,
            mode: SketchBlendMode.blend,
          );
        _canvasImage.copyFrom(
          source: _blendImage,
          sourceRect: Rect.fromLTWH(0, 0, 200, 200),
          destRect: Rect.fromLTWH(0, 0, 200, 200),
        );

        _addImage = _bottomImage.copy()
          ..blend(
            _topImage,
            sourceRect: copyRect,
            destRect: copyRect,
            mode: SketchBlendMode.add,
          );
        _canvasImage.copyFrom(
          source: _addImage,
          sourceRect: Rect.fromLTWH(0, 0, 200, 200),
          destRect: Rect.fromLTWH(200, 0, 200, 200),
        );

        _subtractImage = _bottomImage.copy()
          ..blend(
            _topImage,
            sourceRect: copyRect,
            destRect: copyRect,
            mode: SketchBlendMode.subtract,
          );
        _canvasImage.copyFrom(
          source: _subtractImage,
          sourceRect: Rect.fromLTWH(0, 0, 200, 200),
          destRect: Rect.fromLTWH(400, 0, 200, 200),
        );

        _darkestImage = _bottomImage.copy()
          ..blend(
            _topImage,
            sourceRect: copyRect,
            destRect: copyRect,
            mode: SketchBlendMode.darkest,
          );
        _canvasImage.copyFrom(
          source: _darkestImage,
          sourceRect: Rect.fromLTWH(0, 0, 200, 200),
          destRect: Rect.fromLTWH(600, 0, 200, 200),
        );

        _lightestImage = _bottomImage.copy()
          ..blend(
            _topImage,
            sourceRect: copyRect,
            destRect: copyRect,
            mode: SketchBlendMode.lightest,
          );
        _canvasImage.copyFrom(
          source: _lightestImage,
          sourceRect: Rect.fromLTWH(0, 0, 200, 200),
          destRect: Rect.fromLTWH(800, 0, 200, 200),
        );

        _differenceImage = _bottomImage.copy()
          ..blend(
            _topImage,
            sourceRect: copyRect,
            destRect: copyRect,
            mode: SketchBlendMode.difference,
          );
        _canvasImage.copyFrom(
          source: _differenceImage,
          sourceRect: Rect.fromLTWH(0, 0, 200, 200),
          destRect: Rect.fromLTWH(1000, 0, 200, 200),
        );

        _exclusionImage = _bottomImage.copy()
          ..blend(
            _topImage,
            sourceRect: copyRect,
            destRect: copyRect,
            mode: SketchBlendMode.exclusion,
          );
        _canvasImage.copyFrom(
          source: _exclusionImage,
          sourceRect: Rect.fromLTWH(0, 0, 200, 200),
          destRect: Rect.fromLTWH(1200, 0, 200, 200),
        );

        _multiplyImage = _bottomImage.copy()
          ..blend(
            _topImage,
            sourceRect: copyRect,
            destRect: copyRect,
            mode: SketchBlendMode.multiply,
          );
        _canvasImage.copyFrom(
          source: _multiplyImage,
          sourceRect: Rect.fromLTWH(0, 0, 200, 200),
          destRect: Rect.fromLTWH(0, 200, 200, 200),
        );

        _screenImage = _bottomImage.copy()
          ..blend(
            _topImage,
            sourceRect: copyRect,
            destRect: copyRect,
            mode: SketchBlendMode.screen,
          );
        _canvasImage.copyFrom(
          source: _screenImage,
          sourceRect: Rect.fromLTWH(0, 0, 200, 200),
          destRect: Rect.fromLTWH(200, 200, 200, 200),
        );

        _overlayImage = _bottomImage.copy()
          ..blend(
            _topImage,
            sourceRect: copyRect,
            destRect: copyRect,
            mode: SketchBlendMode.overlay,
          );
        _canvasImage.copyFrom(
          source: _overlayImage,
          sourceRect: Rect.fromLTWH(0, 0, 200, 200),
          destRect: Rect.fromLTWH(400, 200, 200, 200),
        );

        _hardLightImage = _bottomImage.copy()
          ..blend(
            _topImage,
            sourceRect: copyRect,
            destRect: copyRect,
            mode: SketchBlendMode.hardLight,
          );
        _canvasImage.copyFrom(
          source: _hardLightImage,
          sourceRect: Rect.fromLTWH(0, 0, 200, 200),
          destRect: Rect.fromLTWH(600, 200, 200, 200),
        );

        _softLightImage = _bottomImage.copy()
          ..blend(
            _topImage,
            sourceRect: copyRect,
            destRect: copyRect,
            mode: SketchBlendMode.softLight,
          );
        _canvasImage.copyFrom(
          source: _softLightImage,
          sourceRect: Rect.fromLTWH(0, 0, 200, 200),
          destRect: Rect.fromLTWH(800, 200, 200, 200),
        );

        _dodgeImage = _bottomImage.copy()
          ..blend(
            _topImage,
            sourceRect: copyRect,
            destRect: copyRect,
            mode: SketchBlendMode.dodge,
          );
        _canvasImage.copyFrom(
          source: _dodgeImage,
          sourceRect: Rect.fromLTWH(0, 0, 200, 200),
          destRect: Rect.fromLTWH(1000, 200, 200, 200),
        );

        _burnImage = _bottomImage.copy()
          ..blend(
            _topImage,
            sourceRect: copyRect,
            destRect: copyRect,
            mode: SketchBlendMode.burn,
          );
        _canvasImage.copyFrom(
          source: _burnImage,
          sourceRect: Rect.fromLTWH(0, 0, 200, 200),
          destRect: Rect.fromLTWH(1200, 200, 200, 200),
        );
      },
      draw: (s) async {
        await s.image(image: _canvasImage);

        s.noLoop();
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
