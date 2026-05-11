import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignUpParams {
  final String email;
  final String password;
  final String name;

  SignUpParams({
    required this.email,
    required this.password,
    required this.name,
  });
}

class SignUp {
  final AuthRepository repository;

  SignUp(this.repository);

  Future<User> call(SignUpParams params) async {
    return await repository.signUp(params.email, params.password, params.name);
  }
}
