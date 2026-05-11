import '../entities/pokemon_game.dart';
import '../entities/user.dart';

abstract class PokemonRepository {
  Future<List<PokemonGame>> getUserGameHistory(User user);
  Future<PokemonGame> saveGameResult(PokemonGame game);
  Future<List<String>> getLeaderboard();
}
