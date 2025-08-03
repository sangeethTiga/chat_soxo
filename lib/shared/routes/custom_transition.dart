// File: lib/shared/routes/custom_transitions.dart
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
}
