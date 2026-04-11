import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/app.dart';
import 'src/log.dart';

void main() {
  setupLogging();
  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
