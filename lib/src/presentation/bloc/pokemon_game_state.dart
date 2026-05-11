import 'package:equatable/equatable.dart';
import '../../data/models/pokemon_model.dart';
import '../../domain/entities/pokemon_game.dart';

abstract class PokemonGameState extends Equatable {
  const PokemonGameState();

  @override
  List<Object?> get props => [];
}

class PokemonGameInitial extends PokemonGameState {}

class PokemonGameLoading extends PokemonGameState {}

class PokemonsLoaded extends PokemonGameState {
  final List<PokemonModel> pokemons;
  final List<PokemonGame> highScores;

  const PokemonsLoaded(this.pokemons, [this.highScores = const []]);

  @override
  List<Object?> get props => [pokemons, highScores];
}

class GameStarted extends PokemonGameState {
  final List<PokemonQuestion> questions;
  final int currentQuestionIndex;
  final int score;
  final int totalQuestions;

  const GameStarted({
    required this.questions,
    required this.currentQuestionIndex,
    required this.score,
    required this.totalQuestions,
  });

  PokemonQuestion get currentQuestion => questions[currentQuestionIndex];

  bool get isLastQuestion => currentQuestionIndex >= totalQuestions - 1;

  @override
  List<Object?> get props =>
      [questions, currentQuestionIndex, score, totalQuestions];
}

class AnswerSubmitted extends PokemonGameState {
  final List<PokemonQuestion> questions;
  final int currentQuestionIndex;
  final int score;
  final String selectedAnswer;
  final bool isCorrect;
  final int totalQuestions;

  const AnswerSubmitted({
    required this.questions,
    required this.currentQuestionIndex,
    required this.score,
    required this.selectedAnswer,
    required this.isCorrect,
    required this.totalQuestions,
  });

  @override
  List<Object?> get props => [
        questions,
        currentQuestionIndex,
        score,
        selectedAnswer,
        isCorrect,
        totalQuestions
      ];
}

class GameCompleted extends PokemonGameState {
  final PokemonGame gameResult;

  const GameCompleted(this.gameResult);

  @override
  List<Object?> get props => [gameResult];
}

class PokemonGameError extends PokemonGameState {
  final String message;

  const PokemonGameError(this.message);

  @override
  List<Object?> get props => [message];
}
