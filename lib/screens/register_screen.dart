import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:messanger_ui/models/usermodel.dart';
import 'package:messanger_ui/services/alert_service.dart';
import 'package:messanger_ui/services/auth_service.dart';
import 'package:messanger_ui/services/database_service.dart';
import 'package:messanger_ui/services/media_service.dart';
import 'package:messanger_ui/services/navigation_service.dart';
import 'package:messanger_ui/services/storage_service.dart';
import 'package:messanger_ui/widgets/custom_button.dart';
import 'package:messanger_ui/widgets/custom_textformfield.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _signupFormKey = GlobalKey();
  final GetIt _getIt = GetIt.instance;

  String? name, email, password;
  bool obscureText = true;
  File? selectedImage;

  late AuthService _authService;
  late AlertService _alertService;
  late NavigationService _navigationService;
  late MediaService _mediaService;
  late StorageService _storageService;
  late DatabaseService _databaseService;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _alertService = _getIt.get<AlertService>();
    _navigationService = _getIt.get<NavigationService>();
    _mediaService = _getIt.get<MediaService>();
    _storageService = _getIt.get<StorageService>();
    _databaseService = _getIt.get<DatabaseService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _buildUI(),
      ),
    );
  }

  Widget _buildUI() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Let\'s go!',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            _signupForm(),
            _loginButton(),
          ],
        ),
      ),
    );
  }

  Widget _signupForm() {
    return Column(
      children: [
        _formUI(),
      ],
    );
  }

  Widget _formUI() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.all(8.0),
      child: Form(
        key: _signupFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _pfpSelectionField(),
            CustomTextformfield(
              height: MediaQuery.sizeOf(context).height * 0.1,
              label: 'Name',
              onSaved: (value) {
                name = value;
              },
            ),
            CustomTextformfield(
              height: MediaQuery.sizeOf(context).height * 0.1,
              label: 'Email',
              onSaved: (value) {
                email = value;
              },
            ),
            CustomTextformfield(
              height: MediaQuery.sizeOf(context).height * 0.1,
              label: 'Password',
              obscureText: obscureText,
              onSaved: (value) {
                password = value;
              },
              suffixIcon: Icon(
                obscureText
                    ? Icons.visibility_rounded
                    : Icons.visibility_off_rounded,
              ),
              onIconTap: () {
                setState(() {
                  obscureText = !obscureText;
                });
              },
            ),
            CustomButton(
              width: MediaQuery.sizeOf(context).width,
              height: MediaQuery.sizeOf(context).height * 0.05,
              onPressed: () async {
                if (_signupFormKey.currentState?.validate() ?? false) {
                  _signupFormKey.currentState?.save();
                  bool result = await _authService.signUp(email!, password!);
                  if (result) {
                    String? pfpUrl = await _storageService.uploadUserPfp(
                        file: selectedImage!, uid: _authService.user!.uid);
                    if (pfpUrl != null) {
                      await _databaseService.createUserModel(
                        userModel: UserModel(
                          uid: _authService.user!.uid,
                          username: name,
                          pfpURL: pfpUrl,
                          email: email,
                        ),
                      );
                      _alertService.showToast(
                        text: "User registered successfully!",
                        icon: Icons.check,
                      );
                      _navigationService.goBack();
                    } else {
                      _alertService.showToast(
                        text: "Unable to upload user profile picture",
                        icon: Icons.error,
                      );
                    }
                  } else {
                    _alertService.showToast(
                      text: "Failed to signup, Please try again!",
                      icon: Icons.error,
                    );
                  }
                }
              },
              buttonText: 'Sign Up',
            ),
          ],
        ),
      ),
    );
  }

  Widget _pfpSelectionField() {
    return GestureDetector(
      onTap: () async {
        File? file = await _mediaService.getImageFromGallery();
        if (file != null) {
          setState(() {
            selectedImage = file;
          });
        }
      },
      child: CircleAvatar(
        radius: MediaQuery.sizeOf(context).width * 0.15,
        backgroundImage: selectedImage != null
            ? FileImage(selectedImage!)
            : const AssetImage('assets/images/person.png'),
      ),
    );
  }

  Widget _loginButton() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      height: MediaQuery.sizeOf(context).height * 0.2,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          const Text(
            'Already have an account? ',
          ),
          GestureDetector(
            onTap: () {
              _navigationService.goBack();
            },
            child: const Text(
              'Login',
              style: TextStyle(
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
