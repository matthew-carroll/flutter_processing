import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'test_infra.dart';

void main() async {
  test('Decode image (dart test)', () async {
    await TestAssetBundle().load('space_100x.png');

    final imageData = await TestAssetBundle().load('space_100x.png');

    final codec = await (await ImageDescriptor.encoded(
      await ImmutableBuffer.fromUint8List(imageData.buffer.asUint8List()),
    ))
        .instantiateCodec();

    final frame = await codec.getNextFrame();
  });

  testWidgets('Decode image (widget test)', (tester) async {
    tester.binding;
    tester.runAsync(() async {
      await TestAssetBundle().load('space_100x.png');

      final imageData = await TestAssetBundle().load('space_100x.png');

      final codec = await (await ImageDescriptor.encoded(
        await ImmutableBuffer.fromUint8List(imageData.buffer.asUint8List()),
      ))
          .instantiateCodec();

      final frame = await codec.getNextFrame();
    });
  });
}
