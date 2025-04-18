import 'package:discipline_plus/models/initiative.dart';
import 'package:discipline_plus/taskmanager.dart';
import 'package:flutter/material.dart';
import '../models/app_time.dart';

class CustomPopupDialog extends StatelessWidget {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController numberController = TextEditingController();

  CustomPopupDialog({super.key});




  void  addInitiative()
  {
    var ini = Initiative(index: TaskManager.instance.getNextIndex(), title: titleController.text, completionTime: AppTime(0, int.parse(numberController.text)));
    TaskManager.instance.addInitiative(ini);
  }


  @override
  Widget build(BuildContext context) {



      return AlertDialog(
        title: Text("Add Initiative"),
        backgroundColor: Colors.white, // White background for dialog
        contentPadding: EdgeInsets.all(16),
        actionsPadding: EdgeInsets.all(4),

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
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.blueAccent),
                ),
                child: TextField(
                  controller: titleController,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: 'title',
                    hintStyle: TextStyle(color: Color.fromRGBO(0, 0, 0, 0.6)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  ),
                ),
              ),
              SizedBox(height: 10),

              // Number TextField with colorful border and width of 50
              Row(
                children: [
                  Container(
                    width: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.greenAccent),
                    ),
                    child: TextField(
                      controller: numberController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        hintText: '0',
                        hintStyle: TextStyle(color: Color.fromRGBO(0, 0, 0, 0.6)),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      ),
                    ),
                  ),
                  SizedBox(width: 5),
                  Text(
                    'min',
                    style: TextStyle(color: Colors.black, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(12), // 👈 Rounded only here
                        bottomRight: Radius.circular(0),
                        topLeft: Radius.circular(0),
                        topRight: Radius.circular(0),
                      ),
                    ),
                  ),
                  child: Text('Cancel'),
                ),
              ),
              Container(
                width: 1,  // Thin white line
                height: 48, // Match button height
                color: Colors.white,
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(0), // 👈 Rounded only here
                        bottomRight: Radius.circular(12),
                        topLeft: Radius.circular(0),
                        topRight: Radius.circular(0),
                      ),
                    ),
                  ),
                  child: Text('Add'),
                ),
              ),
            ],
          )
        ],


      );


  }
}
