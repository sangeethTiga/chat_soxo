import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:soxo_chat/feature/chat/cubit/chat_cubit.dart';
import 'package:soxo_chat/feature/chat/screen/widgets/appbar.dart';
import 'package:soxo_chat/feature/chat/screen/widgets/build_chat_item.dart';
import 'package:soxo_chat/feature/chat/screen/widgets/build_tab.dart';
import 'package:soxo_chat/feature/chat/screen/widgets/floating_button.dart';
import 'package:soxo_chat/feature/person_lists/cubit/person_lists_cubit.dart';
import 'package:soxo_chat/shared/animation/empty_state.dart';
import 'package:soxo_chat/shared/app/list/helper.dart';
import 'package:soxo_chat/shared/routes/routes.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final GlobalKey<ExpandableFabState> _key = GlobalKey<ExpandableFabState>();

  late AnimationController _containerAnimationController;
  late AnimationController _listAnimationController;
  late AnimationController _tabAnimationController;

  late Animation<double> _containerSlideAnimation;
  late Animation<double> _containerOpacityAnimation;
  late Animation<double> _tabSlideAnimation;
  late Animation<double> _listSlideAnimation;

  final ScrollController _scrollController = ScrollController();
  final ScrollController _tabScrollController = ScrollController();

  final int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    context.read<ChatCubit>().getChatList();
    context.read<PersonListsCubit>().getPersonList();
    _containerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _tabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _containerSlideAnimation = Tween<double>(begin: 100.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _containerAnimationController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _containerOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _containerAnimationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _tabSlideAnimation = Tween<double>(begin: -50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _tabAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _listSlideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _listAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  void _startAnimations() {
    _containerAnimationController.forward();

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _tabAnimationController.forward();
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _listAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _containerAnimationController.dispose();
    _listAnimationController.dispose();
    _tabAnimationController.dispose();
    _scrollController.dispose();
    _tabScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildSeamlessAppBar(title: 'Chat', context, {}, isLeading: false),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF2F2F2), Color(0xFFB7E8CA)],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24.r),
                  ),
                ),
                child: Column(
                  children: [_buildAnimatedTabs(), _buildAnimatedChatList()],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: FlatingWidget(keys: _key),
    );
  }

  Widget _buildAnimatedTabs() {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        return AnimatedBuilder(
          animation: _tabAnimationController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_tabSlideAnimation.value, 0),
              child: Container(
                padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 12.h),
                child: SizedBox(
                  height: 30.h,
                  child: ListView.separated(
                    controller: _tabScrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: chatTab.length,
                    separatorBuilder: (context, index) => SizedBox(width: 6.w),
                    itemBuilder: (context, index) {
                      return TweenAnimationBuilder<double>(
                        duration: Duration(milliseconds: 600 + (index * 100)),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          final clampedValue = value.clamp(0.0, 1.0);

                          return Transform.scale(
                            scale: 0.8 + (0.2 * clampedValue),
                            child: Opacity(
                              opacity: clampedValue,
                              child: GestureDetector(
                                onTap: () => _onTabTapped(chatTab[index].type),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  transform: Matrix4.identity()
                                    ..scale(
                                      _selectedTabIndex == index ? 1.00 : 1.0,
                                    ),
                                  child: buildTab(
                                    chatTab[index].name,
                                    state.selectedTab == chatTab[index].type,
                                    width: index == 0 ? 20.w : 8.w,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAnimatedChatList() {
    return Expanded(
      child: AnimatedBuilder(
        animation: _listAnimationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _listSlideAnimation.value),
            child: Opacity(
              opacity: _listAnimationController.value,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: BlocBuilder<ChatCubit, ChatState>(
                  builder: (context, state) {
                    final filteredChats = state.chatList ?? [];

                    if (filteredChats.isEmpty) {
                      return AnimatedEmptyState(
                        selectedTab: state.selectedTab ?? 'all',
                      );
                    }

                    return ListView.separated(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.only(bottom: 100.h),
                      itemCount: filteredChats.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 0.h),
                      itemBuilder: (context, index) {
                        final data = filteredChats[index];

                        final delay = index * 100;
                        final progress =
                            (_listAnimationController.value * 1000 - delay) /
                            400;
                        final itemOpacity = progress.clamp(0.0, 1.0);
                        final itemTranslate = (1 - itemOpacity) * 30;

                        return Transform.translate(
                          offset: Offset(0, itemTranslate),
                          child: Opacity(
                            opacity: itemOpacity,
                            child: GestureDetector(
                              onTap: () =>
                                  onChatItemTappedWithGo(index, state, context),
                              child: buildChatItem(
                                name: data.title ?? '',
                                message: data.description ?? '',
                                time: getFormattedDate(data.updatedAt ?? ''),
                                unreadCount: 2,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _onTabTapped(String value) {
    HapticFeedback.lightImpact();
    context.read<ChatCubit>().selectedTab(value);
  }
}

void onChatItemTappedWithGo(int index, ChatState state, BuildContext context) {
  HapticFeedback.selectionClick();

  context.read<ChatCubit>().getChatEntry(
    chatId: state.chatList?[index].chatId,
    userId: 2,
  );

  context.read<ChatCubit>().initStateClear();

  context.push(
    routeChatDetail,
    extra: {
      "title": state.chatList?[index].title,
      "chatId": state.chatList?[index].chatId,
    },
  );
}

// void _onChatItemTapped(int index, ChatState state, BuildContext context) {
//   HapticFeedback.selectionClick();
//   context.read<ChatCubit>().getChatEntry(
//     chatId: state.chatList?[index].chatId,
//     userId: 2,
//   );
//   context.read<ChatCubit>().initStateClear();
//   Navigator.of(context).push(
//     PageRouteBuilder(
//       pageBuilder: (context, animation, secondaryAnimation) {
//         return ChatDetailScreen(
//           data: {
//             "title": state.chatList?[index].title,
//             // "description": state.chatList?[index].description,
//           },
//         );
//       },
//       transitionsBuilder: (context, animation, secondaryAnimation, child) {
//         const begin = Offset(1.0, 0.0);
//         const end = Offset.zero;
//         const curve = Curves.fastOutSlowIn;

//         var tween = Tween(
//           begin: begin,
//           end: end,
//         ).chain(CurveTween(curve: curve));

//         return SlideTransition(
//           position: animation.drive(tween),
//           child: FadeTransition(opacity: animation, child: child),
//         );
//       },
//       transitionDuration: const Duration(milliseconds: 400),
//     ),
//   );
// }
