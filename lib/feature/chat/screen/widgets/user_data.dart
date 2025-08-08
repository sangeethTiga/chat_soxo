import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatColorGenerator {
  static const List<Color> colorPalette = [
    Color(0xFF6B73FF),
    Color(0xFF9C88FF),
    Color(0xFFFFC947),
    Color(0xFFFF6B6B),
    Color(0xFF4ECDC4),
    Color(0xFF45B7D1),
    Color(0xFF96CEB4),
    Color(0xFFFECEA8),
    Color(0xFFFF8A95),
    Color(0xFFD63384),
    Color(0xFF20C997),
    Color(0xFF6F42C1),
    Color(0xFFE83E8C),
    Color(0xFF17A2B8),
    Color(0xFF28A745),
    Color(0xFFFD7E14),
    Color(0xFF6610F2),
    Color(0xFFE91E63),
    Color(0xFF00BCD4),
    Color(0xFF4CAF50),
    Color(0xFFFF9800),
    Color(0xFF795548),
    Color(0xFF607D8B),
    Color(0xFF9E9E9E),
  ];

  static Color generateColorFromName(String name) {
    if (name.isEmpty) return colorPalette[0];
    String cleanName = name.trim().toUpperCase();
    if (cleanName.isEmpty) return colorPalette[0];
    int hash = _generateConsistentHash(cleanName);
    int colorIndex = hash % colorPalette.length;

    return colorPalette[colorIndex];
  }

  static int _generateConsistentHash(String name) {
    int hash = 0;

    for (int i = 0; i < name.length; i++) {
      int charCode = name.codeUnitAt(i);
      hash = ((hash * 31) + charCode + (i * 7)) & 0x7FFFFFFF;
    }

    hash = ((hash * name.length) + _getCharacterSum(name)) & 0x7FFFFFFF;

    return hash;
  }

  static int _getCharacterSum(String name) {
    int sum = 0;
    for (int i = 0; i < name.length; i++) {
      sum += name.codeUnitAt(i) * (i + 1);
    }
    return sum;
  }

  static String generateInitials(String name) {
    if (name.isEmpty) return 'U';

    String cleanName = name.trim();
    if (cleanName.isEmpty) return 'U';

    List<String> words = cleanName
        .split(' ')
        .where((word) => word.isNotEmpty)
        .toList();

    if (words.length >= 2) {
      return '${words[0][0].toUpperCase()}${words[1][0].toUpperCase()}';
    } else {
      String word = words[0];
      if (word.length >= 2) {
        return '${word[0].toUpperCase()}${word[1].toUpperCase()}';
      } else {
        return word[0].toUpperCase();
      }
    }
  }

  static Color generateSecondaryColor(Color primaryColor) {
    HSVColor hsv = HSVColor.fromColor(primaryColor);
    return hsv
        .withSaturation((hsv.saturation * 0.8).clamp(0.0, 1.0))
        .withValue((hsv.value * 1.1).clamp(0.0, 1.0))
        .toColor();
  }
}

class ChatAvatar extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final double size;
  final TextStyle? textStyle;
  final bool useGradient;

  const ChatAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.size = 40,
    this.textStyle,
    this.useGradient = true,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      final List decodedList = jsonDecode(imageUrl!);
      if (decodedList.isNotEmpty &&
          decodedList.first['ProfilePicture'] != null) {
        final base64Image = decodedList.first['ProfilePicture'] as String;
        Uint8List imageBytes = base64Decode(base64Image);
        log("IMAGE ++___.  $base64Image");
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size / 2),
            // boxShadow: [
            //   BoxShadow(
            //     color: Colors.black.withOpacity(0.1),
            //     blurRadius: 4,
            //     offset: const Offset(0, 2),
            //   ),
            // ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Image.memory(imageBytes),
            // child: Image.network(
            //   imageUrl!,
            //   width: size,
            //   height: size,
            //   fit: BoxFit.cover,
            //   errorBuilder: (context, error, stackTrace) {
            //     return _buildInitialsAvatar();
            //   },
            //   loadingBuilder: (context, child, loadingProgress) {
            //     if (loadingProgress == null) return child;
            //     return _buildInitialsAvatar();
            //   },
            // ),
          ),
        );
      }
    }
    return _buildInitialsAvatar();
  }

  Widget _buildInitialsAvatar() {
    final Color primaryColor = ChatColorGenerator.generateColorFromName(name);
    final String initials = ChatColorGenerator.generateInitials(name);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        gradient: useGradient
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryColor,
                  ChatColorGenerator.generateSecondaryColor(primaryColor),
                ],
              )
            : null,
        color: useGradient ? null : primaryColor,
        // boxShadow: [
        //   BoxShadow(
        //     color: primaryColor.withOpacity(0.3),
        //     blurRadius: 8,
        //     offset: const Offset(0, 2),
        //   ),
        // ],
      ),
      child: Center(
        child: Text(
          initials,
          style:
              textStyle ??
              TextStyle(
                color: Colors.white,
                fontSize: size * 0.4,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.25),
                    offset: const Offset(0, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
        ),
      ),
    );
  }
}
