import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:soxo_chat/feature/chat/cubit/chat_cubit.dart';
import 'package:soxo_chat/feature/chat/screen/chat_detail_screen.dart';
import 'package:soxo_chat/feature/chat/screen/widgets/appbar.dart';
import 'package:soxo_chat/feature/chat/screen/widgets/build_chat_item.dart';
import 'package:soxo_chat/feature/chat/screen/widgets/build_tab.dart';
import 'package:soxo_chat/feature/chat/screen/widgets/flating_button.dart';

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

  int _selectedTabIndex = 0;
  final List<String> _tabs = [
    'All',
    'Group Chat',
    'Personal Chat',
    'Broadcast',
  ];

  final List<ChatItemData> _chatItems = [
    ChatItemData(
      'RD',
      Colors.blue,
      'Internal Review',
      'Pls Review',
      'Today',
      1,
    ),
    ChatItemData('AT', Colors.green, 'Anoop Ts', 'How is it going?', '17/5', 0),
    ChatItemData(
      'CS',
      Colors.deepOrange,
      'Case Study\'s',
      'Please check xray image',
      'Today',
      1,
    ),
    ChatItemData(
      'MK',
      Colors.purple,
      'Marketing Team',
      'New campaign ready',
      'Yesterday',
      2,
    ),
    ChatItemData(
      'PR',
      Colors.teal,
      'Project Review',
      'Meeting at 3 PM',
      'Today',
      0,
    ),
    ChatItemData(
      'DT',
      Colors.amber,
      'Design Team',
      'UI mockups uploaded',
      '16/5',
      3,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    context.read<ChatCubit>().getChatList();
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
                itemCount: _tabs.length,
                separatorBuilder: (context, index) => SizedBox(width: 8.w),
                itemBuilder: (context, index) {
                  return TweenAnimationBuilder<double>(
                    duration: Duration(milliseconds: 600 + (index * 100)),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: 0.8 + (0.2 * value),
                        child: Opacity(
                          opacity: value,
                          child: GestureDetector(
                            onTap: () => _onTabTapped(index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              transform: Matrix4.identity()
                                ..scale(
                                  _selectedTabIndex == index ? 1.00 : 1.0,
                                ),
                              child: buildTab(
                                _tabs[index],
                                _selectedTabIndex == index,
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
  }

  Widget _buildAnimatedChatList() {
    return Expanded(
      child: AnimatedBuilder(
        animation: _listAnimationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _listSlideAnimation.value),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: BlocBuilder<ChatCubit, ChatState>(
                builder: (context, state) {
                  return ListView.separated(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(bottom: 100.h),
                    itemCount: state.chatList?.length ?? 0,
                    separatorBuilder: (context, index) => SizedBox(height: 4.h),
                    itemBuilder: (context, index) {
                      final data = state.chatList?[index];
                      return TweenAnimationBuilder<double>(
                        duration: Duration(milliseconds: 800 + (index * 150)),
                        tween: Tween(begin: 0.0, end: 1.0),
                        curve: Curves.easeOutBack,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: 0.9 + (0.1 * value),
                            child: GestureDetector(
                              onTap: () => _onChatItemTapped(index, state),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.r),
                                  color: Colors.transparent,
                                ),
                                child: buildChatItem(
                                  _chatItems[index].initials,
                                  _chatItems[index].color,
                                  data?.title ?? '',
                                  data?.description ?? '',
                                  getFormattedDate(data?.updatedAt ?? ''),
                                  _chatItems[index].unreadCount,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  void _onTabTapped(int index) {
    if (_selectedTabIndex != index) {
      setState(() {
        _selectedTabIndex = index;
      });
      HapticFeedback.lightImpact();
      final double targetOffset = (index * 100.w).clamp(
        0.0,
        _tabScrollController.hasClients
            ? _tabScrollController.position.maxScrollExtent
            : 0.0,
      );

      if (_tabScrollController.hasClients) {
        _tabScrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _onChatItemTapped(int index, ChatState state) {
    HapticFeedback.selectionClick();
    context.read<ChatCubit>().getChatEntry(
      chatId: state.chatList?[index].chatId,
      userId: 2,
    );
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return ChatDetailScreen();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.fastOutSlowIn;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }
}

class ChatItemData {
  final String initials;
  final Color color;
  final String title;
  final String subtitle;
  final String time;
  final int unreadCount;

  ChatItemData(
    this.initials,
    this.color,
    this.title,
    this.subtitle,
    this.time,
    this.unreadCount,
  );
}

String getFormattedDate(String dateStr) {
  final DateTime inputDate = DateTime.parse(dateStr).toLocal();
  final DateTime now = DateTime.now();
  final DateTime today = DateTime(now.year, now.month, now.day);
  final DateTime inputDay = DateTime(
    inputDate.year,
    inputDate.month,
    inputDate.day,
  );

  final difference = today.difference(inputDay).inDays;

  if (difference == 0) {
    return "Today";
  } else if (difference == 1) {
    return "Yesterday";
  } else {
    return DateFormat('dd MMM yyyy').format(inputDate); // e.g. 17 Jul 2025
  }
}
