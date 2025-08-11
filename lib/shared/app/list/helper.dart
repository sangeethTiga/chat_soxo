import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:soxo_chat/shared/routes/routes.dart';
import 'package:soxo_chat/shared/utils/auth/auth_utils.dart';

class Helper {
  static void afterInit(Function function) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      function();
    });
  }

  int checkPasswordStrength(String password) {
    int score = 0;

    if (password.length >= 8) score += 35;
    if (password.length >= 12) score += 10;

    if (password.contains(RegExp(r'[a-z]'))) score += 15;

    if (password.contains(RegExp(r'[A-Z]'))) score += 15;

    if (password.contains(RegExp(r'[0-9]'))) score += 15;

    if (password.contains(
      RegExp(
        r'[!@#\$%\^&\*\(\)_\+\-=\[\]\{\};:\'
        ",.<>/?\\|`~]",
      ),
    )) {
      score += 20;
    }

    if (password.contains(
      RegExp(r'(password|1234|qwerty|abcd)', caseSensitive: false),
    )) {
      score -= 30;
    }

    score = score.clamp(1, 100);

    return score;
  }

  Map<String, dynamic> removeNullValues(Map<String, dynamic> input) {
    return Map.fromEntries(input.entries.where((e) => e.value != null));
  }

  Future<void> logout(BuildContext context) async {
    try {
      await _deleteCacheDir();
      await _deleteAppDir();
      await AuthUtils.instance.deleteAll();
      await clearCache();
      // context.read<AuthBloc>().add(LogoutEventClear());

      if (!context.mounted) return;

      context.go(routeSignIn);
    } catch (e) {
      log('Error during logout: $e');
    }
  }

  Future<void> _deleteCacheDir() async {
    try {
      Directory tempDir = await getTemporaryDirectory();
      log('Cache Directory: ${tempDir.path}');
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
        log('Cache directory deleted successfully.');
      } else {
        log('Cache directory does not exist.');
      }
    } catch (e) {
      log('Error deleting cache directory: $e');
    }
  }

  Future<void> _deleteAppDir() async {
    try {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      log('App Documents Directory: ${appDocDir.path}');
      if (await appDocDir.exists()) {
        await appDocDir.delete(recursive: true);
        log('App directory deleted successfully.');
      } else {
        log('App directory does not exist.');
      }
    } catch (e) {
      log('Error deleting application directory: $e');
    }
  }
}

Future<void> clearCache() async {
  final cacheDir = await getTemporaryDirectory();

  if (cacheDir.existsSync()) {
    cacheDir.deleteSync(recursive: true); // Deletes everything in cache
  }
}

int? parseInt(dynamic value) {
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  if (value is double) return value.toInt();
  return null;
}

double? parseDouble(dynamic value) {
  if (value is double) return value;
  if (value is String) return double.tryParse(value);
  if (value is double) return value.toDouble();
  return null;
}

String truncateTo2Decimals(double? value) {
  if (value == null) return '0.00';
  int truncated = (value * 100).truncate();
  return (truncated / 100).toStringAsFixed(2);
}

class ChatTab {
  String name;
  String type;

  ChatTab(this.name, this.type);
}

List<ChatTab> chatTab = [
  ChatTab('All', 'all'),
  ChatTab('Group Chat', 'group'),
  ChatTab('Personal Chat', 'personal'),
  ChatTab('Broadcast', 'broadcast'),
];
String getFormattedDate(String dateStr) {
  final DateTime inputDate = DateTime.parse(dateStr).toLocal();
  final DateTime now = DateTime.now();
  final DateTime today = DateTime(now.year, now.month, now.day);
  final DateTime inputDay = DateTime(
    inputDate.year,
    inputDate.month,
    inputDate.day,
  );

  final difference = today.difference(inputDay).inDays;

  if (difference == 0) {
    return "Today";
  } else if (difference == 1) {
    return "Yesterday";
  } else {
    return DateFormat('dd MMM yyyy').format(inputDate);
  }
}

IconData getEmptyStateIcon(String selectedTab) {
  switch (selectedTab) {
    case 'Group Chat':
      return Icons.group;
    case 'Personal Chat':
      return Icons.person;
    case 'Broadcast':
      return Icons.campaign;
    default:
      return Icons.chat;
  }
}

Widget buildEmptyState(String selectedTab) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          getEmptyStateIcon(selectedTab),
          size: 80.sp,
          color: Colors.grey[400],
        ),
        16.verticalSpace,
        Text(
          'No ${selectedTab.toLowerCase()} found',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        8.verticalSpace,
        Text(
          _getEmptyStateMessage(selectedTab),
          style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
          textAlign: TextAlign.center,
        ),
        120.verticalSpace,
      ],
    ),
  );
}

String _getEmptyStateMessage(String selectedTab) {
  switch (selectedTab) {
    case 'Group Chat':
      return 'You haven\'t joined any group chats yet.\nCreate or join a group to get started.';
    case 'Personal Chat':
      return 'No personal conversations yet.\nStart chatting with your contacts.';
    case 'Broadcast':
      return 'No broadcast messages.\nSubscribe to channels for updates.';
    default:
      return 'No chats available.\nStart a new conversation.';
  }
}
