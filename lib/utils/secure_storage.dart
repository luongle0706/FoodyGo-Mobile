import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  SecureStorage._();
  static final SecureStorage instance = SecureStorage._();
  final FlutterSecureStorage _flutterSecureStorage = FlutterSecureStorage();

  Future<String?> get({required String key}) async {
    return _flutterSecureStorage.read(key: key);
  }

  Future<void> put({required String key, required String value}) async {
    _flutterSecureStorage.write(key: key, value: value);
  }

  Future<void> delete({required String key}) async {
    _flutterSecureStorage.delete(key: key);
  }
}
