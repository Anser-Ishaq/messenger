import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:messanger_ui/model/chat.dart';
import 'package:messanger_ui/model/message.dart';
import 'package:messanger_ui/model/usermodel.dart';
import 'package:messanger_ui/services/auth_service.dart';
import 'package:messanger_ui/utils.dart';

class DatabaseService {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final GetIt _getIt = GetIt.instance;

  CollectionReference? _userCollection;
  CollectionReference? _chatCollection;

  late AuthService _authService;

  UserModel _userModel = UserModel();

  UserModel get userModel => _userModel;

  DatabaseService() {
    _authService = _getIt.get<AuthService>();
    _setupCollectionreferences();
  }

  void _setupCollectionreferences() {
    _userCollection = _firebaseFirestore.collection('users').withConverter<UserModel>(
          fromFirestore: (snapshot, _) => UserModel.fromJson(snapshot.data()!),
          toFirestore: (userModel, _) => userModel.toJson(),
        );
        _chatCollection = _firebaseFirestore.collection('chats').withConverter<Chat>(
          fromFirestore: (snapshot, _) => Chat.fromJson(snapshot.data()!),
          toFirestore: (chat, _) => chat.toJson(),
        );
  }

  Future<void> createUserModel({required UserModel userModel}) async {
    await _userCollection?.doc(userModel.uid).set(userModel);
  }

  Future<void> getCurrentUser() async {
    final DocumentSnapshot<UserModel> userDoc = await _userCollection
        ?.doc(_authService.user!.uid)
        .get() as DocumentSnapshot<UserModel>;

    if (userDoc.exists && userDoc.data() != null) {
      _userModel = userDoc.data()!;
    } else {
      throw Exception("User not found or data is null");
    }
  }

  Future<void> updateUserProfile({
    required String uid,
    String? newUsername,
    String? newPfpURL,
  }) async {
    Map<String, dynamic> data = {};
    if (newUsername != null) data['username'] = newUsername;
    if (newPfpURL != null) data['pfpURL'] = newPfpURL;

    await _userCollection?.doc(uid).update(data);
  }

  Stream<QuerySnapshot<UserModel>> getFriendUsers() {
    if (_userModel.friends == null || _userModel.friends!.isEmpty) {
      // Return an empty stream if the friends list is null or empty
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

  Future<void> sendChatMessage(String uid1, String uid2, Message message) async {
    String chatId = generateChatID(uid1: uid1, uid2: uid2);
    final docRef = _chatCollection!.doc(chatId);
    await docRef.update({
      'messages': FieldValue.arrayUnion([message.toJson()])
    });
  }

  Stream<DocumentSnapshot<Chat>> getChatData(String uid1, String uid2) {
    String chatID = generateChatID(uid1: uid1, uid2: uid2);
    return _chatCollection!.doc(chatID).snapshots() as Stream<DocumentSnapshot<Chat>>;
  }
}
