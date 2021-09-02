import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

void processingSpecTest(String description, Future<void> Function(WidgetTester) test) {
  testGoldens(description, (tester) async {
    configureWindowForSpecTest(tester);

    await test(tester);

    tester.binding.window.clearAllTestValues();
  });
}

void configureWindowForSpecTest(WidgetTester tester) {
  tester.binding.window
    ..physicalSizeTestValue = Size(100, 100)
    ..devicePixelRatioTestValue = 1.0;
}

class TestAssetBundle implements AssetBundle {
  static Map<String, ByteData> _cache = {};

  /// [filepath] is relative to the "/test/assets/" directory.
  @override
  Future<ByteData> load(String filename) async {
    if (_cache.containsKey(filename)) {
      return _cache[filename]!;
    }

    final file = File('test/assets/$filename');
    final fileData = await file.readAsBytes();
    _cache[filename] = ByteData.view(fileData.buffer);

    return _cache[filename]!;
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) {
    // TODO: implement loadString
    throw UnimplementedError();
  }

  @override
  Future<T> loadStructuredData<T>(String key, Future<T> Function(String value) parser) {
    // TODO: implement loadStructuredData
    throw UnimplementedError();
  }

  @override
  void evict(String key) {
    // TODO: implement evict
  }
}
