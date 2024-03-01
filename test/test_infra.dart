import 'dart:async';
import 'dart:io';

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

/// Golden test that paints to a 400x400 px canvas, just like
/// images in the official Processing reference from after
/// Aug, 2021.
///
/// See [processingLegacySpecTest] for testing reference images
/// from before Aug, 2021.
void processingSpecTest(String description, Future<void> Function(WidgetTester) test) {
  testGoldens(description, (tester) async {
    tester.binding.window
      ..physicalSizeTestValue = Size(400, 400)
      ..devicePixelRatioTestValue = 1.0;

    await test(tester);

    tester.binding.window.clearAllTestValues();
  });
}

/// Golden test that paints to a 100x100 px canvas, just like
/// images in the official Processing reference from before
/// Aug, 2021.
///
/// See [processingSpecTest] for testing reference images from
/// after Aug, 2021.
void processingLegacySpecTest(String description, Future<void> Function(WidgetTester) test) {
  testGoldens(description, (tester) async {
    // All the legacy Processing reference examples (before Aug 2021)
    // were 100x100 px.
    tester.binding.window
      ..physicalSizeTestValue = Size(100, 100)
      ..devicePixelRatioTestValue = 1.0;

    await test(tester);

    tester.binding.window.clearAllTestValues();
  });
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
    _cache.remove(key);
  }

  @override
  void clear() {
    _cache.clear();
  }

  @override
  Future<ImmutableBuffer> loadBuffer(String key) {
    // TODO: implement loadBuffer
    throw UnimplementedError();
  }

  @override
  Future<T> loadStructuredBinaryData<T>(String key, FutureOr<T> Function(ByteData data) parser) {
    // TODO: implement loadStructuredBinaryData
    throw UnimplementedError();
  }
}
