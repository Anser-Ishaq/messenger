import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:messanger_ui/constans/routes.dart';
import 'package:messanger_ui/services/alert_service.dart';
import 'package:messanger_ui/services/auth_service.dart';
import 'package:messanger_ui/services/database_service.dart';
import 'package:messanger_ui/services/navigation_service.dart';
import 'package:messanger_ui/widgets/custom_button.dart';
import 'package:messanger_ui/widgets/custom_textformfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _loginFormKey = GlobalKey();
  final GetIt _getIt = GetIt.instance;

  String? email, password;
  bool obscureText = true;

  late AuthService _authService;
  late AlertService _alertService;
  late NavigationService _navigationService;
  late DatabaseService _databaseService;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _alertService = _getIt.get<AlertService>();
    _navigationService = _getIt.get<NavigationService>();
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hello, Welcome back!',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            _loginForm(),
            _signupButton(),
          ],
        ),
      ),
    );
  }

  Widget _loginForm() {
    return Column(
      children: [
        _formUI(),
      ],
    );
  }

  Widget _formUI() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      padding: const EdgeInsets.all(8.0),
      child: Form(
        key: _loginFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
            GestureDetector(
              onTap: () {
                _navigationService.pushNamed(Routes.forgotPassword);
              },
              child: const Text(
                'Forgot Password?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            CustomButton(
              width: MediaQuery.sizeOf(context).width,
              height: MediaQuery.sizeOf(context).height * 0.05,
              onPressed: () async {
                if (_loginFormKey.currentState?.validate() ?? false) {
                  _loginFormKey.currentState?.save();
                  bool result = await _authService.login(email!, password!);
                  if (result) {
                    await _databaseService.getCurrentUser();
                    _navigationService.pushNamed(Routes.home);
                  } else {
                    _alertService.showToast(
                      text: "Failed to login, Please try again!",
                      icon: Icons.error,
                    );
                  }
                }
              },
              buttonText: 'Login',
            ),
          ],
        ),
      ),
    );
  }

  Widget _signupButton() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      height: MediaQuery.sizeOf(context).height * 0.3,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          const Text(
            'Don\'t have an account? ',
          ),
          GestureDetector(
            onTap: () {
              _navigationService.pushNamed(Routes.register);
            },
            child: const Text(
              'Sign up',
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
