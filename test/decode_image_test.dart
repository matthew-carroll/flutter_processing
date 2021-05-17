import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'test_infra.dart';

void main() async {
  test('Decode image (dart test)', () async {
    print('DART TEST');
    print('Doing initial load of image from disk');
    await TestAssetBundle().load('space_100x.png');

    print('Loading cached image data');
    final imageData = await TestAssetBundle().load('space_100x.png');

    print('loaded image data from bundle');
    final codec = await (await ImageDescriptor.encoded(
      await ImmutableBuffer.fromUint8List(imageData.buffer.asUint8List()),
    ))
        .instantiateCodec();
    print('instantiated codec: ${codec.runtimeType}, frame count: ${codec.frameCount}');

    final frame = await codec.getNextFrame();
    print('Image frame: ${frame.image}');
  });

  testWidgets('Decode image (widget test)', (tester) async {
    print('WIDGET TEST');
    tester.binding;
    tester.runAsync(() async {
      print('Doing initial load of image from disk');
      await TestAssetBundle().load('space_100x.png');

      print('Loading cached image data');
      final imageData = await TestAssetBundle().load('space_100x.png');

      print('loaded image data from bundle');
      final codec = await (await ImageDescriptor.encoded(
        await ImmutableBuffer.fromUint8List(imageData.buffer.asUint8List()),
      ))
          .instantiateCodec();
      print('instantiated codec: ${codec.runtimeType}, frame count: ${codec.frameCount}');

      final frame = await codec.getNextFrame();
      print('Image frame: ${frame.image}');
    });
  });
}
