import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignInParams {
  final String email;
  final String password;

  SignInParams({required this.email, required this.password});
}

class SignIn {
  final AuthRepository repository;

  SignIn(this.repository);

  Future<User> call(SignInParams params) async {
    return await repository.signIn(params.email, params.password);
  }
}
