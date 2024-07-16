import 'package:cloud_firestore/cloud_firestore.dart';

enum StoryType { text, image, video }

class Story {
  final String? sid;
  final String? userId;
  final String? storyURL;
  final StoryType? storyType;
  final Timestamp? sentAt;
  final String? caption;
  final List<String>? viewers;

  Story({
    this.sid,
    this.userId,
    this.storyURL,
    this.storyType,
    this.sentAt,
    this.caption,
    this.viewers,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      sid: json['sid'],
      userId: json['userId'],
      storyURL: json['storyURL'],
      storyType: StoryType.values.byName(json['storyType']),
      sentAt: json['sentAt'],
      caption: json['caption'],
      viewers: (json['viewers'] as List<dynamic>?)?.map((viewer) => viewer as String).toList() ?? [],
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
    data['viewers'] = viewers;
    return data;
  }
}
