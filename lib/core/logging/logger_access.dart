import 'package:embutido_tracker/core/services/logger_service.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class LoggerAccess {
  static BuildContext? _context;
  static LoggerService? _loggerService;

  static void init({BuildContext? context, LoggerService? loggerService}) {
    final hasContext = context != null;
    final hasLoggerService = loggerService != null;

    if (hasContext == hasLoggerService) {
      throw ArgumentError(
        "Must provide EITHER a BuildContext, or a LoggerService.",
      );
    }

    if (hasContext) _context = context;
    if (hasLoggerService) _loggerService = loggerService;
  }

  static LoggerService get logger {
    if (_loggerService != null) return _loggerService!;
    if (_context == null) {
      throw StateError("LoggerAccess not initialized. Call init() first.");
    }

    return Provider.of<LoggerService>(_context!, listen: false);
  }
}
