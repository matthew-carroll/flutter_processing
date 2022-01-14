import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_processing/flutter_processing.dart';
import 'package:flutter_processing_example/_processing_demo_sketch_display.dart';

class CodingTrainFireEffectScreen extends StatefulWidget {
  const CodingTrainFireEffectScreen({
    Key? key,
    required this.sketchDemoController,
  }) : super(key: key);

  final SketchDemoController sketchDemoController;

  @override
  _CodingTrainFireEffectScreenState createState() => _CodingTrainFireEffectScreenState();
}

class _CodingTrainFireEffectScreenState extends State<CodingTrainFireEffectScreen> {
  @override
  Widget build(BuildContext context) {
    return ProcessingDemo(
      sketchDemoController: widget.sketchDemoController,
      createSketch: () {
        return _FireEffectSketch();
      },
    );
  }
}

class _FireEffectSketch extends Sketch {
  ByteData? _flame;
  ByteData? _coolingMap;

  @override
  void setup() {
    size(width: 500, height: 500);
  }

  @override
  void draw() {
    _addTinder();
    _burn();
    _cool();
  }

  void _addTinder() {
    // TODO:
  }

  void _burn() {
    // TODO:
  }

  void _cool() {
    // TODO:
  }
}
