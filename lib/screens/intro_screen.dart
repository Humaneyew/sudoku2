import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  late final VideoPlayerController _controller;
  Timer? _navigationTimer;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/videos/intro.mp4')
      ..setLooping(false);
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    await _controller.initialize();
    if (!mounted) {
      return;
    }
    setState(() {});
    await _controller.play();
    _navigationTimer = Timer(const Duration(seconds: 5), _navigateToHome);
  }

  void _navigateToHome() {
    if (!mounted || _navigated) {
      return;
    }
    _navigated = true;
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _controller.value.isInitialized
            ? SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                ),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
