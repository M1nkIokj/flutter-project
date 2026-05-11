import '../entities/user.dart';

class PokemonGame {
  final String id;
  final User user;
  final int score;
  final int totalQuestions;
  final DateTime createdAt;
  final List<PokemonQuestion> questions;

  PokemonGame({
    required this.id,
    required this.user,
    required this.score,
    required this.totalQuestions,
    required this.createdAt,
    required this.questions,
  });

  double get percentage => totalQuestions > 0 ? (score / totalQuestions) * 100 : 0;
}

class PokemonQuestion {
  final String pokemonName;
  final String imageUrl;
  final List<String> options;
  final String correctAnswer;
  final String? userAnswer;
  final bool isCorrect;

  PokemonQuestion({
    required this.pokemonName,
    required this.imageUrl,
    required this.options,
    required this.correctAnswer,
    this.userAnswer,
    required this.isCorrect,
  });
}
