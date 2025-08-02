import 'package:flutter/material.dart';
import 'package:soxo_chat/feature/chat/screen/chat_screen.dart';
import 'package:soxo_chat/feature/group/screen/group_screen.dart';
import 'package:soxo_chat/shared/routes/routes.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    final Object? args = routeSettings.arguments;

    switch (routeSettings.name) {
      case routeRoot:
        return MaterialPageRoute(builder: (_) => ChatScreen());
      case routeGroup:
        return MaterialPageRoute(builder: (_) => GroupScreen());
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute({String? error, bool argsError = false}) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Error'), centerTitle: true),
        body: Center(
          child: Text(
            error ?? '${argsError ? 'Arguments' : 'Navigation'} Error',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
        ),
      ),
    );
  }
}
