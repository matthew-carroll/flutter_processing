class SketchTimeAndDate {
  final _appStartTime = DateTime.now();

  int millis() => DateTime.now().millisecondsSinceEpoch - _appStartTime.millisecondsSinceEpoch;

  int second() => DateTime.now().second;

  int minute() => DateTime.now().minute;

  int hour() => DateTime.now().hour;

  int day() => DateTime.now().day;

  int month() => DateTime.now().month;

  int year() => DateTime.now().year;
}
