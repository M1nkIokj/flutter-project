import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/pokemon_game_bloc.dart';
import '../../bloc/pokemon_game_event.dart';
import '../../bloc/pokemon_game_state.dart';
import '../../bloc/auth_bloc.dart';
import '../../bloc/auth_state.dart';
import '../../../data/datasources/pokemon_remote_datasource.dart';
import '../../../data/repositories/pokemon_repository_impl.dart';
import '../../../domain/usecases/save_game_score.dart';
import '../../../domain/entities/pokemon_game.dart';

class PokemonGamePage extends StatelessWidget {
  const PokemonGamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PokemonGameBloc(
        remoteDataSource: PokemonRemoteDataSource(),
        saveGameScore: SaveGameScore(PokemonRepositoryImpl(
          remoteDataSource: PokemonRemoteDataSource(),
        )),
        pokemonRepository: PokemonRepositoryImpl(
          remoteDataSource: PokemonRemoteDataSource(),
        ),
        currentUser: (context.read<AuthBloc>().state as Authenticated).user,
      )..add(LoadPokemons()),
      child: const PokemonGameView(),
    );
  }
}

class PokemonGameView extends StatefulWidget {
  const PokemonGameView({super.key});

  @override
  State<PokemonGameView> createState() => _PokemonGameViewState();
}

class _PokemonGameViewState extends State<PokemonGameView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokemon Guess Game'),
        key: const Key('pokemon_game_appbar'),
        leading: IconButton(
          key: const Key('pokemon_game_back_button'),
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<PokemonGameBloc, PokemonGameState>(
        listener: (context, state) {
          if (state is PokemonGameError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is PokemonGameLoading) {
            return const Center(
                key: Key('pokemon_game_loading'),
                child: CircularProgressIndicator());
          } else if (state is PokemonsLoaded) {
            return _GameSetupView(
                pokemons: state.pokemons, highScores: state.highScores);
          } else if (state is GameStarted) {
            return _GamePlayView(
              question: state.currentQuestion,
              questionNumber: state.currentQuestionIndex + 1,
              totalQuestions: state.totalQuestions,
              score: state.score,
            );
          } else if (state is AnswerSubmitted) {
            return _AnswerResultView(
              question: state.questions[state.currentQuestionIndex],
              questionNumber: state.currentQuestionIndex + 1,
              totalQuestions: state.totalQuestions,
              score: state.score,
              isCorrect: state.isCorrect,
              selectedAnswer: state.selectedAnswer,
            );
          } else if (state is GameCompleted) {
            return _GameCompletedView(gameResult: state.gameResult);
          } else if (state is PokemonGameError) {
            return _ErrorView(message: state.message);
          } else {
            return _InitialView();
          }
        },
      ),
    );
  }
}

class _InitialView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.catching_pokemon, size: 100, color: Colors.blue),
          SizedBox(height: 20),
          Text('Loading Pokemon...', style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}

class _GameSetupView extends StatelessWidget {
  final List pokemons;
  final List<PokemonGame> highScores;

  const _GameSetupView({required this.pokemons, this.highScores = const []});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.red[400]!, Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(Icons.catching_pokemon,
                  size: 100, color: Colors.white),
            ),
            const SizedBox(height: 20),
            const Text(
              'Pokemon Guess Game',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Guess the name of ${pokemons.length} Pokemon!',
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF7F8C8D),
              ),
            ),
            const SizedBox(height: 20),
            if (highScores.isNotEmpty) ...[
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFF59D), Color(0xFFFFF176)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFFFD54F).withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFFFD54F),
                            ),
                            child: const Icon(Icons.emoji_events,
                                color: Color(0xFFFF6F00), size: 24),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'High Scores',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF6F00),
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...highScores
                          .take(3)
                          .toList()
                          .asMap()
                          .entries
                          .map((entry) {
                        final index = entry.key;
                        final game = entry.value;
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 2),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${index + 1}. ${game.user.name}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2C3E50),
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '${game.score}/${game.totalQuestions}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF7F8C8D),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Color(0xFF4CAF50),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${game.percentage.toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFEF5350), Color(0xFFE53935)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFEF5350).withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: ElevatedButton(
                key: const Key('pokemon_game_start_10'),
                onPressed: () =>
                    context.read<PokemonGameBloc>().add(StartGame(10)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Start Game (10 questions)',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF42A5F5), Color(0xFF1E88E5)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF42A5F5).withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: ElevatedButton(
                key: const Key('pokemon_game_start_20'),
                onPressed: () =>
                    context.read<PokemonGameBloc>().add(StartGame(20)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Start Game (20 questions)',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF66BB6A).withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: ElevatedButton(
                key: const Key('pokemon_game_start_30'),
                onPressed: () =>
                    context.read<PokemonGameBloc>().add(StartGame(30)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Start Game (30 questions)',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GamePlayView extends StatelessWidget {
  final PokemonQuestion question;
  final int questionNumber;
  final int totalQuestions;
  final int score;

  const _GamePlayView({
    required this.question,
    required this.questionNumber,
    required this.totalQuestions,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE3F2FD), Color(0xFFFFFFFF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF42A5F5), Color(0xFF1E88E5)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF42A5F5).withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Question $questionNumber/$totalQuestions',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Score: $score',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [Colors.white, Color(0xFFF5F5F5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 3,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        question.imageUrl,
                        height: 200,
                        width: 200,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            width: 200,
                            decoration: BoxDecoration(
                              color: Color(0xFFFFF3E0),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 100,
                              color: Color(0xFFFF9800),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF66BB6A).withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Text(
                      'What is this Pokemon?',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  ...question.options.asMap().entries.map((entry) {
                    final index = entry.key;
                    final option = entry.value;
                    final colors = [
                      [Color(0xFFEF5350), Color(0xFFE53935)],
                      [Color(0xFF42A5F5), Color(0xFF1E88E5)],
                      [Color(0xFF66BB6A), Color(0xFF43A047)],
                      [Color(0xFFFF9800), Color(0xFFF57C00)],
                    ];
                    final buttonColors = colors[index % colors.length];

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: buttonColors,
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: buttonColors[0].withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          key: Key('pokemon_game_answer_${index}'),
                          onPressed: () => context
                              .read<PokemonGameBloc>()
                              .add(SubmitAnswer(option)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            minimumSize: const Size(double.infinity, 55),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Text(
                            option,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnswerResultView extends StatelessWidget {
  final PokemonQuestion question;
  final int questionNumber;
  final int totalQuestions;
  final int score;
  final bool isCorrect;
  final String selectedAnswer;

  const _AnswerResultView({
    required this.question,
    required this.questionNumber,
    required this.totalQuestions,
    required this.score,
    required this.isCorrect,
    required this.selectedAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE3F2FD), Color(0xFFFFFFFF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF42A5F5), Color(0xFF1E88E5)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF42A5F5).withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Question $questionNumber/$totalQuestions',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Score: $score',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [Colors.white, Color(0xFFF5F5F5)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 3,
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            question.imageUrl,
                            height: 180,
                            width: 180,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 180,
                                width: 180,
                                decoration: BoxDecoration(
                                  color: Color(0xFFFFF3E0),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(
                                  Icons.image_not_supported,
                                  size: 80,
                                  color: Color(0xFFFF9800),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isCorrect
                                ? [Color(0xFF66BB6A), Color(0xFF43A047)]
                                : [Color(0xFFEF5350), Color(0xFFE53935)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(
                              color: (isCorrect
                                      ? Color(0xFF66BB6A)
                                      : Color(0xFFEF5350))
                                  .withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(
                          isCorrect ? Icons.check_circle : Icons.cancel,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isCorrect
                                ? [Color(0xFF66BB6A), Color(0xFF43A047)]
                                : [Color(0xFFEF5350), Color(0xFFE53935)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: (isCorrect
                                      ? Color(0xFF66BB6A)
                                      : Color(0xFFEF5350))
                                  .withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          isCorrect ? 'Correct!' : 'Wrong!',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              'The correct answer is:',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF7F8C8D),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              question.correctAnswer,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                            if (!isCorrect) ...[
                              const SizedBox(height: 8),
                              const Divider(color: Color(0xFFE0E0E0)),
                              const SizedBox(height: 8),
                              Text(
                                'Your answer:',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF95A5A6),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                selectedAnswer,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFFE74C3C),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: questionNumber >= totalQuestions
                                ? [Color(0xFFFF9800), Color(0xFFF57C00)]
                                : [Color(0xFF42A5F5), Color(0xFF1E88E5)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: (questionNumber >= totalQuestions
                                      ? Color(0xFFFF9800)
                                      : Color(0xFF42A5F5))
                                  .withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () => context
                              .read<PokemonGameBloc>()
                              .add(LoadNextQuestion()),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Text(
                            questionNumber >= totalQuestions
                                ? 'See Results'
                                : 'Next Question',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20), // Extra padding at bottom
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GameCompletedView extends StatelessWidget {
  final PokemonGame gameResult;

  const _GameCompletedView({required this.gameResult});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events, size: 100, color: Colors.amber),
            const SizedBox(height: 20),
            const Text(
              'Game Completed!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              'Your Score: ${gameResult.score}/${gameResult.totalQuestions}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Accuracy: ${gameResult.percentage.toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                context.read<PokemonGameBloc>().add(SaveGameResult());
                Navigator.pop(context);
              },
              child: const Text('Save and Exit'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => context.read<PokemonGameBloc>().add(ResetGame()),
              child: const Text('Play Again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;

  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 100, color: Colors.red),
          const SizedBox(height: 20),
          Text('Error: $message', style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () =>
                context.read<PokemonGameBloc>().add(LoadPokemons()),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
