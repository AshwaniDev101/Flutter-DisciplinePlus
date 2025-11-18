import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ImportExporterPage extends StatelessWidget {
  ImportExporterPage({super.key});

  final textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Import Exported'),
      ),
      body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(onPressed: () {}, child: Text('Import')),
                      SizedBox(
                        width: 20,
                      ),
                      ElevatedButton(
                          onPressed: () {
                            historyCalorieFoodListExported();
                          },
                          child: Text('Export')),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 300,
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.all(8),
                    child: TextField(
                      controller: textEditingController,
                      readOnly: true,
                      showCursor: false,
                      expands: true,
                      maxLines: null,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontFamily: 'monospace',
                        fontSize: 8,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isCollapsed: true,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )),
    );
  }

  void historyCalorieFoodListExported() async {
    final db = FirebaseFirestore.instance;

    // /users/user1/history/2025/10
    // final ref =
    // db.collection('users')
    //     .doc('user1')
    //     .collection('history')
    //     .doc('2025')
    //     .collection('11');


    ///users/user1/food_list/2025-10-14_09:33.68_339
    final ref =
    db.collection('users')
        .doc('user1')
        .collection('food_list');

    final snapshot = await ref.get();

    print("=========== Exported Data =================");


    for (var doc in snapshot.docs) {
      final data = doc.data();

      textEditingController.text += 'id:${doc.id.toString()} ${data.toString()}\n';

      print('id:${doc.id.toString()} ${data.toString()}\n');
    }
  }
}
