import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void configureWindowForSpecTest(WidgetTester tester) {
  tester.binding.window
    ..physicalSizeTestValue = Size(100, 100)
    ..devicePixelRatioTestValue = 1.0;
}
