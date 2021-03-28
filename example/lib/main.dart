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
        child: Processing(
          sketch: Sketch.simple(
            setup: (s) {
              s
                ..size(width: 400, height: 400)
                ..background(color: Colors.white);
            },
            draw: (s) {
              s.circle(
                center: Size(s.width.toDouble(), s.height.toDouble()).center(Offset.zero),
                diameter: 50,
              );
            },
          ),
        ),
      ),
    );
  }
}
