import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:messanger_ui/services/database_service.dart';
import 'package:story_view/story_view.dart';

import 'package:messanger_ui/models/story.dart';
import 'package:messanger_ui/models/usermodel.dart';

class StoryScreen extends StatefulWidget {
  final List<Story> stories;
  final UserModel currentUser;
  const StoryScreen({
    super.key,
    required this.stories,
    required this.currentUser,
  });

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  final GetIt _getIt = GetIt.instance;
  final StoryController _storyController = StoryController();

  late DatabaseService _databaseService;

  @override
  void initState() {
    super.initState();
    _databaseService = _getIt.get<DatabaseService>();
  }

  @override
  void dispose() {
    _storyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: StoryView(
          storyItems: widget.stories.map((story) {
            return StoryItem.pageVideo(
              story.storyURL!,
              controller: _storyController,
              caption: story.caption != null
                  ? Text(
                      story.caption!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white),
                    )
                  : null,
              duration: const Duration(seconds: 10),
            );
          }).toList(),
          controller: _storyController,
          onComplete: () {
            Navigator.pop(context);
          },
          onStoryShow: (storyItem, index) async {
            await _databaseService.updateStoryDoc(sid: widget.stories[index].sid!, uid: widget.currentUser.uid!);
          },
          onVerticalSwipeComplete: (details) {
            if (details == Direction.down) {
              Navigator.of(context).pop();
            }
          },
          indicatorColor: Colors.grey[400],
          indicatorForegroundColor: Colors.white70, // const Color(0xFF0584FE),
        ),
      ),
    );
  }
}
