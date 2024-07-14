import 'package:cloud_firestore/cloud_firestore.dart';

enum StoryType { text, inlineImage, inlineVideo, pageImage, pageVideo }

class Story {
  String? sid;
  String? userId;
  String? storyURL;
  StoryType? storyType;
  Timestamp? sentAt;
  String? caption;

  Story({
    this.sid,
    this.userId,
    this.storyURL,
    this.storyType,
    this.sentAt,
    this.caption,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      sid: json['sid'],
      userId: json['userId'],
      storyURL: json['storyURL'],
      storyType: StoryType.values.byName(json['storyType']),
      sentAt: json['sentAt'],
      caption: json['caption'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['sid'] = sid;
    data['userId'] = userId;
    data['storyURL'] = storyURL;
    data['storyType'] = storyType!.name;
    data['sentAt'] = sentAt;
    data['caption'] = caption;
    return data;
  }
}
