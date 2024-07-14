import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:messanger_ui/constans/routes.dart';
import 'package:messanger_ui/models/story.dart';
import 'package:messanger_ui/services/auth_service.dart';
import 'package:messanger_ui/services/database_service.dart';
import 'package:messanger_ui/services/navigation_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final GetIt _getIt = GetIt.instance;

  late AuthService _authService;
  late DatabaseService _databaseService;
  late NavigationService _navigationService;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _databaseService = _getIt.get<DatabaseService>();
    _navigationService = _getIt.get<NavigationService>();
    navigate();
  }

  Future<void> navigate() async {
    
    final result = await _databaseService.getCurrentUser();
    // await Future.delayed(const Duration(seconds: 3));
    List<Story> stories = await _databaseService.getUserStories();
    for (var story in stories) {
      await _databaseService.deleteStory(story.sid!);
    }
    if (result) {
      _navigationService.pushReplacementNamed(
          _authService.user != null ? Routes.home : Routes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF64B5F6),
      body: Center(
        child: Container(
          width: 960,
          height: 960,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/icons/messenger_icon.png'),
            ),
          ),
        ),
      ),
    );
  }
}
