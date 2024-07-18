import 'package:messanger_ui/models/message.dart';

class Group {
  String? gid;
  String? pfpURL;
  String? groupName;
  List<String>? members;
  List<Message>? messages;

  Group({
    required this.gid,
    required this.pfpURL,
    required this.groupName,
    required this.members,
    required this.messages,
  });

  Group.fromJson(Map<String, dynamic> json) {
    gid = json['gid'];
    pfpURL = json['pfpURL'];
    groupName = json['groupName'];
    members = List<String>.from(json['members']);
    messages = List.from(json['messages']).map((m) => Message.fromJson(m)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['gid'] = gid;
    data['pfpURL'] = pfpURL;
    data['groupName'] = groupName;
    data['members'] = members;
    data['messages'] = messages?.map((m) => m.toJson()).toList() ?? [];
    return data;
  }
}
