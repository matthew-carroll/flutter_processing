import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart' hide Image;
import 'package:flutter/services.dart';
import 'package:flutter_processing/flutter_processing.dart';

import '../../_processing_demo_sketch_display.dart';

class CodingTrainFlappyBirdScreen extends StatefulWidget {
  const CodingTrainFlappyBirdScreen({
    Key? key,
    required this.sketchDemoController,
  }) : super(key: key);

  final SketchDemoController sketchDemoController;

  @override
  _CodingTrainFlappyBirdScreenState createState() => _CodingTrainFlappyBirdScreenState();
}

class _CodingTrainFlappyBirdScreenState extends State<CodingTrainFlappyBirdScreen> {
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
  final _parallaxSpeedMultiple = 1.0;
  final _birdSize = 30.0;
  final _pipeSpeed = 3.0;
  final _pipeWidth = 50.0;

  late Image _backdropBitmap;
  late Image _topPipeBitmap;
  late Image _bottomPipeBitmap;
  late Image _birdBitmap;

  late Offset _backdrop1Offset;
  late Offset _backdrop2Offset;
  late Bird _bird;
  final _pipes = <Pipe>[];
  bool _isGameOver = false;

  @override
  Future<void> setup() async {
    size(width: 400, height: 600);

    _backdropBitmap = await loadImage('assets/coding-train/031_flappy_bird/flappy-bird_bk.png');
    _topPipeBitmap = await loadImage('assets/coding-train/031_flappy_bird/pipe_top.png');
    _bottomPipeBitmap = await loadImage('assets/coding-train/031_flappy_bird/pipe_bottom.png');
    _birdBitmap = await loadImage('assets/coding-train/031_flappy_bird/dash.png');

    final backdropScale = height / _backdropBitmap.height;
    final backdropScaledWidth = _backdropBitmap.width * backdropScale;
    _backdrop1Offset = Offset.zero;
    _backdrop2Offset = _backdrop1Offset + Offset(backdropScaledWidth, 0);

    _bird = Bird(
      size: _birdSize,
      position: Offset(100, 100),
    );
  }

  @override
  Future<void> draw() async {
    // Update the game loop
    _bird.update();

    final pipesToRemove = <Pipe>[];
    for (final pipe in _pipes) {
      pipe.move(distance: _pipeSpeed);

      if (pipe.left + pipe.width <= 0) {
        pipesToRemove.add(pipe);
      }
    }
    _pipes.removeWhere((pipe) => pipesToRemove.contains(pipe));

    if (frameCount % 100 == 0) {
      _pipes.add(_createPipe());
    }

    // Apply lift
    if (isKeyPressed && key == LogicalKeyboardKey.space) {
      _bird.lift();
    }

    // Draw landscape backdrop
    image(image: _backdropBitmap, origin: _backdrop1Offset, height: height.toDouble());
    image(image: _backdropBitmap, origin: _backdrop2Offset, height: height.toDouble());

    final backdropScale = height / _backdropBitmap.height;
    final backdropScaledWidth = _backdropBitmap.width * backdropScale;
    _backdrop1Offset -= Offset(_parallaxSpeedMultiple, 0);
    _backdrop2Offset -= Offset(_parallaxSpeedMultiple, 0);
    if (_backdrop1Offset.dx < -backdropScaledWidth) {
      _backdrop1Offset = _backdrop2Offset;
      _backdrop2Offset = _backdrop1Offset + Offset(backdropScaledWidth, 0);
    }

    // Draw Pipes
    for (final pipe in _pipes) {
      final bitmapScale = pipe.width / _topPipeBitmap.width;
      final topPipeBitmapHeight = max(_topPipeBitmap.height * bitmapScale, pipe.holeTop);
      image(
        image: _topPipeBitmap,
        origin: Offset(pipe.left, pipe.holeTop - topPipeBitmapHeight),
        width: pipe.width,
        height: topPipeBitmapHeight,
      );
      image(
        image: _bottomPipeBitmap,
        origin: Offset(pipe.left, pipe.holeBottom),
        width: pipe.width,
        height: max(_bottomPipeBitmap.height * bitmapScale, height - pipe.holeBottom),
      );
    }

    // Draw Bird
    final birdBitmapSize = _birdSize * 1.75;
    final birdBitmapOffset = _bird.position - (Offset(birdBitmapSize, birdBitmapSize) / 2);
    image(image: _birdBitmap, origin: birdBitmapOffset, width: birdBitmapSize, height: birdBitmapSize);

    // _drawSolids();

    // Check for game over condition
    if (!_bird.isInBounds(height: height.toDouble())) {
      _isGameOver = true;
    }
    for (final pipe in _pipes) {
      if (_bird.didHitPipe(pipe)) {
        _isGameOver = true;
        break;
      }
    }

    if (_isGameOver) {
      noFill();
      stroke(color: Colors.red);
      strokeWeight(5);

      rect(rect: Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()));

      noLoop();
      return;
    }
  }

  void _drawSolids() {
    // Draw Pipes
    fill(color: Colors.blue);
    for (final pipe in _pipes) {
      rect(rect: Rect.fromLTRB(pipe.left, 0, pipe.left + pipe.width, pipe.holeTop));
      rect(rect: Rect.fromLTRB(pipe.left, pipe.holeBottom, pipe.left + pipe.width, height.toDouble()));
    }

    // Draw Bird
    fill(color: Colors.white);
    circle(center: _bird.position, diameter: _bird.size);
  }

  Pipe _createPipe() {
    final random = Random();
    final holeTop = random.nextInt((height / 2).round()) + 50;
    final holeHeight = random.nextInt((6 * _birdSize).round()) + (3 * _birdSize);

    return Pipe(
      left: width.toDouble(),
      width: _pipeWidth,
      holeTop: holeTop.toDouble(),
      holeBottom: (holeTop + holeHeight).toDouble(),
    );
  }
}

class Bird {
  final _gravityForce = 0.3;

  Bird({
    required double size,
    required Offset position,
    Offset velocity = Offset.zero,
  })  : _size = size,
        _position = position,
        _velocity = velocity;

  double _size; // interpreted as circle diameter
  double get size => _size;

  Offset _position;
  Offset get position => _position;

  double get right => position.dx + (size / 2);
  double get left => position.dx - (size / 2);
  double get top => position.dy - (size / 2);
  double get bottom => position.dy + (size / 2);

  Offset _velocity;
  Offset get velocity => _velocity;

  bool _applyLift = false;

  bool isInBounds({required double height}) {
    return _position.dy > 0 && _position.dy < height;
  }

  bool didHitPipe(Pipe pipe) {
    if (right < pipe.left || left > pipe.right) {
      return false;
    }

    if (top < pipe.holeTop || bottom > pipe.holeBottom) {
      return true;
    }

    return false;
  }

  void lift() {
    _applyLift = true;
  }

  void update() {
    if (_applyLift) {
      _velocity -= Offset(0, _gravityForce * 1.5);
      _applyLift = false;
    } else {
      _velocity += Offset(0, _gravityForce);
    }
    _position += _velocity;
  }
}

class Pipe {
  Pipe({
    required double left,
    required double width,
    required double holeTop,
    required double holeBottom,
  })  : _left = left,
        _width = width,
        _holeTop = holeTop,
        _holeBottom = holeBottom;

  double _left;
  double get left => _left;

  double get right => left + width;

  double _width;
  double get width => _width;

  double _holeTop;
  double get holeTop => _holeTop;

  double _holeBottom;
  double get holeBottom => _holeBottom;

  void move({required double distance}) {
    _left -= distance;
  }
}
