import 'dart:async';

import 'package:flutter/foundation.dart';

class Debouncer {
  final int milliseconds;
  static Timer? timer;

  Debouncer({this.milliseconds = 300});

  run(VoidCallback action) {
    if (timer != null) {
      timer!.cancel();
    }
    timer = Timer(Duration(milliseconds: milliseconds), action);

    // timer?.cancel();
    // timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
