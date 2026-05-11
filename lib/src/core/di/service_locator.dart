import 'package:get_it/get_it.dart';
import 'package:login_app/src/data/datasources/auth_remote_datasource.dart';
import 'package:login_app/src/data/repositories/auth_repository_impl.dart';
import 'package:login_app/src/domain/repositories/auth_repository.dart';
import 'package:login_app/src/domain/usecases/sign_in.dart';
import 'package:login_app/src/domain/usecases/sign_out.dart';
import 'package:login_app/src/domain/usecases/sign_up.dart';
import 'package:login_app/src/presentation/bloc/auth_bloc.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(
    () => SignIn(sl()),
  );
  sl.registerLazySingleton(
    () => SignUp(sl()),
  );
  sl.registerLazySingleton(
    () => SignOut(sl()),
  );

  // BLoC
  sl.registerFactory(
    () => AuthBloc(
      signIn: sl(),
      signUp: sl(),
      signOut: sl(),
      authRepository: sl(),
    ),
  );
}
