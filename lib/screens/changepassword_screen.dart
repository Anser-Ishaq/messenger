import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:messanger_ui/services/auth_service.dart';
import 'package:messanger_ui/services/alert_service.dart';
import 'package:messanger_ui/services/navigation_service.dart';
import 'package:messanger_ui/widgets/custom_button.dart';
import 'package:messanger_ui/widgets/custom_textformfield.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final GetIt _getIt = GetIt.instance;

  String? oldPassword, newPassword;
  bool obscureText1 = true;
  bool obscureText2 = true;

  late AuthService _authService;
  late AlertService _alertService;
  late NavigationService _navigationService;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _alertService = _getIt.get<AlertService>();
    _navigationService = _getIt.get<NavigationService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change Password')),
      body: SafeArea(
        child: _buildUI(),
      ),
    );
  }

  Widget _buildUI() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            CustomTextformfield(
              height: MediaQuery.sizeOf(context).height * 0.1,
              label: 'Old Password',
              obscureText: obscureText1,
              onSaved: (value) {
                oldPassword = value;
              },
              suffixIcon: Icon(
                obscureText1
                    ? Icons.visibility_rounded
                    : Icons.visibility_off_rounded,
              ),
              onIconTap: () {
                setState(() {
                  obscureText1 = !obscureText1;
                });
              },
            ),
            CustomTextformfield(
              height: MediaQuery.sizeOf(context).height * 0.1,
              label: 'New Password',
              obscureText: obscureText2,
              onSaved: (value) {
                newPassword = value;
              },
              suffixIcon: Icon(
                obscureText2
                    ? Icons.visibility_rounded
                    : Icons.visibility_off_rounded,
              ),
              onIconTap: () {
                setState(() {
                  obscureText2 = !obscureText2;
                });
              },
            ),
            CustomButton(
              width: MediaQuery.sizeOf(context).width,
              height: MediaQuery.sizeOf(context).height * 0.05,
              onPressed: () async {
                if (_formKey.currentState?.validate() ?? false) {
                  _formKey.currentState?.save();
                  bool result = await _authService.changePassword(
                      oldPassword!, newPassword!);
                  if (result) {
                    _alertService.showToast(
                      text: "Password changed successfully",
                      icon: Icons.check,
                    );
                    _navigationService.goBack();
                  } else {
                    _alertService.showToast(
                      text: "Failed to change password, Please try again!",
                      icon: Icons.error,
                    );
                  }
                }
              },
              buttonText: 'Change Password',
            ),
          ],
        ),
      ),
    );
  }
}
