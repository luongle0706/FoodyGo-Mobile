import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:foodygo/repository/auth_repository.dart';
import 'package:foodygo/service/auth_service.dart';
import 'package:get_it/get_it.dart';

final locator = GetIt.instance;

void setupInjection() {
  // Storage
  locator.registerSingleton<FlutterSecureStorage>(FlutterSecureStorage());

  // Repositories
  locator.registerSingleton<AuthRepository>(AuthRepository());

  //Services
  locator.registerSingleton<AuthService>(AuthService());
}
