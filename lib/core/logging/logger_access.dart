import 'package:embutido_tracker/core/services/logger_service.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class LoggerAccess {
  static late BuildContext _context;

  static void init(BuildContext context) => _context = context;

  static LoggerService get logger =>
      Provider.of<LoggerService>(_context, listen: false);
}
