import 'dart:developer';

import 'package:dio/dio.dart';

class Helper {
  String? errorMapping(Response? response) {
    if (response?.data == null) return 'Unknown error occurred';

    try {
      final data = response!.data;

      // Handle different response data types
      if (data is Map<String, dynamic>) {
        // Handle validation errors
        if (data.containsKey('errors') && data['errors'] is Map) {
          final errors = data['errors'] as Map<String, dynamic>;
          List<String> errorMessages = [];

          errors.forEach((key, value) {
            if (value is List) {
              errorMessages.addAll(value.map((e) => e.toString()));
            } else {
              errorMessages.add(value.toString());
            }
          });

          return errorMessages.isNotEmpty
              ? errorMessages.join(', ')
              : 'Validation error';
        }

        // Handle other error formats
        if (data.containsKey('title')) {
          return data['title'].toString();
        }

        if (data.containsKey('message')) {
          return data['message'].toString();
        }

        return 'Error: ${data.toString()}';
      }

      // Handle string responses
      if (data is String) {
        return data;
      }

      // Handle list responses (shouldn't happen for errors, but just in case)
      if (data is List) {
        return 'Multiple errors occurred';
      }

      return 'Unknown error format';
    } catch (e) {
      log('Error parsing error response: $e');
      return 'Failed to parse error response';
    }
  }

  Map<String, dynamic> removeNullValues(Map<String, dynamic> data) {
    final Map<String, dynamic> result = {};
    data.forEach((key, value) {
      if (value != null) {
        if (value is Map<String, dynamic>) {
          result[key] = removeNullValues(value);
        } else if (value is List) {
          result[key] = value.where((item) => item != null).toList();
        } else {
          result[key] = value;
        }
      }
    });
    return result;
  }
}
