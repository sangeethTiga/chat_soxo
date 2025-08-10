import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:soxo_chat/feature/chat/screen/widgets/chat_card.dart';

Future<void> showMyDialog(
  BuildContext context,
  String fileUrl,
  String mediaId,
) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black87,
    builder: (BuildContext context) {
      return Center(
        child: _ImageViewerDialog(fileUrl: fileUrl, mediaId: mediaId),
      );
    },
  );
}

class _ImageViewerDialog extends StatefulWidget {
  final String fileUrl;
  final String mediaId;

  const _ImageViewerDialog({required this.fileUrl, required this.mediaId});

  @override
  State<_ImageViewerDialog> createState() => _ImageViewerDialogState();
}

class _ImageViewerDialogState extends State<_ImageViewerDialog>
    with TickerProviderStateMixin {
  late TransformationController _transformationController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;

  double _currentScale = 1.0;
  bool _showControls = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _transformationController.addListener(_onTransformationChanged);

    // Start animations
    _fadeController.forward();
    _scaleController.forward();

    // Start auto-hide timer
    _startHideTimer();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _hideTimer?.cancel();
    super.dispose();
  }

  void _onTransformationChanged() {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    if (scale != _currentScale) {
      setState(() {
        _currentScale = scale;
      });
    }
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _showControls && _currentScale <= 1.1) {
        _hideControls();
      }
    });
  }

  void _showControlsTemporary() {
    if (!_showControls) {
      setState(() {
        _showControls = true;
      });
    }
    _startHideTimer();
  }

  void _hideControls() {
    setState(() {
      _showControls = false;
    });
  }

  void _toggleControls() {
    if (_showControls) {
      _hideControls();
    } else {
      _showControlsTemporary();
    }
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }

  void _zoomIn() {
    final newScale = (_currentScale * 1.5).clamp(0.5, 4.0);
    _transformationController.value = Matrix4.identity()..scale(newScale);
  }

  void _zoomOut() {
    final newScale = (_currentScale / 1.5).clamp(0.5, 4.0);
    _transformationController.value = Matrix4.identity()..scale(newScale);
  }

  void _onDoubleTap() {
    if (_currentScale > 1.1) {
      _resetZoom();
    } else {
      _transformationController.value = Matrix4.identity()..scale(2.0);
    }
    _showControlsTemporary();
  }

  void _closeDialog() {
    _fadeController.reverse().then((_) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeController,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.8, end: 1.0).animate(
          CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
        ),
        child: Dialog(
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          child: Container(
            width: double.infinity,
            height: 700.h,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(0),
            ),
            child: Stack(
              children: [
                GestureDetector(
                  onTap: _toggleControls,
                  onDoubleTap: _onDoubleTap,
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.transparent,
                  ),
                ),

                // Main image with zoom
                Center(
                  child: InteractiveViewer(
                    transformationController: _transformationController,
                    panEnabled: true,
                    scaleEnabled: true,
                    minScale: 0.5,
                    maxScale: 4.0,
                    clipBehavior: Clip.none,
                    boundaryMargin: const EdgeInsets.all(20),
                    constrained: false,
                    child: GestureDetector(
                      onTap: () {}, // Prevent image tap from closing
                      child: CachedImageDisplay(
                        fileUrl: widget.fileUrl,
                        mediaId: widget.mediaId,
                        isInChatBubble: false,
                      ),
                    ),
                  ),
                ),

                // Top gradient and close button
                AnimatedOpacity(
                  opacity: _showControls ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.8),
                          Colors.black.withOpacity(0.4),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Zoom indicator
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.zoom_in,
                                    color: Colors.white70,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${(_currentScale * 100).round()}%',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Close button
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                onPressed: _closeDialog,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Bottom controls
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  bottom: _showControls ? 0 : -100,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.8),
                          Colors.black.withOpacity(0.4),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _ZoomButton(
                              icon: Icons.zoom_out,
                              onPressed: _currentScale > 0.5 ? _zoomOut : null,
                              isActive: _currentScale > 0.5,
                            ),
                            _ZoomButton(
                              icon: Icons.fit_screen,
                              onPressed: _currentScale != 1.0
                                  ? _resetZoom
                                  : null,
                              isActive: _currentScale != 1.0,
                            ),
                            _ZoomButton(
                              icon: Icons.zoom_in,
                              onPressed: _currentScale < 4.0 ? _zoomIn : null,
                              isActive: _currentScale < 4.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Tap instruction (shows briefly)
                if (_currentScale <= 1.1 && _showControls)
                  Positioned(
                    bottom: 120,
                    left: 20,
                    right: 20,
                    child: AnimatedOpacity(
                      opacity: _showControls ? 0.7 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.touch_app,
                              color: Colors.white70,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Double tap to zoom • Pinch to scale',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ZoomButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isActive;

  const _ZoomButton({
    required this.icon,
    required this.onPressed,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isActive
            ? Colors.white.withOpacity(0.15)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: isActive
              ? Colors.white.withOpacity(0.3)
              : Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(
              icon,
              color: isActive ? Colors.white : Colors.white.withOpacity(0.4),
              size: 26,
            ),
          ),
        ),
      ),
    );
  }
}
