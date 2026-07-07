class AppConfig {
  AppConfig._();

  /// API base URL.
  /// 
  /// - localhost (Web/Desktop/local test): http://localhost:3000
  /// - Android emulator: http://10.0.2.2:3000
  /// - Real device: Kompyuter LAN IP manzili (masalan: http://192.168.1.X:3000)
  static const String apiBaseUrl = 'http://10.0.2.2:3000';
}
