import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:bitmap_canvas/bitmap_canvas.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' hide Image, TextStyle, TextAlignVertical;
import 'package:flutter_processing/flutter_processing.dart';
import 'package:flutter_processing/src/constants/_constants.dart';
import 'package:flutter_processing/src/math/_random.dart';
import 'package:flutter_processing/src/math/_trigonometry.dart';
import 'package:image/image.dart' as imageFormats;
import 'package:path/path.dart' as path;

import '_painting_context.dart';
import 'data/conversion.dart';
import 'input/_time_and_date.dart';
import 'math/_calculations.dart';

part '_processing_widget.dart';
part '_sketch.dart';
part 'color/_setting.dart';
part 'environment/_environment.dart';
part 'input/_keyboard.dart';
part 'input/_mouse.dart';
part 'image/_loading_and_displaying.dart';
part 'image/_pixels.dart';
part 'output/_image.dart';
part 'rendering/_rendering.dart';
part 'shape/_attributes.dart';
part 'shape/_two_d_primitives.dart';
part 'shape/_vertex.dart';
part 'structure/_structure.dart';
part 'transform/_transform.dart';
part 'typography/_typography.dart';

abstract class BaseSketch {
  set paintingContext(SketchPaintingContext context) => _paintingContext = context;
  late SketchPaintingContext _paintingContext;

  AssetBundle? _assetBundle;
}
