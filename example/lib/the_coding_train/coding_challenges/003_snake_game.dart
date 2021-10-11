import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_processing/flutter_processing.dart';

import '../../_processing_demo_sketch_display.dart';

class CodingTrainSnakeGameScreen extends StatefulWidget {
  const CodingTrainSnakeGameScreen({
    Key? key,
    required this.sketchDemoController,
  }) : super(key: key);

  final SketchDemoController sketchDemoController;

  @override
  _CodingTrainSnakeGameScreenState createState() => _CodingTrainSnakeGameScreenState();
}

class _CodingTrainSnakeGameScreenState extends State<CodingTrainSnakeGameScreen> {
  final _sketchFocusNode = FocusNode();

  @override
  void reassemble() {
    super.reassemble();
    _sketchFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _sketchFocusNode.dispose();
    super.dispose();
  }

  Sketch createSketch() {
    return _SnakeGameSketch();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ProcessingDemo(
          sketchFocusNode: _sketchFocusNode,
          createSketch: createSketch,
          sketchDemoController: widget.sketchDemoController,
        ),
        IgnorePointer(
          child: AnimatedBuilder(
            animation: _sketchFocusNode,
            builder: (context, child) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 100, vertical: 2),
                decoration: BoxDecoration(
                  border: _sketchFocusNode.hasFocus ? Border.all(color: Colors.blue) : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SnakeGameSketch extends Sketch {
  final _pixelsPerCell = 10.0;
  late int colCount;
  late int rowCount;

  late Snake _snake;
  Point<int>? _food;
  bool _isGameOver = false;

  @override
  Future<void> setup() async {
    size(width: 500, height: 500);
    frameRate = 10;

    colCount = (width / _pixelsPerCell).floor();
    rowCount = (height / _pixelsPerCell).floor();

    final random = Random();
    _snake = Snake(position: Point(random.nextInt(colCount), random.nextInt(rowCount)));
  }

  @override
  Future<void> draw() async {
    background(color: const Color.fromARGB(255, 51, 51, 51));

    if (_isGameOver) {
      background(color: Colors.red);
      noLoop();
      return;
    }

    // Draw food
    if (_food != null) {
      fill(color: Colors.red);
      rect(
          rect: Rect.fromLTWH(
        _food!.x * _pixelsPerCell,
        _food!.y * _pixelsPerCell,
        _pixelsPerCell,
        _pixelsPerCell,
      ));
    }

    // Draw Snake
    fill(color: Colors.white);
    for (final cell in _snake.cells) {
      rect(
          rect: Rect.fromLTWH(
        cell.x * _pixelsPerCell,
        cell.y * _pixelsPerCell,
        _pixelsPerCell,
        _pixelsPerCell,
      ));
    }

    // Eat (maybe?)
    if (_food != null) {
      final didEat = _snake.maybeEat(_food!);
      if (didEat) {
        _food = null;
      }
    }

    // Update the game loop
    _snake.update();

    // Check for game over condition
    if (!_snake.isInBounds(width: colCount, height: rowCount) || _snake.isOverlapping()) {
      _isGameOver = true;
    }

    // Generate food, if needed
    if (_food == null) {
      _food = _randomCell();
    }
  }

  Point<int> _randomCell() {
    final random = Random();
    return Point(random.nextInt(colCount), random.nextInt(rowCount));
  }

  @override
  void keyPressed() {
    if (key == LogicalKeyboardKey.arrowUp) {
      _snake.direction = _Direction.up;
    } else if (key == LogicalKeyboardKey.arrowDown) {
      _snake.direction = _Direction.down;
    } else if (key == LogicalKeyboardKey.arrowRight) {
      _snake.direction = _Direction.right;
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      _snake.direction = _Direction.left;
    }
  }
}

class Snake {
  Snake({
    required Point<int> position,
  }) : _cells = [position];

  List<Point<int>> _cells;
  List<Point<int>> get cells => _cells;

  Point<int> get head => cells.first;

  _Direction _direction = _Direction.right;
  _Direction get direction => _direction;
  set direction(_Direction newDirection) {
    if (!newDirection.isOpposite(_direction)) {
      _direction = newDirection;
    }
  }

  bool _didJustEat = false;

  bool isInBounds({
    required int width,
    required int height,
  }) {
    return head.x >= 0 && head.x < width && head.y >= 0 && head.y < height;
  }

  bool isOverlapping() {
    if (_cells.length < 5) {
      return false;
    }

    for (int i = 1; i < _cells.length; i += 1) {
      if (_cells[i] == head) {
        return true;
      }
    }
    return false;
  }

  bool maybeEat(Point<int> foodPosition) {
    _didJustEat = foodPosition == head;
    return _didJustEat;
  }

  void update() {
    final newHead = direction.move(head);

    if (!_didJustEat) {
      _cells.removeLast();
    }
    _didJustEat = false;

    _cells.insert(0, newHead);
  }
}

enum _Direction {
  left,
  up,
  right,
  down,
}

extension on _Direction {
  bool isOpposite(_Direction other) {
    switch (this) {
      case _Direction.left:
        return other == _Direction.right;
      case _Direction.up:
        return other == _Direction.down;
      case _Direction.right:
        return other == _Direction.left;
      case _Direction.down:
        return other == _Direction.up;
    }
  }

  Point<int> move(Point<int> position) {
    switch (this) {
      case _Direction.left:
        return position + Point(-1, 0);
      case _Direction.up:
        return position + Point(0, -1);
      case _Direction.right:
        return position + Point(1, 0);
      case _Direction.down:
        return position + Point(0, 1);
    }
  }
}
