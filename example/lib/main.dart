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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow,
      body: Center(
        child: Processing(
          sketch: Sketch.simple(setup: (s) {
            s.size(width: 500, height: 500);
          }, draw: (s) {
            // TODO:
          }, mouseMoved: (s) {
            print(
                'mouseMoved - current position: ${s.mouseX}, ${s.mouseY}, previous position: ${s.pmouseX}, ${s.pmouseY}');
          }, mousePressed: (s) {
            print(
                'mousePressed - current position: ${s.mouseX}, ${s.mouseY}, previous position: ${s.pmouseX}, ${s.pmouseY}');
          }, mouseDragged: (s) {
            print(
                'mouseDragged - current position: ${s.mouseX}, ${s.mouseY}, previous position: ${s.pmouseX}, ${s.pmouseY}');
          }, mouseReleased: (s) {
            print(
                'mouseReleased - current position: ${s.mouseX}, ${s.mouseY}, previous position: ${s.pmouseX}, ${s.pmouseY}');
          }, mouseClicked: (s) {
            print(
                'mouseClicked - current position: ${s.mouseX}, ${s.mouseY}, previous position: ${s.pmouseX}, ${s.pmouseY}');
          }, mouseWheel: (s, count) {
            print('mouseWheel - count: $count');
          }),
        ),
      ),
    );
  }
}
