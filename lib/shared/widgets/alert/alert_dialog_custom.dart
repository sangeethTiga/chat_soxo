import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:soxo_chat/shared/constants/colors.dart';
import 'package:soxo_chat/shared/themes/font_palette.dart';

void kAlertDialog({
  final dynamic title,
  content,
  final String? submitText,
  final List<Widget>? actions,
  final Function()? submitAction,
  final Color submitColor = kBlack,
  final bool isBlur = false,
  required final BuildContext context,
}) {
  // final BuildContext context = navigatorKey.currentContext!;
  showDialog(
    barrierDismissible: true,
    context: context,
    builder: (context) {
      return BackdropFilter(
        filter: isBlur
            ? ImageFilter.blur(sigmaX: 3, sigmaY: 3)
            : ImageFilter.blur(),
        child: AlertDialog(
          backgroundColor: kWhite,
          surfaceTintColor: kWhite,
          title: title is Widget
              ? title
              : title is String
              ? Text(title, style: FontPalette.hW600S14)
              : null,
          content: content is Widget
              ? content
              : Text(
                  content ?? 'This is just placeholder content.',
                  style: FontPalette.hW600S14,
                ),
          actionsPadding: const EdgeInsets.all(5),
          actions:
              actions ??
              [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Cancel',
                    style: FontPalette.hW600S14.copyWith(color: kRedColor),
                  ),
                ),
                TextButton(
                  onPressed: submitAction,
                  child: Text(
                    submitText ?? 'Yes',
                    style: FontPalette.hW600S14.copyWith(color: submitColor),
                  ),
                ),
              ],
        ),
      );
    },
  );
}

class CustomAlertDialog extends StatelessWidget {
  const CustomAlertDialog({
    this.title,
    this.content,
    this.actions,
    this.submitText,
    this.submitAction,
    this.submitColor = kBlack,
    super.key,
  });

  final dynamic title, content;
  final String? submitText;
  final List<Widget>? actions;
  final Function()? submitAction;
  final Color submitColor;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: title is Widget
          ? title
          : title is String
          ? Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: kPrimaryColor,
              ),
            )
          : null,
      content: content is Widget
          ? content
          : Text(content, style: TextStyle(fontSize: 15, color: kPrimaryColor)),
      actions:
          actions ??
          [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: kPrimaryColor),
              ),
            ),
            TextButton(
              onPressed: submitAction,
              child: Text(
                submitText ?? 'Yes',
                style: TextStyle(color: submitColor),
              ),
            ),
          ],
    );
  }
}

void showPermissionDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Microphone Permission Required'),
      content: const Text(
        'This app needs microphone access to record voice messages. Please grant permission in settings.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            openAppSettings();
          },
          child: const Text('Settings'),
        ),
      ],
    ),
  );
}
