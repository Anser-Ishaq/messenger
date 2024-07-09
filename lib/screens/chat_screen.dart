import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get_it/get_it.dart';
import 'package:messanger_ui/components/header.dart';
import 'package:messanger_ui/components/searchbox.dart';
import 'package:messanger_ui/components/video_trimmer.dart';
import 'package:messanger_ui/model/chat.dart';
import 'package:messanger_ui/model/usermodel.dart';
import 'package:messanger_ui/screens/message_screen.dart';
import 'package:messanger_ui/screens/story_screen.dart';
import 'package:messanger_ui/services/auth_service.dart';
import 'package:messanger_ui/services/database_service.dart';
import 'package:messanger_ui/services/navigation_service.dart';
import 'package:messanger_ui/users.dart';
import 'package:messanger_ui/utils.dart';
import 'package:messanger_ui/widgets/custom_container.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GetIt _getIt = GetIt.instance;

  late AuthService _authService;
  late NavigationService _navigationService;
  late DatabaseService _databaseService;

  Future<void>? _userController;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    _databaseService = _getIt.get<DatabaseService>();
    _userController = _databaseService.getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _userController,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text("Unable to load data."),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: SizedBox());
          }
          return _buildUI();
        },
      ),
    );
  }

  Widget _buildUI() {
    return SafeArea(
      child: Column(
        children: [
          Header(
            pfp: _databaseService.userModel.pfpURL!,
            screenText: 'Chats',
            icon1: Icons.camera_alt_rounded,
            icon2: Icons.edit_square,
          ),
          const Searchbox(),
          _storyAndOnlineBox(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _chatsBox(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _storyAndOnlineBox() {
    return SizedBox(
      height: 120,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _storyBox(),
            _onlineBox(),
          ],
        ),
      ),
    );
  }

  Widget _storyBox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Container(
            width: 52,
            height: 52,
            margin: const EdgeInsets.all(12.0),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0x0A000000),
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Center(
                child: Icon(
                  Icons.add,
                  size: 25.5,
                ),
              ),
            ),
          ),
        ),
        const Text(
          'Your story',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _onlineBox() {
    return Row(
      children: users.map((user) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () async {
                String? inputPath =
                    await VideoTrimmer.copyAssetToFile(user.videoPath!);
                File? videoFile = await VideoTrimmer.trimVideo(inputPath, 10);
                _navigationService.push(
                  MaterialPageRoute(
                    builder: (context) => StoryScreen(videoFile: videoFile),
                  ),
                );
                await Future.delayed(const Duration(seconds: 2));
                setState(() {
                  user.played = true;
                });
              },
              child: Container(
                width: 55,
                height: 55,
                margin: const EdgeInsets.all(9.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: user.played! ? Colors.transparent : Colors.green,
                    width: user.played! ? 0.0 : 1,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(user.played! ? 0.0 : 1.0),
                  child: ClipOval(
                    child: Image.asset(
                      user.pfpURL!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 50,
              child: Text(
                user.username!,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _chatsBox() {
    return StreamBuilder(
      stream: _databaseService.getFriendUsers(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text("Unable to load data."),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: SizedBox());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text("No friends found."),
          );
        }
        final users = snapshot.data!.docs;
        return SlidableAutoCloseBehavior(
          closeWhenTapped: true,
          closeWhenOpened: true,
          child: Column(
            children: users.map((userDoc) {
              UserModel user = userDoc.data();
              return StreamBuilder(
                stream: _databaseService.getChatData(
                    user.uid!, _authService.user!.uid),
                builder: (context, chatSnapshot) {
                  if (chatSnapshot.hasError) {
                    return const Center(
                      child: Text("Unable to load chat data."),
                    );
                  }
                  if (chatSnapshot.connectionState == ConnectionState.waiting) {
                    return const ListTile(
                      title: Text("Loading..."),
                    );
                  }
                  if (!chatSnapshot.hasData || !chatSnapshot.data!.exists) {
                    return const ListTile(
                      title: Text("No chat data found."),
                    );
                  }
                  Chat chatData = chatSnapshot.data!.data()!;
                  String lastMessage = chatData.messages!.last.content!;
                  String dateTime =
                      formatDateTime(chatData.messages!.last.sentAt!);
                  return Slidable(
                    key: Key(user.uid!),
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      children: [
                        CustomSlidableAction(
                          padding: const EdgeInsets.all(0),
                          onPressed: (context) {},
                          child: const CustomContainer(
                            leftM: 0,
                            rightM: 0,
                            child: Icon(Icons.menu_rounded),
                          ),
                        ),
                        CustomSlidableAction(
                          padding: const EdgeInsets.all(0),
                          onPressed: (context) {},
                          child: const CustomContainer(
                            leftM: 0,
                            rightM: 0,
                            child: Icon(Icons.notifications),
                          ),
                        ),
                        CustomSlidableAction(
                          padding: const EdgeInsets.all(0),
                          onPressed: (context) {},
                          child: const CustomContainer(
                            leftM: 0,
                            rightM: 0,
                            color: Colors.red,
                            child: Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    startActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      children: [
                        CustomSlidableAction(
                          padding: const EdgeInsets.all(0),
                          onPressed: (context) {},
                          child: const CustomContainer(
                            leftM: 0,
                            rightM: 0,
                            child: Icon(Icons.camera_alt_rounded),
                          ),
                        ),
                        CustomSlidableAction(
                          padding: const EdgeInsets.all(0),
                          onPressed: (context) {},
                          child: const CustomContainer(
                            leftM: 0,
                            rightM: 0,
                            child: Icon(Icons.phone_rounded),
                          ),
                        ),
                        CustomSlidableAction(
                          padding: const EdgeInsets.all(0),
                          onPressed: (context) {},
                          child: const CustomContainer(
                            leftM: 0,
                            rightM: 0,
                            child: Icon(Icons.videocam_rounded),
                          ),
                        ),
                      ],
                    ),
                    child: ListTile(
                      dense: false,
                      minLeadingWidth: 60,
                      minVerticalPadding: 10,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 12,
                      ),
                      leading: Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0x0A000000),
                        ),
                        child: ClipOval(
                          child: Image.network(
                            user.pfpURL!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      title: Text(
                        user.username!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: Text(
                              lastMessage,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Color(0xFFBDBDBD),
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            dateTime.toString(),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFBDBDBD),
                            ),
                          ),
                        ],
                      ),
                      trailing: Text(
                        dateTime.toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFBDBDBD),
                        ),
                      ),
                      onTap: () async {
                        final chatExists = await _databaseService
                            .checkChatExists(_authService.user!.uid, user.uid!);
                        if (!chatExists) {
                          await _databaseService.createNewChat(
                              _authService.user!.uid, user.uid!);
                        }
                        _navigationService.push(
                          MaterialPageRoute(
                            builder: (context) => MessageScreen(
                              chatUser: user,
                              currentUser: _databaseService.userModel,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
