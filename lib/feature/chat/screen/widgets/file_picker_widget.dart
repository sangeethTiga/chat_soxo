import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soxo_chat/feature/chat/cubit/chat_cubit.dart';

void showFilePickerBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Select File Type',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.photo_library, color: Colors.purple),
            title: const Text('Gallery'),
            onTap: () =>
                context.read<ChatCubit>().selectImageFromGallery(context),
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt, color: Colors.blue),
            title: const Text('Camera'),
            onTap: () =>
                context.read<ChatCubit>().selectImageFromGallery(context),
          ),

          ListTile(
            leading: const Icon(Icons.folder, color: Colors.grey),
            title: const Text('Any File'),
            onTap: () => context.read<ChatCubit>().selectFiles(),
          ),

          const SizedBox(height: 20),
        ],
      ),
    ),
  );
}
