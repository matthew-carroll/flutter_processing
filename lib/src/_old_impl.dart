import 'package:flutter/material.dart';

import '_core.dart';

class ProcessingDisplayOld extends StatefulWidget {
  const ProcessingDisplayOld({Key key, this.sketch}) : super(key: key);

  final Sketch sketch;

  @override
  _ProcessingDisplayOldState createState() => _ProcessingDisplayOldState();
}

class _ProcessingDisplayOldState extends State<ProcessingDisplayOld>
    with SingleTickerProviderStateMixin {
  double _width = 100;
  double _height = 100;

  Ticker _ticker;
  Duration _lastTickerTime;
  Duration _desiredFrameTime = Duration(milliseconds: 16);

  @override
  void initState() {
    super.initState();

    _ticker = createTicker(_onTick);
    _startTicking();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  // Hook into Flutter's render cycle so that we can draw on every frame.
  void _startTicking() {
    _lastTickerTime = Duration.zero;
    _ticker.start();
  }

  // Do whatever we want during the current Flutter frame, like draw() something.
  void _onTick(currentElapsedTime) {
    // TODO: conform to desired frame rate, rather than calling draw() automatically.
    final timeSinceLastTick = currentElapsedTime - _lastTickerTime;
    _lastTickerTime = currentElapsedTime;

    if (timeSinceLastTick >= _desiredFrameTime) {
      setState(() {});
    }
  }

  // Stop hooking into Flutter's render cycle.
  void _stopTicking() {
    _ticker.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: _width,
        height: _height,
        child: CustomPaint(
          painter: ProcessingSketchPainter(),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class ProcessingSketchPainter extends CustomPainter {
  ProcessingSketchPainter({
    this.sketch,
  });

  final Sketch sketch;

  @override
  void paint(Canvas canvas, Size size) {
    if (sketch != null) {
      sketch.draw();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: use real condition
    return true;
  }
}
