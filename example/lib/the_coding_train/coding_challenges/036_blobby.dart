import 'package:flutter/material.dart';
import 'package:flutter_processing/flutter_processing.dart';
import 'package:flutter_processing_example/_processing_demo_sketch_display.dart';

class CodingTrainBlobbyScreen extends StatefulWidget {
  const CodingTrainBlobbyScreen({
    Key? key,
    required this.sketchDemoController,
  }) : super(key: key);

  final SketchDemoController sketchDemoController;

  @override
  _CodingTrainBlobbyScreenState createState() => _CodingTrainBlobbyScreenState();
}

class _CodingTrainBlobbyScreenState extends State<CodingTrainBlobbyScreen> {
  @override
  Widget build(BuildContext context) {
    return ProcessingDemo(
      sketchDemoController: widget.sketchDemoController,
      createSketch: () {
        return _BlobbySketch();
      },
    );
  }
}

class _BlobbySketch extends Sketch {
  @override
  void setup() {
    size(width: 500, height: 500);
  }

  @override
  void draw() {
    background(color: Colors.black);
    fill(color: Colors.white);

    final angularSteps = 64;
    final stepAngle = TWO_PI / angularSteps;
    final radius = 100;

    translate(x: width / 2, y: height / 2);
    beginShape();
    for (int i = 0; i < angularSteps; i += 1) {
      final angle = i * stepAngle;
      final vertexPosition = PVector(
        radius * cos(angle),
        radius * sin(angle),
      );

      final vertexOffset = _chooseVertexOffset(index: i, stepCount: angularSteps, angle: angle);
      vertexPosition.mag = vertexPosition.mag + vertexOffset;

      vertex(vertexPosition.x, vertexPosition.y);
    }
    endShape(close: true);
  }

  num _chooseVertexOffset({
    required int index,
    required int stepCount,
    required num angle,
  }) {
    // return _randomOffset();

    // return _waveOffset(
    //   percent: index / stepCount,
    //   cycles: 5,
    // );

    return _perlineNoise(percent: index / stepCount, offset: frameCount / 1);
  }

  num _randomOffset() => random(10);

  num _waveOffset({required num percent, required int cycles}) {
    return 30 * sin(percent * TWO_PI * cycles);
  }

  num _perlineNoise({required num percent, required num offset}) {
    final noiseValue = noise(
      x: 1000 * cos(TWO_PI * percent),
      y: 1000 * sin(TWO_PI * percent),
      z: offset.toDouble(),
    );

    return noiseValue * 30 - 15;
  }
}
