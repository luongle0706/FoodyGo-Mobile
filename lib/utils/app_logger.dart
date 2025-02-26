import 'package:logger/logger.dart';

class AppLogger {
  AppLogger._();
  static final AppLogger instance = AppLogger._();
  final Logger _logger = Logger();

  void debug(String message) => _logger.d(message);
  void info(String message) => _logger.i(message);
  void warning(String message) => _logger.w(message);
  void error(String message) => _logger.e(message);
}
