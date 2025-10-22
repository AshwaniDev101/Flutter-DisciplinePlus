
import 'package:discipline_plus/pages/homepage/golabl_initiative_list_page/widget/global_initiative_listview.dart';
import 'package:flutter/material.dart';
import '../../../../managers/selected_day_manager.dart';
import '../dialog_helper.dart';



class GlobalInitiativeListPage extends StatefulWidget {
  const GlobalInitiativeListPage({
    super.key,
  });

  @override
  State<GlobalInitiativeListPage> createState() => _GlobalInitiativeListPageState();
}

class _GlobalInitiativeListPageState extends State<GlobalInitiativeListPage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Add tasks to '${SelectedDayManager.currentSelectedWeekDay.value}'"),
          actions: [

            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: Container(
            //     width: 30,
            //     height: 30,
            //     decoration: BoxDecoration(
            //       shape: BoxShape.circle,
            //       color: Colors.grey, // background fill
            //       border: Border.all(color: Colors.grey.shade700, width: 2), // optional darker border
            //     ),
            //     child: IconButton(
            //       padding: EdgeInsets.zero,
            //       icon: Icon(Icons.add, color: Colors.white), // icon color contrasts background
            //       onPressed: () {
            //         // your click action here
            //       },
            //     ),
            //   ),
            // )



            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: TextButton(
                onPressed: () {

                  DialogHelper.showAddInitiativeDialog(context: context);
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue, // bright background
                  foregroundColor: Colors.white, // text color
                  // padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25), // rounded corners
                  ),
                  shadowColor: Colors.blueAccent,
                  elevation: 1, // gives subtle shadow
                ),
                child: const Text(
                  'New',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            )



            // IconButton(
            //   icon: Icon(Icons.add),
            //   onPressed: () => Navigator.pop(context),
            // ),
          ],
        ),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () => DialogHelper.showAddInitiativeDialog(context: context),
        //   child: Text("new"),
        // ),
        body: SafeArea(child: Column(
          children: [
            Expanded(child: GlobalInitiativeListview())
          ],
        ))
    );
  }

}
