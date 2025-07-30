import 'package:logger/logger.dart';

class LoggerService {
  final Logger _logger;

  LoggerService({Logger? logger}) : _logger = logger ?? Logger();

  void debug(String message) => _logger.d(message);
  void info(String message) => _logger.i(message);
  void warn(String message) => _logger.w(message);
  void error(String message) => _logger.e(message);
}