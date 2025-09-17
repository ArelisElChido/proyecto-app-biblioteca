class GameConsole {
  final String id;
  String name;

  GameConsole({required this.id, required this.name});

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  factory GameConsole.fromJson(Map<String, dynamic> json) =>
      GameConsole(id: json['id'] as String, name: json['name'] as String);
}
