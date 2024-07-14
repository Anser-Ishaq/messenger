import 'package:flutter/material.dart';
import 'package:messanger_ui/models/story.dart';
import 'package:story_view/story_view.dart';

class StoryScreen extends StatefulWidget {
  final List<Story> stories;
  const StoryScreen({
    required this.stories,
    super.key,
  });

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  final StoryController _storyController = StoryController();

  @override
  void initState() {
    super.initState();
  }

  // void _markStoriesAsPlayed() {
  //   for (var story in widget.stories) {
  //     // Update the story's `isPlayed` status in Firestore or wherever it's stored
  //     // For example, using your DatabaseService:
  //     // _databaseService.markStoryAsPlayed(story.sid);
  //   }
  // }

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
          onStoryShow: (storyItem, index) {},
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
