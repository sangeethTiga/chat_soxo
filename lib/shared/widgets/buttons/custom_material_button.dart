import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:soxo_chat/shared/constants/colors.dart';
import 'package:soxo_chat/shared/themes/font_palette.dart';

class CustomMaterialBtton extends StatelessWidget {
  const CustomMaterialBtton({
    required this.onPressed,
    this.buttonText = 'Submit',
    this.textStyle,
    this.child,
    this.leading,
    this.height = 45,
    this.fontSize,
    this.textColor,
    this.color,
    this.minWidth = double.infinity,
    this.padding,
    super.key,
    this.fontWeight = FontWeight.w500,
    this.borderRadius = 8,
    this.borderColor,
    this.elevation = 0,
    this.margin,
    this.loadingColor = kWhite,
    this.isLoading = false,
    this.shimmer = false,
    this.shrinkWrap = false,
  });
  final Widget? child;
  final String buttonText;
  final Widget? leading;
  final double? fontSize;
  final Color? textColor;
  final Color? color;
  final double? minWidth;
  final double height;
  final Function() onPressed;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;
  final FontWeight? fontWeight;
  final double? borderRadius;
  final Color? borderColor;
  final double? elevation;
  final EdgeInsets? margin;
  final bool isLoading;
  final Color? loadingColor;
  final bool shimmer;
  final bool shrinkWrap;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: MaterialButton(
        materialTapTargetSize: shrinkWrap
            ? MaterialTapTargetSize.shrinkWrap
            : MaterialTapTargetSize.padded,
        height: height,
        minWidth: minWidth,
        onPressed: !isLoading ? onPressed : () {},
        color: color ?? kPrimaryColor,
        splashColor: borderColor,
        elevation: elevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 8.r),
          side: BorderSide(color: borderColor ?? kPrimaryColor),
        ),
        child: SizedBox(
          height: height,
          child: isLoading
              ? Center(
                  child: SizedBox(
                    height: height / 2,
                    width: height / 2,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.75,
                      color: loadingColor,
                    ),
                  ),
                )
              : child ??
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (leading != null) leading!,
                        if (leading != null) 8.verticalSpace,
                        Flexible(
                          child: FittedBox(
                            child: Text(
                              buttonText,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  textStyle ??
                                  FontPalette.hW700S14.copyWith(
                                    color: textColor ?? kWhite,
                                    letterSpacing: 0,
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}
