class ConnectionsModel {
  String? groupAffiliation;
  String? relatives;

  ConnectionsModel({this.groupAffiliation, this.relatives});

  // Deserialization
  factory ConnectionsModel.fromJson(Map<String, dynamic> json){

    return ConnectionsModel(
        groupAffiliation : json["group-affiliation"],
        relatives : json["relatives"],
    );
  }

  // Serialization
  Map<String, dynamic> toJson() => {
    "group-affiliation": groupAffiliation,
    "relatives": relatives,
  };
}