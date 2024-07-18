import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:messanger_ui/models/groupmodel.dart';
import 'package:messanger_ui/models/usermodel.dart';
import 'package:messanger_ui/services/database_service.dart';
import 'package:messanger_ui/services/media_service.dart';
import 'package:messanger_ui/services/navigation_service.dart';
import 'package:messanger_ui/services/storage_service.dart';
import 'package:messanger_ui/widgets/custom_back_button.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({
    super.key,
  });

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final StreamController _friendStreamController = StreamController();
  final GetIt _getIt = GetIt.instance;

  List<String> groupFriend = [];

  bool isCreatingGroup = false;

  final TextEditingController _groupNameController = TextEditingController();
  File? selectedImage;

  late DatabaseService _databaseService;
  late NavigationService _navigationService;
  late MediaService _mediaService;
  late StorageService _storageService;

  _onTap(String uid) {
    if (!groupFriend.contains(uid)) {
      groupFriend.add(uid);
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _databaseService = _getIt.get<DatabaseService>();
    _friendStreamController.addStream(
      _databaseService.getUserFriends(),
    );
    _navigationService = _getIt.get<NavigationService>();
    _mediaService = _getIt.get<MediaService>();
    _storageService = _getIt.get<StorageService>();
    groupFriend.add(_databaseService.userModel.uid!);
  }

  Future<void> _showAlert() async {
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Create Group'),
              content: SizedBox(
                height: 70,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        File? file = await _mediaService.getImageFromGallery();
                        if (file != null) {
                          setState(() {
                            selectedImage = file;
                          });
                        }
                      },
                      child: CircleAvatar(
                        radius: 30,
                        backgroundImage: selectedImage != null
                            ? FileImage(selectedImage!)
                            : const AssetImage('assets/images/person.png'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _groupNameController,
                        decoration: const InputDecoration(
                            hintText: 'Group Name',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 5,
                            ),
                            border: InputBorder.none),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _navigationService.goBack();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    if (_groupNameController.text.isNotEmpty) {
                      Navigator.of(context).pop();
                      _createGroup();
                    }
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _createGroup() async {
    setState(() {
      isCreatingGroup = true;
    });
    String groupId = _databaseService.generateUniqueGroupId();
    String? pfpUrl = await _storageService.uploadGroupPfp(
        file: selectedImage!, groupId: groupId);
    if (pfpUrl != null) {
      Group group = Group(
        gid: groupId,
        groupName: _groupNameController.text,
        pfpURL: pfpUrl,
        members: groupFriend,
        messages: [],
      );
      await _databaseService.setGroupDoc(group: group);
    }

    for (String uid in groupFriend) {
      _databaseService.updateUserProfile(uid: uid, newGid: groupId);
    }

    isCreatingGroup = false;
    _navigationService.goBack();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        forceMaterialTransparency: true,
        title: const Row(
          children: [
            CustomBackButton(),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Create Group',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 30,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
      body: isCreatingGroup
          ? const Center(
            child: CircularProgressIndicator(
                color: Color(0xFF0584FE),
                strokeWidth: 3,
              ),
          )
          : _buildUI(),
      floatingActionButton: isCreatingGroup ? null : 
          groupFriend.isNotEmpty ? _floatingActionButton() : null,
    );
  }

  Widget _buildUI() {
    return StreamBuilder(
      stream: _friendStreamController.stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: SizedBox(),
          );
        }
        final users = snapshot.data!.docs;
        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            UserModel user = users[index].data();
            if (user.uid == 'AIzaSyCR5VZ4MakKQ0ChoiGk22sWeaESNAqsTyo') {
              return const SizedBox.shrink();
            }
            return Stack(
              children: [
                ListTile(
                  onTap: () {
                    _onTap(user.uid!);
                  },
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                      user.pfpURL!,
                    ),
                  ),
                  title: Text(
                    user.username!,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                groupFriend.contains(user.uid)
                    ? Positioned(
                        left: 40,
                        bottom: 6,
                        child: Container(
                          decoration: const BoxDecoration(
                              color: Colors.white, shape: BoxShape.circle),
                          child: Icon(
                            Icons.check_circle_rounded,
                            color: Colors.green[400],
                            size: 15,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ],
            );
          },
        );
      },
    );
  }

  Widget _floatingActionButton() {
    return FloatingActionButton(
      onPressed: _showAlert,
      child: const Icon(
        Icons.done_rounded,
        size: 30,
      ),
    );
  }
}
