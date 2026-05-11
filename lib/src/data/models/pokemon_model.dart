class PokemonModel {
  final int id;
  final String name;
  final List<String> types;
  final String imageUrl;
  final int height;
  final int weight;

  PokemonModel({
    required this.id,
    required this.name,
    required this.types,
    required this.imageUrl,
    required this.height,
    required this.weight,
  });

  factory PokemonModel.fromJson(Map<String, dynamic> json) {
    final types = (json['types'] as List)
        .map((type) => type['type']['name'] as String)
        .toList();

    return PokemonModel(
      id: json['id'],
      name: json['name'],
      types: types,
      imageUrl: json['sprites']['front_default'] ?? '',
      height: json['height'],
      weight: json['weight'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'types': types,
      'image_url': imageUrl,
      'height': height,
      'weight': weight,
    };
  }

  String get formattedName => name[0].toUpperCase() + name.substring(1);
}
