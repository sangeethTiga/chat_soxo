// File: lib/shared/routes/custom_transitions.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomTransitions {
  //=-=-=-=-=- Slide from right to left =-=-=-=-=-==--=
  static Page<T> slideRightToLeft<T extends Object?>(
    BuildContext context,
    GoRouterState state,
    Widget child,
  ) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end);
        final offsetAnimation = animation.drive(tween);

        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }

  //=-=-=-=-=-  Slide from left to right
  static Page<T> slideLeftToRight<T extends Object?>(
    BuildContext context,
    GoRouterState state,
    Widget child,
  ) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(-1.0, 0.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end);
        final offsetAnimation = animation.drive(tween);

        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }

  //=-=-=-=-=-  Slide from bottom to top
  static Page<T> slideBottomToTop<T extends Object?>(
    BuildContext context,
    GoRouterState state,
    Widget child,
  ) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end);
        final offsetAnimation = animation.drive(tween);

        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }

  //=-=-=-=-=-  Fade transition
  static Page<T> fade<T extends Object?>(
    BuildContext context,
    GoRouterState state,
    Widget child,
  ) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  //=-=-=-=-=-  Scale transition
  static Page<T> scale<T extends Object?>(
    BuildContext context,
    GoRouterState state,
    Widget child,
  ) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.elasticOut),
          ),
          child: child,
        );
      },
    );
  }

  //=-=-=-=-=-  Rotation transition
  static Page<T> rotation<T extends Object?>(
    BuildContext context,
    GoRouterState state,
    Widget child,
  ) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 500),
      reverseTransitionDuration: const Duration(milliseconds: 500),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return RotationTransition(
          turns: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.elasticOut),
          ),
          child: child,
        );
      },
    );
  }

  //=-=-=-=-=-  Combined slide and fade
  static Page<T> slideFade<T extends Object?>(
    BuildContext context,
    GoRouterState state,
    Widget child, {
    Offset begin = const Offset(1.0, 0.0),
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 400),
      reverseTransitionDuration: const Duration(milliseconds: 400),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slideAnimation = Tween<Offset>(
          begin: begin,
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut));

        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut));

        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(opacity: fadeAnimation, child: child),
        );
      },
    );
  }

  static CustomTransitionPage seamlessMorph(
    BuildContext context,
    GoRouterState state,
    Widget child, {
    Duration duration = const Duration(milliseconds: 800),
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _buildSeamlessMorphTransition(
          animation,
          secondaryAnimation,
          child,
        );
      },
    );
  }

  // LIQUID TRANSITION - Like content flowing naturally
  static CustomTransitionPage liquidTransition(
    BuildContext context,
    GoRouterState state,
    Widget child, {
    Duration duration = const Duration(milliseconds: 700),
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _buildLiquidTransition(animation, secondaryAnimation, child);
      },
    );
  }

  // BREATHING TRANSITION - Subtle scale with fade
  static CustomTransitionPage breathingTransition(
    BuildContext context,
    GoRouterState state,
    Widget child, {
    Duration duration = const Duration(milliseconds: 600),
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _buildBreathingTransition(animation, secondaryAnimation, child);
      },
    );
  }

  // DISSOLVE TRANSITION - Content dissolves and reforms
  static CustomTransitionPage dissolveTransition(
    BuildContext context,
    GoRouterState state,
    Widget child, {
    Duration duration = const Duration(milliseconds: 900),
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _buildDissolveTransition(animation, secondaryAnimation, child);
      },
    );
  }

  // FLOATING TRANSITION - Like content floating into place
  static CustomTransitionPage floatingTransition(
    BuildContext context,
    GoRouterState state,
    Widget child, {
    Duration duration = const Duration(milliseconds: 750),
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _buildFloatingTransition(animation, secondaryAnimation, child);
      },
    );
  }

  // Build seamless morph transition
  static Widget _buildSeamlessMorphTransition(
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Ultra-subtle scale (98% to 100%)
    final scaleAnimation = Tween<double>(begin: 0.98, end: 1.0).animate(
      CurvedAnimation(
        parent: animation,
        curve: const Cubic(0.25, 0.1, 0.25, 1.0), // Material motion curve
      ),
    );

    // Gentle vertical movement
    final slideAnimation =
        Tween<Offset>(begin: const Offset(0.0, 0.02), end: Offset.zero).animate(
          CurvedAnimation(
            parent: animation,
            curve: const Cubic(0.25, 0.1, 0.25, 1.0),
          ),
        );

    // Smooth opacity transition
    final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animation,
        curve: const Interval(0.1, 0.9, curve: Cubic(0.25, 0.1, 0.25, 1.0)),
      ),
    );

    // Blur effect for extra smoothness
    final blurAnimation = Tween<double>(begin: 2.0, end: 0.0).animate(
      CurvedAnimation(
        parent: animation,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    return SlideTransition(
      position: slideAnimation,
      child: ScaleTransition(
        scale: scaleAnimation,
        child: FadeTransition(
          opacity: fadeAnimation,
          child: AnimatedBuilder(
            animation: blurAnimation,
            builder: (context, child) {
              return ImageFiltered(
                imageFilter: ImageFilter.blur(
                  sigmaX: blurAnimation.value,
                  sigmaY: blurAnimation.value,
                ),
                child: child!,
              );
            },
            child: child,
          ),
        ),
      ),
    );
  }

  // Build liquid transition
  static Widget _buildLiquidTransition(
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Wave-like scale animation
    final scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutQuart));

    // Flowing slide animation
    final slideAnimation =
        Tween<Offset>(begin: const Offset(0.0, 0.05), end: Offset.zero).animate(
          CurvedAnimation(
            parent: animation,
            curve: const Cubic(0.19, 1.0, 0.22, 1.0), // Fluid curve
          ),
        );

    // Multi-stage fade
    final fadeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 0.7), weight: 30),
      TweenSequenceItem(tween: Tween<double>(begin: 0.7, end: 1.0), weight: 70),
    ]).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

    return SlideTransition(
      position: slideAnimation,
      child: ScaleTransition(
        scale: scaleAnimation,
        child: FadeTransition(opacity: fadeAnimation, child: child),
      ),
    );
  }

  // Build breathing transition
  static Widget _buildBreathingTransition(
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Breathing scale effect
    final scaleAnimation = TweenSequence<double>(
      [
        TweenSequenceItem(
          tween: Tween<double>(begin: 0.96, end: 1.02),
          weight: 50,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: 1.02, end: 1.0),
          weight: 50,
        ),
      ],
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic));

    // Gentle opacity pulse
    final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animation,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutExpo),
      ),
    );

    return ScaleTransition(
      scale: scaleAnimation,
      child: FadeTransition(opacity: fadeAnimation, child: child),
    );
  }

  // Build dissolve transition
  static Widget _buildDissolveTransition(
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Multiple fade stages for dissolve effect
    final fadeAnimation1 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animation,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    final fadeAnimation2 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animation,
        curve: const Interval(0.3, 0.7, curve: Curves.easeInOut),
      ),
    );

    final fadeAnimation3 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animation,
        curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
      ),
    );

    // Subtle scale
    final scaleAnimation = Tween<double>(
      begin: 0.99,
      end: 1.0,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutQuart));

    return ScaleTransition(
      scale: scaleAnimation,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final combinedOpacity =
              (fadeAnimation1.value *
                      fadeAnimation2.value *
                      fadeAnimation3.value)
                  .clamp(0.0, 1.0);

          return Opacity(opacity: combinedOpacity, child: child!);
        },
        child: child,
      ),
    );
  }

  // Build floating transition
  static Widget _buildFloatingTransition(
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Floating scale animation
    final scaleAnimation = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(
        parent: animation,
        curve: const Cubic(0.175, 0.885, 0.32, 1.275), // Bouncy curve
      ),
    );

    // Floating movement
    final slideAnimation =
        Tween<Offset>(begin: const Offset(0.0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(
            parent: animation,
            curve: const Cubic(0.175, 0.885, 0.32, 1.0),
          ),
        );

    // Soft fade in
    final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animation,
        curve: const Interval(0.15, 0.85, curve: Curves.easeOutQuart),
      ),
    );

    // Rotation for floating effect
    final rotationAnimation = Tween<double>(
      begin: 0.01,
      end: 0.0,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

    return SlideTransition(
      position: slideAnimation,
      child: ScaleTransition(
        scale: scaleAnimation,
        child: FadeTransition(
          opacity: fadeAnimation,
          child: Transform.rotate(angle: rotationAnimation.value, child: child),
        ),
      ),
    );
  }

  // BONUS: Micro-interaction transition (almost imperceptible)
  static CustomTransitionPage microTransition(
    BuildContext context,
    GoRouterState state,
    Widget child, {
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Almost invisible scale (99% to 100%)
        final scaleAnimation = Tween<double>(begin: 0.995, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutQuart),
        );

        // Tiny vertical movement
        final slideAnimation =
            Tween<Offset>(
              begin: const Offset(0.0, 0.005),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutQuart),
            );

        // Quick fade
        final fadeAnimation = Tween<double>(
          begin: 0.3,
          end: 1.0,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));

        return SlideTransition(
          position: slideAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: FadeTransition(opacity: fadeAnimation, child: child),
          ),
        );
      },
    );
  }

  //=-=-=-=-=-  No transition (instant)
  //   static Page<T> noTransition<T extends Object?>(
  //     BuildContext context,
  //     GoRouterState state,
  //     Widget child,
  //   ) {
  //     return NoTransitionPage<T>(key: state.pageKey, child: child);
  //   }
  // }
  static CustomTransitionPage noTransition(
    BuildContext context,
    GoRouterState state,
    Widget child,
  ) {
    return CustomTransitionPage(
      key: state.pageKey, // <== add this
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return child;
      },
    );
  }

  static CustomTransitionPage heroZoomTransitionPage({
    required Widget child,
    required GoRouterState state,
    Duration duration = const Duration(milliseconds: 500),
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _buildHeroZoomTransition(animation, secondaryAnimation, child);
      },
    );
  }

  static CustomTransitionPage zoomWithSlideBack(
    BuildContext context,
    GoRouterState state,
    Widget child, {
    Duration forwardDuration = const Duration(milliseconds: 500),
    Duration reverseDuration = const Duration(milliseconds: 300),
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: forwardDuration,
      reverseTransitionDuration: reverseDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // For forward navigation (entering page)
        if (animation.status == AnimationStatus.forward ||
            animation.status == AnimationStatus.completed) {
          return _buildHeroZoomTransition(animation, secondaryAnimation, child);
        }
        // For reverse navigation (going back)
        else {
          final slideAnimation =
              Tween<Offset>(
                begin: Offset.zero,
                end: const Offset(1.0, 0.0), // Slide to right
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              );

          final fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          );

          return SlideTransition(
            position: slideAnimation,
            child: FadeTransition(opacity: fadeAnimation, child: child),
          );
        }
      },
    );
  }

  static Widget _buildZoomTransition(
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutBack));

    final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animation,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    return FadeTransition(
      opacity: fadeAnimation,
      child: ScaleTransition(scale: scaleAnimation, child: child),
    );
  }

  // Hero-like zoom with slide
  static Widget _buildHeroZoomTransition(
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final scaleAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.elasticOut));

    final slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

    final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animation,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: ScaleTransition(scale: scaleAnimation, child: child),
      ),
    );
  }
}
  // CustomTransitionPage slideLeftToRight(
  //   BuildContext context,
  //   GoRouterState state,
  //   Widget child,
  // ) {
  //   return CustomTransitionPage(
  //     key: state.pageKey, // <== add this
  //     child: child,
  //     transitionsBuilder: (context, animation, secondaryAnimation, child) {
  //       final tween = Tween(begin: const Offset(1, 0), end: Offset.zero);
  //       final curvedAnimation = CurvedAnimation(
  //         parent: animation,
  //         curve: Curves.easeInOut,
  //       );
  //       return SlideTransition(
  //         position: tween.animate(curvedAnimation),
  //         child: child,
  //       );
  //     },
  //   );
  // }

