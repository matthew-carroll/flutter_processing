import 'package:flutter/painting.dart';

class SketchConversion {
  bool boolean(Object value) {
    if (value is int) {
      return value != 0;
    } else if (value is String) {
      return value == 'true';
    } else {
      throw FormatException("Can't convert a value of type ${value.runtimeType} to a boolean");
    }
  }

  int byte(Object value) {
    throw UnimplementedError();
  }

  String char(int charCode) {
    return String.fromCharCode(charCode);
  }

  double float(Object value) {
    if (value is int) {
      return value.toDouble();
    } else if (value is String) {
      return double.parse(value);
    } else {
      throw FormatException("Can't convert a value of type ${value.runtimeType} to a floating point number");
    }
  }

  int toInt(Object value) {
    if (value is int) {
      return value;
    } else if (value is double) {
      return value.floor();
    } else if (value is bool) {
      return value ? 1 : 0;
    } else if (value is String) {
      return int.parse(value);
    } else {
      throw FormatException("Can't convert a value of type ${value.runtimeType} to an integer");
    }
  }

  String str(Object value) {
    return value.toString();
  }

  String binary(Object value) {
    if (value is int) {
      return value.toRadixString(2);
    } else if (value is Color) {
      return value.value.toRadixString(2);
    } else {
      throw FormatException("Can't convert a value of type ${value.runtimeType} to a binary string");
    }
  }

  int unbinary(String binary) => int.parse(binary, radix: 2);

  String hex(Object value) {
    if (value is int) {
      return value.toRadixString(16);
    } else if (value is Color) {
      return value.value.toRadixString(16);
    } else {
      throw FormatException("Can't convert a value of type ${value.runtimeType} to a hex string");
    }
  }

  int unhex(String hex) => int.parse(hex, radix: 16);
}
