import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:messanger_ui/models/chat.dart';
import 'package:messanger_ui/models/message.dart';
import 'package:messanger_ui/models/story.dart';
import 'package:messanger_ui/models/usermodel.dart';
import 'package:messanger_ui/services/auth_service.dart';
import 'package:messanger_ui/utils.dart';

class DatabaseService {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final GetIt _getIt = GetIt.instance;

  CollectionReference? _userCollection;
  CollectionReference? _chatCollection;
  CollectionReference? _storyCollection;

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
  }) async {
    Map<String, dynamic> data = {};
    if (newUsername != null) data['username'] = newUsername;
    if (newPfpURL != null) data['pfpURL'] = newPfpURL;
    if (newSid != null) data['stories'] = FieldValue.arrayUnion([newSid]);

    await _userCollection?.doc(uid).update(data);
  }

  Stream<QuerySnapshot<UserModel>> getFriendUsers() {
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

  Future<List<Story>> getUserStories() async {
    try {
      if (_userModel.stories == null || _userModel.stories!.isEmpty) {
        return [];
      }

      QuerySnapshot<Story> querySnapshot = await _storyCollection
          ?.where('sid', whereIn: _userModel.stories)
          .get() as QuerySnapshot<Story>;

      List<Story> stories =
          querySnapshot.docs.map((doc) => doc.data()).toList();

      return stories;
    } catch (e) {
      if (kDebugMode) print('Error fetching user stories: $e');
      return [];
    }
  }

  Future<void> deleteStory(String sid) async {
    try {
      DocumentSnapshot<Story>? storySnapshot = await _storyCollection!.doc(sid).get() as DocumentSnapshot<Story>?;

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

  Future<List<Story>> getFriendsStories() async {
  try {
    if (_userModel.friends == null || _userModel.friends!.isEmpty) {
      return []; 
    }

    QuerySnapshot<Story> querySnapshot = await _storyCollection
        ?.where('userId', whereIn: _userModel.friends)
        .get() as QuerySnapshot<Story>;

    List<Story> stories =
        querySnapshot.docs.map((doc) => doc.data()).toList();

    return stories;
  } catch (e) {
    if (kDebugMode) print('Error fetching friend stories: $e');
    return [];
  }
}

}
