import 'package:flutter/material.dart';
import 'package:flutter_application_2/components/habit_tile.dart';
import 'package:flutter_application_2/components/month_summary.dart';
import 'package:flutter_application_2/components/my_fab.dart';
import 'package:flutter_application_2/components/my_alert_box.dart';
import 'package:flutter_application_2/data/habit_database.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  HabitDatabase db = HabitDatabase();
  final _myBox = Hive.box("Habit_Database");

  @override
  void initState() {
    //if there is no current habit list , then it;s the 1st time ever openning the app
    //then creat default data
    if (_myBox.get("CURRENT_HABIT_LIST") == null) {
      db.creatDefaultData();
    }
    // there is already data , it's not the first time
    else {
      db.loadData();
    }
    //Update the Database
    db.updateDatabase();
    super.initState();
  }

  bool habbitCompleted = false;
  void checkBoxTapped(bool? value, int index) {
    setState(() {
      db.todaysHabitList[index][1] = value!;
    });
    db.updateDatabase();
  }

  final _newHabitNameController = TextEditingController();
  //creat new habbit
  void creatNewHabit() {
    showDialog(
        context: context,
        builder: (context) {
          return MyAlertBox(
            hintText: 'Enter Habit Name..',
            controller: _newHabitNameController,
            onSave: saveNewHabit,
            onCancel: cancelDialogBox,
          );
        });
  }

  void saveNewHabit() {
    setState(() {
      db.todaysHabitList.add([_newHabitNameController.text, false]);
    });
    //clear Text Field
    _newHabitNameController.clear();
    //Pop Dialog Box
    Navigator.of(context).pop();
    db.updateDatabase();
  }

  void cancelDialogBox() {
    //clear Text Field
    _newHabitNameController.clear();
    //Pop Dialog Box
    Navigator.of(context).pop();
  }

  void oppenHabitSettings(int index) {
    showDialog(
        context: context,
        builder: (context) {
          return MyAlertBox(
            hintText: db.todaysHabitList[index][0],
            controller: _newHabitNameController,
            onSave: () => saveExistingHabit(index),
            onCancel: cancelDialogBox,
          );
        });
  }

  void saveExistingHabit(int index) {
    setState(() {
      db.todaysHabitList[index][0] = _newHabitNameController.text;
    });
    _newHabitNameController.clear();
    Navigator.of(context).pop();
    db.updateDatabase();
  }

  void deleteHabbit(int index) {
    setState(() {
      db.todaysHabitList.removeAt(index);
    });
    db.updateDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[300],
        floatingActionButton: MyFloatingActionButton(
          onPressed: () => creatNewHabit(),
        ),
        body: ListView(
          children: [
            //monthly summry heat map 
            MonthlySummary(datasets: db.heatMapDataset, startDate: _myBox.get("START_DATE")),
            //List of habits 
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
            itemCount: db.todaysHabitList.length,
            itemBuilder: (context, index) {
              return HabitTile(
                habitName: db.todaysHabitList[index][0],
                habitCompleted: db.todaysHabitList[index][1],
                onChanged: (value) => checkBoxTapped(value, index),
                settingsTapped: (context) => oppenHabitSettings(index),
                deleteTapped: (context) => deleteHabbit(index),
              );
            })
          ],
        )
            );
  }
}
