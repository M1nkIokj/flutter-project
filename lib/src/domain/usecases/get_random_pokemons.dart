import '../repositories/pokemon_repository.dart';
import '../entities/pokemon_game.dart';
import '../entities/user.dart';

class GetRandomPokemons {
  final PokemonRepository repository;

  GetRandomPokemons(this.repository);

  Future<List<PokemonGame>> call(User user) async {
    return await repository.getUserGameHistory(user);
  }
}
