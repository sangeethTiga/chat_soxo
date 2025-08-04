import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
            onTap: () => pickFromGallery(context),
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt, color: Colors.blue),
            title: const Text('Camera'),
            onTap: () => pickFromCamera(context),
          ),

          ListTile(
            leading: const Icon(Icons.folder, color: Colors.grey),
            title: const Text('Any File'),
            onTap: () => pickAnyFile(context),
          ),

          const SizedBox(height: 20),
        ],
      ),
    ),
  );
}

Future<void> pickFromGallery(BuildContext context) async {
  Navigator.pop(context);
  final ImagePicker picker = ImagePicker();
  try {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // Handle selected image
      print('Selected image: ${image.path}');
      // You can process the file here
    }
  } catch (e) {
    print('Error picking from gallery: $e');
  }
}

Future<void> pickFromCamera(BuildContext context) async {
  Navigator.pop(context);
  final ImagePicker picker = ImagePicker();
  try {
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      print('Captured image: ${image.path}');
    }
  } catch (e) {
    print('Error taking photo: $e');
  }
}

Future<void> pickImages(BuildContext context) async {
  Navigator.pop(context);
  final ImagePicker picker = ImagePicker();
  try {
    final List<XFile> images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      print('Selected ${images.length} images');
      for (var image in images) {
        print('Image: ${image.path}');
      }
    }
  } catch (e) {
    print('Error picking images: $e');
  }
}

Future<void> pickPDF(BuildContext context) async {
  Navigator.pop(context);
  try {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
    );

    if (result != null) {
      for (var file in result.files) {
        print('Selected PDF: ${file.name}, Path: ${file.path}');
      }
    }
  } catch (e) {
    print('Error picking PDF: $e');
  }
}

Future<void> pickDocuments(BuildContext context) async {
  Navigator.pop(context);
  try {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'pdf',
        'doc',
        'docx',
        'txt',
        'xls',
        'xlsx',
        'ppt',
        'pptx',
      ],
      allowMultiple: true,
    );

    if (result != null) {
      for (var file in result.files) {
        print('Selected document: ${file.name}, Path: ${file.path}');
      }
    }
  } catch (e) {
    print('Error picking documents: $e');
  }
}

Future<void> pickAnyFile(BuildContext context) async {
  Navigator.pop(context);
  try {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
    );

    if (result != null) {
      for (var file in result.files) {
        print('Selected file: ${file.name}, Path: ${file.path}');
      }
    }
  } catch (e) {
    print('Error picking files: $e');
  }
}
