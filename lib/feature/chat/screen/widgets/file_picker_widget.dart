import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soxo_chat/feature/chat/cubit/chat_cubit.dart';

void showFilePickerBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => const _FilePickerBottomSheet(),
  );
}

class _FilePickerBottomSheet extends StatelessWidget {
  const _FilePickerBottomSheet();

  @override
  Widget build(BuildContext context) {
    final chatCubit = context.read<ChatCubit>();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          _buildDragHandle(),

          // Title
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Text(
              'Select File Type',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),

          // Options
          ..._buildFileOptions(context, chatCubit),

          // Bottom padding for safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }

  Widget _buildDragHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  List<Widget> _buildFileOptions(BuildContext context, ChatCubit chatCubit) {
    final options = [
      _FileOption(
        icon: Icons.photo_library,
        color: Colors.purple,
        title: 'Gallery',
        onTap: () => _handleOptionTap(
          context,
          () => chatCubit.selectImageFromGallery(context),
        ),
      ),
      _FileOption(
        icon: Icons.camera_alt,
        color: Colors.blue,
        title: 'Camera',
        onTap: () => _handleOptionTap(
          context,
          () => chatCubit.selectImageFromCamera(), // Fixed method name
        ),
      ),
      _FileOption(
        icon: Icons.folder,
        color: Colors.orange,
        title: 'Files',
        onTap: () => _handleOptionTap(context, () => chatCubit.selectFiles()),
      ),
    ];

    return options.map((option) => _buildListTile(option)).toList();
  }

  Widget _buildListTile(_FileOption option) {
    return ListTile(
      leading: Icon(option.icon, color: option.color, size: 28),
      title: Text(
        option.title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      onTap: option.onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  void _handleOptionTap(BuildContext context, VoidCallback action) {
    Navigator.of(context).pop();
    action();
  }
}

class _FileOption {
  final IconData icon;
  final Color color;
  final String title;
  final VoidCallback onTap;

  const _FileOption({
    required this.icon,
    required this.color,
    required this.title,
    required this.onTap,
  });
}
