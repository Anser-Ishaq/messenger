import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class StoryScreen extends StatefulWidget {
  const StoryScreen({super.key, required this.videoFile});

  final File videoFile;

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  late VideoPlayerController _videoPlayerController;
  bool _isVideoLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      _videoPlayerController = VideoPlayerController.file(widget.videoFile);

      await _videoPlayerController.initialize();
      setState(() {
        _isVideoLoading = false;
        _videoPlayerController.play();
      });

      _videoPlayerController.addListener(() {
        if (_videoPlayerController.value.position >=
            _videoPlayerController.value.duration) {
          Navigator.pop(context);
        }
      });
    } catch (error) {
      if (kDebugMode) {
        print("Error initializing video: $error");
      }
      setState(() {
        _isVideoLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => Column(
            children: [
              Stack(
                children: [
                  Container(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: _isVideoLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : _videoPlayerController.value.isInitialized
                              ? AspectRatio(
                                  aspectRatio: constraints.maxWidth /
                                      constraints.maxHeight,
                                  child: VideoPlayer(_videoPlayerController),
                                )
                              : const SizedBox(),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    right: 10,
                    child: VideoProgressIndicator(
                      _videoPlayerController,
                      allowScrubbing: true,
                      colors: const VideoProgressColors(
                        playedColor: Colors.white,
                        bufferedColor: Colors.transparent,
                        // backgroundColor: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
