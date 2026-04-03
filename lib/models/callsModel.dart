class CallsModel{
  final String id;
  final String userName;
  final String profileImageUrl;
  final String timestamp;

  CallsModel({
    required this.id,
    required this.userName,
    required this.profileImageUrl,
    required this.timestamp
});
  factory CallsModel.fromJson(Map<String,dynamic> json){
    return CallsModel(
      id: json['id'] ?? '',
      userName: json['userName'] ?? '',
        profileImageUrl: json['profileImageUrl'] ?? '',
        timestamp: json['timestamp'] ?? ''
    );
  }

  Map<String,dynamic> toJson(){
    return {
      'id':id,
      'userName':userName,
      'profileImageUrl':profileImageUrl,
      'timestamp':timestamp
    };
  }
}