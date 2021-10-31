import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_processing/flutter_processing.dart';
import 'package:flutter_processing_example/_processing_demo_sketch_display.dart';

class CodingTrainGameOfLifeScreen extends StatefulWidget {
  const CodingTrainGameOfLifeScreen({
    Key? key,
    required this.sketchDemoController,
  }) : super(key: key);

  final SketchDemoController sketchDemoController;

  @override
  _CodingTrainGameOfLifeScreenState createState() => _CodingTrainGameOfLifeScreenState();
}

class _CodingTrainGameOfLifeScreenState extends State<CodingTrainGameOfLifeScreen> {
  @override
  Widget build(BuildContext context) {
    return ProcessingDemo(
      sketchDemoController: widget.sketchDemoController,
      createSketch: () {
        return _GameOfLifeSketch();
      },
    );
  }
}

class _GameOfLifeSketch extends Sketch {
  final _pixelsPerCell = 25.0;
  late int colCount;
  late int rowCount;
  late List<List<bool>> _grid;

  @override
  void setup() {
    size(width: 500, height: 500);

    colCount = (width / _pixelsPerCell).floor();
    rowCount = (height / _pixelsPerCell).floor();

    _grid = List.generate(
      colCount,
      (index) => List.generate(
        rowCount,
        (index) => Random().nextBool(),
      ),
    );

    frameRate = 3;
  }

  @override
  void draw() {
    background(color: Colors.black);

    fill(color: Colors.white);
    for (int col = 0; col < colCount; col += 1) {
      for (int row = 0; row < rowCount; row += 1) {
        if (_grid[col][row]) {
          final topLeft = Offset(col * _pixelsPerCell, row * _pixelsPerCell);
          rect(rect: Rect.fromLTWH(topLeft.dx, topLeft.dy, _pixelsPerCell, _pixelsPerCell));
        }
      }
    }

    _createNextGeneration();
  }

  void _createNextGeneration() {
    final newGrid = List.generate(
      colCount,
      (index) => List.generate(
        rowCount,
        (index) => false,
      ),
    );

    for (int col = 0; col < colCount; col += 1) {
      for (int row = 0; row < rowCount; row += 1) {
        newGrid[col][row] = _calculateNextCellValue(col: col, row: row);
      }
    }

    _grid = newGrid;
  }

  bool _calculateNextCellValue({
    required int col,
    required int row,
  }) {
    int liveNeighborsCount = 0;

    // Top left
    liveNeighborsCount += col > 0 && row > 0 && _grid[col - 1][row - 1] ? 1 : 0;

    // Top
    liveNeighborsCount += row > 0 && _grid[col][row - 1] ? 1 : 0;

    // Top right
    liveNeighborsCount += col < colCount - 1 && row > 0 && _grid[col + 1][row - 1] ? 1 : 0;

    // Right
    liveNeighborsCount += col < colCount - 1 && _grid[col + 1][row] ? 1 : 0;

    // Bottom Right
    liveNeighborsCount += col < colCount - 1 && row < rowCount - 1 && _grid[col + 1][row + 1] ? 1 : 0;

    // Bottom
    liveNeighborsCount += row < rowCount - 1 && _grid[col][row + 1] ? 1 : 0;

    // Bottom Left
    liveNeighborsCount += col > 0 && row < rowCount - 1 && _grid[col - 1][row + 1] ? 1 : 0;

    // Left
    liveNeighborsCount += col > 0 && _grid[col - 1][row] ? 1 : 0;

    if (_grid[col][row] && liveNeighborsCount >= 2 && liveNeighborsCount <= 3) {
      // The living cell survives.
      return true;
    } else if (!_grid[col][row] && liveNeighborsCount == 3) {
      // A dead cell is born.
      return true;
    } else {
      // The cell dies, or remains dead.
      return false;
    }
  }
}
