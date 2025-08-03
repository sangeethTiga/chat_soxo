import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:soxo_chat/feature/chat/cubit/chat_cubit.dart';
import 'package:soxo_chat/shared/constants/colors.dart';
import 'package:soxo_chat/shared/themes/font_palette.dart';

void showRecordingDialog(
  BuildContext context,
  Animation<double> pulseAnimation,
  VoidCallback cancelRecording,
  VoidCallback stopRecording,
) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: pulseAnimation.value,
                      child: Container(
                        height: 60.h,
                        width: 60.w,
                        decoration: BoxDecoration(
                          color: kPrimaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: kPrimaryColor.withOpacity(0.5),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.mic,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    );
                  },
                ),

                20.verticalSpace,

                Text(
                  'Recording...',
                  style: FontPalette.hW400S16.copyWith(color: Colors.red),
                ),

                10.verticalSpace,
                Text(
                  context.read<ChatCubit>().formatDuration(
                    state.recordingDuration,
                  ),
                  style: FontPalette.hW400S14.copyWith(
                    color: Colors.grey[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),

                30.verticalSpace,

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: cancelRecording,
                      child: Container(
                        height: 35.h,
                        padding: EdgeInsets.only(left: 10.w, right: 10.w),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.close, color: Colors.red),
                            5.horizontalSpace,
                            Text(
                              'Cancel',
                              style: FontPalette.hW500S14.copyWith(
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    10.horizontalSpace,
                    GestureDetector(
                      onTap: stopRecording,
                      child: Container(
                        height: 35.h,
                        padding: EdgeInsets.only(left: 10.w, right: 10.w),
                        decoration: BoxDecoration(
                          color: kPrimaryColor,
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: kPrimaryColor.withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.send, color: Colors.white),
                            5.horizontalSpace,
                            Text(
                              'Send',
                              style: FontPalette.hW500S14.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
