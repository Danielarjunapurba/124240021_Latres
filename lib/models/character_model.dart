class CharacterLocation {
  final String name;
  final String url;

  const CharacterLocation({
    required this.name,
    required this.url,
  });

  factory CharacterLocation.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const CharacterLocation(name: 'Unknown', url: '');
    }
    final rawName = (json['name'] ?? '').toString().trim();
    return CharacterLocation(
      name: rawName.isEmpty ? 'Unknown' : rawName,
      url: (json['url'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'url': url,
    };
  }
}

class CharacterModel {
  final int id;
  final String name;
  final String status;
  final String species;
  final String type;
  final String gender;
  final CharacterLocation origin;
  final CharacterLocation location;
  final String image;
  final List<String> episode;
  final String url;

  const CharacterModel({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.type,
    required this.gender,
    required this.origin,
    required this.location,
    required this.image,
    required this.episode,
    required this.url,
  });

  factory CharacterModel.fromJson(Map<String, dynamic> json) {
    final episodeList = (json['episode'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        <String>[];

    return CharacterModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? 'Unknown').toString(),
      status: (json['status'] ?? 'unknown').toString(),
      species: (json['species'] ?? 'Unknown').toString(),
      type: (json['type'] ?? '').toString(),
      gender: (json['gender'] ?? 'Unknown').toString(),
      origin: CharacterLocation.fromJson(
        json['origin'] as Map<String, dynamic>?,
      ),
      location: CharacterLocation.fromJson(
        json['location'] as Map<String, dynamic>?,
      ),
      image: (json['image'] ?? '').toString(),
      episode: episodeList,
      url: (json['url'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status,
      'species': species,
      'type': type,
      'gender': gender,
      'origin': origin.toJson(),
      'location': location.toJson(),
      'image': image,
      'episode': episode,
      'url': url,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CharacterModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
