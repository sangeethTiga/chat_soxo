import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:soxo_chat/feature/chat/screen/chat_detail_screen.dart';
import 'package:soxo_chat/feature/chat/screen/chat_screen.dart';
import 'package:soxo_chat/feature/group/screen/group_screen.dart';
import 'package:soxo_chat/feature/notifcation/screen/notification_screen.dart';
import 'package:soxo_chat/feature/person_lists/screen/person_lists_screen.dart';
import 'package:soxo_chat/shared/routes/routes.dart';

// class RouteGenerator {
//   static Route<dynamic> generateRoute(RouteSettings routeSettings) {
//     final Object? args = routeSettings.arguments;

//     switch (routeSettings.name) {
//       case routeRoot:
//         return MaterialPageRoute(builder: (_) => ChatScreen());
//       case routeGroup:
//         return MaterialPageRoute(builder: (_) => GroupScreen());
//       case routePerson:
//         return MaterialPageRoute(builder: (_) => PersonListsScreen());
//       case routeChatDetail:
//         return MaterialPageRoute(builder: (_) => ChatDetailScreen());
//       case routeNotification:
//         return MaterialPageRoute(builder: (_) => NotificationScreen());
//       default:
//         return _errorRoute();
//     }
//   }

//   static Route<dynamic> _errorRoute({String? error, bool argsError = false}) {
//     return MaterialPageRoute(
//       builder: (_) => Scaffold(
//         appBar: AppBar(title: const Text('Error'), centerTitle: true),
//         body: Center(
//           child: Text(
//             error ?? '${argsError ? 'Arguments' : 'Navigation'} Error',
//             style: const TextStyle(
//               fontWeight: FontWeight.w600,
//               color: Colors.black54,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

class RouteGenerator {
  static GoRouter generateRoute() {
    return GoRouter(
      initialLocation: routeRoot,
      routes: [
        GoRoute(path: routeRoot, builder: (context, state) => ChatScreen()),
        GoRoute(path: routeGroup, builder: (context, state) => GroupScreen()),
        GoRoute(
          path: routePerson,
          builder: (context, state) => PersonListsScreen(),
        ),
        GoRoute(
          path: routeChatDetail,
          builder: (context, state) => ChatDetailScreen(),
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
