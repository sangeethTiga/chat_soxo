import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:soxo_chat/feature/chat/cubit/chat_cubit.dart';
import 'package:soxo_chat/feature/chat/domain/models/chat_entry/chat_entry_response.dart';
import 'package:soxo_chat/feature/chat/domain/models/chat_res/chat_list_response.dart';
import 'package:soxo_chat/feature/chat/screen/widgets/user_data.dart';
import 'package:soxo_chat/shared/constants/colors.dart';

class WhatsAppForwardBottomSheet extends StatefulWidget {
  final Entry messageToForward;

  const WhatsAppForwardBottomSheet({super.key, required this.messageToForward});

  @override
  State<WhatsAppForwardBottomSheet> createState() =>
      _WhatsAppForwardBottomSheetState();
}

class _WhatsAppForwardBottomSheetState extends State<WhatsAppForwardBottomSheet>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<ChatListResponse> _filteredChats = [];
  bool _isSearching = false;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    context.read<ChatCubit>().startForward(widget.messageToForward);
    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _filterChats(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
      final allChats = context.read<ChatCubit>().state.allChats ?? [];

      if (query.isEmpty) {
        _filteredChats = allChats;
      } else {
        _filteredChats = allChats.where((chat) {
          return (chat.title ?? '').toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            0,
            MediaQuery.of(context).size.height * _slideAnimation.value,
          ),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
              ),
              child: Column(
                children: [
                  // Top handle
                  Container(
                    width: 35.w,
                    height: 4.h,
                    margin: EdgeInsets.only(top: 8.h, bottom: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),

                  // Header section
                  _buildHeader(),

                  // Quick actions section
                  // _buildQuickActions(),

                  // Search bar
                  _buildSearchBar(),

                  // Frequently contacted section
                  // _buildFrequentlyContacted(),

                  // All chats section
                  _buildAllChatsSection(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              context.read<ChatCubit>().cancelForward();
              Navigator.pop(context);
            },
            child: Icon(Icons.close, size: 24, color: Colors.grey[700]),
          ),
          SizedBox(width: 16.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Forward to...',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 2.h),
              BlocBuilder<ChatCubit, ChatState>(
                buildWhen: (previous, current) =>
                    previous.selectedChatsForForward?.length !=
                    current.selectedChatsForForward?.length,
                builder: (context, state) {
                  final selectedCount =
                      state.selectedChatsForForward?.length ?? 0;
                  return selectedCount > 0
                      ? Text(
                          '$selectedCount selected',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.green[600],
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      : SizedBox.shrink();
                },
              ),
            ],
          ),
          Spacer(),
          BlocBuilder<ChatCubit, ChatState>(
            buildWhen: (previous, current) =>
                previous.selectedChatsForForward?.length !=
                    current.selectedChatsForForward?.length ||
                previous.isForwarding != current.isForwarding,
            builder: (context, state) {
              final selectedCount = state.selectedChatsForForward?.length ?? 0;

              return selectedCount > 0
                  ? Container(
                      decoration: BoxDecoration(
                        color: kPrimaryColor,
                        borderRadius: BorderRadius.circular(50.r),
                      ),
                      child: IconButton(
                        onPressed: () async {
                          await context
                              .read<ChatCubit>()
                              .forwardMessageToSelectedChats();
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Message forwarded to $selectedCount chat(s)',
                                ),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                                margin: EdgeInsets.all(16.w),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                              ),
                            );
                          }
                        },
                        icon: Icon(Icons.send, color: Colors.white, size: 20),
                      ),
                    )
                  : SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      height: 80.h,
      margin: EdgeInsets.symmetric(vertical: 8.h),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        children: [
          _buildQuickActionItem(
            icon: Icons.bookmark_outline,
            label: 'Saved Messages',
            onTap: () {
              // Handle saved messages
            },
          ),
          _buildQuickActionItem(
            icon: Icons.groups_outlined,
            label: 'New Group',
            onTap: () {
              // Handle new group
            },
          ),
          _buildQuickActionItem(
            icon: Icons.person_add_outlined,
            label: 'New Contact',
            onTap: () {
              // Handle new contact
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70.w,
        margin: EdgeInsets.only(right: 16.w),
        child: Column(
          children: [
            Container(
              width: 50.w,
              height: 50.h,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 24, color: Colors.grey[600]),
            ),
            SizedBox(height: 6.h),
            Text(
              label,
              style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _filterChats,
        style: TextStyle(fontSize: 16.sp),
        decoration: InputDecoration(
          hintText: 'Search',
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16.sp),
          prefixIcon: Icon(Icons.search, color: Colors.grey[500], size: 20),
          suffixIcon: _isSearching
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey[500], size: 20),
                  onPressed: () {
                    _searchController.clear();
                    _filterChats('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
        ),
      ),
    );
  }

  Widget _buildFrequentlyContacted() {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        final recentChats = (state.allChats ?? []).take(5).toList();

        if (recentChats.isEmpty) return SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Text(
                'Frequently contacted',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(
              height: 80.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: recentChats.length,
                itemBuilder: (context, index) {
                  final chat = recentChats[index];
                  final isSelected =
                      state.selectedChatsForForward?.any(
                        (selected) => selected.chatId == chat.chatId,
                      ) ??
                      false;

                  return _buildFrequentContactItem(chat, isSelected);
                },
              ),
            ),
            SizedBox(height: 8.h),
          ],
        );
      },
    );
  }

  Widget _buildFrequentContactItem(ChatListResponse chat, bool isSelected) {
    return GestureDetector(
      onTap: () {
        context.read<ChatCubit>().toggleChatForForward(chat);
      },
      child: Container(
        width: 65.w,
        margin: EdgeInsets.only(right: 12.w),
        child: Column(
          children: [
            Stack(
              children: [
                CachedChatAvatar(
                  name: chat.title ?? '',
                  imageUrl: chat.otherDetail1,
                ),
                // Container(
                //   width: 50.w,
                //   height: 50.h,
                //   decoration: BoxDecoration(
                //     shape: BoxShape.circle,
                //     border: isSelected
                //         ? Border.all(color: Colors.green[600]!, width: 3)
                //         : null,
                //   ),
                //   child: CircleAvatar(
                //     radius: 25.r,
                //     backgroundImage: chat.otherDetail1?.isNotEmpty == true
                //         ? NetworkImage(chat.otherDetail1!)
                //         : null,
                //     backgroundColor: Colors.grey[300],
                //     child: chat.otherDetail1?.isEmpty != false
                //         ? Text(
                //             chat.title?.substring(0, 1).toUpperCase() ?? 'C',
                //             style: TextStyle(
                //               fontWeight: FontWeight.bold,
                //               color: Colors.white,
                //               fontSize: 18.sp,
                //             ),
                //           )
                //         : null,
                //   ),
                // ),
                if (isSelected)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 20.w,
                      height: 20.h,
                      decoration: BoxDecoration(
                        color: kPrimaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(Icons.check, size: 12, color: Colors.white),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 6.h),
            Text(
              chat.title ?? 'Unknown',
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllChatsSection() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Text(
              'All chats',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<ChatCubit, ChatState>(
              buildWhen: (previous, current) =>
                  previous.allChats != current.allChats ||
                  previous.selectedChatsForForward !=
                      current.selectedChatsForForward,
              builder: (context, state) {
                final chats = _isSearching
                    ? _filteredChats
                    : (state.allChats ?? []);

                if (chats.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isSearching ? Icons.search_off : Icons.chat_outlined,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          _isSearching
                              ? 'No chats found'
                              : 'No chats available',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    final chat = chats[index];
                    final isSelected =
                        state.selectedChatsForForward?.any(
                          (selected) => selected.chatId == chat.chatId,
                        ) ??
                        false;

                    return WhatsAppChatTile(
                      chat: chat,
                      isSelected: isSelected,
                      onTap: () {
                        context.read<ChatCubit>().toggleChatForForward(chat);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class WhatsAppChatTile extends StatelessWidget {
  final ChatListResponse chat;
  final bool isSelected;
  final VoidCallback onTap;

  const WhatsAppChatTile({
    super.key,
    required this.chat,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? Colors.green[50] : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            children: [
              // Avatar with selection indicator
              Stack(
                children: [
                  CachedChatAvatar(
                    name: chat.title ?? '',
                    imageUrl: chat.otherDetail1,
                  ),
                  // Container(
                  //   decoration: BoxDecoration(
                  //     shape: BoxShape.circle,
                  //     border: isSelected
                  //         ? Border.all(color: Colors.green[600]!, width: 2)
                  //         : null,
                  //   ),
                  //   child: CircleAvatar(
                  //     radius: 25.r,
                  //     backgroundImage: chat.otherDetail1?.isNotEmpty == true
                  //         ? NetworkImage(chat.otherDetail1!)
                  //         : null,
                  //     backgroundColor: _getAvatarColor(chat.title ?? ''),
                  //     child: chat.otherDetail1?.isEmpty != false
                  //         ? Text(
                  //             chat.title?.substring(0, 1).toUpperCase() ?? 'C',
                  //             style: TextStyle(
                  //               fontWeight: FontWeight.bold,
                  //               color: Colors.white,
                  //               fontSize: 18.sp,
                  //             ),
                  //           )
                  //         : null,
                  //   ),
                  // ),
                  if (isSelected)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 18.w,
                        height: 18.h,
                        decoration: BoxDecoration(
                          color: kPrimaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Icon(Icons.check, size: 10, color: Colors.white),
                      ),
                    ),
                ],
              ),

              SizedBox(width: 16.w),

              // Chat info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chat.title ?? 'Unknown Chat',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.green[700] : Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (chat.description?.isNotEmpty == true) ...[
                      SizedBox(height: 2.h),
                      Text(
                        chat.description!,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Chat type indicator
              if (chat.type?.toLowerCase() == 'group')
                Icon(Icons.group, size: 18, color: Colors.grey[500]),
            ],
          ),
        ),
      ),
    );
  }

  Color _getAvatarColor(String name) {
    final colors = [
      Colors.red[400]!,
      Colors.pink[400]!,
      Colors.purple[400]!,
      Colors.deepPurple[400]!,
      Colors.indigo[400]!,
      Colors.blue[400]!,
      Colors.lightBlue[400]!,
      Colors.cyan[400]!,
      Colors.teal[400]!,
      Colors.green[400]!,
      Colors.lightGreen[400]!,
      Colors.lime[400]!,
      Colors.yellow[400]!,
      Colors.amber[400]!,
      Colors.orange[400]!,
      Colors.deepOrange[400]!,
    ];

    return colors[name.hashCode % colors.length];
  }
}
