import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:gme/features/settings/data/datasource/settings_remote_datasource.dart';
import 'package:gme/features/settings/data/repository/settings_repository_impl.dart';
import 'package:gme/features/settings/domain/repository/settings_repository.dart';
import '../../features/auth/data/datasource/auth_remote_datasource.dart';
import '../../features/auth/data/repository/auth_repository_impl.dart';
import '../../features/auth/domain/repository/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import 'storage_service.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'network_info.dart';
import '../../features/processing/presentation/bloc/processing_bloc.dart';
import '../../features/processing/domain/repository/processing_repository.dart';
import '../../features/processing/data/repository/processing_repository_impl.dart';
import '../../features/processing/data/datasource/processing_remote_datasource.dart';
import '../../features/processing/presentation/bloc/processing_event.dart';

import '../../features/client_mgmt/data/datasource/clients_remote_datasource.dart';
import '../../features/client_mgmt/data/repository/clients_repository_impl.dart';
import '../../features/client_mgmt/domain/repository/clients_repository.dart';
import '../../features/client_mgmt/presentation/bloc/clients_bloc.dart';

import '../../features/assaying/data/datasource/assaying_remote_datasource.dart';
import '../../features/assaying/data/repository/assaying_repository_impl.dart';
import '../../features/assaying/domain/repository/assaying_repository.dart';
import '../../features/assaying/presentation/bloc/assaying_bloc.dart';

import '../../features/warehousing/data/datasource/warehousing_remote_datasource.dart';
import '../../features/warehousing/data/repository/warehousing_repository_impl.dart';
import '../../features/warehousing/domain/repository/warehousing_repository.dart';
import '../../features/warehousing/presentation/bloc/warehousing_bloc.dart';

import '../../features/dispatch/data/datasource/dispatch_remote_datasource.dart';
import '../../features/dispatch/data/repository/dispatch_repository_impl.dart';
import '../../features/dispatch/domain/repository/dispatch_repository.dart';
import '../../features/dispatch/presentation/bloc/dispatch_bloc.dart';

import '../../features/export/data/datasource/export_remote_datasource.dart';
import '../../features/export/data/repository/export_repository_impl.dart';
import '../../features/export/domain/repository/export_repository.dart';
import '../../features/export/presentation/bloc/export_bloc.dart';

import '../../features/transportation/data/datasource/transportation_remote_datasource.dart';
import '../../features/transportation/data/repository/transportation_repository_impl.dart';
import '../../features/transportation/domain/repository/transportation_repository.dart';
import '../../features/transportation/presentation/bloc/transportation_bloc.dart';

import '../../features/financials/data/datasource/financials_remote_datasource.dart';
import '../../features/financials/data/repository/financials_repository_impl.dart';
import '../../features/financials/domain/repository/financials_repository.dart';
import '../../features/financials/presentation/bloc/financials_bloc.dart';
import '../../features/settings/presentation/bloc/settings_bloc.dart';
import '../../features/yard_intake/data/datasource/yard_intake_remote_datasource.dart';
import '../../features/yard_intake/data/repository/yard_intake_repository_impl.dart';
import '../../features/yard_intake/domain/repository/yard_intake_repository.dart';
import '../../features/yard_intake/presentation/bloc/yard_intake_bloc.dart';

import 'api_interceptor.dart';

import '../constants/api_constants.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Features - Auth
  // Bloc
  sl.registerFactory(() => AuthBloc(loginUseCase: sl()));
  sl.registerFactory(() => ProcessingBloc(repository: sl()));
  sl.registerFactory(() => ClientsBloc(repository: sl()));
  sl.registerFactory(() => AssayingBloc(repository: sl()));
  sl.registerFactory(() => WarehousingBloc(repository: sl()));
  sl.registerFactory(() => DispatchBloc(repository: sl()));
  sl.registerFactory(() => ExportBloc(repository: sl()));
  sl.registerFactory(() => TransportationBloc(repository: sl()));
  sl.registerFactory(() => FinancialsBloc(repository: sl()));
  sl.registerFactory(() => SettingsBloc(repository: sl()));
  sl.registerFactory(() => YardIntakeBloc(repository: sl()));

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      storageService: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<ProcessingRepository>(
    () => ProcessingRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<ClientsRepository>(
    () => ClientsRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<AssayingRepository>(
    () => AssayingRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<WarehousingRepository>(
    () => WarehousingRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<DispatchRepository>(
    () => DispatchRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<ExportRepository>(
    () => ExportRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<TransportationRepository>(
    () => TransportationRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<FinancialsRepository>(
    () => FinancialsRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<YardIntakeRepository>(
    () => YardIntakeRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<ProcessingRemoteDataSource>(
    () => ProcessingRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<ClientsRemoteDataSource>(
    () => ClientsRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<AssayingRemoteDataSource>(
    () => AssayingRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<WarehousingRemoteDataSource>(
    () => WarehousingRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<DispatchRemoteDataSource>(
    () => DispatchRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<ExportRemoteDataSource>(
    () => ExportRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<TransportationRemoteDataSource>(
    () => TransportationRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<FinancialsRemoteDataSource>(
    () => FinancialsRemoteDataSourceImpl(dio: sl()),
  );

  sl.registerLazySingleton<SettingsRemoteDataSource>(
    () => SettingsRemoteDataSourceImpl(dio: sl()),
  );

  sl.registerLazySingleton<YardIntakeRemoteDataSource>(
    () => YardIntakeRemoteDataSourceImpl(dio: sl()),
  );

  // Core
  sl.registerLazySingleton(() => StorageService());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton(() => InternetConnectionChecker());

  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  dio.interceptors.add(ApiInterceptor(storageService: sl()));

  sl.registerLazySingleton(() => dio);
}
