import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart' hide Image;
import 'package:flutter/services.dart';
import 'package:flutter_processing/flutter_processing.dart';
import 'package:flutter_processing_example/_processing_demo_sketch_display.dart';

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

  @override
  Widget build(BuildContext context) {
    return ProcessingDemo(
      sketchFocusNode: _sketchFocusNode,
      sketchDemoController: widget.sketchDemoController,
      createSketch: () {
        return _FlappyBirdSketch();
      },
    );
  }
}

class _FlappyBirdSketch extends Sketch {
  final _parallaxSpeedMultiple = 1.0;
  late Image _backdropBitmap;
  late double _backdropScale;
  late double _backdropScaledWidth;
  late double _backdrop1XOffset;
  late double _backdrop2XOffset;

  final _pipeSpeed = 3.0;
  final _pipeSolidWidth = 50.0;
  late Image _topPipeBitmap;
  late Image _bottomPipeBitmap;
  final _pipes = <Pipe>[];

  final _birdSolidSize = 30.0;
  final _birdVisualScale = 1.75;
  late double _birdBitmapSize = _birdSolidSize * _birdVisualScale;
  late Image _birdBitmap;
  late Bird _bird;

  bool _isGameOver = false;

  @override
  Future<void> setup() async {
    size(width: 400, height: 600);

    _backdropBitmap = await loadImage('assets/coding-train/031_flappy_bird/flappy-bird_bk.png');
    _topPipeBitmap = await loadImage('assets/coding-train/031_flappy_bird/pipe_top.png');
    _bottomPipeBitmap = await loadImage('assets/coding-train/031_flappy_bird/pipe_bottom.png');
    _birdBitmap = await loadImage('assets/coding-train/031_flappy_bird/dash.png');

    // Scale the backdrop so it fits exactly the height of the canvas
    _backdropScale = height / _backdropBitmap.height;
    _backdropScaledWidth = _backdropScale * _backdropBitmap.width;

    _backdrop1XOffset = 0;
    _backdrop2XOffset = _backdropScaledWidth;

    _bird = Bird(
      size: _birdSolidSize,
      position: Offset(100, 100),
    );
  }

  @override
  Future<void> draw() async {
    // Update the game loop
    _bird.update();

    // Update pipe positions and remove any pipes off screen.
    final pipesToRemove = <Pipe>[];
    for (final pipe in _pipes) {
      pipe.move(distance: _pipeSpeed);

      if (pipe.right <= -50) {
        pipesToRemove.add(pipe);
      }
    }
    _pipes.removeWhere((pipe) => pipesToRemove.contains(pipe));

    // Generate new pipes.
    if (frameCount % 100 == 0) {
      _pipes.add(_createPipe());
    }
    print('${_pipes.length} pipes');

    if (isKeyPressed && key == LogicalKeyboardKey.space) {
      _bird.lift();
    }

    _drawAndUpdateBackdrop();
    _drawPipes(drawSolids: false);
    _drawBird(drawSolids: false);

    _checkForGameOver();
    if (_isGameOver) {
      _drawGameOver();
    }
  }

  void _drawAndUpdateBackdrop() {
    image(image: _backdropBitmap, origin: Offset(_backdrop1XOffset, 0), height: height.toDouble());
    image(image: _backdropBitmap, origin: Offset(_backdrop2XOffset, 0), height: height.toDouble());

    _backdrop1XOffset -= _parallaxSpeedMultiple;
    _backdrop2XOffset -= _parallaxSpeedMultiple;
    if (_backdrop1XOffset < -_backdropScaledWidth) {
      _backdrop1XOffset = _backdrop2XOffset;
      _backdrop2XOffset = _backdrop1XOffset + _backdropScaledWidth;
    }
  }

  void _drawPipes({
    bool drawSolids = false,
  }) {
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

    if (drawSolids) {
      fill(color: Colors.blue);
      for (final pipe in _pipes) {
        rect(rect: Rect.fromLTRB(pipe.left, 0, pipe.right, pipe.holeTop));
        rect(rect: Rect.fromLTRB(pipe.left, pipe.holeBottom, pipe.right, height.toDouble()));
      }
    }
  }

  void _drawBird({
    bool drawSolids = false,
  }) {
    final birdBitmapOffset = _bird.position - (Offset(_birdBitmapSize, _birdBitmapSize) / 2);
    image(
      image: _birdBitmap,
      origin: birdBitmapOffset,
      width: _birdBitmapSize,
      height: _birdBitmapSize,
    );

    if (drawSolids) {
      fill(color: Colors.white);
      circle(center: _bird.position, diameter: _bird.size);
    }
  }

  Pipe _createPipe() {
    final random = Random();
    final holeTop = random.nextInt((height / 2).round()) + 50;
    final holeHeight = random.nextInt((6 * _birdSolidSize).round()) + (3 * _birdSolidSize);

    return Pipe(
      left: width.toDouble(),
      width: _pipeSolidWidth,
      holeTop: holeTop.toDouble(),
      holeBottom: (holeTop + holeHeight).toDouble(),
    );
  }

  void _checkForGameOver() {
    if (!_bird.isInBounds(height: height.toDouble())) {
      _isGameOver = true;
    }

    for (final pipe in _pipes) {
      if (_bird.didHitPipe(pipe)) {
        _isGameOver = true;
        return;
      }
    }
  }

  void _drawGameOver() {
    noFill();
    stroke(color: Colors.red);
    strokeWeight(5);

    rect(rect: Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()));

    noLoop();
    return;
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

  double _size; // interpreted as a circle diameter
  double get size => _size;

  Offset _position;
  Offset get position => _position;

  double get left => position.dx - (size / 2);
  double get right => position.dx + (size / 2);
  double get top => position.dy - (size / 2);
  double get bottom => position.dy + (size / 2);

  Offset _velocity;
  Offset get velocity => _velocity;

  bool isInBounds({required double height}) {
    return top >= 0 && bottom <= height;
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

  bool _applyLift = false;
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

  double get right => _left + _width;

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
