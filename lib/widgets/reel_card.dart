import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/reel.dart';

class ReelCard extends StatefulWidget {
  final Reel reel;
  final bool autoPlay;

  const ReelCard({
    super.key,
    required this.reel,
    this.autoPlay = false,
  });

  @override
  State<ReelCard> createState() => _ReelCardState();
}

class _ReelCardState extends State<ReelCard> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    print('Initializing video: ${widget.reel.videoUrl}');
    _controller = VideoPlayerController.network(widget.reel.videoUrl);
    try {
      await _controller.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
          if (widget.autoPlay) {
            _controller.play();
            _isPlaying = true;
          }
        });
        print('Video initialized successfully');
      }
    } catch (e) {
      print('Error initializing video: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading video: $e')),
        );
      }
    }
  }

  void _togglePlay() {
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
    setState(() {
      _isPlaying = _controller.value.isPlaying;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isInitialized ? _togglePlay : null,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (!_isInitialized)
              widget.reel.thumbnailUrl != null
                  ? Image.network(
                      widget.reel.thumbnailUrl!,
                      fit: BoxFit.cover,
                    )
                  : const Center(child: CircularProgressIndicator())
            else
              VideoPlayer(_controller),
            if (!_isPlaying)
              Center(
                child: Icon(
                  Icons.play_circle_outline,
                  size: 64,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.reel.caption != null)
                      Text(
                        widget.reel.caption!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.favorite,
                          color: Colors.red[400],
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.reel.likes}',
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        const Icon(
                          Icons.remove_red_eye,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.reel.views}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
