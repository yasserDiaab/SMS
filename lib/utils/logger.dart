import 'dart:developer' as developer;

enum LogLevel {
  debug,
  info,
  warning,
  error,
  critical
}

class AppLogger {
  static const String _appName = 'FollowSafe';
  
  // Colors for different log levels (for console output)
  static const String _reset = '\x1B[0m';
  static const String _red = '\x1B[31m';
  static const String _green = '\x1B[32m';
  static const String _yellow = '\x1B[33m';
  static const String _blue = '\x1B[34m';
  static const String _magenta = '\x1B[35m';
  static const String _cyan = '\x1B[36m';

  static void debug(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.debug, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  static void info(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  static void warning(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.warning, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.error, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  static void critical(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.critical, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  static void _log(LogLevel level, String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    final timestamp = DateTime.now().toIso8601String();
    final levelStr = level.name.toUpperCase();
    final tagStr = tag != null ? '[$tag]' : '';
    final errorStr = error != null ? ' ERROR: $error' : '';
    
    String color;
    switch (level) {
      case LogLevel.debug:
        color = _cyan;
        break;
      case LogLevel.info:
        color = _green;
        break;
      case LogLevel.warning:
        color = _yellow;
        break;
      case LogLevel.error:
        color = _red;
        break;
      case LogLevel.critical:
        color = _magenta;
        break;
    }

    final logMessage = '$color[$timestamp] [$_appName] [$levelStr] $tagStr $message$errorStr$_reset';
    
    // Use developer.log for better debugging support
    developer.log(
      message,
      time: DateTime.now(),
      level: _getLevelValue(level),
      name: tag ?? _appName,
      error: error,
      stackTrace: stackTrace,
    );
    
    // Also print to console for immediate visibility
    print(logMessage);
    
    if (stackTrace != null) {
      print('$color[STACK TRACE]$_reset');
      print(stackTrace.toString());
    }
  }

  static int _getLevelValue(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 500;
      case LogLevel.info:
        return 800;
      case LogLevel.warning:
        return 900;
      case LogLevel.error:
        return 1000;
      case LogLevel.critical:
        return 1200;
    }
  }

  // Specialized logging methods for different components
  static void hive(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, tag: 'HIVE', error: error, stackTrace: stackTrace);
  }

  static void signalR(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, tag: 'SIGNALR', error: error, stackTrace: stackTrace);
  }

  static void sos(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, tag: 'SOS', error: error, stackTrace: stackTrace);
  }

  static void auth(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, tag: 'AUTH', error: error, stackTrace: stackTrace);
  }

  static void location(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, tag: 'LOCATION', error: error, stackTrace: stackTrace);
  }

  static void network(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, tag: 'NETWORK', error: error, stackTrace: stackTrace);
  }

  static void navigation(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, tag: 'NAVIGATION', error: error, stackTrace: stackTrace);
  }

  static void timer(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, tag: 'TIMER', error: error, stackTrace: stackTrace);
  }

  static void notification(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, tag: 'NOTIFICATION', error: error, stackTrace: stackTrace);
  }

  static void trip(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, tag: 'TRIP', error: error, stackTrace: stackTrace);
  }

  // Method to log method entry and exit
  static void methodEntry(String className, String methodName, {Map<String, dynamic>? params}) {
    final paramsStr = params != null ? ' with params: $params' : '';
    debug('→ Entering $className.$methodName$paramsStr', tag: 'METHOD');
  }

  static void methodExit(String className, String methodName, {dynamic result}) {
    final resultStr = result != null ? ' returning: $result' : '';
    debug('← Exiting $className.$methodName$resultStr', tag: 'METHOD');
  }

  // Method to log API calls
  static void apiCall(String method, String url, {Map<String, dynamic>? headers, dynamic body}) {
    info('🌐 API $method $url', tag: 'API');
    if (headers != null) debug('Headers: $headers', tag: 'API');
    if (body != null) debug('Body: $body', tag: 'API');
  }

  static void apiResponse(String method, String url, int statusCode, {dynamic response}) {
    if (statusCode >= 200 && statusCode < 300) {
      info('✅ API $method $url - $statusCode', tag: 'API');
    } else {
      error('❌ API $method $url - $statusCode', tag: 'API');
    }
    if (response != null) debug('Response: $response', tag: 'API');
  }

  // Method to log state changes
  static void stateChange(String cubitName, String fromState, String toState) {
    info('🔄 $cubitName: $fromState → $toState', tag: 'STATE');
  }

  // Method to log user actions
  static void userAction(String action, {Map<String, dynamic>? details}) {
    final detailsStr = details != null ? ' - $details' : '';
    info('👤 User action: $action$detailsStr', tag: 'USER');
  }

  // Method to log performance metrics
  static void performance(String operation, Duration duration, {Map<String, dynamic>? metrics}) {
    final metricsStr = metrics != null ? ' - $metrics' : '';
    info('⏱️ $operation took ${duration.inMilliseconds}ms$metricsStr', tag: 'PERFORMANCE');
  }
}
