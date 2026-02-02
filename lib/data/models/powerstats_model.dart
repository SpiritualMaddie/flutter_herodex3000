class PowerstatsModel {
  int intelligence;
  int strength;
  int speed;
  int durability;
  int power;
  int combat;

  PowerstatsModel({
    required this.intelligence,
    required this.strength,
    required this.speed,
    required this.durability,
    required this.power,
    required this.combat
  });

  // Deserialization
  factory PowerstatsModel.fromJson(Map<String, dynamic> json){

    return PowerstatsModel(
      intelligence: _safeParse(json["intelligence"]),
      strength: _safeParse(json["strength"]),
      speed: _safeParse(json["speed"]),
      durability: _safeParse(json["durability"]),
      power: _safeParse(json["power"]),
      combat: _safeParse(json["combat"]),
    );
  }

  // Serialization
  Map<String, dynamic> toJson() => {
    "intelligence": intelligence.toString(),
    "strength": strength.toString(),
    "speed": speed.toString(),
    "durability": durability.toString(),
    "power": power.toString(),
    "combat": combat.toString(),
  };

  static int _safeParse(dynamic value) {
    if (value == null || value == "null" || value == "") return 0;
    return int.tryParse(value.toString()) ?? 0;
  }
}