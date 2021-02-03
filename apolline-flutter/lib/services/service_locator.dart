import 'package:get_it/get_it.dart';

import 'realtime_data_service.dart';
import 'realtime_data_service_impl.dart';
import 'package:apollineflutter/models/user_configuration.dart';

GetIt locator = GetIt.instance;

setupServiceLocator() {
  locator.registerLazySingleton<RealtimeDataService>(
      () => RealtimeDataServiceImpl());
  locator.registerLazySingleton<UserConfiguration>(() => UserConfiguration());
  
}
