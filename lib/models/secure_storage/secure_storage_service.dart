

import 'package:flutter_secure_storage/flutter_secure_storage.dart';


/// This is the secure storage service that contains sensitive app data
/// on iOS it is stored on keychain
class SecureStorageService {
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  void writeSecureData(String key, String value) async => storage.write(key: key, value:value); // don't think we need to await this

  Future<String?> retrieveSecureData(String key) async => await storage.read(key: key);

  void deleteSecureData(String key) async => storage.delete(key:key);
}