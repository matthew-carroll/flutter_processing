import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_processing/flutter_processing.dart';
import 'package:flutter_processing_example/_processing_demo_sketch_display.dart';

class CodingTrainMitosisScreen extends StatefulWidget {
  const CodingTrainMitosisScreen({
    Key? key,
    required this.sketchDemoController,
  }) : super(key: key);

  final SketchDemoController sketchDemoController;

  @override
  _CodingTrainMitosisScreenState createState() => _CodingTrainMitosisScreenState();
}

class _CodingTrainMitosisScreenState extends State<CodingTrainMitosisScreen> {
  final _cells = <Cell>[];

  Sketch createSketch() {
    return Sketch.simple(
      setup: (s) async {
        s.size(width: 512, height: 512);

        for (int i = 0; i < 10; ++i) {
          _cells.add(Cell.randomLocationAndColor(s.width, s.height));
        }
      },
      draw: (s) async {
        s.background(color: Color.fromARGB(255, 200, 200, 200));

        for (final cell in _cells) {
          cell.move();
          cell.show(s);
        }
      },
      mouseClicked: (s) {
        print('clicked - x: ${s.mouseX}, y: ${s.mouseY}');
        final newCells = <Cell>[];
        final oldCells = <Cell>[];

        for (final cell in _cells) {
          if (cell.containsPoint(s.mouseX.toDouble(), s.mouseY.toDouble())) {
            print('Found an intersecting cell');
            cell.containsPoint(s.mouseX.toDouble(), s.mouseY.toDouble());
            newCells.add(cell.mitosis());
            newCells.add(cell.mitosis());

            oldCells.add(cell);
          }
        }

        // Remove "dead" cells
        _cells.removeWhere((element) => oldCells.contains(element));

        // Add new cells
        _cells.addAll(newCells);
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

class Cell {
  factory Cell.randomLocationAndColor(int width, int height) {
    final random = Random();
    return Cell(
      position: Offset(random.nextDouble() * width, random.nextDouble() * height),
      radius: 60,
      color: Color.fromARGB(100, random.nextInt(155) + 100, 0, random.nextInt(155) + 100),
    );
  }

  Cell({
    required this.position,
    required this.radius,
    required this.color,
  });

  Offset position;
  final double radius;
  final Color color;

  bool containsPoint(double x, double y) {
    final distance = (position - Offset(x, y)).distance;
    print('Cell center: $position, tap location: ${Offset(x, y)}');
    print('Distance to cell: $distance, radius: $radius');
    return distance <= radius;
  }

  void move() {
    final randomAngle = Random().nextDouble() * 2 * pi;
    position += Offset.fromDirection(randomAngle, 3);
  }

  void show(Sketch s) {
    s
      ..noStroke()
      ..fill(color: color)
      ..circle(center: position, diameter: radius * 2);
  }

  Cell mitosis() {
    return Cell(
      position: position,
      radius: radius * 0.8,
      color: color,
    );
  }
}
