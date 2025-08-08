import 'dart:async';
import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CompactAudioPlayerWidget extends StatefulWidget {
  final String fileUrl;
  final String mediaId;
  final Future<String?> Function(String, String) saveBase64ToFile;
  final bool isCompact;

  const CompactAudioPlayerWidget({
    super.key,
    required this.fileUrl,
    required this.mediaId,
    required this.saveBase64ToFile,
    this.isCompact = true,
  });

  @override
  State<CompactAudioPlayerWidget> createState() =>
      _CompactAudioPlayerWidgetState();
}

class _CompactAudioPlayerWidgetState extends State<CompactAudioPlayerWidget> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  String? _filePath;
  StreamSubscription<Duration>? _durationSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<void>? _playerCompleteSubscription;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _setupAudioPlayer();
    _prepareAudio();
  }

  void _setupAudioPlayer() {
    // Cancel existing subscriptions if any
    _cancelSubscriptions();

    // Setup new subscriptions with mounted checks
    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() => _duration = duration);
      }
    });

    _positionSubscription = _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() => _position = position);
      }
    });

    _playerStateSubscription = _audioPlayer.onPlayerStateChanged.listen((
      state,
    ) {
      if (mounted) {
        setState(() => _isPlaying = state == PlayerState.playing);
      }
    });

    _playerCompleteSubscription = _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
      }
    });
  }

  void _cancelSubscriptions() {
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
  }

  Future<void> _prepareAudio() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      if (widget.fileUrl.startsWith('data:')) {
        _filePath = await widget.saveBase64ToFile(
          widget.fileUrl,
          'temp_audio_${widget.mediaId}.m4a',
        );
      } else {
        _filePath = widget.fileUrl;
      }
    } catch (e) {
      log('Error preparing audio: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _playPause() async {
    if (_filePath == null || !mounted) return;

    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play(DeviceFileSource(_filePath!));
      }
    } catch (e) {
      log('Error playing/pausing audio: $e');
      if (mounted) {
        setState(() => _isPlaying = false);
      }
    }
  }

  @override
  void dispose() {
    _cancelSubscriptions();
    _audioPlayer.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.blue[200]!),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 8),
            Text('Loading audio...'),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(widget.isCompact ? 8.w : 12.w),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _playPause,
            child: Container(
              width: widget.isCompact ? 32.w : 40.w,
              height: widget.isCompact ? 32.h : 40.h,
              decoration: BoxDecoration(
                color: Colors.blue[600],
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: widget.isCompact ? 16.sp : 20.sp,
              ),
            ),
          ),

          SizedBox(width: 8.w),

          // Progress and duration
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.mic,
                      size: widget.isCompact ? 12.sp : 14.sp,
                      color: Colors.blue[600],
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Voice message',
                      style: TextStyle(
                        fontSize: widget.isCompact ? 10.sp : 12.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),

                if (widget.isCompact) ...[
                  SizedBox(height: 2.h),
                  Text(
                    _formatDuration(_duration),
                    style: TextStyle(fontSize: 10.sp, color: Colors.grey[600]),
                  ),
                ] else ...[
                  SizedBox(height: 4.h),
                  LinearProgressIndicator(
                    value: _duration.inSeconds > 0
                        ? _position.inSeconds / _duration.inSeconds
                        : 0.0,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.blue[600]!,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(_position),
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        _formatDuration(_duration),
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
