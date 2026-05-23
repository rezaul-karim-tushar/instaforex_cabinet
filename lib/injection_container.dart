import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart'; // Added for the plain SOAP Dio instance
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import 'core/network/dio_client.dart';
import 'core/network/network_info.dart';
import 'core/storage/secure_storage.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/profile/data/datasources/profile_remote_datasource.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/domain/repositories/profile_repository.dart';
import 'features/profile/presentation/cubit/profile_cubit.dart';
import 'features/promo/data/datasources/promo_soap_datasource.dart';
import 'features/promo/data/repositories/promo_repository_impl.dart';
import 'features/promo/domain/repositories/promo_repository.dart';
import 'features/promo/presentation/cubit/promo_cubit.dart';
import 'features/signals/data/datasources/signals_remote_datasource.dart';
import 'features/signals/data/repositories/signals_repository_impl.dart';
import 'features/signals/domain/repositories/signals_repository.dart';
import 'features/signals/presentation/cubit/signals_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // BLoCs & Cubits
  sl.registerFactory(() => AuthBloc(authRepository: sl()));
  sl.registerFactory(() => ProfileCubit(profileRepository: sl()));
  sl.registerFactory(() => SignalsCubit(signalsRepository: sl()));
  sl.registerFactory(() => PromoCubit(promoRepository: sl()));

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      secureStorage: sl(),
    ),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<SignalsRepository>(
    () => SignalsRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<PromoRepository>(
    () => PromoRepositoryImpl(dataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      peanutDio: sl(instanceName: 'peanut'),
      partnerDio: sl(instanceName: 'partner'),
    ),
  );
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(peanutDio: sl(instanceName: 'peanut')),
  );
  sl.registerLazySingleton<SignalsRemoteDataSource>(
    () => SignalsRemoteDataSourceImpl(partnerDio: sl(instanceName: 'partner')),
  );
  sl.registerLazySingleton<PromoSoapDataSource>(
    () => PromoSoapDataSourceImpl(dio: sl(instanceName: 'soap')),
  );

  // Core / External
  sl.registerLazySingleton(() => SecureStorage(sl()));
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton(
    () => DioClient.peanutDio(),
    instanceName: 'peanut',
  );
  sl.registerLazySingleton(
    () => DioClient.partnerDio(),
    instanceName: 'partner',
  );
  sl.registerLazySingleton(
    () => Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    )),
    instanceName: 'soap',
  );
}
