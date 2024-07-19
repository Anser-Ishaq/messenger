import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get_it/get_it.dart';
import 'package:messanger_ui/components/header.dart';
import 'package:messanger_ui/components/searchbox.dart';
import 'package:messanger_ui/constans/const.dart';
import 'package:messanger_ui/constans/routes.dart';
import 'package:messanger_ui/models/chat.dart';
import 'package:messanger_ui/models/groupmodel.dart';
import 'package:messanger_ui/models/story.dart';
import 'package:messanger_ui/models/usermodel.dart';
import 'package:messanger_ui/screens/groupmessage_screen.dart';
import 'package:messanger_ui/screens/message_screen.dart';
import 'package:messanger_ui/screens/story_screen.dart';
import 'package:messanger_ui/services/auth_service.dart';
import 'package:messanger_ui/services/database_service.dart';
import 'package:messanger_ui/services/media_service.dart';
import 'package:messanger_ui/services/navigation_service.dart';
import 'package:messanger_ui/services/storage_service.dart';
import 'package:messanger_ui/utils.dart';
import 'package:messanger_ui/widgets/custom_container.dart';
import 'package:status_view/status_view.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _searchController = TextEditingController();
  final GetIt _getIt = GetIt.instance;

  late AuthService _authService;
  late NavigationService _navigationService;
  late DatabaseService _databaseService;
  late MediaService _mediaService;
  late StorageService _storageService;

  Future<void>? _userController;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _databaseService = _getIt.get<DatabaseService>();
    _userController = _databaseService.getCurrentUser();
    _navigationService = _getIt.get<NavigationService>();
    _mediaService = _getIt.get<MediaService>();
    _storageService = _getIt.get<StorageService>();
  }

  void addStory() async {
    File? videoFile = await _mediaService.getVideoFromGallery();
    setState(() {
      isLoading = true;
    });
    if (videoFile != null) {
      // Upload the video file to Firebase Storage
      String? storyURL = await _storageService.uploadStory(
        file: videoFile,
        uid: _authService.user!.uid,
      );
      if (storyURL != null) {
        // Update the videoPath field of the user with the download URL
        final docId = _databaseService.createNewStoryDoc();
        await _databaseService.setStoryDoc(
          story: Story(
            sid: docId,
            userId: _authService.user!.uid,
            storyURL: storyURL,
            storyType: StoryType.video,
            caption: 'New Story',
            sentAt: Timestamp.now(),
            viewers: [],
          ),
        );
        await _databaseService.updateUserProfile(
          uid: _authService.user!.uid,
          newSid: docId,
        );
      }
      setState(() {
        _databaseService.getCurrentUser();
        isLoading = false;
      });
    }
  }

  Future<int> _indexOfSeenStatus(UserModel user) async {
    int index = 0;

    List<Story> stories = await _databaseService.getStories(user: user);
    for (Story story in stories) {
      if (story.viewers != null &&
          story.viewers!.contains(_authService.user!.uid)) {
        index++;
      }
    }

    return index;
  }

  List<QueryDocumentSnapshot<UserModel>> moveValueToZeroIndex(List<QueryDocumentSnapshot<UserModel>> users) {
    for (var user in users) {
      if (user['uid'] == chatAIuid) {
        users.remove(user);
        users.insert(0, user);
      }
    }
    return users;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF0584FE),
                strokeWidth: 3,
              ),
            )
          : FutureBuilder(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Header(
            pfp: _databaseService.userModel.pfpURL!,
            screenText: 'Chats',
            containIcons: true,
            icon1: Icons.camera_alt_rounded,
            icon2: Icons.edit_square,
            onPressedIcon1: () {},
            onPressedIcon2: () {
              _navigationService.pushNamed(Routes.createGroup);
            },
          ),
          Searchbox(
            searchController: _searchController,
          ),
          Expanded(
            child: StreamBuilder(
              stream: _databaseService.getMergedStream(),
              builder: (context, snapshot) {
                // if (snapshot.hasError) {
                //   return const Center(
                //     child: Text("Unable to load data."),
                //   );
                // }
                // if (snapshot.connectionState == ConnectionState.waiting) {
                //   return const Center(child: SizedBox());
                // }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _storyBox();
                }
                final users = snapshot.data!['friends']!;
                final groups = snapshot.data!['groups']!;
                return Column(
                  children: [
                    _storyAndFriendStoryBox(users),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _chatsBox(users, groups),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _storyAndFriendStoryBox(users) {
    return SizedBox(
      height: 120,
      width: MediaQuery.of(context).size.width,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _storyBox(),
            _friendStoryBox(users),
          ],
        ),
      ),
    );
  }

  Widget _storyBox() {
    bool isStory = _databaseService.userModel.stories == null
        ? false
        : _databaseService.userModel.stories!.isNotEmpty;
    return FutureBuilder<int>(
      future: _indexOfSeenStatus(_databaseService.userModel),
      builder: (context, snapshot) {
        int seenIndex = 0;
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          seenIndex = snapshot.data!;
        }
        return Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                children: [
                  Container(
                    width: 55,
                    height: 55,
                    margin: const EdgeInsets.all(9.0),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0x0A000000),
                    ),
                    child: isStory
                        ? GestureDetector(
                            onTap: () async {
                              List<Story> stories = await _databaseService
                                  .getStories(user: _databaseService.userModel);
                              _navigationService.push(
                                MaterialPageRoute(
                                  builder: (context) => StoryScreen(
                                    stories: stories,
                                    currentUser: _databaseService.userModel,
                                  ),
                                ),
                              );
                            },
                            child: StatusView(
                              centerImageUrl:
                                  _databaseService.userModel.pfpURL!,
                              numberOfStatus:
                                  _databaseService.userModel.stories!.length,
                              radius: 30.5,
                              indexOfSeenStatus: seenIndex,
                              spacing: 8,
                              strokeWidth: 2,
                            ),
                          )
                        : IconButton(
                            onPressed: addStory,
                            icon: const Center(
                              child: Icon(
                                Icons.add,
                                size: 25.5,
                              ),
                            ),
                          ),
                  ),
                  isStory
                      ? Positioned(
                          bottom: 9,
                          right: 12,
                          child: GestureDetector(
                            onTap: addStory,
                            child: Container(
                              padding: const EdgeInsets.all(1),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1,
                                ),
                              ),
                              child: const Icon(
                                Icons.add,
                                size: 10,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ],
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
          ),
        );
      },
    );
  }

  Widget _friendStoryBox(List<QueryDocumentSnapshot<UserModel>> users) {
    users = moveValueToZeroIndex(users);
    return ListView.builder(
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: users.length,
      itemBuilder: (context, index) {
        UserModel user = users[index].data();
        return FutureBuilder<int>(
          future: _indexOfSeenStatus(user),
          builder: (context, snapshot) {
            int seenIndex = 0;
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              seenIndex = snapshot.data!;
            }
            return user.stories!.isNotEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 55,
                        height: 55,
                        margin: const EdgeInsets.all(9.0),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: GestureDetector(
                          onTap: () async {
                            List<Story> stories =
                                await _databaseService.getStories(user: user);
                            _navigationService.push(
                              MaterialPageRoute(
                                builder: (context) => StoryScreen(
                                  stories: stories,
                                  currentUser: _databaseService.userModel,
                                ),
                              ),
                            );
                          },
                          child: StatusView(
                            centerImageUrl: user.pfpURL!,
                            numberOfStatus: user.stories!.length,
                            radius: 30.5,
                            indexOfSeenStatus: seenIndex,
                            spacing: 8,
                            strokeWidth: 2,
                            seenColor: Colors.grey,
                            unSeenColor: Colors.blue,
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
                  )
                : const SizedBox.shrink();
          },
        );
      },
    );
  }

  Widget _chatsBox(users, groups) {
    return SlidableAutoCloseBehavior(
      closeWhenTapped: true,
      closeWhenOpened: true,
      child: Column(
        children: [
          ...users.map<Widget>((userDoc) {
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
                String lastMessage = '';
                String dateTime = '';
                if (!chatSnapshot.hasData || !chatSnapshot.data!.exists) {
                  lastMessage = '';
                  dateTime = '';
                } else {
                  Chat chatData = chatSnapshot.data!.data()!;
                  if (chatData.messages!.isEmpty) {
                    lastMessage = '';
                    dateTime = '';
                  } else {
                    lastMessage = chatData.messages!.last.content!;
                    dateTime = formatDateTime(chatData.messages!.last.sentAt!);
                  }
                }
                return _buildSlidable(
                  key: user.uid!,
                  leading: Image.network(
                    user.pfpURL!,
                    fit: BoxFit.cover,
                  ),
                  title: user.username!,
                  lastMessage: lastMessage,
                  dateTime: dateTime,
                  onTap: () async {
                    final chatExists = await _databaseService.checkChatExists(
                        _authService.user!.uid, user.uid!);
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
                );
              },
            );
          }).toList(),
          ...groups.map<Widget>((groupDoc) {
            Group group = groupDoc.data();
            return StreamBuilder(
              stream: _databaseService.getGroupData(group.gid!),
              builder: (context, groupSnapshot) {
                if (groupSnapshot.hasError) {
                  return const Center(
                    child: Text("Unable to load group data."),
                  );
                }
                if (groupSnapshot.connectionState == ConnectionState.waiting) {
                  return const ListTile(
                    title: Text("Loading..."),
                  );
                }
                String lastMessage = '';
                String dateTime = '';
                if (!groupSnapshot.hasData || !groupSnapshot.data!.exists) {
                  lastMessage = '';
                  dateTime = '';
                } else {
                  Group groupData = groupSnapshot.data!.data()!;
                  if (groupData.messages!.isEmpty) {
                    lastMessage = '';
                    dateTime = '';
                  } else {
                    lastMessage = groupData.messages!.last.content!;
                    dateTime = formatDateTime(groupData.messages!.last.sentAt!);
                  }
                }
                return _buildSlidable(
                  key: group.gid!,
                  leading: Image.network(
                    group.pfpURL!,
                    fit: BoxFit.cover,
                  ),
                  title: group.groupName!,
                  lastMessage: lastMessage,
                  dateTime: dateTime,
                  onTap: () {
                    _navigationService.push(
                      MaterialPageRoute(
                        builder: (context) => GroupMessageScreen(
                          group: group,
                          currentUser: _databaseService.userModel,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildSlidable({
    required String key,
    required Widget leading,
    required String title,
    required String lastMessage,
    required String dateTime,
    required VoidCallback onTap,
  }) {
    return Slidable(
      key: Key(key),
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
        contentPadding: const EdgeInsets.symmetric(
          vertical: 3,
          horizontal: 12,
        ),
        leading: Container(
          width: 60,
          height: 60,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0x0A000000),
          ),
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: leading,
            ),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.4,
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
            Text(
              dateTime,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFFBDBDBD),
              ),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
