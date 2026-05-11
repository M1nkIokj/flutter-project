import '../repositories/pokemon_repository.dart';
import '../entities/pokemon_game.dart';

class SaveGameScore {
  final PokemonRepository repository;

  SaveGameScore(this.repository);

  Future<PokemonGame> call(PokemonGame game) async {
    return await repository.saveGameResult(game);
  }
}
