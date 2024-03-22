import 'package:flutter/material.dart';
import 'task_manager_tab.dart';

class Task {
  final String time;
  final String task;
  final int duration;
  bool isActive;

  Task({
    required this.time,
    required this.task,
    required this.duration,
    this.isActive = false, // Initialize isActive to false
  });
}

class TimePlannerTab extends StatefulWidget {
  final Function(List<Task>) onTaskAdded; // Callback function

  TimePlannerTab({required this.onTaskAdded});

  @override
  _TimePlannerTabState createState() => _TimePlannerTabState();
}

class _TimePlannerTabState extends State<TimePlannerTab>
    with AutomaticKeepAliveClientMixin<TimePlannerTab> {
  List<Task> tasks = [];

  void _addTask(Task task) {
    setState(() {
      tasks.add(task);
      widget.onTaskAdded(tasks); // Callback to update tasks in HomeScreen
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Ensure that the state is kept alive
    return Scaffold(
      appBar: AppBar(
        title: Text("Time Planner"),
      ),
      body: ListView.builder(
        itemCount: tasks.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildAddTaskButton();
          } else {
            return _buildTaskItem(tasks[index - 1]);
          }
        },
      ),
    );
  }

  Widget _buildAddTaskButton() {
    return ListTile(
      title: Text("Add Task"),
      onTap: () {
        _showAddTaskDialog();
      },
    );
  }

  Widget _buildTaskItem(Task task) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 80,
            child: Text(
              task.time,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.task,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Duration: ${task.duration} minutes',
                  // Display duration properly
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              setState(() {
                tasks.remove(task);
                widget.onTaskAdded(tasks);
              });
            },
          ),
          Checkbox(
            value: task.isActive,
            onChanged: (value) {
              setState(() {
                task.isActive = value ?? false;
                widget.onTaskAdded(tasks);
              });
            },
          ),
        ],
      ),
    );
  }
  void _showAddTaskDialog() {
    TimeOfDay selectedTime = TimeOfDay.now();
    String selectedTask = '';
    String duration = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add Task'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text("Time"),
                    trailing: GestureDetector(
                      child: Text(selectedTime.format(context)),
                      onTap: () async {
                        TimeOfDay? newTime = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                        );
                        if (newTime != null) {
                          setState(() {
                            selectedTime = newTime;
                          });
                        }
                      },
                    ),
                  ),
                  DropdownButton<String>(
                    value: selectedTask,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedTask = newValue!;
                      });
                    },
                    items: (tasks as List<TaskItem>).map((TaskItem task) {
                      return DropdownMenuItem<String>(
                        value: task.taskName,
                        child: Text(task.taskName),
                      );
                    }).toList(),
                  ),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Duration (minutes)'),
                    onChanged: (value) {
                      duration = value;
                    },
                  ),
                ],
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
                    if (selectedTask.isNotEmpty && duration.isNotEmpty) {
                      var task = Task(
                        time: "${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')}",
                        task: selectedTask,
                        duration: int.parse(duration), // Parse duration to int
                      );
                      _addTask(task);
                      Navigator.of(context).pop();
                    } else {
                      // Handle validation or inform user to fill all fields
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

//   void _showAddTaskDialog() {
//     TimeOfDay selectedTime = TimeOfDay.now();
//     String taskName = '';
//     String duration = '';
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Add Task'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               ListTile(
//                 title: Text("Time"),
//                 trailing: GestureDetector(
//                   child: Text(selectedTime.format(context)),
//                   onTap: () async {
//                     TimeOfDay? newTime = await showTimePicker(
//                       context: context,
//                       initialTime: selectedTime,
//                     );
//                     if (newTime != null) {
//                       selectedTime = newTime;
//                     }
//                   },
//                 ),
//               ),
//               TextField(
//                 decoration: InputDecoration(labelText: 'Task Name'),
//                 onChanged: (value) {
//                   taskName = value;
//                 },
//               ),
//               TextField(
//                 keyboardType: TextInputType.number,
//                 decoration: InputDecoration(labelText: 'Duration (minutes)'),
//                 onChanged: (value) {
//                   duration = value;
//                 },
//               ),
//             ],
//           ),
//           actions: <Widget>[
//             TextButton(
//               child: Text('Cancel'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//             TextButton(
//               child: Text('Add'),
//               onPressed: () {
//                 if (taskName.isNotEmpty && duration.isNotEmpty) {
//                   var task = Task(
//                     time: "${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')}",
//                     task: taskName,
//                     duration: int.parse(duration), // Parse duration to int
//                   );
//                   _addTask(task);
//                   Navigator.of(context).pop();
//                 } else {
//                   // Handle validation or inform user to fill all fields
//                 }
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
}