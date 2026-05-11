import '../services/supabase_service.dart';
import '../constants/supabase_constants.dart';

class DebugHelper {
  static void logSupabaseConfig() {
    print('=== Supabase Configuration ===');
    print('URL: ${SupabaseConstants.supabaseUrl}');
    print('Anon Key: ${SupabaseConstants.supabaseAnonKey.substring(0, 10)}...');
    print('Client initialized: ${SupabaseService.client != null}');
    print('Auth client: ${SupabaseService.auth != null}');
    print('===============================');
  }

  static void testConnection() async {
    try {
      print('Testing Supabase connection...');
      final currentUser = SupabaseService.auth.currentUser;
      print('Current user: ${currentUser?.email ?? 'None'}');
      final currentSession = SupabaseService.auth.currentSession;
      print('Current session: ${currentSession != null ? 'Active' : 'None'}');
    } catch (e) {
      print('Connection test failed: $e');
    }
  }
}
