import 'dart:ui';

import 'package:flutter/material.dart' hide Image;
import 'package:flutter_processing/flutter_processing.dart';
import 'package:flutter_processing_example/_processing_demo_sketch_display.dart';

class PImageFiltersSketchDemo extends StatefulWidget {
  const PImageFiltersSketchDemo({
    Key? key,
    required this.sketchDemoController,
  }) : super(key: key);

  final SketchDemoController sketchDemoController;

  @override
  _PImageFiltersSketchDemoState createState() => _PImageFiltersSketchDemoState();
}

class _PImageFiltersSketchDemoState extends State<PImageFiltersSketchDemo> {
  late PImage _canvasImage;

  late PImage _baseImage;

  late PImage _thresholdImage;
  late PImage _grayImage;
  late PImage _opaqueImage;
  late PImage _invertedImage;
  late PImage _posterizedImage;
  late PImage _blurredImage;
  late PImage _erodedImage;
  late PImage _dilatedImage;

  Sketch createSketch() {
    return Sketch.simple(
      setup: (s) async {
        s.size(width: 800, height: 400);
        s.background(color: const Color(0xFFFFFFFF));

        _canvasImage = PImage.empty(800, 400, ImageFileFormat.png);

        _baseImage = await s.loadPImage("assets/coffee.png");
        // _baseImage.filter(ImageFilter.gray);

        _thresholdImage = _baseImage.copy()..filter(ImageFilter.threshold, 0.5);
        _canvasImage.copyFrom(
          source: _thresholdImage,
          sourceRect: Rect.fromLTWH(0, 0, 200, 200),
          destRect: Rect.fromLTWH(0, 0, 200, 200),
        );

        _grayImage = _baseImage.copy()..filter(ImageFilter.gray);
        _canvasImage.copyFrom(
          source: _grayImage,
          sourceRect: Rect.fromLTWH(0, 0, 200, 200),
          destRect: Rect.fromLTWH(200, 0, 200, 200),
        );

        _opaqueImage = _baseImage.copy()..filter(ImageFilter.opaque);
        _canvasImage.copyFrom(
          source: _opaqueImage,
          sourceRect: Rect.fromLTWH(0, 0, 200, 200),
          destRect: Rect.fromLTWH(400, 0, 200, 200),
        );

        _invertedImage = _baseImage.copy()..filter(ImageFilter.invert);
        _canvasImage.copyFrom(
          source: _invertedImage,
          sourceRect: Rect.fromLTWH(0, 0, 200, 200),
          destRect: Rect.fromLTWH(600, 0, 200, 200),
        );

        _posterizedImage = _baseImage.copy()..filter(ImageFilter.posterize, 4);
        _canvasImage.copyFrom(
          source: _posterizedImage,
          sourceRect: Rect.fromLTWH(0, 0, 200, 200),
          destRect: Rect.fromLTWH(0, 200, 200, 200),
        );

        _erodedImage = _baseImage.copy()..filter(ImageFilter.erode);
        _canvasImage.copyFrom(
          source: _erodedImage,
          sourceRect: Rect.fromLTWH(0, 0, 200, 200),
          destRect: Rect.fromLTWH(400, 200, 200, 200),
        );

        _dilatedImage = _baseImage.copy()..filter(ImageFilter.dilate);
        _canvasImage.copyFrom(
          source: _dilatedImage,
          sourceRect: Rect.fromLTWH(0, 0, 200, 200),
          destRect: Rect.fromLTWH(600, 200, 200, 200),
        );
      },
      draw: (s) async {
        await s.pImage(image: _canvasImage);

        // await s.pImage(image: _opaqueImage);
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
