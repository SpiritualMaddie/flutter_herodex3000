class ImageModel {
  String? url;

  ImageModel({required this.url});

  // Deserialization
  factory ImageModel.fromJson(Map<String, dynamic> json){
    
    return ImageModel(
        url : json["url"],
    );
  }

  // Serialization
  Map<String, dynamic> toJson() => {
    "url": url,
  };
}