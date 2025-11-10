import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();

    // Controlador del video
    _videoController =
        VideoPlayerController.asset("assets/animation/ecogrid.mp4")
          ..initialize().then((_) {
            _videoController.play();
            _videoController.setLooping(false); // No repetir
            setState(() {});
          });

    // Ir a la siguiente pantalla cuando el video termine
    _videoController.addListener(() {
      if (_videoController.value.position >= _videoController.value.duration) {
        if (mounted) context.go('/');
      }
    });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: _videoController.value.isInitialized
            ? FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoController.value.size.width,
                  height: _videoController.value.size.height,
                  child: VideoPlayer(_videoController),
                ),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
