import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:soxo_chat/shared/constants/colors.dart';
import 'package:soxo_chat/shared/themes/font_palette.dart';

class AppbarWidget extends StatelessWidget implements PreferredSizeWidget {
  const AppbarWidget({
    super.key,
    this.title,
    this.logo = false,
    this.centerTitle = true,
    this.actions = const [],
    this.color = kWhite,
    this.iconColor,
    this.actionTitle,
    this.titleColor,
    this.shadow = false,
    this.hideLeading = false,
    this.height = kToolbarHeight,
    this.style,
    this.onLeadingPressed,
    this.leadingIcon,
    this.titleWidget,
    this.automaticallyImplyLeading = true,
  });

  final String? title, actionTitle;
  final bool logo, shadow, centerTitle;
  final List<Widget> actions;
  final Color? color, iconColor, titleColor;
  final bool hideLeading, automaticallyImplyLeading;
  final double height;
  final TextStyle? style;
  final VoidCallback? onLeadingPressed;
  final Widget? leadingIcon, titleWidget;

  @override
  Widget build(BuildContext context) {
    final bool canPop = Navigator.canPop(context);

    return AppBar(
      toolbarHeight: height,
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(color: iconColor ?? kBlack, size: 20.sp),
      backgroundColor: color,
      elevation: shadow ? 1.0 : 0,
      shadowColor: shadow ? kBlack.withOpacity(0.1) : null,
      leadingWidth: logo ? 22.w : null,
      automaticallyImplyLeading: automaticallyImplyLeading,
      shape: shadow
          ? Border(
              bottom: BorderSide(color: kBlack.withOpacity(0.1), width: 0.5),
            )
          : null,
      leading: _buildLeading(context, canPop),
      titleSpacing: canPop ? 0 : null,
      title: _buildTitle(),
      centerTitle: centerTitle,
      actions: _buildActions(),
    );
  }

  Widget? _buildLeading(BuildContext context, bool canPop) {
    if (hideLeading) return null;

    if (!automaticallyImplyLeading && !canPop) return null;

    return leadingIcon ??
        IconButton(
          onPressed: onLeadingPressed ?? () => Navigator.maybePop(context),
          icon: Icon(Icons.arrow_back_ios, color: iconColor ?? kBlack),
          tooltip: 'Back',
        );
  }

  Widget? _buildTitle() {
    if (titleWidget != null) return titleWidget;

    if (title != null) {
      return Text(
        title!,
        style: (style ?? FontPalette.hW700S14).copyWith(color: titleColor),
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      );
    }

    return null;
  }

  List<Widget> _buildActions() {
    if (actionTitle != null) {
      return [
        TextButton(
          onPressed: () {}, // Add your action callback
          child: Text(
            actionTitle!,
            style: FontPalette.hW700S14.copyWith(color: iconColor ?? kBlack),
          ),
        ),
        SizedBox(width: 8.w),
      ];
    }

    return actions;
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
