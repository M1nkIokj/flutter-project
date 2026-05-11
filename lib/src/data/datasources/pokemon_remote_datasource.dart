import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/pokemon_model.dart';

class PokemonRemoteDataSource {
  static const String baseUrl = 'https://pokeapi.co/api/v2';

  Future<List<PokemonModel>> getRandomPokemons(int count) async {
    try {
      // Get random pokemon IDs
      final randomIds = List.generate(count, (index) => _getRandomPokemonId());
      
      final List<PokemonModel> pokemons = [];
      
      for (final id in randomIds) {
        final response = await http.get(Uri.parse('$baseUrl/pokemon/$id'));
        
        if (response.statusCode == 200) {
          final pokemonData = json.decode(response.body);
          pokemons.add(PokemonModel.fromJson(pokemonData));
        } else {
          throw Exception('Failed to load pokemon with ID: $id');
        }
      }
      
      return pokemons;
    } catch (e) {
      throw Exception('Failed to load pokemons: $e');
    }
  }

  Future<PokemonModel> getPokemonById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/pokemon/$id'));
      
      if (response.statusCode == 200) {
        final pokemonData = json.decode(response.body);
        return PokemonModel.fromJson(pokemonData);
      } else {
        throw Exception('Failed to load pokemon with ID: $id');
      }
    } catch (e) {
      throw Exception('Failed to load pokemon: $e');
    }
  }

  Future<List<PokemonModel>> getPokemonList(int offset, int limit) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/pokemon?offset=$offset&limit=$limit'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        
        final List<PokemonModel> pokemons = [];
        for (final result in results) {
          final url = result['url'];
          final pokemonId = int.parse(url.split('/')[6]);
          final pokemon = await getPokemonById(pokemonId);
          pokemons.add(pokemon);
        }
        
        return pokemons;
      } else {
        throw Exception('Failed to load pokemon list');
      }
    } catch (e) {
      throw Exception('Failed to load pokemon list: $e');
    }
  }

  int _getRandomPokemonId() {
    // There are currently 1010+ Pokemon, let's use the first 898 for now
    // (the original National Pokedex)
    const int maxPokemonId = 898;
    return (DateTime.now().millisecondsSinceEpoch % maxPokemonId) + 1;
  }
}
