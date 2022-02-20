part of '_core.dart';

class Processing extends StatefulWidget {
  const Processing({
    Key? key,
    this.focusNode,
    required this.sketch,
    this.clipBehavior = Clip.hardEdge,
  }) : super(key: key);

  final FocusNode? focusNode;
  final Sketch sketch;
  final Clip clipBehavior;

  @override
  _ProcessingState createState() => _ProcessingState();
}

class _ProcessingState extends State<Processing> with SingleTickerProviderStateMixin {
  final _controlKeys = <LogicalKeyboardKey>{
    LogicalKeyboardKey.control,
    LogicalKeyboardKey.controlLeft,
    LogicalKeyboardKey.controlRight,
    LogicalKeyboardKey.meta,
    LogicalKeyboardKey.metaLeft,
    LogicalKeyboardKey.metaRight,
    LogicalKeyboardKey.alt,
    LogicalKeyboardKey.altLeft,
    LogicalKeyboardKey.altRight,
    LogicalKeyboardKey.shift,
    LogicalKeyboardKey.shiftLeft,
    LogicalKeyboardKey.shiftRight,
    LogicalKeyboardKey.capsLock,
    LogicalKeyboardKey.escape,
    LogicalKeyboardKey.arrowLeft,
    LogicalKeyboardKey.arrowRight,
    LogicalKeyboardKey.arrowUp,
    LogicalKeyboardKey.arrowDown,
    LogicalKeyboardKey.home,
    LogicalKeyboardKey.end,
    LogicalKeyboardKey.pageUp,
    LogicalKeyboardKey.pageDown,
  };

  final _sketchCanvasKey = GlobalKey();

  late Ticker _ticker;
  late FocusNode _focusNode;

  Image? _currentImage;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();

    _focusNode = widget.focusNode ?? FocusNode();

    widget.sketch
      ..addOnFrameAvailableCallback(_onFrameAvailable)
      .._onSizeChanged = _onSizeChanged
      .._loop = _loop
      .._noLoop = _noLoop;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.sketch._assetBundle = DefaultAssetBundle.of(context);
  }

  @override
  void didUpdateWidget(Processing oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.focusNode != oldWidget.focusNode) {
      _focusNode = widget.focusNode ?? FocusNode();
    }

    if (widget.sketch != oldWidget.sketch) {
      oldWidget.sketch
        ..removeOnFrameAvailableCallback(_onFrameAvailable)
        .._onSizeChanged = null
        .._loop = null
        .._noLoop = null;

      widget.sketch
        ..addOnFrameAvailableCallback(_onFrameAvailable)
        .._assetBundle = DefaultAssetBundle.of(context)
        .._onSizeChanged = _onSizeChanged
        .._loop = _loop
        .._noLoop = _noLoop;

      _ticker.stop();
      if (widget.sketch._isLooping) {
        _ticker.start();
      }
    }
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(elapsedTime) {
    widget.sketch._doDrawFrame(elapsedTime);
  }

  void _onFrameAvailable(Image newFrame) {
    if (mounted) {
      setState(() {
        _currentImage = newFrame;
      });
    }
  }

  void _onSizeChanged() {
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _noLoop() {
    if (_ticker.isTicking) {
      _ticker.stop();
    }
  }

  void _loop() {
    if (!_ticker.isTicking) {
      _ticker.start();
    }
  }

  void _onKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      final key = event.logicalKey;
      widget.sketch
        .._pressedKeys.add(key)
        .._key = key
        ..keyPressed();

      if (!_controlKeys.contains(event.logicalKey)) {
        widget.sketch.keyTyped();
      }
    } else if (event is KeyUpEvent) {
      final key = event.logicalKey;
      widget.sketch
        .._pressedKeys.remove(key)
        .._key = key
        ..keyReleased();
    }
  }

  MouseButton _getMouseButton(int mouseButtonMask) {
    if (mouseButtonMask & kPrimaryMouseButton != 0) {
      return MouseButton.left;
    } else if (mouseButtonMask & kSecondaryMouseButton != 0) {
      return MouseButton.right;
    } else if (mouseButtonMask & kMiddleMouseButton != 0) {
      return MouseButton.center;
    } else {
      throw Exception('Invalid mouse button mask: $mouseButtonMask');
    }
  }

  Offset _getCanvasOffsetFromWidgetOffset(Offset widgetOffset) {
    final myBox = context.findRenderObject();
    final canvasBox = _sketchCanvasKey.currentContext!.findRenderObject() as RenderBox;
    return canvasBox.globalToLocal(widgetOffset, ancestor: myBox);
  }

  void _onPointerDown(PointerDownEvent event) {
    if (event.kind != PointerDeviceKind.mouse && event.kind != PointerDeviceKind.touch) {
      return;
    }

    final mouseButton = _getMouseButton(event.buttons);

    widget.sketch._pressedMouseButtons.add(mouseButton);
    widget.sketch
      .._mouseButton = mouseButton
      .._updateMousePosition(
        _getCanvasOffsetFromWidgetOffset(event.position),
      )
      ..mousePressed();
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (event.kind != PointerDeviceKind.mouse && event.kind != PointerDeviceKind.touch) {
      return;
    }

    final mouseButton = _getMouseButton(event.buttons);

    widget.sketch
      .._mouseButton = mouseButton
      .._updateMousePosition(
        _getCanvasOffsetFromWidgetOffset(event.position),
      )
      ..mouseDragged();
  }

  void _onPointerUp(PointerUpEvent event) {
    if (event.kind != PointerDeviceKind.mouse && event.kind != PointerDeviceKind.touch) {
      return;
    }

    // TODO: the PointerUpEvent does not report which button was relased,
    //       therefore we don't know which one to remove from the set.
    //       For now, we remove all pressed button.
    //
    //       Find an appropriate solution to handle concurrent mouse button
    //       presses and releases.
    widget.sketch._pressedMouseButtons.clear();
    widget.sketch
      .._mouseButton = null
      .._updateMousePosition(
        _getCanvasOffsetFromWidgetOffset(event.position),
      )
      ..mouseReleased()
      ..mouseClicked();
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (event.kind != PointerDeviceKind.mouse && event.kind != PointerDeviceKind.touch) {
      return;
    }

    // TODO: the PointerUpEvent does not report which button was relased,
    //       therefore we don't know which one to remove from the set.
    //       For now, we remove all pressed button.
    //
    //       Find an appropriate solution to handle concurrent mouse button
    //       presses and releases.
    widget.sketch._pressedMouseButtons.clear();
    widget.sketch
      .._mouseButton = null
      .._updateMousePosition(
        _getCanvasOffsetFromWidgetOffset(event.position),
      )
      ..mouseReleased();
  }

  void _onPointerHover(PointerHoverEvent event) {
    if (event.kind != PointerDeviceKind.mouse && event.kind != PointerDeviceKind.touch) {
      return;
    }

    widget.sketch
      .._updateMousePosition(
        _getCanvasOffsetFromWidgetOffset(event.position),
      )
      ..mouseMoved();
  }

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) {
      return;
    }

    widget.sketch.mouseWheel(event.scrollDelta.dy);
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (focusNode, keyEvent) {
        _onKeyEvent(keyEvent);
        return KeyEventResult.handled;
      },
      child: Listener(
        onPointerDown: _onPointerDown,
        onPointerMove: _onPointerMove,
        onPointerUp: _onPointerUp,
        onPointerCancel: _onPointerCancel,
        onPointerHover: _onPointerHover,
        onPointerSignal: _onPointerSignal,
        child: Center(
          child: _currentImage != null
              ? OverflowBox(
                  maxWidth: double.infinity,
                  maxHeight: double.infinity,
                  child: SizedBox(
                    width: _currentImage!.width.toDouble(),
                    height: _currentImage!.height.toDouble(),
                    child: RawImage(
                      key: _sketchCanvasKey,
                      image: _currentImage,
                    ),
                  ),
                )
              : SizedBox(
                  key: _sketchCanvasKey,
                ),
        ),
      ),
    );
  }
}
