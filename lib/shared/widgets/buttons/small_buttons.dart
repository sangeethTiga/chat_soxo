// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:food_delivery_app/features/screens/product_list/screens/widgets/product_listing_widget.dart';
// import 'package:food_delivery_app/shared/constant/colors.dart';

// class SmallButtons extends StatelessWidget {
//   Function onTap;
//   IconData icon;
//   SmallButtons({super.key, required this.onTap, required this.icon});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         onTap();
//       },
//       child: Container(
//         height: 30.h,
//         width: 30,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.all(Radius.circular(6.h)),
//           color: kWhite,
//           border: Border.all(color: primaryColor),
//         ),
//         child: Icon(icon, size: 19.h),
//       ),
//     );
//   }
// }

// class QuntityControls extends StatelessWidget {
//   int cartQty;
//   Function inOnTap;
//   Function deOnTap;
//   bool isCustmization;
//   QuntityControls(
//       {super.key,
//       required this.cartQty,
//       required this.deOnTap,
//       required this.inOnTap,
//       required this.isCustmization});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         isCustmization
//             ? buildDummyIconButton(Icons.add)
//             : SmallButtons(
//                 icon: Icons.add,
//                 onTap: () {
//                   inOnTap();
//                 }),
//         5.horizontalSpace,
//         buildQuantityDisplay(cartQty),
//         5.horizontalSpace,
//         isCustmization
//             ? buildDummyIconButton(Icons.remove)
//             : SmallButtons(
//                 icon: Icons.remove,
//                 onTap: () {
//                   deOnTap();
//                 }),
//       ],
//     );
//   }
// }
