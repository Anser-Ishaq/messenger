import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:messanger_ui/models/chat.dart';
import 'package:messanger_ui/models/groupmodel.dart';
import 'package:messanger_ui/models/message.dart';
import 'package:messanger_ui/models/story.dart';
import 'package:messanger_ui/models/usermodel.dart';
import 'package:messanger_ui/services/auth_service.dart';
import 'package:messanger_ui/utils.dart';
import 'package:rxdart/rxdart.dart';

class DatabaseService {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final GetIt _getIt = GetIt.instance;

  CollectionReference? _userCollection;
  CollectionReference? _chatCollection;
  CollectionReference? _storyCollection;
  CollectionReference? _groupCollection;

  late AuthService _authService;

  UserModel _userModel = UserModel();

  UserModel get userModel => _userModel;

  DatabaseService() {
    _authService = _getIt.get<AuthService>();
    _setupCollectionreferences();
  }

  void _setupCollectionreferences() {
    _userCollection = _firebaseFirestore
        .collection('users')
        .withConverter<UserModel>(
          fromFirestore: (snapshot, _) => UserModel.fromJson(snapshot.data()!),
          toFirestore: (userModel, _) => userModel.toJson(),
        );
    _chatCollection =
        _firebaseFirestore.collection('chats').withConverter<Chat>(
              fromFirestore: (snapshot, _) => Chat.fromJson(snapshot.data()!),
              toFirestore: (chat, _) => chat.toJson(),
            );
    _storyCollection =
        _firebaseFirestore.collection('stories').withConverter<Story>(
              fromFirestore: (snapshot, _) => Story.fromJson(snapshot.data()!),
              toFirestore: (story, _) => story.toJson(),
            );
    _groupCollection =
        _firebaseFirestore.collection('groups').withConverter<Group>(
              fromFirestore: (snapshot, _) => Group.fromJson(snapshot.data()!),
              toFirestore: (group, _) => group.toJson(),
            );
  }

  Future<void> createUserModel({required UserModel userModel}) async {
    await _userCollection?.doc(userModel.uid).set(userModel);
  }

  Future<bool> getCurrentUser() async {
    final DocumentSnapshot<UserModel> userDoc = await _userCollection
        ?.doc(_authService.user!.uid)
        .get() as DocumentSnapshot<UserModel>;

    if (userDoc.exists && userDoc.data() != null) {
      _userModel = userDoc.data()!;
    } else {
      throw Exception("User not found or data is null");
    }
    return true;
  }

  Future<void> updateUserProfile({
    required String uid,
    String? newUsername,
    String? newPfpURL,
    String? newSid,
    String? newGid,
  }) async {
    Map<String, dynamic> data = {};
    if (newUsername != null) data['username'] = newUsername;
    if (newPfpURL != null) data['pfpURL'] = newPfpURL;
    if (newSid != null) data['stories'] = FieldValue.arrayUnion([newSid]);
    if (newGid != null) data['groups'] = FieldValue.arrayUnion([newGid]);

    await _userCollection?.doc(uid).update(data);
  }

  Stream<QuerySnapshot<UserModel>> getUserFriends() {
    if (_userModel.friends == null || _userModel.friends!.isEmpty) {
      return const Stream.empty();
    }
    return _userCollection
        ?.where('uid', whereIn: _userModel.friends)
        .snapshots() as Stream<QuerySnapshot<UserModel>>;
  }

  Future<bool> checkChatExists(String uid1, String uid2) async {
    String chatID = generateChatID(uid1: uid1, uid2: uid2);
    final result = await _chatCollection?.doc(chatID).get();
    if (result != null) {
      return result.exists;
    }
    return false;
  }

  Future<void> createNewChat(String uid1, String uid2) async {
    String chatId = generateChatID(uid1: uid1, uid2: uid2);
    final docRef = _chatCollection!.doc(chatId);
    final chat = Chat(id: chatId, participants: [uid1, uid2], messages: []);
    await docRef.set(chat);
  }

  Future<void> sendChatMessage(
      String uid1, String uid2, Message message) async {
    String chatId = generateChatID(uid1: uid1, uid2: uid2);
    final docRef = _chatCollection!.doc(chatId);
    await docRef.update({
      'messages': FieldValue.arrayUnion([message.toJson()])
    });
  }

  Stream<DocumentSnapshot<Chat>> getChatData(String uid1, String uid2) {
    String chatID = generateChatID(uid1: uid1, uid2: uid2);
    return _chatCollection!.doc(chatID).snapshots()
        as Stream<DocumentSnapshot<Chat>>;
  }

  String createNewStoryDoc() {
    try {
      final docRef = _storyCollection!.doc();
      return docRef.id;
    } catch (e) {
      if (kDebugMode) print('Error creating story: $e');
      rethrow;
    }
  }

  Future<void> setStoryDoc({required Story story}) async {
    try {
      await _storyCollection!.doc(story.sid).set(story);
    } catch (e) {
      if (kDebugMode) print('Error setting story document: $e');
      rethrow;
    }
  }

  Future<void> updateStoryDoc(
      {required String sid, required String uid}) async {
    try {
      await _storyCollection!.doc(sid).update({
        'viewers': FieldValue.arrayUnion([uid])
      });
    } catch (e) {
      if (kDebugMode) print('Error updating story document: $e');
      rethrow;
    }
  }

  Future<List<Story>> getStories({required UserModel user}) async {
    try {
      if (user.stories == null || user.stories!.isEmpty) {
        return [];
      }

      QuerySnapshot<Story> querySnapshot = await _storyCollection
          ?.where('sid', whereIn: user.stories)
          .get() as QuerySnapshot<Story>;

      List<Story> stories =
          querySnapshot.docs.map((doc) => doc.data()).toList();

      return stories;
    } catch (e) {
      if (kDebugMode) print('Error fetching stories: $e');
      return [];
    }
  }

  Future<void> deleteStory({required String sid}) async {
    try {
      DocumentSnapshot<Story>? storySnapshot =
          await _storyCollection!.doc(sid).get() as DocumentSnapshot<Story>?;

      if (storySnapshot!.exists) {
        Story story = storySnapshot.data()!;

        DateTime sentAt = story.sentAt!.toDate();
        DateTime currentTime = DateTime.now();
        Duration difference = currentTime.difference(sentAt);
        int hoursDifference = difference.inHours;

        if (hoursDifference >= 24) {
          await _storyCollection!.doc(sid).delete();
          await _removeStoryFromUserList(sid);
        } else {
          if (kDebugMode) {
            print('Story is not older than 24 hours, not deleting.');
          }
        }
      } else {
        if (kDebugMode) {
          print('Story document does not exist.');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting story: $e');
      }
      rethrow;
    }
  }

  Future<void> _removeStoryFromUserList(String sid) async {
    try {
      _userModel.stories?.remove(sid);
      await _userCollection?.doc(_userModel.uid).update({
        'stories': FieldValue.arrayRemove([sid])
      });
    } catch (e) {
      if (kDebugMode) print('Error updating user stories: $e');
      rethrow;
    }
  }

  Future<bool> checkGroupExists(String gid) async {
    final result = await _groupCollection?.doc(gid).get();
    if (result != null) {
      return result.exists;
    }
    return false;
  }

  String generateUniqueGroupId() {
    final docRef = _groupCollection!.doc();
    return docRef.id;
  }

  Future<void> setGroupDoc({required Group group}) async {
    try {
      await _groupCollection?.doc(group.gid).set(group);
    } catch (e) {
      if (kDebugMode) print('Error setting story document: $e');
      rethrow;
    }
  }

  Stream<QuerySnapshot<Group>> getUserGroups() {
    if (_userModel.groups == null || _userModel.groups!.isEmpty) {
      return const Stream.empty();
    }
    return _groupCollection
        ?.where('gid', whereIn: _userModel.groups)
        .snapshots() as Stream<QuerySnapshot<Group>>;
  }

  Future<void> sendGroupMessage(String gid, Message message) async {
    final docRef = _groupCollection!.doc(gid);
    await docRef.update({
      'messages': FieldValue.arrayUnion([message.toJson()])
    });
  }

  Stream<DocumentSnapshot<Group>> getGroupData(String gid) {
    return _groupCollection!.doc(gid).snapshots()
        as Stream<DocumentSnapshot<Group>>;
  }

  Stream<Map<String, List<QueryDocumentSnapshot<dynamic>>>> getMergedStream() {
  Stream<QuerySnapshot<UserModel>> friends = getUserFriends();
  Stream<QuerySnapshot<Group>> groups = getUserGroups();

  Stream<Map<String, List<QueryDocumentSnapshot<dynamic>>>> mergedStream = Rx.zip2(
    friends,
    groups,
    (QuerySnapshot<UserModel> friendsSnapshot, QuerySnapshot<Group> groupsSnapshot) {
      return {
        'friends': friendsSnapshot.docs,
        'groups': groupsSnapshot.docs,
      };
    },
  );

  return mergedStream;
}
}
