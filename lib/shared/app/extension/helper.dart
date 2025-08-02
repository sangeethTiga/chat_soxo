import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:soxo_chat/shared/utils/failures/bad_request.dart';
import 'package:url_launcher/url_launcher.dart';

class Helper {
  static void afterInit(Function function) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      function();
    });
  }

  dynamic errorMapping(Response? response) {
    final badRequest = <BadRequest>[]; // List to store BadRequest objects
    var errorString = ''; // String to accumulate error messages

    // Iterate over response data keys
    (response?.data.keys.forEach((key) {
      if (key == 'message' ||
          key == 'error' ||
          key == 'detail' ||
          key == 'email') {
        final message = <String>[];
        if (key == 'email') {
          message.add(response.data[key][0]);
        } else {
          message.add(response.data[key]);
        }
        badRequest.add(
          BadRequest(
            errorField: '',
            error: message,
          ), // Add message/error to badRequest
        );
      } else {
        badRequest.add(
          BadRequest(
            errorField: key,
            error: List<String>.from(response.data[key].map((x) => x)),
          ), // Add other errors to badRequest
        );
      }
    }));

    // Construct error string from badRequest list
    for (var element in badRequest) {
      var subString = '';
      element.error?.forEach((sub) {
        subString = '$subString\n$sub';
      });
      if (errorString.isEmpty) {
        errorString =
            '${replaceCharacters(element.errorField ?? '')}$subString';
      } else {
        errorString =
            '$errorString\n\n${replaceCharacters(element.errorField ?? '')}$subString';
      }
    }

    // // Show error string in a snackbar
    // log('---------------------- errorString ----------------------');
    // log(errorString);
    // log('---------------------- errorString ----------------------');
    return errorString;
  }

  String replaceCharacters(String text) =>
      capitalizeFirstLetter(text.replaceAll(RegExp('[\\W_]+'), ' '));

  String capitalizeFirstLetter(String input) {
    if (input.isEmpty) {
      return input;
    }
    return input[0].toUpperCase() + input.substring(1);
  }

  Map<String, dynamic> removeNullValues(Map<String, dynamic> input) {
    return Map.fromEntries(input.entries.where((e) => e.value != null));
  }

  Future<void> logout(BuildContext context) async {
    try {
      // await AuthUtils.instance.deleteAll();
      // context.read<AuthBloc>().add(LogoutEventClear());
      // context.read<AddressBloc>().add(InitStateOfAddressEvent());
      // await AuthUtils.instance.deleteAddress();
      // await AuthUtils.instance.clearUserData();
      // await AuthUtils.instance.deleteAll();

      // if (!context.mounted) return;
      // context.go(routeSignIn);
    } catch (e) {
      log('Error during logout: $e');
    }
  }

  String generateCacheKey(String url, Map<String, dynamic> data) {
    const methodString = 'GET';
    final dataString = jsonEncode(data);
    return '$methodString|$url|$dataString';
  }

  static String formatDate({
    required DateTime date,
    String format = 'dd/MM/yyyy',
  }) {
    final DateFormat dateFormat = DateFormat(format);
    return dateFormat.format(date);
  }

  Future<void> launchUrls(String url) async {
    try {
      if (!await launchUrl(Uri.parse(url))) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      log('Error launching URL: $e');
    }
  }

  Future<void> launchPhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (!await launchUrl(launchUri)) {
      throw Exception('Could not launch phone call');
    }
  }

  Future<void> launchEmail(String email) async {
    final Uri launchUri = Uri(scheme: 'mailto', path: email);
    if (!await launchUrl(launchUri)) {
      throw Exception('Could not launch email');
    }
  }
}
