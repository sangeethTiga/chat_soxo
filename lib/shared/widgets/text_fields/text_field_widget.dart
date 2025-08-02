import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:soxo_chat/shared/constants/colors.dart';
import 'package:soxo_chat/shared/themes/font_palette.dart';

class TextFeildWidget extends StatelessWidget {
  const TextFeildWidget({
    super.key,
    this.labelText,
    this.topLabelText,
    this.hintText,
    this.textStyle,
    this.hintStyle,
    this.isHint = false,
    this.textInputType,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.textDirection,
    this.maxLines,
    this.maxLength,
    this.couterText,
    this.hideCounterText = false,
    this.controller,
    this.inputBorder = const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      borderSide: BorderSide(color: Colors.transparent),
    ),
    this.borderColor,
    this.prefixIcon,
    this.suffixIcon,
    this.suffixIconConstraints,
    this.autovalidateMode,
    this.validator,
    this.errorStyle = true,
    this.errorText,
    this.focusNode,
    this.enabled,
    this.isDense = true,
    this.contentPadding = const EdgeInsets.all(14),
    this.constraints,
    this.readOnly,
    this.onSaved,
    this.onChanged,
    this.onTap,
    this.obscureText,
    this.floatingLabelBehavior,
    this.fillColor,
    this.errorColor,
    this.fontSize,
    this.hintSize,
    this.textAlign = TextAlign.start,
    this.fontColor,
    this.isRequired = false,
    this.hight,
    this.prefix,
  });
  final String? labelText;
  final String? topLabelText;
  final String? hintText;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final bool isHint;
  final TextInputType? textInputType;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final TextDirection? textDirection;
  final int? maxLines, maxLength;
  final String? couterText;
  final bool hideCounterText;
  final InputBorder? inputBorder;
  final Color? borderColor;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final BoxConstraints? suffixIconConstraints;
  final TextEditingController? controller;
  final AutovalidateMode? autovalidateMode;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final bool? enabled;
  final bool? readOnly;
  final bool? isDense;
  final Function(String?)? onSaved;
  final Function(String?)? onChanged;
  final Function()? onTap;
  final BoxConstraints? constraints;
  final FloatingLabelBehavior? floatingLabelBehavior;
  final EdgeInsetsGeometry? contentPadding;
  final bool? obscureText;
  final bool errorStyle;
  final String? errorText;
  final Color? fontColor, fillColor, errorColor;
  final double? fontSize, hintSize;
  final TextAlign textAlign;
  final bool isRequired;
  final double? hight;
  final Widget? prefix;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (topLabelText != null)
          Column(
            children: [
              Text.rich(
                TextSpan(
                  text: topLabelText!,
                  children: [
                    TextSpan(
                      text: isRequired ? ' *' : '',
                      style: const TextStyle(color: kRedColor),
                    ),
                  ],
                ),
                style: FontPalette.hW500S13.copyWith(
                  color: kGreenColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              8.horizontalSpace,
            ],
          ),
        5.verticalSpace,
        SizedBox(
          height: hight,
          child: TextFormField(
            controller: controller,
            style:
                textStyle ??
                FontPalette.hW500S13.copyWith(
                  color: fontColor,
                  fontSize: fontSize ?? 15.sp,
                  fontWeight: FontWeight.w400,
                ),
            textAlign: textAlign,
            decoration: InputDecoration(
              prefixIcon: prefix ?? SizedBox(),
              prefixStyle: FontPalette.hW700S16,
              counter: const Offstage(),
              floatingLabelBehavior: floatingLabelBehavior,
              counterText: hideCounterText ? '' : couterText,
              labelText: isHint ? null : labelText,
              border: inputBorder,
              focusedBorder: inputBorder?.copyWith(
                borderSide: const BorderSide(color: Color(0XFF666C6D)),
              ),
              disabledBorder: inputBorder,
              enabledBorder: inputBorder,
              focusedErrorBorder: inputBorder,
              errorBorder: inputBorder?.copyWith(
                borderSide: const BorderSide(color: kRedColor),
              ),
              labelStyle: FontPalette.hW500S16CGrey,
              fillColor: fillColor,
              filled: true,
              // prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              suffixIconConstraints: suffixIconConstraints,
              hintText: isHint ? labelText : hintText,
              hintStyle:
                  hintStyle ??
                  TextStyle(fontSize: hintSize ?? 13.sp, color: kBlack),
              isDense: isDense,
              errorText: errorText,
              errorStyle: errorStyle
                  ? TextStyle(color: errorColor, fontSize: 10.sp, height: 1)
                  : const TextStyle(fontSize: 0.01),
              constraints: constraints,
              contentPadding: contentPadding,
            ),
            keyboardType: textInputType ?? TextInputType.text,
            textCapitalization: textCapitalization,
            inputFormatters: inputFormatters,
            textDirection: textDirection ?? TextDirection.ltr,
            maxLines: maxLines ?? 1,
            maxLength: maxLength,
            autovalidateMode: autovalidateMode ?? AutovalidateMode.disabled,
            validator: validator,
            focusNode: focusNode,
            enabled: enabled ?? true,
            readOnly: readOnly ?? false,
            onSaved: onSaved,
            onChanged: onChanged,
            onTap: onTap,
            obscureText: obscureText ?? false,
          ),
        ),
      ],
    );
  }
}

class AddressTextField extends StatelessWidget {
  final TextEditingController? textEditingController;
  final String? labelText;
  final bool? isSuffixIcon;
  final String? Function(String?)? validator;
  final Function? onTap;
  const AddressTextField({
    super.key,
    this.textEditingController,
    this.labelText,
    this.validator,
    this.isSuffixIcon = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      validator: validator,
      builder: (fieldState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 4.h, left: 12.w, right: 12.w),
              height: 48.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  width: 1,
                  color: fieldState.hasError
                      ? kRedColor
                      : const Color(0XFFB7C6C2),
                ),
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: SizedBox(
                      height: 28,
                      child: TextField(
                        controller: textEditingController,
                        onChanged: fieldState.didChange,
                        style: FontPalette.hW500S14,
                        decoration: InputDecoration(
                          disabledBorder: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 0,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,

                          filled: true,
                          fillColor: Colors.white,
                          // suffixIcon: isSuffixIcon == false
                          //     ? null
                          //     : Padding(
                          //         padding: const EdgeInsets.all(8.0),
                          //         child: InkWell(
                          //           onTap: () {
                          //             onTap!();
                          //           },
                          //           child: SvgPicture.asset(
                          //             editIcon,
                          //             height: 10.h,
                          //             width: 10.w,
                          //             color: kBlack,
                          //           ),
                          //         ),
                          //       ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 3,
                    left: 16.w,
                    child: Text(
                      labelText ?? '',
                      style: FontPalette.hW600S11.copyWith(
                        color: const Color(0XFF666C6D),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (fieldState.hasError)
              Padding(
                padding: EdgeInsets.only(left: 16.w, bottom: 8.h),
                child: Text(
                  fieldState.errorText ?? '',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
