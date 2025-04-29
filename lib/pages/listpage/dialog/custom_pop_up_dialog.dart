// import 'package:discipline_plus/models/initiative.dart';
// import 'package:discipline_plus/models/study_break.dart';
// import 'package:discipline_plus/pages/logic/taskmanager.dart';
// import 'package:flutter/material.dart';
//
// import '../../../models/app_time.dart';
// import '../core/current_day_manager.dart';
// import 'widget/quantity_selector.dart';
//
//
// class CustomPopupDialog extends StatelessWidget {
//   final TextEditingController initiativeTitleController = TextEditingController();
//
//   late int initiativeCompletionTime = 30;
//   late int breakTime = 15;
//
//
//   CustomPopupDialog({super.key});
//
//
//   void addInitiative(context) {
//     var ini = Initiative(index: TaskManager.instance.getNextIndex(),
//         title: initiativeTitleController.text,
//         completionTime: AppTime(0, initiativeCompletionTime),
//         studyBreak: StudyBreak(title: "$breakTime min break",  completionTime: AppTime(0, breakTime))
//     );
//
//     TaskManager.instance.addInitiative(CurrentDayManager.getCurrentDay(),ini);
//     Navigator.of(context).pop();
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: Text("New Initiative",
//         style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black38),),
//       backgroundColor: Colors.white,
//       // White background for dialog
//       // contentPadding: EdgeInsets.zero,
//       actionsPadding: EdgeInsets.all(16),
//
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16), // Square corners
//       ),
//       content: SizedBox(
//         width: 500, // Increase the width of the dialog
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // Title TextField with colorful border and white background
//             TextField(
//               controller: initiativeTitleController,
//               style: TextStyle(
//                   color: Colors.black45,    // Your desired text color
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold
//               ),
//               decoration: InputDecoration(
//                 hintText: 'Enter title here',
//                 hintStyle: TextStyle(color: Colors.black26, fontSize: 16,),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(4),
//                   borderSide: BorderSide(color: Colors.blue, width: 2),
//                 ),
//                 contentPadding: EdgeInsets.symmetric(
//                     horizontal: 10, vertical: 10),
//               ),
//             ),
//             SizedBox(height: 10),
//
//             // Number TextField with colorful border and width of 50
//             Row(
//
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//
//
//                 Text("Duration", style: TextStyle(color: Colors.black26, fontSize: 16,)),
//                 Flexible(
//                   child: QuantitySelector(
//                     initialValue: initiativeCompletionTime,
//                     initialStep: 5,
//                     onChanged: (value) {
//                       initiativeCompletionTime = value;
//                     },
//                   ),
//                 ),
//               ],
//             ),
//             // SizedBox(height: 10,),
//             Divider(),
//
//
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text("Break", style: TextStyle(color: Colors.black26, fontSize: 16,)),
//
//                 Flexible(
//                   child: QuantitySelector(
//                     initialValue: breakTime,
//                     initialStep: 5,
//                     onChanged: (value) {
//                       breakTime = value;
//                     },
//                   ),
//                 ),
//               ],
//             ),
//
//
//           ],
//         ),
//       ),
//       actions: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.end,
//           crossAxisAlignment: CrossAxisAlignment.end,
//           children: [
//             Expanded(
//               child: Material(
//                 color: Colors.transparent,
//                 child: InkWell(
//
//                     onTap: () => Navigator.of(context).pop(),
//                     child: Center(child: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Text("Cancel", style: TextStyle(color: Colors.black38, fontSize: 18, fontWeight: FontWeight.bold)),
//                     ))
//
//                 ),
//               ),
//             ),
//             Expanded(
//               child: Material(
//                 color: Colors.blue,
//
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(4),
//                   topRight: Radius.circular(4),
//                   bottomLeft: Radius.circular(4),
//                   bottomRight: Radius.circular(4),
//                 ),
//                 child: InkWell(
//
//                     onTap: ()=> addInitiative(context),
//                     child: Center(child: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Text("Add", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
//                     ))
//
//                 ),
//               ),
//             ),
//           ],
//         )
//       ],
//
//
//
//
//     );
//   }
//
// }
//
