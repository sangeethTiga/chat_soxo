import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MainPadding extends StatelessWidget {
  const MainPadding({
    this.child,
    this.left,
    this.top,
    this.right,
    this.bottom,
    super.key,
  });

  final Widget? child;
  final double? left;
  final double? top;
  final double? right;
  final double? bottom;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        left ?? 12.w,
        top ?? 1.2.h,
        right ?? 12.w,
        bottom ?? 1.2.h,
      ),
      child: child,
    );
  }
}
