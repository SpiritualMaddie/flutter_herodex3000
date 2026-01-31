import 'package:flutter_herodex3000/barrel_files/models.dart';

class AgentModel {

  int heroId;  
  String name;

  final PowerstatsModel powerstats;
  final BiographyModel biography;
  final AppearanceModel appearance;
  final ImageModel? image;
  final WorkModel? work;
  final ConnectionsModel? connections;

  AgentModel({
      this.heroId = 0,
      required this.name,
      required this.powerstats,
      required this.biography,
      required this.appearance,
      this.image,
      this.work,
      this.connections
  });

  // Deserialization
  factory AgentModel.fromJson(Map<String, dynamic> json){
    List<String> missingFields = [];

    if(json["id"] == null) missingFields.add("id");
    if(json["name"] == null) missingFields.add("name");
    if(json["powerstats"] == null) missingFields.add("intelligence");
    if(json["biography"] == null) missingFields.add("strength");
    if(json["appearance"] == null) missingFields.add("speed");

    if(missingFields.isNotEmpty){
        throw FormatException("Missing required fields: ${missingFields.join(", ")}");
    }

    return AgentModel(
        heroId : int.parse(json["id"]),
        name : json["name"],
        powerstats  : json["powerstats"] != null
                    ? PowerstatsModel.fromJson(json["powerstats"])
                    : PowerstatsModel(intelligence: 0, strength: 0, speed: 0, durability: 0, power: 0, combat: 0),
        biography   : json["biography"] != null
                    ? BiographyModel.fromJson(json["biography"])
                    : BiographyModel(placeOfBirth: " ", firstAppearance: " ", publisher: " ", alignment: " "),
        appearance  : json["appearance"] != null
                    ? AppearanceModel.fromJson(json["appearance"])
                    : AppearanceModel(gender: " ", race: " ", height: [" "], weight: [" "]),
        work        : json["work"] != null 
                    ? WorkModel.fromJson(json["work"])
                    : WorkModel(occupation: " ", base: " "),
        connections : json["connections"] != null 
                    ? ConnectionsModel.fromJson(json["connections"])
                    : ConnectionsModel(groupAffiliation: " ", relatives: " "),
        image       : json["image"] != null 
                    ? ImageModel.fromJson(json["image"])
                    : ImageModel(url: " ")
    );
  }
    
  // Serialization
  Map<String, dynamic> toJson() => {
    "id": heroId.toString(),
    "name": name,
    "powerstats": powerstats.toJson(),
    "biography": biography.toJson(),
    "appearance": appearance.toJson(),
    "work": work?.toJson(),
    "connections": connections?.toJson(),
    "image": image?.toJson(),
  };
}