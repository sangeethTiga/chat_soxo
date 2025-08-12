import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:soxo_chat/shared/constants/colors.dart';
import 'package:soxo_chat/shared/themes/font_palette.dart';

void kSnackBar({
  required String content,
  double? height,
  Color color = kWhite,
  IconData? icon,
  int duration = 3000,
  bool error = false,
  bool success = false,
  bool warning = false,
  bool delete = false,
  bool update = false,
  bool floating = false,
  bool infinite = false,
  SnackBarAction? action,
  required BuildContext navigatorKey,
}) {
  ScaffoldMessenger.of(navigatorKey).hideCurrentSnackBar();

  ScaffoldMessenger.of(navigatorKey).showSnackBar(
    SnackBar(
      content: SizedBox(
        height: height,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null)
              Icon(icon, color: kSnackBarIconColor, size: 18.sp)
            else
              error == true
                  ? Icon(
                      Icons.error_outline,
                      color: kSnackBarIconColor,
                      size: 18,
                    )
                  : success == true
                  ? Icon(Icons.done, color: kSnackBarIconColor, size: 18.sp)
                  : delete == true
                  ? Icon(Icons.delete, color: kSnackBarIconColor, size: 18.sp)
                  : update == true
                  ? Icon(Icons.update, color: kSnackBarIconColor, size: 18.sp)
                  : const SizedBox(),
            const VerticalDivider(width: 5),
            Flexible(
              child: Text(
                content,
                softWrap: false,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: FontPalette.hW500S14.copyWith(color: kWhite),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: color,
      duration: infinite
          ? const Duration(days: 1)
          : Duration(milliseconds: duration),
      behavior: floating ? SnackBarBehavior.floating : SnackBarBehavior.fixed,
      action: action,
    ),
  );
}

SnackBar kGetSnackBar({
  required BuildContext context,
  required String content,
  double? height,
  Color color = kWhite,
  IconData? icon,
  int duration = 3500,
  bool error = false,
  bool success = false,
  bool delete = false,
  bool update = false,
  bool floating = false,
  SnackBarAction? action,
}) {
  return SnackBar(
    content: SizedBox(
      height: height,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Icon(icon, color: kSnackBarIconColor, size: 18.sp)
          else
            error == true
                ? Icon(Icons.error_outline, color: kSnackBarIconColor, size: 18)
                : success == true
                ? Icon(Icons.done, color: kSnackBarIconColor, size: 18.sp)
                : delete == true
                ? Icon(Icons.delete, color: kSnackBarIconColor, size: 18.sp)
                : update == true
                ? Icon(Icons.update, color: kSnackBarIconColor, size: 18.sp)
                : const SizedBox(),
          const VerticalDivider(width: 5),
          Flexible(
            child: Text(
              content,
              softWrap: false,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: FontPalette.hW500S14.copyWith(color: kWhite),
            ),
          ),
        ],
      ),
    ),
    backgroundColor: error == true
        ? kRedColor
        : success == true
        ? kPrimaryColor
        : delete == true
        ? kRedColor
        : update == true
        ? kPrimaryColor
        : color,
    duration: Duration(milliseconds: duration),
    behavior: floating ? SnackBarBehavior.floating : SnackBarBehavior.fixed,
    action: action,
  );
}

void kSnackBars({
  required BuildContext context,
  required String content,
  Color color = kRedColor,
  bool floating = false,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(content, style: FontPalette.hW600S14),
      backgroundColor: color,
      behavior: floating ? SnackBarBehavior.floating : SnackBarBehavior.fixed,
      action: (actionLabel != null && onAction != null)
          ? SnackBarAction(
              label: actionLabel,
              onPressed: onAction,
              textColor: Colors.white,
            )
          : null,
    ),
  );
}
