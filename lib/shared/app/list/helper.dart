import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';

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
      // await AuthUtils.instance.deleteAll();
      // context.read<AuthBloc>().add(LogoutEventClear());

      if (!context.mounted) return;

      // Navigator.pushNamedAndRemoveUntil(context, routeSignIn, (route) => false);
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
