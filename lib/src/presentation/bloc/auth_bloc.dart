import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_up.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignIn signIn;
  final SignUp signUp;
  final SignOut signOut;
  final AuthRepository authRepository;

  AuthBloc({
    required this.signIn,
    required this.signUp,
    required this.signOut,
    required this.authRepository,
  }) : super(AuthInitial()) {
    on<SignInRequested>(_onSignInRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<GetCurrentUser>(_onGetCurrentUser);
  }

  Future<void> _onSignInRequested(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await signIn.call(
        SignInParams(email: event.email, password: event.password),
      );
      emit(Authenticated(user));
    } catch (e) {
      // Handle specific error cases for better user experience
      String errorMessage = e.toString().toLowerCase();

      if (errorMessage.contains('invalid_credentials') ||
          errorMessage.contains('invalid_login') ||
          errorMessage.contains('wrong_password') ||
          errorMessage.contains('user_not_found') ||
          errorMessage.contains('invalid email or password') ||
          errorMessage.contains('invalid login credentials')) {
        emit(AuthError('Login failed. Invalid email or password.'));
      } else if (errorMessage.contains('email_not_confirmed') ||
          errorMessage.contains('email_not_verified')) {
        emit(AuthError(
            'Please confirm your email address before logging in. Check your inbox for confirmation email.'));
      } else if (errorMessage.contains('too_many_requests') ||
          errorMessage.contains('rate_limit')) {
        emit(AuthError(
            'Too many login attempts. Please wait a few minutes before trying again.'));
      } else if (errorMessage.contains('network') ||
          errorMessage.contains('connection')) {
        emit(AuthError(
            'Network error. Please check your internet connection and try again.'));
      } else {
        emit(AuthError('Login failed. Please try again later.'));
      }
    }
  }

  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await signUp.call(
        SignUpParams(
          email: event.email,
          password: event.password,
          name: event.name,
        ),
      );
      emit(Authenticated(user));
    } catch (e) {
      // Handle specific error cases for better user experience
      String errorMessage = e.toString().toLowerCase();

      if (errorMessage.contains('user_already_exists') ||
          errorMessage.contains('duplicate') ||
          errorMessage.contains('already registered') ||
          errorMessage.contains('already taken')) {
        emit(AuthError(
            'An account with this email already exists. Please use a different email or try logging in.'));
      } else if (errorMessage.contains('weak_password') ||
          errorMessage.contains('password_too_weak')) {
        emit(AuthError(
            'Password is too weak. Please choose a stronger password with at least 6 characters.'));
      } else if (errorMessage.contains('invalid_email') ||
          errorMessage.contains('email_invalid')) {
        emit(AuthError(
            'Invalid email address. Please enter a valid email address.'));
      } else {
        emit(AuthError('Failed to create account. Please try again later.'));
      }
    }
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await signOut.call();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onGetCurrentUser(
    GetCurrentUser event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.getCurrentUser();
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
