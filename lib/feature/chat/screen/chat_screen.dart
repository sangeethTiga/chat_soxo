import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as path;
import 'package:soxo_chat/feature/chat/cubit/chat_cubit.dart';
import 'package:soxo_chat/feature/chat/screen/widgets/build_chat_item.dart';
import 'package:soxo_chat/feature/chat/screen/widgets/floating_button.dart';
import 'package:soxo_chat/feature/person_lists/cubit/person_lists_cubit.dart';
import 'package:soxo_chat/shared/animation/empty_state.dart';
import 'package:soxo_chat/shared/app/list/helper.dart';
import 'package:soxo_chat/shared/routes/routes.dart';
import 'package:soxo_chat/shared/widgets/appbar/appbar.dart';

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

  // Cache static decorations
  late final BoxDecoration _backgroundDecoration;
  late final BoxDecoration _containerDecoration;

  @override
  void initState() {
    super.initState();
    _initializeDecorations();
    _initializeAnimations();
    _loadData();
    _startAnimations();
  }

  void _initializeDecorations() {
    _backgroundDecoration = const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFF2F2F2), Color(0xFFB7E8CA)],
      ),
    );

    _containerDecoration = BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
    );
  }

  void _loadData() {
    // Load data only once
    context.read<ChatCubit>().getChatList();
    context.read<PersonListsCubit>().getPersonList();
  }

  void _initializeAnimations() {
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

  Future<bool> _showLogoutDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => _LogoutDialog(),
    );
    return result ?? false;
  }

  void _onTabTapped(String value) {
    HapticFeedback.lightImpact();
    context.read<ChatCubit>().selectedTab(value);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _showLogoutDialog();
      },
      child: Scaffold(
        appBar: buildSeamlessAppBar(
          title: 'Chat',
          context,
          {},
          isLeading: false,
        ),
        body: Container(
          decoration: _backgroundDecoration,
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: _containerDecoration,
                  child: Column(
                    children: [
                      _AnimatedTabs(
                        tabAnimationController: _tabAnimationController,
                        tabSlideAnimation: _tabSlideAnimation,
                        tabScrollController: _tabScrollController,
                        onTabTapped: _onTabTapped,
                      ),
                      _AnimatedChatList(
                        listAnimationController: _listAnimationController,
                        listSlideAnimation: _listSlideAnimation,
                        scrollController: _scrollController,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: ExpandableFab.location,
        floatingActionButton: FlatingWidget(keys: _key),
      ),
    );
  }
}

// Extracted to prevent rebuilds of the entire dialog
class _LogoutDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      title: Row(
        children: [
          Icon(Icons.logout_rounded, color: Colors.red[600], size: 24.sp),
          SizedBox(width: 12.w),
          Text(
            'Logout',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
      content: Text(
        'Are you sure you want to logout from your account?',
        style: TextStyle(fontSize: 16.sp, color: Colors.grey[600], height: 1.4),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          child: Text(
            'Cancel',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ),
        SizedBox(width: 8.w),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(true);
            Helper().logout(context);
            if (context.mounted) {
              context.go(routeSignIn);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[600],
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            elevation: 0,
          ),
          child: Text(
            'Logout',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

// Extracted tabs section to prevent unnecessary rebuilds
class _AnimatedTabs extends StatelessWidget {
  final AnimationController tabAnimationController;
  final Animation<double> tabSlideAnimation;
  final ScrollController tabScrollController;
  final Function(String) onTabTapped;

  const _AnimatedTabs({
    required this.tabAnimationController,
    required this.tabSlideAnimation,
    required this.tabScrollController,
    required this.onTabTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCubit, ChatState>(
      buildWhen: (previous, current) =>
          previous.selectedTab != current.selectedTab,
      builder: (context, state) {
        return AnimatedBuilder(
          animation: tabAnimationController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(tabSlideAnimation.value, 0),
              child: Container(
                padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 12.h),
                child: SizedBox(
                  height: 30.h,
                  child: ListView.separated(
                    controller: tabScrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: chatTab.length,
                    separatorBuilder: (context, index) => SizedBox(width: 6.w),
                    itemBuilder: (context, index) {
                      return _TabItem(
                        index: index,
                        tab: chatTab[index],
                        isSelected: state.selectedTab == chatTab[index].type,
                        onTap: () => onTabTapped(chatTab[index].type),
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
}

class _TabItem extends StatelessWidget {
  final int index;
  final dynamic tab;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabItem({
    required this.index,
    required this.tab,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
              onTap: onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                transform: Matrix4.identity()..scale(isSelected ? 1.00 : 1.0),
                child: buildTab(
                  tab.name,
                  isSelected,
                  width: index == 0 ? 20.w : 8.w,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AnimatedChatList extends StatelessWidget {
  final AnimationController listAnimationController;
  final Animation<double> listSlideAnimation;
  final ScrollController scrollController;

  const _AnimatedChatList({
    required this.listAnimationController,
    required this.listSlideAnimation,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedBuilder(
        animation: listAnimationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, listSlideAnimation.value),
            child: Opacity(
              opacity: listAnimationController.value,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: BlocBuilder<ChatCubit, ChatState>(
                  buildWhen: (previous, current) =>
                      previous.chatList != current.chatList ||
                      previous.selectedTab != current.selectedTab,
                  builder: (context, state) {
                    final filteredChats = state.chatList ?? [];

                    if (filteredChats.isEmpty) {
                      return AnimatedEmptyState(
                        selectedTab: state.selectedTab ?? 'all',
                      );
                    }

                    return _ChatListView(
                      filteredChats: filteredChats,
                      scrollController: scrollController,
                      listAnimationController: listAnimationController,
                      state: state,
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
}

class _ChatListView extends StatelessWidget {
  final List<dynamic> filteredChats;
  final ScrollController scrollController;
  final AnimationController listAnimationController;
  final ChatState state;

  const _ChatListView({
    required this.filteredChats,
    required this.scrollController,
    required this.listAnimationController,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: scrollController,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(bottom: 100.h),
      itemCount: filteredChats.length,
      separatorBuilder: (context, index) => SizedBox(height: 0.h),
      itemBuilder: (context, index) {
        final data = filteredChats[index];
        return _ChatListItem(
          index: index,
          data: data,
          state: state,
          listAnimationController: listAnimationController,
        );
      },
    );
  }
}

class _ChatListItem extends StatelessWidget {
  final int index;
  final dynamic data;
  final ChatState state;
  final AnimationController listAnimationController;

  const _ChatListItem({
    required this.index,
    required this.data,
    required this.state,
    required this.listAnimationController,
  });

  @override
  Widget build(BuildContext context) {
    final delay = (index * 0.1).clamp(0.0, 1.0);

    return AnimatedBuilder(
      animation: listAnimationController,
      builder: (context, child) {
        final itemProgress = (listAnimationController.value - delay).clamp(
          0.0,
          1.0,
        );
        final itemTranslate = (1 - itemProgress) * 30;

        return Transform.translate(
          offset: Offset(0, itemTranslate),
          child: Opacity(
            opacity: listAnimationController.value,
            child: GestureDetector(
              onTap: () => _onChatItemTapped(context, index, state),
              child: buildChatItem(
                imageUrl: data.otherDetail1 ?? '',
                name: data.title ?? '',
                message: data.description ?? '',
                time: getFormattedDate(data.updatedAt ?? ''),
                unreadCount: data.unreadCount,
              ),
            ),
          ),
        );
      },
    );
  }

  void _onChatItemTapped(BuildContext context, int index, ChatState state) {
    HapticFeedback.selectionClick();
    context.read<ChatCubit>().getChatEntry(
      chatId: state.chatList?[index].chatId,
    );
    context.read<ChatCubit>().initStateClear();
    context.read<ChatCubit>().getChatListBackground();

    context.push(
      routeChatDetail,
      extra: {
        "title": state.chatList?[index].title,
        "chat_id": state.chatList?[index].chatId,
        "image": state.chatList?[index].otherDetail1,
        "type": state.chatList?[index].type,
      },
    );
  }
}

// Utility class remains the same but can be optimized further
class PdfNameExtractor {
  // Cached regex patterns for better performance
  static final RegExp _pdfExtensionRegex = RegExp(
    r'\.pdf$',
    caseSensitive: false,
  );

  static String extractFileNameFromUrl(String fileUrl) {
    try {
      final uri = Uri.parse(fileUrl);
      String fileName = path.basename(uri.path);

      if (!_pdfExtensionRegex.hasMatch(fileName)) {
        fileName = '$fileName.pdf';
      }

      if (fileName.isEmpty || fileName == '.pdf') {
        return 'Document.pdf';
      }

      return fileName;
    } catch (e) {
      return 'Document.pdf';
    }
  }

  static String extractFileNameFromPath(String filePath) {
    try {
      final String fileName = path.basename(filePath);
      return fileName.isEmpty ? 'Document.pdf' : fileName;
    } catch (e) {
      return 'Document.pdf';
    }
  }
}
