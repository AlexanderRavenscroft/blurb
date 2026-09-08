import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

final log = Logger(
  level: kReleaseMode ? Level.off : Level.all,
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 5,
    lineLength: 80,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.none,
    levelColors: const {
      Level.trace: AnsiColor.fg(0),
      Level.debug: AnsiColor.fg(2),
      Level.info: AnsiColor.fg(6),
      Level.warning: AnsiColor.fg(3),
      Level.error: AnsiColor.fg(202),
      Level.fatal: AnsiColor.fg(199),
    },
    levelEmojis: const {
      Level.trace: '🔍',
      Level.debug: '🐞',
      Level.info: '💡',
      Level.warning: '⚠',
      Level.error: '❌',
      Level.fatal: '👾',
    },
    excludeBox: const {Level.debug: true},
  ),
);
