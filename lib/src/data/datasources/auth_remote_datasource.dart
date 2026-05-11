import '../models/user_model.dart';
import '../../core/services/supabase_service.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signIn(String email, String password);
  Future<UserModel> signUp(String email, String password, String name);
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<UserModel> signIn(String email, String password) async {
    try {
      final response = await SupabaseService.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user != null) {
        print('Login successful: User ID: ${user.id}, Email: ${user.email}');
        return UserModel(
          id: user.id,
          email: user.email ?? '',
          name:
              user.userMetadata?['name'] ?? user.email?.split('@')[0] ?? 'User',
          token: response.session?.accessToken,
        );
      } else {
        throw Exception('Login failed: Invalid credentials');
      }
    } catch (e) {
      print('Login error: $e');
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signUp(String email, String password, String name) async {
    try {
      print('Starting signup for: $email');

      final response = await SupabaseService.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );

      print('Signup response received');
      print('User: ${response.user?.id}');
      print(
          'Session: ${response.session?.accessToken != null ? 'Active' : 'None'}');

      // Supabase returns user but no session when email confirmation is required
      if (response.user != null) {
        if (response.session != null) {
          // User is signed up and logged in (no email confirmation required)
          print('Signup successful with immediate login');
          return UserModel(
            id: response.user!.id,
            email: response.user!.email ?? '',
            name: name,
            token: response.session!.accessToken,
          );
        } else {
          // User is signed up but needs email confirmation
          print('Signup successful, email confirmation required');
          // Return user without session token, but let the app handle navigation
          return UserModel(
            id: response.user!.id,
            email: response.user!.email ?? '',
            name: name,
            token: null, // No session token until email is confirmed
          );
        }
      } else {
        throw Exception('Signup failed: No user data returned from Supabase');
      }
    } catch (e) {
      print('Signup error: $e');
      throw Exception('Signup failed: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await SupabaseService.auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = SupabaseService.auth.currentUser;
      if (user != null) {
        return UserModel(
          id: user.id,
          email: user.email ?? '',
          name:
              user.userMetadata?['name'] ?? user.email?.split('@')[0] ?? 'User',
          token: SupabaseService.auth.currentSession?.accessToken,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get current user: ${e.toString()}');
    }
  }
}
