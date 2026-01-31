class WorkModel {
  String? occupation;
  String? base;

  WorkModel({this.occupation, this.base});

  // Deserialization
  factory WorkModel.fromJson(Map<String, dynamic> json){

    return WorkModel(
        occupation : json["occupation"],
        base : json["base"],
    );
  }

  // Serialization
  Map<String, dynamic> toJson() => {
    "occupation": occupation,
    "base": base,
  };
}