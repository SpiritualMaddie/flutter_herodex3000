class AppearanceModel {
  String gender;
  String race;
  String? eyeColor;
  String? hairColor;

  List<dynamic> height = [];
  List<dynamic> weight = [];

  AppearanceModel({
    required this.gender,
    required this.race,
    required this.height,
    required this.weight,
    this.eyeColor,
    this.hairColor
  });

  // Deserialization
  factory AppearanceModel.fromJson(Map<String, dynamic> json){
    List<String> missingFields = [];

    if(json["gender"] == null) missingFields.add("gender");
    if(json["race"] == null) missingFields.add("race");
    if(json["height"] == null) missingFields.add("height");
    if(json["weight"] == null) missingFields.add("weight");

    if(missingFields.isNotEmpty){
        throw FormatException("Missing required fields: ${missingFields.join(", ")}");
    }

    return AppearanceModel(
        gender : json["gender"],
        race : json["race"],
        height : json["height"],
        weight : json["weight"],
        eyeColor : json["eye-color"],
        hairColor : json["hair-color"],
    );
  }

  // Serialization
  Map<String, dynamic> toJson() => {
    "gender": gender,
    "race": race,
    "height": height,
    "weight": weight,
    "eye-color": eyeColor,
    "hair-color": hairColor,
  };
}