import 'package:flutter/material.dart';
import 'package:flutter_processing/flutter_processing.dart';

void main() {
  runApp(FlutterProcessingExampleApp());
}

class FlutterProcessingExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Processing Example',
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
  Offset _circleOffset = Offset(400, 250);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow,
      body: Center(
        child: SizedBox(
          width: 800,
          height: 500,
          child: Processing(
            sketch: Sketch.simple(
              setup: (s) {
                print('setup()');
                s.frameRate = 30;
              },
              draw: (s) {
                print('draw(), frame: ${s.frameCount}, FPS: ${s.frameRate}');

                if (s.frameCount % 15 == 0) {
                  final x = s.random(200, 600);
                  final y = s.random(100, 400);
                  _circleOffset = Offset(x, y);
                }
                s.circle(center: _circleOffset, diameter: 50);
              },
            ),
          ),
        ),
      ),
    );
  }
}
