import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:soxo_chat/feature/auth/screen/auth_screen.dart';
import 'package:soxo_chat/feature/chat/screen/chat_detail_screen.dart';
import 'package:soxo_chat/feature/chat/screen/chat_screen.dart';
import 'package:soxo_chat/feature/chat/screen/single_chat_screen.dart';
import 'package:soxo_chat/feature/group/screen/group_screen.dart';
import 'package:soxo_chat/feature/notifcation/screen/notification_screen.dart';
import 'package:soxo_chat/feature/person_lists/screen/person_lists_screen.dart';
import 'package:soxo_chat/shared/routes/custom_transition.dart';
import 'package:soxo_chat/shared/routes/routes.dart';

class RouteGenerator {
  static GoRouter generateRoute() {
    return GoRouter(
      initialLocation: routeSignIn,
      routes: [
        GoRoute(path: routeSignIn, builder: (context, state) => SignInScreen()),

        GoRoute(path: routeRoot, builder: (context, state) => ChatScreen()),
        GoRoute(
          path: routeGroup,
          builder: (context, state) {
            final data = state.extra as Map<String, dynamic>;
            return GroupScreen(data: data);
          },
        ),
        GoRoute(
          path: routePerson,
          builder: (context, state) => PersonListsScreen(),
        ),
        GoRoute(
          path: routeChatDetail,
          pageBuilder: (context, state) {
            final data = state.extra as Map<String, dynamic>;

            return CustomTransitions.slideFade(
              context,
              state,
              ChatDetailScreen(data: data),
              begin: const Offset(1.0, 0.0),
            );
          },
        ),
        GoRoute(
          path: routeSingleChat,
          pageBuilder: (context, state) {
            final data = state.extra as Map<String, dynamic>;

            return CustomTransitions.slideFade(
              context,
              state,
              SingleChatScreen(data: data),
              begin: const Offset(1.0, 0.0),
            );
          },
        ),
        GoRoute(
          path: routeNotification,
          builder: (context, state) => NotificationScreen(),
        ),
      ],
      errorBuilder: (context, state) =>
          errorRoute(error: state.error?.toString()).builder(context),
    );
  }

  static MaterialPageRoute errorRoute({String? error, bool argsError = false}) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Text(
            error ?? '${argsError ? 'Arguments' : 'Navigation'} Error',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
