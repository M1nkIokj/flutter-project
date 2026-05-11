import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/pokemon_remote_datasource.dart';
import '../../data/models/pokemon_model.dart';
import '../../domain/entities/pokemon_game.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/save_game_score.dart';
import '../../domain/repositories/pokemon_repository.dart';
import 'pokemon_game_event.dart';
import 'pokemon_game_state.dart';

class PokemonGameBloc extends Bloc<PokemonGameEvent, PokemonGameState> {
  final PokemonRemoteDataSource remoteDataSource;
  final SaveGameScore saveGameScore;
  final PokemonRepository pokemonRepository;
  final User currentUser;

  List<PokemonModel> _allPokemons = [];
  List<PokemonQuestion> _gameQuestions = [];
  int _currentScore = 0;
  int _totalQuestions = 10; // Default to 10 questions

  PokemonGameBloc({
    required this.remoteDataSource,
    required this.saveGameScore,
    required this.pokemonRepository,
    required this.currentUser,
  }) : super(PokemonGameInitial()) {
    on<LoadPokemons>(_onLoadPokemons);
    on<LoadHighScores>(_onLoadHighScores);
    on<StartGame>(_onStartGame);
    on<SubmitAnswer>(_onSubmitAnswer);
    on<NextQuestion>(_onNextQuestion);
    on<LoadNextQuestion>(_onLoadNextQuestion);
    on<SaveGameResult>(_onSaveGameResult);
    on<ResetGame>(_onResetGame);
  }

  Future<void> _onLoadPokemons(
    LoadPokemons event,
    Emitter<PokemonGameState> emit,
  ) async {
    emit(PokemonGameLoading());
    try {
      _allPokemons = await remoteDataSource.getRandomPokemons(50);
      final highScores =
          await pokemonRepository.getUserGameHistory(currentUser);
      emit(PokemonsLoaded(_allPokemons, highScores));
    } catch (e) {
      emit(PokemonGameError('Failed to load pokemons: $e'));
    }
  }

  Future<void> _onLoadHighScores(
    LoadHighScores event,
    Emitter<PokemonGameState> emit,
  ) async {
    try {
      final highScores =
          await pokemonRepository.getUserGameHistory(currentUser);
      // Keep current state but add high scores
      final currentState = state;
      if (currentState is PokemonsLoaded) {
        emit(PokemonsLoaded(currentState.pokemons, highScores));
      }
    } catch (e) {
      emit(PokemonGameError('Failed to load high scores: $e'));
    }
  }

  Future<void> _onStartGame(
    StartGame event,
    Emitter<PokemonGameState> emit,
  ) async {
    if (_allPokemons.isEmpty) {
      emit(PokemonGameError('Please load pokemons first'));
      return;
    }

    emit(PokemonGameLoading());
    try {
      // Set total questions from the event
      _totalQuestions = event.questionCount;

      // Load only the first question to start
      final firstPokemons = await remoteDataSource.getRandomPokemons(1);
      if (firstPokemons.isEmpty) {
        emit(PokemonGameError('Failed to load first Pokemon'));
        return;
      }

      final firstPokemon = firstPokemons.first;
      final firstQuestion = PokemonQuestion(
        pokemonName: firstPokemon.name,
        imageUrl: firstPokemon.imageUrl,
        options: await _generateOptions(firstPokemon),
        correctAnswer: firstPokemon.formattedName,
        isCorrect: false,
      );

      _currentScore = 0;
      _gameQuestions = [firstQuestion];

      emit(GameStarted(
        questions: _gameQuestions,
        currentQuestionIndex: 0,
        score: 0,
        totalQuestions: _totalQuestions,
      ));
    } catch (e) {
      emit(PokemonGameError('Failed to start game: $e'));
    }
  }

  Future<List<PokemonQuestion>> _generateQuestions(int count) async {
    final questions = <PokemonQuestion>[];
    final selectedPokemons = <PokemonModel>[];

    // Select random pokemons for questions
    final availablePokemons = List<PokemonModel>.from(_allPokemons);
    availablePokemons.shuffle();

    for (int i = 0; i < count && i < availablePokemons.length; i++) {
      selectedPokemons.add(availablePokemons[i]);
    }

    // Generate questions with multiple choice options
    for (final pokemon in selectedPokemons) {
      final options = await _generateOptions(pokemon);
      questions.add(PokemonQuestion(
        pokemonName: pokemon.name,
        imageUrl: pokemon.imageUrl,
        options: options,
        correctAnswer: pokemon.formattedName,
        isCorrect: false,
      ));
    }

    return questions;
  }

  Future<List<String>> _generateOptions(PokemonModel correctPokemon) async {
    final Set<String> uniqueOptions = <String>{correctPokemon.formattedName};

    try {
      // Keep fetching random Pokemon until we have 3 unique wrong options
      while (uniqueOptions.length < 4) {
        final randomPokemons = await remoteDataSource
            .getRandomPokemons(6); // Fetch more to increase chances

        // Add unique wrong options
        for (final pokemon in randomPokemons) {
          if (pokemon.id != correctPokemon.id &&
              pokemon.formattedName != correctPokemon.formattedName &&
              !uniqueOptions.contains(pokemon.formattedName)) {
            uniqueOptions.add(pokemon.formattedName);
          }

          if (uniqueOptions.length >= 4) break;
        }
      }
    } catch (e) {
      // If API call fails, add some hardcoded Pokemon names as fallback
      final fallbackOptions = [
        'Pikachu',
        'Charmander',
        'Bulbasaur',
        'Squirtle',
        'Eevee',
        'Jigglypuff',
        'Meowth',
        'Snorlax'
      ];

      for (final name in fallbackOptions) {
        if (name != correctPokemon.formattedName &&
            !uniqueOptions.contains(name)) {
          uniqueOptions.add(name);
        }

        if (uniqueOptions.length >= 4) break;
      }
    }

    // Ensure we have exactly 4 unique options
    while (uniqueOptions.length < 4) {
      uniqueOptions.add('Unknown Pokemon ${uniqueOptions.length}');
    }

    // Convert to list and shuffle
    final options = uniqueOptions.toList();
    options.shuffle();
    return options;
  }

  Future<void> _onSubmitAnswer(
    SubmitAnswer event,
    Emitter<PokemonGameState> emit,
  ) async {
    final currentState = state;
    if (currentState is! GameStarted) return;

    final currentQuestion = currentState.currentQuestion;
    final isCorrect = event.answer == currentQuestion.correctAnswer;

    if (isCorrect) {
      _currentScore++;
    }

    // Update the question with user's answer
    final updatedQuestions = List<PokemonQuestion>.from(currentState.questions);
    updatedQuestions[currentState.currentQuestionIndex] = PokemonQuestion(
      pokemonName: currentQuestion.pokemonName,
      imageUrl: currentQuestion.imageUrl,
      options: currentQuestion.options,
      correctAnswer: currentQuestion.correctAnswer,
      userAnswer: event.answer,
      isCorrect: isCorrect,
    );

    emit(AnswerSubmitted(
      questions: updatedQuestions,
      currentQuestionIndex: currentState.currentQuestionIndex,
      score: _currentScore,
      selectedAnswer: event.answer,
      isCorrect: isCorrect,
      totalQuestions: _totalQuestions,
    ));
  }

  Future<void> _onNextQuestion(
    NextQuestion event,
    Emitter<PokemonGameState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AnswerSubmitted && currentState is! GameStarted)
      return;

    int currentQuestionIndex;
    List<PokemonQuestion> questions;

    if (currentState is AnswerSubmitted) {
      currentQuestionIndex = currentState.currentQuestionIndex;
      questions = currentState.questions;
    } else if (currentState is GameStarted) {
      currentQuestionIndex = currentState.currentQuestionIndex;
      questions = currentState.questions;
    } else {
      return;
    }

    if (currentQuestionIndex >= questions.length - 1) {
      // Game completed
      final gameResult = PokemonGame(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        user: currentUser,
        score: _currentScore,
        totalQuestions: questions.length,
        createdAt: DateTime.now(),
        questions: questions,
      );
      emit(GameCompleted(gameResult));
    } else {
      // Move to next question
      emit(GameStarted(
        questions: questions,
        currentQuestionIndex: currentQuestionIndex + 1,
        score: _currentScore,
        totalQuestions: _totalQuestions,
      ));
    }
  }

  Future<void> _onSaveGameResult(
    SaveGameResult event,
    Emitter<PokemonGameState> emit,
  ) async {
    final currentState = state;
    if (currentState is! GameCompleted) return;

    try {
      await saveGameScore(currentState.gameResult);
      // Keep the same state, just save the result
      emit(currentState);
    } catch (e) {
      emit(PokemonGameError('Failed to save game result: $e'));
    }
  }

  Future<void> _onLoadNextQuestion(
    LoadNextQuestion event,
    Emitter<PokemonGameState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AnswerSubmitted && currentState is! GameStarted)
      return;

    emit(PokemonGameLoading());
    try {
      // Get a new random Pokemon for the next question
      final newPokemons = await remoteDataSource.getRandomPokemons(1);
      if (newPokemons.isEmpty) {
        emit(PokemonGameError('No more Pokemon available'));
        return;
      }

      final newPokemon = newPokemons.first;
      final newQuestion = PokemonQuestion(
        pokemonName: newPokemon.name,
        imageUrl: newPokemon.imageUrl,
        options: await _generateOptions(newPokemon),
        correctAnswer: newPokemon.formattedName,
        isCorrect: false,
      );

      // Update the current question with the answer and add the new question
      List<PokemonQuestion> updatedQuestions;
      int currentQuestionIndex;

      if (currentState is AnswerSubmitted) {
        // Update the answered question
        updatedQuestions = List<PokemonQuestion>.from(currentState.questions);
        updatedQuestions[currentState.currentQuestionIndex] = PokemonQuestion(
          pokemonName: currentState
              .questions[currentState.currentQuestionIndex].pokemonName,
          imageUrl: currentState
              .questions[currentState.currentQuestionIndex].imageUrl,
          options:
              currentState.questions[currentState.currentQuestionIndex].options,
          correctAnswer: currentState
              .questions[currentState.currentQuestionIndex].correctAnswer,
          userAnswer: currentState.selectedAnswer,
          isCorrect: currentState.isCorrect,
        );
        // Add the new question
        updatedQuestions.add(newQuestion);
        currentQuestionIndex = currentState.currentQuestionIndex + 1;
      } else if (currentState is GameStarted) {
        // Directly add new question to existing list
        updatedQuestions = List<PokemonQuestion>.from(currentState.questions);
        updatedQuestions.add(newQuestion);
        currentQuestionIndex = currentState.currentQuestionIndex + 1;
      } else {
        return;
      }

      // Check if we've reached the question limit
      if (currentQuestionIndex >= 10) {
        // Assuming 10 questions per game
        // Game completed
        final gameResult = PokemonGame(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          user: currentUser,
          score: _currentScore,
          totalQuestions: updatedQuestions.length,
          createdAt: DateTime.now(),
          questions: updatedQuestions,
        );
        emit(GameCompleted(gameResult));
      } else {
        // Continue with next question
        emit(GameStarted(
          questions: updatedQuestions,
          currentQuestionIndex: currentQuestionIndex,
          score: _currentScore,
          totalQuestions: _totalQuestions,
        ));
      }
    } catch (e) {
      emit(PokemonGameError('Failed to load next question: $e'));
    }
  }

  Future<void> _onResetGame(
    ResetGame event,
    Emitter<PokemonGameState> emit,
  ) async {
    _gameQuestions = [];
    _currentScore = 0;
    emit(PokemonGameInitial());
  }
}
