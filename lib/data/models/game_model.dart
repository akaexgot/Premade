// Game Model
class GameModel {
  final String id;
  final String title;
  final String icon;

  GameModel({
    required this.id,
    required this.title,
    required this.icon,
  });

  factory GameModel.fromJson(Map<String, dynamic> json) {
    return GameModel(
      id: json['id'],
      title: json['title'],
      icon: json['icon'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'icon': icon,
    };
  }
}
