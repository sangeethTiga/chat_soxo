import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:soxo_chat/shared/constants/colors.dart';
import 'package:soxo_chat/shared/themes/font_palette.dart';

class WorkingVoiceChatInput extends StatefulWidget {
  const WorkingVoiceChatInput({super.key});

  @override
  State<WorkingVoiceChatInput> createState() => _WorkingVoiceChatInputState();
}

class _WorkingVoiceChatInputState extends State<WorkingVoiceChatInput>
    with TickerProviderStateMixin {
  late TextEditingController _messageController;
  late AnimationController _recordingAnimationController;
  late AnimationController _pulseAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  bool _hasText = false;
  bool _isRecordingPermissionGranted = false;
  Duration _recordingDuration = Duration.zero;
  Timer? _recordingTimer;
  String? _recordingPath;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _initializeRecording();

    // Recording animation controller
    _recordingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // Pulse animation for recording indicator
    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _recordingAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _pulseAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Listen to text changes
    _messageController.addListener(_onTextChanged);
  }

  Future<void> _initializeRecording() async {
    // Check and request microphone permission
    final status = await Permission.microphone.request();
    setState(() {
      _isRecordingPermissionGranted = status == PermissionStatus.granted;
    });

    if (!_isRecordingPermissionGranted) {
      _showPermissionDialog();
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Microphone Permission Required'),
        content: const Text(
          'This app needs microphone access to record voice messages. Please grant permission in settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Settings'),
          ),
        ],
      ),
    );
  }

  void _onTextChanged() {
    setState(() {
      _hasText = _messageController.text.trim().isNotEmpty;
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _recordingAnimationController.dispose();
    _pulseAnimationController.dispose();
    _recordingTimer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<String> _getRecordingFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    return '${directory.path}/$fileName';
  }

  Future<void> startRecording() async {
    if (!_isRecordingPermissionGranted) {
      _showPermissionDialog();
      return;
    }

    try {
      // Get recording path
      _recordingPath = await _getRecordingFilePath();

      // Check if recorder is available
      if (await _audioRecorder.hasPermission()) {
        // Start recording
        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: _recordingPath!,
        );

        setState(() {
          _isRecording = true;
          _recordingDuration = Duration.zero;
        });

        // Start animations
        _recordingAnimationController.forward();
        _pulseAnimationController.repeat(reverse: true);

        // Start recording timer
        _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            _recordingDuration = Duration(seconds: timer.tick);
          });
        });

        print('Recording started at: $_recordingPath');

        // Optional: Add haptic feedback
        // HapticFeedback.lightImpact();
      } else {
        print('Recording permission not granted');
        _showPermissionDialog();
      }
    } catch (e) {
      print('Error starting recording: $e');
      _showErrorDialog('Failed to start recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;

    try {
      // Stop recording
      final path = await _audioRecorder.stop();

      setState(() {
        _isRecording = false;
      });

      // Stop animations
      _recordingAnimationController.reverse();
      _pulseAnimationController.stop();

      // Stop timer
      _recordingTimer?.cancel();

      if (path != null) {
        print('Recording saved at: $path');

        // Check if file exists and has content
        final file = File(path);
        if (await file.exists()) {
          final fileSize = await file.length();
          print('Recording file size: $fileSize bytes');

          if (fileSize > 0) {
            _sendVoiceMessage(path);
          } else {
            print('Recording file is empty');
            _showErrorDialog('Recording failed - file is empty');
          }
        } else {
          print('Recording file does not exist');
          _showErrorDialog('Recording failed - file not found');
        }
      } else {
        print('Recording path is null');
        _showErrorDialog('Recording failed - no file path');
      }

      // Reset duration
      setState(() {
        _recordingDuration = Duration.zero;
      });
    } catch (e) {
      print('Error stopping recording: $e');
      _showErrorDialog('Failed to stop recording: $e');
    }
  }

  Future<void> _cancelRecording() async {
    if (!_isRecording) return;

    try {
      await _audioRecorder.stop();

      setState(() {
        _isRecording = false;
      });

      // Stop animations
      _recordingAnimationController.reverse();
      _pulseAnimationController.stop();

      // Stop timer
      _recordingTimer?.cancel();

      // Delete the recording file if it exists
      if (_recordingPath != null) {
        final file = File(_recordingPath!);
        if (await file.exists()) {
          await file.delete();
          print('Recording file deleted');
        }
      }

      // Reset duration
      setState(() {
        _recordingDuration = Duration.zero;
      });

      print('Recording cancelled');
    } catch (e) {
      print('Error cancelling recording: $e');
    }
  }

  void _sendTextMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      final message = _messageController.text.trim();
      print('Sending text message: $message');

      // Add your text message sending logic here
      // Example: context.read<ChatCubit>().sendTextMessage(message);

      _messageController.clear();

      // Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Text message sent: $message'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _sendVoiceMessage(String audioPath) {
    final duration = _recordingDuration;
    print(
      'Sending voice message: $audioPath (Duration: ${_formatDuration(duration)})',
    );

    // Add your voice message sending logic here
    // Example: context.read<ChatCubit>().sendVoiceMessage(audioPath, duration);

    // Show success feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Voice message sent (${_formatDuration(duration)})'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recording Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: _isRecording ? _buildRecordingView() : _buildInputView(),
    );
  }

  Widget _buildInputView() {
    return Row(
      children: [
        // Attachment icon
        GestureDetector(
          onTap: _showAttachmentOptions,
          child: Container(
            padding: EdgeInsets.all(8.w),
            child: SvgPicture.asset(
              'assets/icons/Vector.svg',
              color: const Color(0xFF666666),
            ),
          ),
        ),
        10.horizontalSpace,

        // Text input field
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xffCACACA), width: 1),
              color: kWhite,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: FontPalette.hW400S16,
                    maxLines: 4,
                    minLines: 1,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      hintStyle: FontPalette.hW400S16.copyWith(
                        color: const Color(0XFFBFBFBF),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                    ),
                  ),
                ),

                // Emoji/Camera icon
                GestureDetector(
                  onTap: () {
                    // Handle emoji or camera
                    print('Emoji/Camera tapped');
                  },
                  child: Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: SvgPicture.asset(
                      'assets/icons/Group 1000006770.svg',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        8.horizontalSpace,

        // Send/Voice button
        GestureDetector(
          onLongPress: _hasText ? null : startRecording,
          onTap: _hasText ? _sendTextMessage : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 48.h,
            width: 48.w,
            decoration: BoxDecoration(
              color: _hasText
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFF2196F3),
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(
                  color:
                      (_hasText
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFF2196F3))
                          .withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              _hasText ? Icons.send : Icons.mic,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecordingView() {
    return Row(
      children: [
        // Cancel button
        GestureDetector(
          onTap: _cancelRecording,
          child: Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: const Icon(Icons.close, color: Colors.red, size: 20),
          ),
        ),

        12.horizontalSpace,

        // Recording indicator and duration
        Expanded(
          child: Row(
            children: [
              // Pulsing red dot
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      height: 12.h,
                      width: 12.w,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                },
              ),

              8.horizontalSpace,

              // Recording text and duration
              Text(
                'Recording... ${_formatDuration(_recordingDuration)}',
                style: FontPalette.hW500S16.copyWith(color: Colors.red),
              ),

              const Spacer(),

              // Waveform animation (simplified)
              ...List.generate(5, (index) {
                return AnimatedContainer(
                  duration: Duration(milliseconds: 300 + (index * 100)),
                  margin: EdgeInsets.symmetric(horizontal: 1.w),
                  height: (20 + (index * 5)).h,
                  width: 3.w,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                );
              }),
            ],
          ),
        ),

        12.horizontalSpace,

        // Send voice button
        GestureDetector(
          onTap: _stopRecording,
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  height: 48.h,
                  width: 48.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(24.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4CAF50).withOpacity(0.4),
                        blurRadius: 12,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.send, color: Colors.white, size: 24),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAttachmentOption(
              icon: Icons.photo_library,
              label: 'Gallery',
              color: Colors.purple,
              onTap: () {
                Navigator.pop(context);
                print('Gallery selected');
              },
            ),
            _buildAttachmentOption(
              icon: Icons.camera_alt,
              label: 'Camera',
              color: Colors.blue,
              onTap: () {
                Navigator.pop(context);
                print('Camera selected');
              },
            ),
            _buildAttachmentOption(
              icon: Icons.insert_drive_file,
              label: 'Document',
              color: Colors.orange,
              onTap: () {
                Navigator.pop(context);
                print('Document selected');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            16.horizontalSpace,
            Text(label, style: FontPalette.hW500S16.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}
