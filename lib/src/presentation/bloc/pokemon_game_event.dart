import 'package:equatable/equatable.dart';

abstract class PokemonGameEvent extends Equatable {
  const PokemonGameEvent();

  @override
  List<Object?> get props => [];
}

class LoadPokemons extends PokemonGameEvent {}

class LoadHighScores extends PokemonGameEvent {}

class StartGame extends PokemonGameEvent {
  final int questionCount;

  const StartGame(this.questionCount);

  @override
  List<Object?> get props => [questionCount];
}

class SubmitAnswer extends PokemonGameEvent {
  final String answer;

  const SubmitAnswer(this.answer);

  @override
  List<Object?> get props => [answer];
}

class NextQuestion extends PokemonGameEvent {}

class LoadNextQuestion extends PokemonGameEvent {}

class SaveGameResult extends PokemonGameEvent {}

class ResetGame extends PokemonGameEvent {}
