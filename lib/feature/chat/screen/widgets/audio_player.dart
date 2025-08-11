import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';

/// Enhanced Audio Cache with better lifecycle management
class AudioCache {
  static final Map<String, String> _audioPathCache = {};
  static final Map<String, AudioPlayer> _playerCache = {};
  static final Map<String, Duration> _durationCache = {};
  static final Set<String> _processingFiles = {};
  static final Map<String, String> _errorCache = {};
  static final Map<String, double> _speedCache = {};
  static final Map<String, bool> _readyStateCache =
      {}; // NEW: Track ready state

  static String? getAudioPath(String mediaId) => _audioPathCache[mediaId];
  static void setAudioPath(String mediaId, String path) =>
      _audioPathCache[mediaId] = path;

  static AudioPlayer? getPlayer(String mediaId) => _playerCache[mediaId];
  static void setPlayer(String mediaId, AudioPlayer player) =>
      _playerCache[mediaId] = player;

  static Duration? getDuration(String mediaId) => _durationCache[mediaId];
  static void setDuration(String mediaId, Duration duration) =>
      _durationCache[mediaId] = duration;

  static double getSpeed(String mediaId) => _speedCache[mediaId] ?? 1.0;
  static void setSpeed(String mediaId, double speed) =>
      _speedCache[mediaId] = speed;

  static bool isProcessing(String mediaId) =>
      _processingFiles.contains(mediaId);
  static void setProcessing(String mediaId) => _processingFiles.add(mediaId);
  static void clearProcessing(String mediaId) =>
      _processingFiles.remove(mediaId);

  static String? getError(String mediaId) => _errorCache[mediaId];
  static void setError(String mediaId, String error) =>
      _errorCache[mediaId] = error;
  static void clearError(String mediaId) => _errorCache.remove(mediaId);

  // NEW: Ready state management
  static bool isReady(String mediaId) => _readyStateCache[mediaId] ?? false;
  static void setReady(String mediaId, bool ready) =>
      _readyStateCache[mediaId] = ready;

  static void disposePlayer(String mediaId) {
    _playerCache[mediaId]?.dispose();
    _playerCache.remove(mediaId);
    _processingFiles.remove(mediaId);
    _errorCache.remove(mediaId);
    _speedCache.remove(mediaId);
    _readyStateCache.remove(mediaId); // NEW
  }

  static void clearAll() {
    for (var player in _playerCache.values) {
      player.dispose();
    }
    _playerCache.clear();
    _audioPathCache.clear();
    _durationCache.clear();
    _processingFiles.clear();
    _errorCache.clear();
    _speedCache.clear();
    _readyStateCache.clear(); // NEW
  }
}

/// WhatsApp-style Audio Preview Widget
class InstantAudioPreview extends StatelessWidget {
  final String fileUrl;
  final String mediaId;
  final bool isInChatBubble;
  final bool isSent;
  final double? maxWidth;
  final double? maxHeight;

  const InstantAudioPreview({
    super.key,
    required this.fileUrl,
    required this.mediaId,
    required this.isInChatBubble,
    this.isSent = false,
    this.maxWidth,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: maxWidth ?? (isInChatBubble ? 300.w : 340.w),
      constraints: BoxConstraints(
        maxHeight: maxHeight ?? (isInChatBubble ? 70.h : 90.h),
      ),
      child: _WhatsAppAudioPlayer(
        fileUrl: fileUrl,
        mediaId: mediaId,
        isCompact: isInChatBubble,
        isSent: isSent,
      ),
    );
  }
}

/// WhatsApp-style audio player with speed control and seekable waveform
class _WhatsAppAudioPlayer extends StatefulWidget {
  final String fileUrl;
  final String mediaId;
  final bool isCompact;
  final bool isSent;

  const _WhatsAppAudioPlayer({
    required this.fileUrl,
    required this.mediaId,
    this.isCompact = true,
    this.isSent = false,
  });

  @override
  State<_WhatsAppAudioPlayer> createState() => _WhatsAppAudioPlayerState();
}

class _WhatsAppAudioPlayerState extends State<_WhatsAppAudioPlayer>
    with TickerProviderStateMixin {
  AudioPlayer? _audioPlayer;
  bool _isPlaying = false;
  bool _isReady = false;
  bool _isLoading = true;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  String? _filePath;
  String? _errorMessage;
  double _playbackSpeed = 1.0;
  bool _isDragging = false;

  late AnimationController _playButtonController;
  late AnimationController _waveAnimationController;
  late AnimationController _speedButtonController;
  late Animation<double> _playButtonScale;
  late Animation<double> _speedButtonScale;

  @override
  void initState() {
    super.initState();
    AudioCache.clearError(widget.mediaId);
    AudioCache.setReady(widget.mediaId, false);
    AudioCache.disposePlayer(widget.mediaId);
    _initializeAnimations();
    _initializeAudioOnce();
  }

  void _initializeAnimations() {
    _playButtonController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _waveAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _speedButtonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _playButtonScale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _playButtonController, curve: Curves.easeInOut),
    );

    _speedButtonScale = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _speedButtonController, curve: Curves.easeInOut),
    );
  }

  /// FIXED: Improved initialization with better state management
  Future<void> _initializeAudioOnce() async {
    debugPrint(
      'Audio ${widget.mediaId}: Starting initialization with URL: ${widget.fileUrl}',
    );

    // Clear any existing error for this media
    AudioCache.clearError(widget.mediaId);

    // Restore cached speed
    _playbackSpeed = AudioCache.getSpeed(widget.mediaId);

    // Check if already ready
    if (AudioCache.isReady(widget.mediaId)) {
      final cachedPath = AudioCache.getAudioPath(widget.mediaId);
      final cachedPlayer = AudioCache.getPlayer(widget.mediaId);

      if (cachedPath != null && cachedPlayer != null) {
        debugPrint('Audio ${widget.mediaId}: Using cached ready state');
        _filePath = cachedPath;
        _audioPlayer = cachedPlayer;
        _duration = AudioCache.getDuration(widget.mediaId) ?? Duration.zero;
        _setupPlayerListeners();
        setState(() {
          _isReady = true;
          _isLoading = false;
        });
        return;
      }
    }

    // Check for cached error
    final cachedError = AudioCache.getError(widget.mediaId);
    if (cachedError != null) {
      setState(() {
        _errorMessage = cachedError;
        _isLoading = false;
      });
      return;
    }

    // Prevent multiple simultaneous processing
    if (AudioCache.isProcessing(widget.mediaId)) {
      debugPrint('Audio ${widget.mediaId}: Already processing, waiting...');
      await _waitForProcessing();
      return;
    }

    AudioCache.setProcessing(widget.mediaId);
    await _processAudioFile();
  }

  /// FIXED: Better waiting mechanism with timeout
  Future<void> _waitForProcessing() async {
    int attempts = 0;
    const maxAttempts = 50; // Increased timeout

    while (AudioCache.isProcessing(widget.mediaId) && attempts < maxAttempts) {
      await Future.delayed(
        const Duration(milliseconds: 100),
      ); // Shorter intervals
      attempts++;

      // Check if processing completed
      if (AudioCache.isReady(widget.mediaId) ||
          AudioCache.getError(widget.mediaId) != null) {
        break;
      }
    }

    if (!mounted) return;

    final cachedError = AudioCache.getError(widget.mediaId);
    if (cachedError != null) {
      setState(() {
        _errorMessage = cachedError;
        _isLoading = false;
      });
      return;
    }

    if (AudioCache.isReady(widget.mediaId)) {
      final cachedPath = AudioCache.getAudioPath(widget.mediaId);
      final cachedPlayer = AudioCache.getPlayer(widget.mediaId);

      if (cachedPath != null && cachedPlayer != null) {
        _filePath = cachedPath;
        _audioPlayer = cachedPlayer;
        _duration = AudioCache.getDuration(widget.mediaId) ?? Duration.zero;
        _setupPlayerListeners();
        setState(() {
          _isReady = true;
          _isLoading = false;
        });
        return;
      }
    }

    // If we reach here, something went wrong
    setState(() {
      _errorMessage = 'Failed to load audio';
      _isLoading = false;
    });
  }

  /// FIXED: Enhanced file processing with better error handling
  Future<void> _processAudioFile() async {
    try {
      debugPrint('Audio ${widget.mediaId}: Processing file...');

      // Handle different URL types
      if (widget.fileUrl.startsWith('data:')) {
        debugPrint('Audio ${widget.mediaId}: Processing base64 data');
        _filePath = await _AudioFileUtils.saveBase64Audio(
          widget.fileUrl,
          'audio_${widget.mediaId}',
        );

        if (_filePath == null) {
          throw Exception('Failed to decode base64 audio data');
        }
      } else if (_isNetworkUrl(widget.fileUrl)) {
        debugPrint('Audio ${widget.mediaId}: Using network URL');
        _filePath = widget.fileUrl;
      } else if (widget.fileUrl.startsWith('file://')) {
        debugPrint('Audio ${widget.mediaId}: Using file URL');
        _filePath = widget.fileUrl.replaceFirst('file://', '');
      } else if (widget.fileUrl.startsWith('/')) {
        debugPrint('Audio ${widget.mediaId}: Using absolute file path');
        _filePath = widget.fileUrl;
      } else {
        debugPrint('Audio ${widget.mediaId}: Treating as relative file path');
        _filePath = widget.fileUrl;
      }

      if (_filePath != null) {
        // Verify file exists (for local files)
        if (!_isNetworkUrl(_filePath!)) {
          final file = File(_filePath!);
          if (!await file.exists()) {
            throw Exception('Audio file not found: $_filePath');
          }

          // Check file size
          final fileSize = await file.length();
          if (fileSize == 0) {
            throw Exception('Audio file is empty: $_filePath');
          }

          debugPrint(
            'Audio ${widget.mediaId}: File verified - size: $fileSize bytes',
          );
        }

        debugPrint('Audio ${widget.mediaId}: File path resolved: $_filePath');
        AudioCache.setAudioPath(widget.mediaId, _filePath!);
        await _createNewPlayer();

        // Mark as ready
        AudioCache.setReady(widget.mediaId, true);

        if (mounted) {
          setState(() {
            _isReady = true;
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to resolve audio file path');
      }
    } catch (e) {
      final errorMsg = 'Audio error: ${e.toString()}';
      debugPrint('Audio ${widget.mediaId}: $errorMsg');
      AudioCache.setError(widget.mediaId, errorMsg);

      if (mounted) {
        setState(() {
          _errorMessage = 'Cannot load audio';
          _isLoading = false;
        });
      }
    } finally {
      AudioCache.clearProcessing(widget.mediaId);
    }
  }

  bool _isNetworkUrl(String url) {
    return url.startsWith('http://') || url.startsWith('https://');
  }

  /// FIXED: Enhanced player creation with validation
  Future<void> _createNewPlayer() async {
    try {
      _audioPlayer = AudioPlayer();
      AudioCache.setPlayer(widget.mediaId, _audioPlayer!);
      _setupPlayerListeners();

      // NEW: Preload the audio source to get duration immediately
      if (_filePath != null) {
        await _preloadAudioSource();
      }

      debugPrint('Audio ${widget.mediaId}: Player created and preloaded');
    } catch (e) {
      debugPrint('Audio ${widget.mediaId}: Player creation error: $e');
      throw Exception('Failed to create audio player: $e');
    }
  }

  /// NEW: Preload audio source to get duration and validate file
  Future<void> _preloadAudioSource() async {
    if (_audioPlayer == null || _filePath == null) return;

    try {
      // Set the source without playing
      if (_isNetworkUrl(_filePath!)) {
        await _audioPlayer!.setSource(UrlSource(_filePath!));
      } else {
        await _audioPlayer!.setSource(DeviceFileSource(_filePath!));
      }

      debugPrint('Audio ${widget.mediaId}: Source preloaded successfully');
    } catch (e) {
      debugPrint('Audio ${widget.mediaId}: Preload error: $e');
      throw Exception('Failed to preload audio: $e');
    }
  }

  /// Setup player listeners
  void _setupPlayerListeners() {
    if (_audioPlayer == null) return;

    _audioPlayer!.onDurationChanged.listen((duration) {
      if (mounted && duration.inMilliseconds > 0) {
        AudioCache.setDuration(widget.mediaId, duration);
        setState(() => _duration = duration);
        debugPrint(
          'Audio ${widget.mediaId}: Duration updated: ${duration.inSeconds}s',
        );
      }
    });

    _audioPlayer!.onPositionChanged.listen((position) {
      if (mounted && !_isDragging) {
        setState(() => _position = position);
      }
    });

    _audioPlayer!.onPlayerStateChanged.listen((state) {
      if (mounted) {
        final wasPlaying = _isPlaying;
        setState(() => _isPlaying = state == PlayerState.playing);

        if (state == PlayerState.completed) {
          setState(() => _position = Duration.zero);
          _waveAnimationController.stop();
          _waveAnimationController.reset();
        }

        // Start/stop wave animation
        if (_isPlaying && !wasPlaying) {
          _waveAnimationController.repeat();
        } else if (!_isPlaying && wasPlaying) {
          _waveAnimationController.stop();
        }

        if (wasPlaying != _isPlaying) {
          debugPrint('Audio ${widget.mediaId}: State changed to $state');
        }
      }
    });
  }

  /// FIXED: Enhanced play/pause with better error handling
  Future<void> _togglePlayPause() async {
    if (_audioPlayer == null || _filePath == null) {
      debugPrint('Audio ${widget.mediaId}: Player or file path not ready');
      return;
    }

    // Button press animation
    _playButtonController.forward().then((_) {
      _playButtonController.reverse();
    });

    try {
      if (_isPlaying) {
        await _audioPlayer!.pause();
        debugPrint('Audio ${widget.mediaId}: Paused');
      } else {
        // Set playback speed before playing
        await _audioPlayer!.setPlaybackRate(_playbackSpeed);

        // Play the audio
        await _audioPlayer!.resume();

        debugPrint(
          'Audio ${widget.mediaId}: Started playing at ${_playbackSpeed}x speed',
        );
      }
    } catch (e) {
      debugPrint('Audio ${widget.mediaId}: Playback error: $e');
      if (mounted) {
        setState(() => _errorMessage = 'Playback failed');
      }
    }
  }

  /// Change playback speed (1x -> 1.5x -> 2x -> 1x)
  Future<void> _toggleSpeed() async {
    if (_audioPlayer == null) return;

    _speedButtonController.forward().then((_) {
      _speedButtonController.reverse();
    });

    setState(() {
      if (_playbackSpeed == 1.0) {
        _playbackSpeed = 1.5;
      } else if (_playbackSpeed == 1.5) {
        _playbackSpeed = 2.0;
      } else {
        _playbackSpeed = 1.0;
      }
    });

    // Cache the speed
    AudioCache.setSpeed(widget.mediaId, _playbackSpeed);

    // Apply speed if currently playing
    if (_isPlaying) {
      try {
        await _audioPlayer!.setPlaybackRate(_playbackSpeed);
        debugPrint(
          'Audio ${widget.mediaId}: Speed changed to ${_playbackSpeed}x',
        );
      } catch (e) {
        debugPrint('Audio ${widget.mediaId}: Speed change error: $e');
      }
    }
  }

  /// Seek to specific position in audio
  Future<void> _seekToPosition(double progress) async {
    if (_audioPlayer == null || _duration.inMilliseconds == 0) return;

    final newPosition = Duration(
      milliseconds: (_duration.inMilliseconds * progress).round(),
    );

    try {
      await _audioPlayer!.seek(newPosition);
      setState(() => _position = newPosition);
      debugPrint(
        'Audio ${widget.mediaId}: Seeked to ${newPosition.inSeconds}s',
      );
    } catch (e) {
      debugPrint('Audio ${widget.mediaId}: Seek error: $e');
    }
  }

  @override
  void dispose() {
    _playButtonController.dispose();
    _waveAnimationController.dispose();
    _speedButtonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _WhatsAppAudioShimmer(
        isCompact: widget.isCompact,
        isSent: widget.isSent,
      );
    }

    if (_errorMessage != null) {
      return _WhatsAppAudioError(
        message: _errorMessage!,
        isCompact: widget.isCompact,
        isSent: widget.isSent,
        onRetry: () {
          // FIXED: Better retry mechanism
          AudioCache.clearError(widget.mediaId);
          AudioCache.setReady(widget.mediaId, false);
          AudioCache.disposePlayer(widget.mediaId);

          setState(() {
            _errorMessage = null;
            _isLoading = true;
            _isReady = false;
          });

          _initializeAudioOnce();
        },
      );
    }

    return _buildWhatsAppAudioWidget();
  }

  Widget _buildWhatsAppAudioWidget() {
    final primaryColor = widget.isSent ? Colors.white : Colors.green[600]!;
    final backgroundColor = widget.isSent ? Colors.green[100] : Colors.white;
    final textColor = widget.isSent ? Colors.green[700]! : Colors.black87;

    return Container(
      height: 90,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 0.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          // Main audio controls row
          Row(
            children: [
              // Play/Pause button
              AnimatedBuilder(
                animation: _playButtonScale,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _playButtonScale.value,
                    child: GestureDetector(
                      onTap: _togglePlayPause,
                      child: Container(
                        width: 36.w,
                        height: 36.h,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          color: widget.isSent
                              ? Colors.green[600]
                              : Colors.white,
                          size: 20.sp,
                        ),
                      ),
                    ),
                  );
                },
              ),

              SizedBox(width: 12.w),

              // Waveform and controls
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    10.verticalSpace,
                    // Interactive waveform
                    GestureDetector(
                      onTapDown: (details) {
                        setState(() => _isDragging = true);
                        final progress =
                            details.localPosition.dx / (300.w - 56.w);
                        _seekToPosition(progress.clamp(0.0, 1.0));
                      },
                      onPanUpdate: (details) {
                        final progress =
                            details.localPosition.dx / (300.w - 56.w);
                        _seekToPosition(progress.clamp(0.0, 1.0));
                      },
                      onPanEnd: (details) {
                        setState(() => _isDragging = false);
                      },
                      child: _buildInteractiveWaveform(),
                    ),

                    SizedBox(height: 6.h),

                    // Duration, speed, and status row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Duration display
                        Text(
                          _isPlaying || _position.inMilliseconds > 0
                              ? '${_formatDuration(_position)} / ${_formatDuration(_duration)}'
                              : _formatDuration(_duration),
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: textColor.withOpacity(0.7),
                            fontWeight: FontWeight.w400,
                          ),
                        ),

                        // Speed control and status
                        Row(
                          children: [
                            if (_isPlaying) ...[
                              Icon(
                                Icons.keyboard_voice,
                                size: 12.sp,
                                color: Colors.green[600],
                              ),
                              SizedBox(width: 8.w),
                            ],

                            // Speed button
                            AnimatedBuilder(
                              animation: _speedButtonScale,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _speedButtonScale.value,
                                  child: GestureDetector(
                                    onTap: _toggleSpeed,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 6.w,
                                        vertical: 2.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _playbackSpeed != 1.0
                                            ? Colors.green[600]
                                            : Colors.grey[300],
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
                                      ),
                                      child: Text(
                                        '${_playbackSpeed.toString().replaceAll('.0', '')}x',
                                        style: TextStyle(
                                          fontSize: 10.sp,
                                          color: _playbackSpeed != 1.0
                                              ? Colors.white
                                              : Colors.grey[600],
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveWaveform() {
    return SizedBox(
      height: 30.h,
      child: Row(
        children: List.generate(25, (index) {
          return Expanded(child: _buildInteractiveWaveformBar(index));
        }),
      ),
    );
  }

  Widget _buildInteractiveWaveformBar(int index) {
    // Create realistic waveform heights
    final heights = [
      0.3,
      0.8,
      0.6,
      1.0,
      0.4,
      0.9,
      0.7,
      0.5,
      0.8,
      0.6,
      0.4,
      0.7,
      0.9,
      0.3,
      0.6,
      0.8,
      0.5,
      0.7,
      0.4,
      0.6,
      0.8,
      0.5,
      0.9,
      0.3,
      0.7,
    ];

    final progress = _duration.inMilliseconds > 0
        ? _position.inMilliseconds / _duration.inMilliseconds
        : 0.0;

    final barProgress = index / 25;
    final isPlayed = barProgress <= progress;
    final isActive =
        _isPlaying &&
        (barProgress - 0.04) <= progress &&
        progress <= (barProgress + 0.04);

    return AnimatedBuilder(
      animation: _waveAnimationController,
      builder: (context, child) {
        final baseHeight = heights[index];
        final animatedHeight = isActive && _isPlaying
            ? baseHeight * (0.7 + 0.6 * _waveAnimationController.value)
            : baseHeight;

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 0.5.w),
          child: Align(
            alignment: Alignment.center,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: 2.5.w,
              height: (animatedHeight * 24.h).clamp(3.h, 24.h),
              decoration: BoxDecoration(
                color: isPlayed
                    ? Colors.green[600]
                    : (widget.isSent ? Colors.green[300] : Colors.grey[400]),
                borderRadius: BorderRadius.circular(1.5.r),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

/// WhatsApp-style loading shimmer
class _WhatsAppAudioShimmer extends StatelessWidget {
  final bool isCompact;
  final bool isSent;

  const _WhatsAppAudioShimmer({required this.isCompact, required this.isSent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isCompact ? 300.w : 340.w,
      height: isCompact ? 70.h : 90.h,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isSent ? Colors.green[100] : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Shimmer play button
              Container(
                width: 36.w,
                height: 36.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Shimmer waveform
                    Row(
                      children: List.generate(25, (index) {
                        return Container(
                          width: 2.5.w,
                          height: (8 + (index % 4) * 4).h,
                          margin: EdgeInsets.symmetric(horizontal: 0.5.w),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(1.5.r),
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: 6.h),
                    // Shimmer controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 60.w,
                          height: 10.h,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(5.r),
                          ),
                        ),
                        Container(
                          width: 24.w,
                          height: 16.h,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// WhatsApp-style error widget
class _WhatsAppAudioError extends StatelessWidget {
  final String message;
  final bool isCompact;
  final bool isSent;
  final VoidCallback? onRetry;

  const _WhatsAppAudioError({
    required this.message,
    required this.isCompact,
    required this.isSent,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isCompact ? 300.w : 340.w,
      height: isCompact ? 70.h : 90.h,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isSent ? Colors.green[100] : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: InkWell(
        onTap: onRetry,
        borderRadius: BorderRadius.circular(12.r),
        child: Row(
          children: [
            Container(
              width: 36.w,
              height: 36.h,
              decoration: BoxDecoration(
                color: Colors.red[100],
                shape: BoxShape.circle,
                border: Border.all(color: Colors.red[300]!),
              ),
              child: Icon(
                Icons.error_outline,
                color: Colors.red[600],
                size: 20.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Voice message failed',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.red[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Tap to retry',
                    style: TextStyle(fontSize: 10.sp, color: Colors.red[500]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ENHANCED: Optimized audio file utilities with better caching
class _AudioFileUtils {
  static final Map<String, String> _audioPathCache = {};
  static final Map<String, DateTime> _fileCacheTime = {};
  static const Duration _cacheExpiration = Duration(hours: 24);

  static Future<String?> saveBase64Audio(
    String base64Data,
    String baseFileName,
  ) async {
    try {
      String cleanBase64 = base64Data;
      String extension = '.m4a';

      if (base64Data.contains(',')) {
        final parts = base64Data.split(',');
        final header = parts.first;
        cleanBase64 = parts.last;

        if (header.contains('audio/mp3') || header.contains('audio/mpeg')) {
          extension = '.mp3';
        } else if (header.contains('audio/wav')) {
          extension = '.wav';
        } else if (header.contains('audio/ogg')) {
          extension = '.ogg';
        } else if (header.contains('audio/m4a') ||
            header.contains('audio/mp4')) {
          extension = '.m4a';
        }
      }

      final fileName = '$baseFileName$extension';

      // Check cache with expiration
      if (_audioPathCache.containsKey(fileName)) {
        final cachedPath = _audioPathCache[fileName]!;
        final cacheTime = _fileCacheTime[fileName];

        if (cacheTime != null &&
            DateTime.now().difference(cacheTime) < _cacheExpiration &&
            await File(cachedPath).exists()) {
          debugPrint('Audio file cache hit: $fileName');
          return cachedPath;
        } else {
          // Remove expired cache
          _audioPathCache.remove(fileName);
          _fileCacheTime.remove(fileName);
        }
      }

      final bytes = base64Decode(cleanBase64);
      if (bytes.isEmpty) {
        throw Exception('Empty audio data after base64 decode');
      }

      // Use application documents directory for persistence
      final directory = await getApplicationDocumentsDirectory();
      final audioDir = Directory('${directory.path}/audio_cache');

      // Create directory if it doesn't exist
      if (!await audioDir.exists()) {
        await audioDir.create(recursive: true);
      }

      final file = File('${audioDir.path}/$fileName');
      await file.writeAsBytes(bytes);

      if (!await file.exists()) {
        throw Exception('Failed to write audio file');
      }

      // Verify file integrity
      final writtenBytes = await file.readAsBytes();
      if (writtenBytes.length != bytes.length) {
        throw Exception('File integrity check failed');
      }

      debugPrint('Audio file saved: ${file.path} (${bytes.length} bytes)');
      _audioPathCache[fileName] = file.path;
      _fileCacheTime[fileName] = DateTime.now();

      return file.path;
    } catch (e) {
      debugPrint('Error saving base64 audio: $e');
      return null;
    }
  }

  /// Clean up expired cache files
  static Future<void> cleanupExpiredCache() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final audioDir = Directory('${directory.path}/audio_cache');

      if (!await audioDir.exists()) return;

      final files = await audioDir.list().toList();
      final now = DateTime.now();

      for (final entity in files) {
        if (entity is File) {
          final stat = await entity.stat();
          if (now.difference(stat.modified) > _cacheExpiration) {
            await entity.delete();
            debugPrint('Deleted expired cache file: ${entity.path}');
          }
        }
      }
    } catch (e) {
      debugPrint('Error cleaning up cache: $e');
    }
  }
}
