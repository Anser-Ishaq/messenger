import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:messanger_ui/constans/routes.dart';
import 'package:messanger_ui/services/auth_service.dart';
import 'package:messanger_ui/services/database_service.dart';
import 'package:messanger_ui/services/navigation_service.dart';
import 'package:messanger_ui/widgets/custom_divider.dart';
import 'package:messanger_ui/widgets/custom_profile_view.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GetIt _getIt = GetIt.instance;

  late AuthService _authService;
  late NavigationService _navigationService;
  late DatabaseService _databaseService;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    _databaseService = _getIt.get<DatabaseService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 70),
                  child: CustomProfileView(
                    src: _databaseService.userModel.pfpURL!,
                    name: _databaseService.userModel.username!,
                  ),
                ),
                _actionButton(title: 'Edit Profile', onTap: () {
                  _navigationService.pushNamed(Routes.editProfile);
                }),
                const CustomDivider(),
                _actionButton(
                  title: 'Change Password',
                  onTap: () {
                    _navigationService.pushNamed(Routes.changePassword);
                  },
                ),
                const CustomDivider(),
                _actionButton(
                  title: 'Log Out',
                  onTap: () async {
                    await _authService.logout();
                    _navigationService.pushReplacementNamed(Routes.login);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _actionButton({required String title, required VoidCallback onTap}) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(12),
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.41,
            height: 20.29 / 12,
          ),
        ),
      ),
    );
  }
}
