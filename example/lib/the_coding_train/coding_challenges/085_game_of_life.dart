import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_processing/flutter_processing.dart';

import '../../_processing_demo_sketch_display.dart';

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
  Sketch createSketch() {
    return _GameOfLifeSketch();
  }

  @override
  Widget build(BuildContext context) {
    return ProcessingDemo(
      createSketch: createSketch,
      sketchDemoController: widget.sketchDemoController,
    );
  }
}

class _GameOfLifeSketch extends Sketch {
  final _pixelsPerCell = 25.0;
  late int colCount;
  late int rowCount;
  late List<List<bool>> _grid;

  @override
  Future<void> setup() async {
    size(width: 500, height: 500);

    colCount = (width / _pixelsPerCell).floor();
    rowCount = (height / _pixelsPerCell).floor();

    _grid = List.generate(
        colCount,
        (index) => List.generate(
              rowCount,
              (index) => Random().nextBool(),
            ));

    frameRate = 3;
  }

  @override
  Future<void> draw() async {
    background(color: Colors.black);

    fill(color: Colors.white);
    for (int col = 0; col < colCount; col += 1) {
      for (int row = 0; row < rowCount; row += 1) {
        final topLeft = Offset(col * _pixelsPerCell, row * _pixelsPerCell);

        if (_grid[col][row]) {
          rect(rect: Rect.fromLTWH(topLeft.dx, topLeft.dy, _pixelsPerCell, _pixelsPerCell));
        }
      }
    }

    _createNextGeneration();
  }

  void _createNextGeneration() {
    // Create the grid for the next generation.
    final newGrid = List.generate(
        colCount,
        (index) => List.generate(
              rowCount,
              (index) => false,
            ));

    // Calculate the next generation.
    for (int col = 0; col < colCount; col += 1) {
      for (int row = 0; row < rowCount; row += 1) {
        newGrid[col][row] = _calculateNextCellValue(col: col, row: row);
      }
    }

    // Switch the previous generation for the next generation.
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

    // Bottom right
    liveNeighborsCount += col < colCount - 1 && row < rowCount - 1 && _grid[col + 1][row + 1] ? 1 : 0;

    // Bottom
    liveNeighborsCount += row < rowCount - 1 && _grid[col][row + 1] ? 1 : 0;

    // Bottom left
    liveNeighborsCount += col > 0 && row < rowCount - 1 && _grid[col - 1][row + 1] ? 1 : 0;

    // left
    liveNeighborsCount += col > 0 && _grid[col - 1][row] ? 1 : 0;

    // Apply rules of the game of life
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
