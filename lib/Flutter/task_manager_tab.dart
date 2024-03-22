import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';

class TaskManagerTab extends StatefulWidget {
  final Function(DateTime, String) addNotification;
  TaskManagerTab({required this.addNotification});

  @override
  _TaskManagerTabState createState() => _TaskManagerTabState();

}

class _TaskManagerTabState extends State<TaskManagerTab> {
  List<TaskItem> tasks = [];
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _initSharedPreferences();
    //This is for general notifications and incrementing of days for tasks
    _checkDayTasks();

    //Alerts when there are tasks that are left undone
    _checkWeeklyTasks();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.addNotification(DateTime.now(), "You opened the Task Journal!");
    });
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    // Load saved tasks
    List<String>? savedTasks = _prefs.getStringList('tasks');
    if (savedTasks != null) {
      setState(() {
        tasks = savedTasks.map((task) => TaskItem.fromJson(task)).toList();
      });
    }
  }
  Future<void> _checkDayTasks() async {
    print("Checking for daily Task notifications...");

    // Create a timer that fires every 1 hour
    Timer.periodic(Duration(minutes: 5), (Timer timer) async {
      print("10 secs periodic");
      final Task_lastNotificationTime = _prefs.getInt('last_notification_time') ?? 0;
      final Task_currentTime = DateTime.now().millisecondsSinceEpoch;

        // If a day has passed since the last notification, then notify the user of tasks
        if (Task_currentTime - Task_lastNotificationTime >= Duration(days: 1).inMilliseconds) {
          print("Passed 2 minutes");
          await _prefs.setInt('last_notification_time', Task_currentTime);
          // Load saved tasks
          List<String>? savedTasks = _prefs.getStringList('tasks');
          if (savedTasks != null) {
            List<TaskItem> loadedTasks =
            savedTasks.map((task) => TaskItem.fromJson(task)).toList();
            // Increment daysOpened and save tasks
            loadedTasks.forEach((task) {
              String message = 'Daily Task Reminder!';
              widget.addNotification(DateTime.now(), message);
            });
          }
        }
    });
  }

  Future<void> _checkWeeklyTasks() async {
    print("Checking for weekly tasks");
    Timer.periodic(Duration(minutes: 5), (Timer timer) async {
      final currentTime = DateTime.now();
      tasks.forEach((task) {
        final difference = currentTime.difference(task.daysOpened).inDays;
        if (difference >= 7) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Hey There! Just saying...'),
                content: Text(
                    '${task.taskName} has been unfinished for more than a week! You might need to finish it or else your tree will get hurt!'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      });
    });
  }


  void _saveTasks() {
    List<String> taskStrings =
    tasks.map((task) => task.toJsonString()).toList();
    _prefs.setStringList('tasks', taskStrings);
  }


  void _addTask(String taskName, String description, double difficulty,
      double importance, double fear) {
    setState(() {
      tasks.add(TaskItem(
        taskName: taskName,
        description: description,
        difficulty: difficulty.toInt(),
        importance: importance.toInt(),
        fear: fear.toInt(),
        daysOpened: DateTime.now(),
      ));
    });
    _saveTasks();
  }

  void _removeTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
    _saveTasks();
  }
  void _showAddTaskDialog() {
    String taskName = '';
    String description = '';
    double difficulty = 0;
    double importance = 0;
    double fear = 0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add Task'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(labelText: 'Task Name'),
                      onChanged: (value) {
                        taskName = value;
                      },
                    ),
                    TextField(
                      decoration: InputDecoration(labelText: 'Description'),
                      onChanged: (value) {
                        description = value;
                      },
                    ),
                    _buildSlider(
                      'Difficulty',
                      difficulty,
                          (value) {
                        setState(() {
                          difficulty = value;
                        });
                      },
                    ),
                    _buildSlider(
                      'Importance',
                      importance,
                          (value) {
                        setState(() {
                          importance = value;
                        });
                      },
                    ),
                    _buildSlider(
                      'Fear',
                      fear,
                          (value) {
                        setState(() {
                          fear = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Add'),
                  onPressed: () {
                    _addTask(taskName, description, difficulty,
                        importance, fear);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSlider(
      String label, double value, ValueChanged<double> onChanged) {
    return Column(
      children: [
        Text(label),
        Slider(
          value: value,
          min: 0,
          max: 100,
          divisions: 20,
          onChanged: onChanged,
          label: '${value.round()}%',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Task Manager"),
        actions: [
          IconButton(
            onPressed: _showAddTaskDialog,
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              title: Text(task.taskName),
              subtitle: Text("Difficulty: ${task.difficulty}% | Importance: ${task.importance}% | Fear: ${task.fear}%"),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("Confirm Deletion"),
                        content: Text("Are you sure you want to delete this task?"),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () {
                              _removeTask(index);
                              Navigator.of(context).pop();
                            },
                            child: Text("Delete"),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class TaskItem extends StatelessWidget {
  final String taskName;
  final String description;
  final int difficulty;
  final int importance;
  final int fear;
  final DateTime daysOpened;

  TaskItem({
    required this.taskName,
    required this.description,
    required this.difficulty,
    required this.importance,
    required this.fear,
    required this.daysOpened
  });


  factory TaskItem.fromJson(String json) {
    final Map<String, dynamic> data = Map<String, dynamic>.from(jsonDecode(json));
    return TaskItem(
      taskName: data['taskName'],
      description: data['description'],
      difficulty: data['difficulty'],
      importance: data['importance'],
      fear: data['fear'],
      daysOpened: DateTime.parse(data['daysOpened'])
    );
  }

  String toJsonString() {
    final Map<String, dynamic> data = {
      'taskName': taskName,
      'description': description,
      'difficulty': difficulty,
      'importance': importance,
      'fear': fear,
      'daysOpened': daysOpened.toIso8601String()
    };
    return jsonEncode(data);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Task: $taskName"),
          Text("Description: $description"),
          Text("Difficulty: $difficulty%"),
          Text("Importance: $importance%"),
          Text("Fear: $fear%"),
        ],
      ),
    );
  }
}


