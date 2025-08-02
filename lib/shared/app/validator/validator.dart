import 'package:flutter/services.dart';

enum InputFormatType { name, phoneNumber, email, password }

class Validator {
  Validator.__();

  static String? validatePassword(String? value, {String? msg}) {
    String errorMsg = msg ??
        'Password must be at least 8 characters long, must contain numbers, at least one uppercase and lowercase alphabet, and must not contain spaces.';
    if ((msg ?? '').isNotEmpty) {
      return msg;
    } else if ((value ?? '').isEmpty) {
      return "Password is required";
    } else if (value!.length < 8) {
      return errorMsg;
    } else if (!value.contains(RegExp(r'[0-9]'))) {
      return errorMsg;
    } else if (!value
        .contains(RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?\d)\S{8,}$'))) {
      return errorMsg;
    } else if (!value.contains(RegExp(r'[A-Z]'))) {
      return errorMsg;
    }
    return null;
  }

  static String? validateLoginPassword(String? value, {String? msg}) {
    if ((msg ?? '').isNotEmpty) {
      return msg;
    } else if ((value ?? '').isEmpty) {
      return "Password is required";
    }
    return null;
  }

  static String? validateConfirmPassword(
      String? oldPassword, String? newPassword) {
    if ((newPassword ?? '').isEmpty) {
      return "Confirm password is required";
    } else if (oldPassword != newPassword) {
      return "Passwords do not match. Please enter the same password in both fields.";
    }
    return null;
  }

  static String? validateEmail(String? value, {String? msg}) {
    String pattern =
        r'^(?=.{1,320}$)[a-zA-Z0-9._%+-]{1,64}@[a-zA-Z0-9.-]{1,255}\.[a-zA-Z]{2,63}$';
    RegExp regex = RegExp(pattern);
    if (msg != null) return msg;
    if ((value ?? '').isEmpty) return "Email address is required";
    if (!regex.hasMatch(value!)) {
      return "Please enter a valid email address.";
    } else {
      return null;
    }
  }

  static List<TextInputFormatter>? inputFormatter(InputFormatType type) {
    List<TextInputFormatter>? val;
    switch (type) {
      case InputFormatType.phoneNumber:
        val = [
          FilteringTextInputFormatter.allow(RegExp("[0-9]")),
        ];
        break;

      case InputFormatType.password:
        val = [
          FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z@]")),
        ];
        break;
      case InputFormatType.name:
        val = [FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z]+|\s"))];
        break;
      case InputFormatType.email:
        val = [FilteringTextInputFormatter.deny(RegExp(r'[- /+?:;*#$%^&()]'))];
        break;
    }
    return val;
  }

  static String? validateOTPCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter the email verification code';
    } else if (value.length != 6) {
      return 'Enter exactly 6 digits';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    } else if (value.length < 3) {
      return 'The field can\'t be empty';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value != null && value.isNotEmpty && value.length != 10) {
      return 'Enter exactly 10 digits';
    }
    return null;
  }

  static String? validateField(String? value, String errorMessage) {
    if (value == null || value.isEmpty) {
      return errorMessage;
    }
    return null;
  }

  static String? validateDropdownField(String? value, String errorMessage) {
    if (value == null || value.isEmpty || value == '0') {
      return errorMessage;
    }
    return null;
  }

  static String? validateURL(String? value) {
    if (value == null || value.isEmpty) {
      return 'URL is required';
    } else if (!RegExp(r'^(https?:\/\/)?([\w\d\-]+\.)+[\w]{2,}(\/.*)?$')
        .hasMatch(value)) {
      return 'Enter a valid URL';
    }
    return null;
  }
}
