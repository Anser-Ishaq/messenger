import 'package:flutter/material.dart';
import 'package:messanger_ui/constans/routes.dart';
import 'package:messanger_ui/screens/changepassword_screen.dart';
import 'package:messanger_ui/screens/creategroup_screen.dart';
import 'package:messanger_ui/screens/dashboard_screen.dart';
import 'package:messanger_ui/screens/editprofile_screen.dart';
import 'package:messanger_ui/screens/forgotpassword_screen.dart';
import 'package:messanger_ui/screens/login_screen.dart';
import 'package:messanger_ui/screens/register_screen.dart';
import 'package:messanger_ui/screens/splash_screen.dart';

class NavigationService {

  late GlobalKey<NavigatorState> _navigatorKey;

  final Map<String, Widget Function(BuildContext)> _routes = {
    Routes.splash : (context) => const SplashScreen(),
    Routes.login : (context) => const LoginScreen(),
    Routes.register : (context) => const RegisterScreen(),
    Routes.home : (context) => const DashboardScreen(),
    Routes.forgotPassword : (context) => const ForgotPasswordScreen(),
    Routes.changePassword : (context) => const ChangePasswordScreen(),
    Routes.editProfile: (context) => const EditProfileScreen(),
    Routes.createGroup: (context) => const CreateGroupScreen(),
  };

  GlobalKey<NavigatorState>? get navigatorKey => _navigatorKey;
  Map<String, Widget Function(BuildContext)> get routes => _routes;

  NavigationService() {
    _navigatorKey = GlobalKey<NavigatorState>();
  }

  void push(MaterialPageRoute route) {
    _navigatorKey.currentState?.push(route);
  }

  void pushNamed(String routeName) {
    _navigatorKey.currentState?.pushNamed(routeName);
  }

  void pushReplacementNamed(String routeName) {
    _navigatorKey.currentState?.pushReplacementNamed(routeName);
  }

  void goBack() {
    _navigatorKey.currentState?.pop();
  }

}