class Lists {
  String id;
  String name;

  Lists({required this.id, required this.name});

  Lists.fromMap(Map<String, dynamic> map)
      : id = map["id"],
        name = map["name"];

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
    };
  }
}
