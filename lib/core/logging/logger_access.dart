import 'package:embutido_tracker/core/services/logger_service.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class LoggerAccess {
  static late BuildContext _context;
  static LoggerService? _overrideLogger;

  static void init(BuildContext context) => _context = context;

  static void overrideLogger(LoggerService logger) => _overrideLogger = logger;

  static void clearOverride() => _overrideLogger = null;

  static LoggerService get logger =>
      _overrideLogger ?? Provider.of<LoggerService>(_context, listen: false);
}
