// import 'package:flutter/material.dart';
// // TODO still in use?
// class CustomCard extends StatelessWidget {
//   final String title;
//   final String text;
//   final Color titleColor; // TODO change to theme
//   final Color textColor; // TODO change to theme
//   final Color backgroundColor; // TODO change to theme

//   const CustomCard({super.key, 
//   required this.title, 
//   required this.text, 
//   required this.textColor, 
//   required this.titleColor,
//   required this.backgroundColor});

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//     child: Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: backgroundColor,
//         borderRadius: .circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withAlpha(15),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: .start,
//         children: [
//           Text(
//             title,
//             style: TextStyle(
//               fontSize: 12,
//               fontWeight: .bold,
//               color: titleColor,
//               letterSpacing: 1.2,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             text,
//             style: TextStyle(
//               fontSize: 22,
//               fontWeight: .w900,
//               color: textColor,
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
//   }
// }