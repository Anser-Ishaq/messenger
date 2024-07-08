import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:messanger_ui/services/alert_service.dart';
import 'package:messanger_ui/services/auth_service.dart';
import 'package:messanger_ui/services/navigation_service.dart';
import 'package:messanger_ui/widgets/custom_button.dart';
import 'package:messanger_ui/widgets/custom_textformfield.dart';


class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  
  final GlobalKey<FormState> _forgotPasswordFormKey = GlobalKey();
  final GetIt _getIt = GetIt.instance;

  late AuthService _authService;
  late AlertService _alertService;
  late NavigationService _navigationService;

  String? email;

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
      appBar: AppBar(
        title: const Text('Forgot Password'),
      ),
      body: SafeArea(
        child: _buildUI(),
      ),
    );
  }

  Widget _buildUI() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Forgot your password?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Please enter your email address. We will send you a link to reset your password.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          _forgotPasswordForm(),
        ],
      ),
    );
  }

  Widget _forgotPasswordForm() {
    return Form(
      key: _forgotPasswordFormKey,
      child: Column(
        children: [
          CustomTextformfield(
            height: MediaQuery.sizeOf(context).height * 0.1,
            label: 'Email',
            onSaved: (value) {
              email = value;
            },
          ),
          const SizedBox(height: 20),
          CustomButton(
            width: MediaQuery.of(context).size.width,
            height: 50,
            onPressed: () async {
              if (_forgotPasswordFormKey.currentState!.validate()) {
                _forgotPasswordFormKey.currentState!.save();
                await _authService.forgotPassword(email!);
                _alertService.showToast(
                  text: 'Password reset email sent!',
                  icon: Icons.email,
                );
                _navigationService.goBack();
              }
            },
            buttonText: 'Send Reset Link',
          ),
        ],
      ),
    );
  }
}
