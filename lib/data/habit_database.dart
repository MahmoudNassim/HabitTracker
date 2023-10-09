import 'package:flutter_application_2/components/date_time/date_time.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

//refrence our box
final _myBox = Hive.box("Habit_Database");

class HabitDatabase {
  List todaysHabitList = [];
  Map <DateTime,int> heatMapDataset ={};
//creat initial default data
  void creatDefaultData() {
    todaysHabitList = [
      ['Run', false],
      ['Read', false]
    ];

    _myBox.put("START_DATE", todaysDateFormatted());
  }

//load data if it's already exist
  void loadData() {
    //If it's a new day , get habit list from database
    if (_myBox.get(todaysDateFormatted()) == null) {
      todaysHabitList = _myBox.get("CURRENT_HABIT_LIST");
      //set all habits completed into false since it's a new day
      for (var i = 0; i < todaysHabitList.length; i++) {
        todaysHabitList[i][1] = false;
      }
    }
//If it's not a new day , load today list

    else {
      todaysHabitList = _myBox.get(todaysDateFormatted());
    }
  }

// update database
  void updateDatabase() {
    // Update todays entry
    _myBox.put(todaysDateFormatted(), todaysHabitList);
    //Update universal habit list in case it changed (new habit , edit habit , delete habit)
    _myBox.put("CURRENT_HABIT_LIST", todaysHabitList);

    //calculate habit vomplete percentage for each day
    calculateHabitPercentage();

    //load Heat map
    loadHeatMap();
  }

  void calculateHabitPercentage() {
    int countCompleted = 0;
    for (var i = 0; i < todaysHabitList.length; i++) {
      if (todaysHabitList[i][1] == true) {
        countCompleted++;
      }
    }
    String percent = todaysHabitList.isEmpty
        ? '0.0'
        : (countCompleted / todaysHabitList.length).toStringAsFixed(1);
    // key: "PERCENTAGE_SUMMARY_yyyymmdd"
    // value: string of 1dp number between 0.0-1.0 inclusive
    _myBox.put("PERCENTAGE_SUMMARY_${todaysDateFormatted()}", percent);
  }

  void loadHeatMap() {
        DateTime startDate = createDateTimeObject(_myBox.get("START_DATE"));

    // count the number of days to load
    int daysInBetween = DateTime.now().difference(startDate).inDays;

    // go from start date to today and add each percentage to the dataset
    // "PERCENTAGE_SUMMARY_yyyymmdd" will be the key in the database
    for (int i = 0; i < daysInBetween + 1; i++) {
      String yyyymmdd = convertDateTimeToString(
        startDate.add(Duration(days: i)),
      );

      double strengthAsPercent = double.parse(
        _myBox.get("PERCENTAGE_SUMMARY_$yyyymmdd") ?? "0.0",
      );

      // split the datetime up like below so it doesn't worry about hours/mins/secs etc.

      // year
      int year = startDate.add(Duration(days: i)).year;

      // month
      int month = startDate.add(Duration(days: i)).month;

      // day
      int day = startDate.add(Duration(days: i)).day;

      final percentForEachDay = <DateTime, int>{
        DateTime(year, month, day): (10 * strengthAsPercent).toInt(),
      };

      heatMapDataset.addEntries(percentForEachDay.entries);
      print(heatMapDataset);
    }
  }

  
}
