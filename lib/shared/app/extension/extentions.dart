import 'package:intl/intl.dart';

extension StringExtension on String {
  String capitalizeFirstLetter() {
    if (isEmpty) {
      return this; // Return an empty string if the input is empty.
    }
    return this[0].toUpperCase() + substring(1);
  }
}

extension DateParsing on String {
  String toFormattedDate() {
    try {
      final DateTime parsedDate = DateTime.parse(this);
      final DateFormat formatter = DateFormat('yyyy, MMM dd');
      return formatter.format(parsedDate);
    } catch (e) {
      return this; // Return the original string if parsing fails.
    }
  }
}

extension StringNullOrEmpty on String? {
  bool get isNullOrEmpty {
    return this == null || this!.isEmpty;
  }

  bool get isNotNullOrEmpty {
    return !isNullOrEmpty;
  }
}

