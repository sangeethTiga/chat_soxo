import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:soxo_chat/feature/chat/cubit/chat_cubit.dart';
import 'package:soxo_chat/feature/chat/domain/models/chat_entry/chat_entry_response.dart';
import 'package:soxo_chat/feature/chat/screen/widgets/chat_bubble_widget.dart';
import 'package:soxo_chat/feature/chat/screen/widgets/pdf_viewer.dart';
import 'package:soxo_chat/feature/chat/screen/widgets/user_data.dart';
import 'package:soxo_chat/shared/constants/colors.dart';
import 'package:soxo_chat/shared/themes/font_palette.dart';
import 'package:soxo_chat/shared/widgets/appbar/appbar.dart';

class ChatProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? chatData;

  const ChatProfileScreen({super.key, this.chatData});

  @override
  State<ChatProfileScreen> createState() => _ChatProfileScreenState();
}

class _ChatProfileScreenState extends State<ChatProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final isGroup = widget.chatData?["type"] == 'group';
    _tabController = TabController(length: isGroup ? 4 : 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(title: '', context, {}, isLeading: true),
      body: BlocBuilder<ChatCubit, ChatState>(
        builder: (context, state) {
          return Container(
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
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24.r),
                        topRight: Radius.circular(24.r),
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildProfileHeader(context, state),
                        Container(
                          color: Colors.white,
                          child: TabBar(
                            controller: _tabController,
                            labelColor: Colors.blue,
                            unselectedLabelColor: Colors.grey,
                            indicatorColor: Colors.blue,
                            tabs: [
                              if (widget.chatData?["type"] == 'group') ...{
                                Tab(text: 'Members'),
                              },
                              Tab(text: 'Media'),
                              Tab(text: 'Documents'),
                              Tab(text: 'Links'),
                            ],
                          ),
                        ),
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              if (widget.chatData?["type"] == 'group') ...{
                                _buildMembers(state),
                              },
                              _buildMediaTab(state),
                              _buildDocumentsTab(state),
                              _buildLinksTab(state),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, ChatState state) {
    final chatTitle = widget.chatData?['title'] ?? 'Unknown';
    final chatImage = widget.chatData?['image'];
    final isGroup = widget.chatData?['type'] == 'group';

    return Container(
      padding: EdgeInsets.all(20.w),
      color: Colors.white,
      child: Column(
        children: [
          Container(
            width: 100.w,
            height: 100.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[300],
            ),
            child: chatImage != null
                ? Image.network(
                    chatImage,
                    width: 100.w,
                    height: 100.w,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildDefaultAvatar(
                          chatTitle,
                          widget.chatData?['image'],
                          isGroup,
                        ),
                  )
                : _buildDefaultAvatar(
                    chatTitle,
                    widget.chatData?['image'],
                    isGroup,
                  ),
          ),
          SizedBox(height: 16.h),
          Text(
            chatTitle,
            style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          if (isGroup) ...[
            BlocBuilder<ChatCubit, ChatState>(
              builder: (context, state) {
                final memberCount = state.chatEntry?.userChats?.length ?? 0;
                return Text(
                  'Group - $memberCount Members',
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                );
              },
            ),
          ] else ...[
            Text(
              'Last seen recently',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar(String name, String? image, bool isGroup) {
    return CachedChatAvatar(name: name, imageUrl: image);
  }

  Widget _buildMembers(ChatState state) {
    if (state.chatEntry?.userChats?.isEmpty ?? true) {
      return _buildEmptyState('No members found', Icons.person);
    }

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(left: 16.w, right: 10.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${state.chatEntry?.userChats?.length.toString() ?? ''} Members",
              ),
              Transform.scale(
                scale: .8,
                child: ElevatedButton.icon(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(kWhite),
                    side: WidgetStatePropertyAll(
                      BorderSide(color: kPrimaryColor, width: 1),
                    ),
                  ),
                  onPressed: () {},
                  label: Text(
                    'Add',
                    style: FontPalette.hW400S13.copyWith(color: kGrey400),
                  ),
                  icon: Icon(Icons.person_add, color: kGrey400),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: state.chatEntry?.userChats?.length,
            itemBuilder: (context, i) {
              final data = state.chatEntry?.userChats?[i];
              return ListTile(
                leading: CachedChatAvatar(
                  name: data?.user?.name ?? '',
                  imageUrl: data?.user?.otherDetails1 ?? '',
                ),
                title: Text(data?.user?.name ?? ''),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMediaTab(ChatState state) {
    final mediaEntries = _getMediaEntries(state);
    if (mediaEntries.isEmpty) {
      return _buildEmptyState('No media files found', Icons.photo);
    }

    return GridView.builder(
      padding: EdgeInsets.all(8.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4.w,
        mainAxisSpacing: 4.w,
      ),
      itemCount: mediaEntries.length,
      itemBuilder: (context, index) {
        final media = mediaEntries[index];
        return _buildMediaTile(media, state);
      },
    );
  }

  Widget _buildDocumentsTab(ChatState state) {
    final documentEntries = _getDocumentEntries(state);
    if (documentEntries.isEmpty) {
      return _buildEmptyState('No documents found', Icons.insert_drive_file);
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: documentEntries.length,
      itemBuilder: (context, index) {
        final document = documentEntries[index];
        return _buildDocumentTile(document, state);
      },
    );
  }

  Widget _buildLinksTab(ChatState state) {
    final linkEntries = _getLinkEntries(state);
    if (linkEntries.isEmpty) {
      return _buildEmptyState('No links found', Icons.link);
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: linkEntries.length,
      itemBuilder: (context, index) {
        final link = linkEntries[index];
        return _buildLinkTile(link);
      },
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64.w, color: Colors.grey[400]),
          SizedBox(height: 16.h),
          Text(
            message,
            style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaTile(ChatMedias media, ChatState state) {
    final mediaId = media.id?.toString() ?? '';
    final isLoaded = context.read<ChatCubit>().isFileLoaded(mediaId);
    final isLoading = context.read<ChatCubit>().isFileLoading(mediaId);

    return GestureDetector(
      onTap: () {
        if (isLoaded) {
          final mediaEntries = _getMediaEntries(state);
          final currentIndex = mediaEntries.indexWhere((m) => m.id == media.id);
          _openImageViewer(
            context,
            currentIndex >= 0 ? currentIndex : 0,
            mediaEntries,
          );
        } else {
          context.read<ChatCubit>().loadMediaFile(media);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: isLoading
            ? Center(child: CircularProgressIndicator(strokeWidth: 2.w))
            : isLoaded
            ? _buildLoadedMediaContent(media, mediaId, state)
            : _buildUnloadedMediaContent(media),
      ),
    );
  }

  Widget _buildLoadedMediaContent(
    ChatMedias media,
    String mediaId,
    ChatState state,
  ) {
    final fileUrl = context.read<ChatCubit>().getFileUrl(mediaId);
    final fileType = context.read<ChatCubit>().getFileType(mediaId);

    if (fileUrl == null) return _buildUnloadedMediaContent(media);

    switch (fileType) {
      case 'image':
        return ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: Image.memory(
            Uri.parse(fileUrl).data!.contentAsBytes(),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        );
      case 'video':
        return Container(
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Center(
            child: Icon(
              Icons.play_circle_outline,
              color: Colors.white,
              size: 32.w,
            ),
          ),
        );
      default:
        return _buildUnloadedMediaContent(media);
    }
  }

  Widget _buildUnloadedMediaContent(ChatMedias media) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getMediaIcon(media.mediaType),
            size: 24.w,
            color: Colors.grey[600],
          ),
          SizedBox(height: 4.h),
          Text(
            media.mediaType?.toUpperCase() ?? 'FILE',
            style: TextStyle(fontSize: 10.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentTile(ChatMedias document, ChatState state) {
    final mediaId = document.id?.toString() ?? '';
    final isLoaded = context.read<ChatCubit>().isFileLoaded(mediaId);
    final isLoading = context.read<ChatCubit>().isFileLoading(mediaId);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              _getDocumentIcon(document.mediaType),
              color: Colors.blue,
              size: 24.w,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _extractFileName(document) ?? 'Document',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Text(
                      document.mediaType?.toUpperCase() ?? 'PDF',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (isLoading) ...[
                      SizedBox(width: 8.w),
                      SizedBox(
                        width: 12.w,
                        height: 12.w,
                        child: CircularProgressIndicator(strokeWidth: 1.5),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _openDocument(document),
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Icon(
                isLoaded ? Icons.visibility : Icons.download,
                color: Colors.blue,
                size: 20.w,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkTile(Entry entry) {
    final links = _extractLinksFromContent(entry.content ?? '');

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...links.map(
            (link) => Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                children: [
                  Icon(Icons.link, color: Colors.blue, size: 20.w),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      link,
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 14.sp,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (entry.createdAt != null) ...[
            SizedBox(height: 8.h),
            Text(
              _formatDate(entry.createdAt!),
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }

  void _openDocument(ChatMedias document) {
    _openPdfDirectly(document);
  }

  Future<void> _openPdfDirectly(ChatMedias document) async {
    try {
      final mediaId = document.id?.toString() ?? '';

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );

      String? filePath;
      final cubit = context.read<ChatCubit>();
      final existingUrl = cubit.getFileUrl(mediaId);

      if (existingUrl != null &&
          !existingUrl.startsWith('http') &&
          !existingUrl.startsWith('data:')) {
        if (await File(existingUrl).exists()) {
          filePath = existingUrl;
        }
      }

      if (filePath == null) {
        if (document.mediaUrl != null) {
          if (document.mediaUrl!.startsWith('data:')) {
            filePath = await _saveBase64AsFile(document.mediaUrl!, mediaId);
          } else if (document.mediaUrl!.startsWith('http')) {
            await cubit.loadMediaFile(document);
            await Future.delayed(Duration(seconds: 2));
            final downloadedUrl = cubit.getFileUrl(mediaId);
            if (downloadedUrl != null && await File(downloadedUrl).exists()) {
              filePath = downloadedUrl;
            }
          } else {
            if (await File(document.mediaUrl!).exists()) {
              filePath = document.mediaUrl!;
            }
          }
        }
      }

      Navigator.of(context).pop();

      if (filePath != null && await File(filePath).exists()) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PdfViewScreen(
              filePath: filePath!,
              fileName: _extractFileName(document) ?? 'Document.pdf',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not load PDF file'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening PDF: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<String?> _saveBase64AsFile(String base64Data, String mediaId) async {
    try {
      String cleanBase64 = base64Data;
      if (base64Data.contains(',')) {
        cleanBase64 = base64Data.split(',').last;
      }

      final bytes = base64Decode(cleanBase64);
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/pdf_$mediaId.pdf');
      await file.writeAsBytes(bytes);

      return file.path;
    } catch (e) {
      print('Error saving base64 to file: $e');
      return null;
    }
  }

  void _openImageViewer(
    BuildContext context,
    int index,
    List<ChatMedias> images,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ImageViewerScreen(images: images, initialIndex: index),
      ),
    );
  }

  // Helper methods
  List<ChatMedias> _getMediaEntries(ChatState state) {
    final entries = state.chatEntry?.entries ?? [];
    final mediaList = <ChatMedias>[];

    for (final entry in entries) {
      if (entry.chatMedias?.isNotEmpty == true) {
        for (final media in entry.chatMedias!) {
          if (_isMediaType(media.fileName)) {
            mediaList.add(media);
          }
        }
      }
    }
    return mediaList;
  }

  List<ChatMedias> _getDocumentEntries(ChatState state) {
    final entries = state.chatEntry?.entries ?? [];
    final documentList = <ChatMedias>[];

    for (final entry in entries) {
      if (entry.chatMedias?.isNotEmpty == true) {
        for (final media in entry.chatMedias!) {
          if (_isDocumentType(media.fileName)) {
            documentList.add(media);
          }
        }
      }
    }
    return documentList;
  }

  List<Entry> _getLinkEntries(ChatState state) {
    final entries = state.chatEntry?.entries ?? [];
    return entries.where((entry) {
      final content = entry.content ?? '';
      return _containsLinks(content);
    }).toList();
  }

  bool _isMediaType(String? filePath) {
    if (filePath == null) return false;
    final extension = p.extension(filePath).toLowerCase();
    return [
      '.jpg',
      '.jpeg',
      '.png',
      '.gif',
      '.bmp',
      '.webp',
      '.mp4',
      '.mov',
      '.avi',
      '.mkv',
      '.mp3',
      '.wav',
      '.aac',
      '.ogg',
    ].contains(extension);
  }

  bool _isDocumentType(String? type) {
    if (type == null) return false;
    final extension = p.extension(type).toLowerCase();
    return ['.pdf'].contains(extension);
  }

  bool _containsLinks(String content) {
    final urlPattern = RegExp(r'https?://[^\s]+', caseSensitive: false);
    return urlPattern.hasMatch(content);
  }

  List<String> _extractLinksFromContent(String content) {
    final urlPattern = RegExp(r'https?://[^\s]+', caseSensitive: false);
    return urlPattern
        .allMatches(content)
        .map((match) => match.group(0)!)
        .toList();
  }

  IconData _getMediaIcon(String? type) {
    switch (type) {
      case 'image':
        return Icons.image;
      case 'video':
        return Icons.videocam;
      case 'audio':
        return Icons.audiotrack;
      default:
        return Icons.attach_file;
    }
  }

  IconData _getDocumentIcon(String? type) {
    switch (type) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'document':
        return Icons.description;
      default:
        return Icons.insert_drive_file;
    }
  }

  String? _extractFileName(ChatMedias media) {
    if (media.mediaUrl != null) {
      try {
        final uri = Uri.parse(media.mediaUrl!);
        final segments = uri.pathSegments;
        if (segments.isNotEmpty) {
          return segments.last;
        }
      } catch (e) {
        // Ignore parsing errors
      }
    }
    return 'Document_${media.id}';
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}
