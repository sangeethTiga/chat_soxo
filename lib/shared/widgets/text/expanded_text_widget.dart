
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
// import 'package:html/parser.dart';

// class ExpandableText extends StatefulWidget {
//   final String text;
//   final TextStyle style;
//   final int trimLines;

//   const ExpandableText({
//     required this.text,
//     required this.style,
//     this.trimLines = 1,
//     super.key,
//   });

//   @override
//   ExpandableTextState createState() => ExpandableTextState();
// }

// class ExpandableTextState extends State<ExpandableText> {
//   bool _readMore = false;

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, size) {
//         // Use TextPainter to check overflow
//         final span = TextSpan(text: widget.text, style: widget.style);
//         final tp = TextPainter(
//           text: span,
//           maxLines: widget.trimLines,
//           textDirection: TextDirection.ltr,
//         )..layout(maxWidth: size.maxWidth);

//         final isOverflow = tp.didExceedMaxLines;

//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               widget.text,
//               style: widget.style,
//               maxLines: _readMore ? null : widget.trimLines,
//               overflow: _readMore
//                   ? TextOverflow.visible
//                   : TextOverflow.ellipsis,
//             ),
//             if (isOverflow)
//               GestureDetector(
//                 onTap: () => setState(() => _readMore = !_readMore),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       _readMore ? 'Read less' : 'Read more',
//                       style: widget.style.copyWith(
//                         color: kPrimaryColor,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     Icon(
//                       _readMore
//                           ? Icons.keyboard_arrow_up
//                           : Icons.arrow_forward_ios,
//                       size: 14,
//                       color: kPrimaryColor,
//                     ),
//                   ],
//                 ),
//               ),
//           ],
//         );
//       },
//     );
//   }
// }

// class ExpandableHtmlDescription extends StatefulWidget {
//   final String htmlContent;

//   const ExpandableHtmlDescription({super.key, required this.htmlContent});

//   @override
//   State<ExpandableHtmlDescription> createState() =>
//       _ExpandableHtmlDescriptionState();
// }

// class _ExpandableHtmlDescriptionState extends State<ExpandableHtmlDescription> {
//   bool isExpanded = false;

//   String get plainText {
//     final document = parse(widget.htmlContent);
//     return document.body?.text ?? '';
//   }

//   @override
//   Widget build(BuildContext context) {
//     final textStyle = FontPalette.hW400S14.copyWith(letterSpacing: 1.5);

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         if (isExpanded)
//           HtmlWidget(widget.htmlContent, textStyle: textStyle)
//         else
//           Stack(
//             children: [
//               Text(
//                 plainText,
//                 maxLines: 4,
//                 overflow: TextOverflow.ellipsis,
//                 style: textStyle,
//               ),
//               Positioned(
//                 bottom: 0,
//                 left: 0,
//                 right: 0,
//                 child: Container(
//                   height: 20,
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.topCenter,
//                       end: Alignment.bottomCenter,
//                       colors: [
//                         Colors.white.withOpacity(0.0),
//                         Colors.white.withOpacity(1),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         const SizedBox(height: 4),
//         GestureDetector(
//           onTap: () => setState(() => isExpanded = !isExpanded),
//           child: Text(
//             isExpanded ? 'Read less' : 'Read more',
//             style: FontPalette.hW600S13.copyWith(
//               color: kPrimaryColor,
//               fontWeight: FontWeight.bold,
//               decoration: TextDecoration.underline,
//               decorationThickness: 2.h,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
