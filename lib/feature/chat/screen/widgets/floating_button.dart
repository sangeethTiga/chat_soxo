import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:soxo_chat/shared/constants/colors.dart';
import 'package:soxo_chat/shared/routes/routes.dart';

class FlatingWidget extends StatelessWidget {
  const FlatingWidget({super.key, this.keys});

  final GlobalKey<ExpandableFabState>? keys;

  @override
  Widget build(BuildContext context) {
    return ExpandableFab(
      key: keys,
      type: ExpandableFabType.up,
      childrenAnimation: ExpandableFabAnimation.none,
      openButtonBuilder: RotateFloatingActionButtonBuilder(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SvgPicture.asset('assets/icons/Group 1000007039.svg'),
        ),
        fabSize: ExpandableFabSize.regular,
        backgroundColor: Color(0xFF3D9970),
        shape: const CircleBorder(),
      ),
      distance: 58,
      closeButtonBuilder: FloatingActionButtonBuilder(
        size: 50,
        builder:
            (
              BuildContext context,
              void Function()? onPressed,
              Animation<double> progress,
            ) {
              return InkWell(
                onTap: onPressed,
                child: Container(
                  height: 46.h,
                  width: 46.w,
                  decoration: BoxDecoration(
                    color: Color(0xFF3D9970),
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SvgPicture.asset('assets/icons/close.svg'),
                  ),
                ),
              );
            },
      ),
      children: [
        FloatingActionButton.small(
          shape: const CircleBorder(),
          backgroundColor: kPrimaryColor,
          heroTag: null,
          onPressed: () {
            keys?.currentState?.close();
            context.push(
              routeGroup,
              extra: {
                'title': 'Create Group',
                'subtitle': 'Group',
                'type': 'group',
              },
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: SvgPicture.asset('assets/icons/users-two-plus.svg'),
          ),
        ),
        FloatingActionButton.small(
          shape: const CircleBorder(),
          backgroundColor: kPrimaryColor,
          heroTag: null,
          onPressed: () {
            keys?.currentState?.close();
            context.push(routePerson);
          },
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: SvgPicture.asset('assets/icons/user.svg'),
          ),
        ),
        FloatingActionButton.small(
          shape: const CircleBorder(),
          backgroundColor: kPrimaryColor,
          heroTag: null,
          onPressed: () {
            context.push(
              routeGroup,
              extra: {
                'title': 'Create Broadcast',
                'subtitle': 'Broadcast',
                'type': 'broadcast',
              },
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: SvgPicture.asset('assets/icons/notification.svg'),
          ),
        ),
      ],
    );
  }
}
