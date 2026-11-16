class EpisodeModel {
  final int id;
  final String name;
  final String airDate;
  final String episode;
  final List<String> characters;
  final String url;

  const EpisodeModel({
    required this.id,
    required this.name,
    required this.airDate,
    required this.episode,
    required this.characters,
    required this.url,
  });

  factory EpisodeModel.fromJson(Map<String, dynamic> json) {
    final characterList = (json['characters'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        <String>[];

    return EpisodeModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? 'Untitled Episode').toString(),
      airDate: (json['air_date'] ?? '-').toString(),
      episode: (json['episode'] ?? '').toString(),
      characters: characterList,
      url: (json['url'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'air_date': airDate,
      'episode': episode,
      'characters': characters,
      'url': url,
    };
  }
}
