import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:messanger_ui/services/database_service.dart';
import 'package:messanger_ui/services/media_service.dart';
import 'package:messanger_ui/services/updateprofile_service.dart';
import 'package:messanger_ui/widgets/custom_back_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _usernameController =
      TextEditingController(text: null);
  final GetIt _getIt = GetIt.instance;

  File? _selectedImage;
  bool isLoading = false;

  late DatabaseService _databaseService;
  late MediaService _mediaService;
  late UpdateprofileService _updateprofileService;

  @override
  void initState() {
    super.initState();
    _databaseService = _getIt.get<DatabaseService>();
    _mediaService = _getIt.get<MediaService>();
    _updateprofileService = _getIt.get<UpdateprofileService>();
    _usernameController.text = _databaseService.userModel.username!;
  }

  void _saveProfile() async {
    setState(() {
      isLoading = true;
    });
    // Implement save profile logic here using the updated username and profile image
    String newUsername = _usernameController.text;
    File? newPfp = _selectedImage;
    bool result = false;
    if (_selectedImage != null && _usernameController.text.isEmpty || _usernameController.text == '') {
      result = await _updateprofileService.updateProfile(
        newUsername: null,
        newPfp: newPfp,
      );
    } else if (_selectedImage == null && _usernameController.text.isNotEmpty) {
      result = await _updateprofileService.updateProfile(
        newUsername: newUsername,
        newPfp: null,
      );
    } else {
      result = await _updateprofileService.updateProfile(
        newUsername: newUsername,
        newPfp: newPfp,
      );
    }
    setState(() {
      if (result) {
        isLoading = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _appBar(),
        automaticallyImplyLeading: false,
        forceMaterialTransparency: true,
      ),
      body: SafeArea(
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: Colors.grey[350],
                  strokeWidth: 3,
                ),
              )
            : _buildUI(),
      ),
    );
  }

  Widget _appBar() {
    return const Row(
      children: [
        CustomBackButton(),
        SizedBox(
          width: 10,
        ),
        Expanded(
          child: Text(
            'Edit Profile',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
        ),
        SizedBox(width: 35),
      ],
    );
  }

  Widget _buildUI() {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _profileImageWidget(),
            const SizedBox(height: 20),
            _usernameField(),
            const SizedBox(height: 20),
            _actionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _profileImageWidget() {
    return Stack(
      children: [
        CircleAvatar(
          radius: MediaQuery.sizeOf(context).width * 0.3,
          backgroundImage: _selectedImage != null
              ? FileImage(_selectedImage!)
              : NetworkImage(_databaseService.userModel.pfpURL!),
        ),
        Positioned(
          bottom: 15,
          right: 15,
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0x8A000000),
            ),
            child: IconButton(
              padding: const EdgeInsets.all(0),
              icon: const Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
              ),
              onPressed: () async {
                File? file = await _mediaService.getImageFromGallery();
                if (file != null) {
                  setState(() {
                    _selectedImage = file;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _usernameField() {
    return TextField(
      controller: _usernameController,
      decoration: InputDecoration(
        label: const Text('Username'),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _actionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        MaterialButton(
          color: const Color(0xFF0584FE),
          onPressed: _saveProfile,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
          ),
          child: const Text(
            'Save',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        MaterialButton(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
              side: const BorderSide(
                color: Color(0xFF0584FE),
              )),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            'Cancel',
            style: TextStyle(
              color: Color(0xFF0584FE),
            ),
          ),
        ),
      ],
    );
  }
}
