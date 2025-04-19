import 'package:discipline_plus/models/initiative.dart';
import 'package:discipline_plus/taskmanager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/app_time.dart';
import '../widget/quantity_selector.dart';

class CustomPopupDialog extends StatelessWidget {
  final TextEditingController initiativeTitleController = TextEditingController();
  late int initiativeCompletionTime = 5;

  final TextEditingController breakTimeController = TextEditingController();

  CustomPopupDialog({super.key});


  void addInitiative() {
    var ini = Initiative(index: TaskManager.instance.getNextIndex(),
        title: initiativeTitleController.text,
        completionTime: AppTime(0, initiativeCompletionTime));

    TaskManager.instance.addInitiative(ini);
  }


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("New Initiative",
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black38),),
      backgroundColor: Colors.white,
      // White background for dialog
      // contentPadding: EdgeInsets.zero,
      actionsPadding: EdgeInsets.all(16),




      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Square corners
      ),
      content: SizedBox(
        width: 500, // Increase the width of the dialog
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title TextField with colorful border and white background
            TextField(
              controller: initiativeTitleController,
              style: TextStyle(
                  color: Colors.black45,    // Your desired text color
                  fontSize: 22,
                  fontWeight: FontWeight.bold
              ),
              decoration: InputDecoration(
                hintText: 'Enter Initiative Name',
                hintStyle: TextStyle(color: Colors.black26, fontSize: 16,),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(
                    horizontal: 10, vertical: 10),
              ),
            ),
            SizedBox(height: 10),

            // Number TextField with colorful border and width of 50
            Row(

              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [


                Text("Duration", style: TextStyle(color: Colors.black38, fontSize: 16,)),
                Flexible(
                  child: QuantitySelector(

                    onChanged: (value) {
                      initiativeCompletionTime = value;
                    },
                  ),
                ),
              ],
            ),
            // SizedBox(height: 10,),
            Divider(),


            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Break", style: TextStyle(color: Colors.black38, fontSize: 16,)),
                Flexible(
                  child: QuantitySelector(

                    onChanged: (value) {
                      breakTimeController.text = value.toString();
                    },
                  ),
                ),
              ],
            ),


          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(

                    onTap: () => Navigator.of(context).pop(),
                    child: Center(child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Cancel", style: TextStyle(color: Colors.black38, fontSize: 18, fontWeight: FontWeight.bold)),
                    ))

                ),
              ),
            ),
            Expanded(
              child: Material(
                color: Colors.blue,

                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(4),
                ),
                child: InkWell(

                    onTap: addInitiative,
                    child: Center(child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Add", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ))

                ),
              ),
            ),
          ],
        )
      ],




    );
  }

}

