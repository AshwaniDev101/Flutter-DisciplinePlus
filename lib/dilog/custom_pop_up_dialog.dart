import 'package:discipline_plus/database/repository/initiative_repository.dart';
import 'package:discipline_plus/models/data_types.dart';
import 'package:flutter/material.dart';

class CustomPopupDialog extends StatelessWidget {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController numberController = TextEditingController();

  final InitiativeRepository repo;

  CustomPopupDialog({super.key, required this.repo});







  void  addInitiative()
  {
    var ini = Initiative(title: titleController.text, completionTime: AppTime(0, int.parse(numberController.text)));
    repo.addInitiative(ini);
  }


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white, // White background for dialog
      contentPadding: EdgeInsets.all(16),
      content: Container(
        width: 400, // Increase the width of the dialog
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
                  hintText: 'Enter title here',
                  hintStyle: TextStyle(color: Colors.black.withOpacity(0.6)),
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
                      hintStyle: TextStyle(color: Colors.black.withOpacity(0.6)),
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
        // Cancel Button with red color
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, backgroundColor: Colors.red, // White text on red background
          ),
        ),
        // Add Button with blue color
        ElevatedButton(
          onPressed: addInitiative,
          child: Text('Add'),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, backgroundColor: Colors.blue, // White text on blue background
          ),
        ),
      ],
    );
  }
}
