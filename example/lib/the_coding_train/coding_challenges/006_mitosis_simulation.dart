import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_processing/flutter_processing.dart';

void main() {
  runApp(FlutterProcessingExampleApp());
}

class FlutterProcessingExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mitosis Simulation',
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

class _HomeScreenState extends State<HomeScreen> {
  final _cells = <Cell>[];

  @override
  void reassemble() {
    super.reassemble();
    _cells.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow,
      body: Center(
        child: Processing(
          sketch: Sketch.simple(
            setup: (s) async {
              s.size(width: 700, height: 700);

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
              final newCells = <Cell>[];
              final oldCells = <Cell>[];

              for (final cell in _cells) {
                if (cell.containsPoint(s.mouseX.toDouble(), s.mouseY.toDouble())) {
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
          ),
        ),
      ),
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
