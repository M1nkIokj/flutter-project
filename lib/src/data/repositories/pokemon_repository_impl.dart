import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/pokemon_game.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/pokemon_repository.dart';
import '../datasources/pokemon_remote_datasource.dart';

class PokemonRepositoryImpl implements PokemonRepository {
  final PokemonRemoteDataSource remoteDataSource;
  static const String _highScoresKey = 'pokemon_high_scores';

  PokemonRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<PokemonGame>> getUserGameHistory(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final highScoresJson = prefs.getStringList(_highScoresKey) ?? [];

      final games = highScoresJson.map((jsonString) {
        final Map<String, dynamic> data = json.decode(jsonString);
        return PokemonGame(
          id: data['id'],
          user: User(
              id: data['userId'],
              name: data['userEmail'],
              email: data['userEmail']),
          score: data['score'],
          totalQuestions: data['totalQuestions'],
          createdAt: DateTime.parse(data['createdAt']),
          questions: [], // We don't need to store questions for high scores
        );
      }).toList();

      // Sort by score (highest first) and take top 10
      games.sort((a, b) => b.score.compareTo(a.score));
      return games.take(10).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<PokemonGame> saveGameResult(PokemonGame game) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final highScoresJson = prefs.getStringList(_highScoresKey) ?? [];

      // Add new game result
      final gameJson = json.encode({
        'id': game.id,
        'userId': game.user.id,
        'userEmail': game.user.email,
        'score': game.score,
        'totalQuestions': game.totalQuestions,
        'createdAt': game.createdAt.toIso8601String(),
      });

      highScoresJson.add(gameJson);

      // Keep only top 50 scores to prevent storage bloat
      if (highScoresJson.length > 50) {
        final games = highScoresJson.map((jsonString) {
          final Map<String, dynamic> data = json.decode(jsonString);
          return {
            'json': jsonString,
            'score': data['score'] as int,
          };
        }).toList();

        games.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));
        highScoresJson.clear();
        highScoresJson
            .addAll(games.take(50).map((game) => game['json'] as String));
      }

      await prefs.setStringList(_highScoresKey, highScoresJson);
      return game;
    } catch (e) {
      return game; // Return game even if save fails
    }
  }

  @override
  Future<List<String>> getLeaderboard() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final highScoresJson = prefs.getStringList(_highScoresKey) ?? [];

      final games = highScoresJson.map((jsonString) {
        final Map<String, dynamic> data = json.decode(jsonString);
        return {
          'score': data['score'] as int,
          'userEmail': data['userEmail'] as String,
          'percentage':
              (data['score'] / data['totalQuestions'] * 100).toStringAsFixed(1),
        };
      }).toList();

      // Sort by score (highest first) and take top 10
      games.sort((a, b) => b['score'].compareTo(a['score']));

      return games.take(10).map((game) {
        return '${game['userEmail']}: ${game['score']} (${game['percentage']}%)';
      }).toList();
    } catch (e) {
      return [];
    }
  }
}
