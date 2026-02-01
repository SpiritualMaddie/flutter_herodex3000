class BiographyModel {
  String? fullName;
  String? alterEgos;
  String placeOfBirth;
  String firstAppearance;
  String publisher;
  String alignment;

  List<dynamic>? aliases = [];

  BiographyModel({
    required this.placeOfBirth,
    required this.firstAppearance,
    required this.publisher,
    required this.alignment,
    this.fullName,
    this.alterEgos,
    this.aliases
  });

  // Deserialization
  factory BiographyModel.fromJson(Map<String, dynamic> json){
    List<String> missingFields = [];

    if(json["place-of-birth"] == null) missingFields.add("place-of-birth");
    if(json["first-appearance"] == null) missingFields.add("first-appearance");
    if(json["publisher"] == null) missingFields.add("publisher");
    if(json["alignment"] == null) missingFields.add("alignment");

    if(missingFields.isNotEmpty){
        throw FormatException("Missing required fields: ${missingFields.join(", ")}");
    }

    return BiographyModel(
        fullName : json["full-name"],
        alterEgos : json["alter-egos"],
        aliases : json["aliases"],
        placeOfBirth : json["place-of-birth"],
        firstAppearance : json["first-appearance"],
        publisher : json["publisher"],
        alignment : json["alignment"],
    );
  }

  // Serialization
  Map<String, dynamic> toJson() => {
    "full-name": fullName,
    "alter-egos": alterEgos,
    "aliases": aliases,
    "place-of-birth": placeOfBirth,
    "first-appearance": firstAppearance,
    "publisher": publisher,
    "alignment": alignment,
  };
}