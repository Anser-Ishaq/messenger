class UserModel {
  String? uid;
  String? username;
  String? pfpURL;
  String? email;
  List<String>? stories;
  List<String>? friends;

  UserModel({
    this.uid,
    this.username,
    this.pfpURL,
    this.email,
    this.stories,
    this.friends,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      username: json['username'],
      pfpURL: json['pfpURL'],
      email: json['email'],
      friends: (json['friends'] as List<dynamic>?)?.map((friend) => friend as String).toList() ?? [],
      stories: (json['stories'] as List<dynamic>?)?.map((story) => story as String).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uid'] = uid;
    data['username'] = username;
    data['pfpURL'] = pfpURL;
    data['email'] = email;
    data['friends'] = friends;
    data['stories'] = stories;
    return data;
  }
}
