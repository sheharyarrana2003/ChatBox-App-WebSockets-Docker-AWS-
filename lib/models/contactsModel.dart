class ContactModel{
  final String id;
  final String userName;
  final String profileImageUrl;
  final String bio;

  ContactModel({
   required this.id,
   required this.userName,
   required this.profileImageUrl,
    required this.bio
});
  factory ContactModel.fromJson(Map<String,dynamic> json){
    return ContactModel(
        id: json['id'] ?? '',
        userName: json['userName'] ?? '',
        profileImageUrl: json['profileImageUrl'] ?? '',
      bio: json['bio'] ?? ''
    );
  }
}