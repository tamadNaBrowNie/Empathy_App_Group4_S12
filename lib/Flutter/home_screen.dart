import 'package:flutter/material.dart';
import 'mini_journal_tab.dart';
import 'task_manager_tab.dart';
import 'time_planner_tab.dart';
import 'tree_tab.dart';
import 'dart:async';
import 'notification.dart' as custom; // Import Notification class
import 'package:dart_sentiment/dart_sentiment.dart';
import 'package:shared_preferences/shared_preferences.dart';


double treeState = 0;
bool isWorking = true;

class HomeScreen extends StatefulWidget {
  final List<String> journalEntries;
  HomeScreen({required this.journalEntries});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool pomodoroActive = false;
  int pomodoroMinutes = 0;
  int pomodoroSeconds = 0;
  late Timer pomodoroTimer;
  List<Task> tasks = [];
  late custom.NotificationManager _notificationManager;

  void refreshTreeTab() {
    setState(() {
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _notificationManager = custom.NotificationManager();
    _notificationManager.initializePrefs();
  }

  void addNotification(DateTime date, String message) {
    setState(() {
      _notificationManager.addNotification(custom.Notification(date: date, message: message));
    });
  }


  void deleteNotification(int index) {
    setState(() {
      _notificationManager.deleteNotification(index);
    });
    // Reload notifications dialog
    _showNotificationsDialog();
  }


  void _showNotificationsDialog() {
    List<custom.Notification> notifications = _notificationManager.getNotifications();

    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Notifications'),
            ),
            body: ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(notifications[index].message),
                  subtitle: Text(notifications[index].date.toString()),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      deleteNotification(index);
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    ).then((_) {
      // Handle navigation back to home screen after notifications screen is popped
      Navigator.popUntil(context, ModalRoute.withName('/'));
    });
  }








  @override
  void dispose() {
    _tabController.dispose();
    if (pomodoroTimer.isActive) {
      pomodoroTimer.cancel();
    }
    super.dispose();
  }

  void startPomodoroTimer() {
    if (treeState > 100){
      treeState = 100;
    }
    else if (treeState < 0){
      treeState = 0;
    }

    pomodoroTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (pomodoroMinutes == 0 && pomodoroSeconds == 0 && isWorking) {
          timer.cancel();
          pomodoroActive = true;
          pomodoroMinutes = 5;
          pomodoroSeconds = 0;
          if (treeState < 100){
            setState(() {
              treeState += 20;
            });
          }
          isWorking = false;
          startPomodoroTimer();
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Congratulations!'),
                content: Text(
                    'Your Tree is Growing!, You should rest for 5 minutes'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Close'),
                  ),
                ],
              );
            },
          );
        } else if (pomodoroMinutes == 0 && pomodoroSeconds == 0 && !isWorking) {
          timer.cancel();
          pomodoroActive = false;
          pomodoroMinutes = 0;
          pomodoroSeconds = 0;
          if (treeState < 100){
            setState(() {
              treeState += 20;
            });
          }
          isWorking = true;
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Congratulations!'),
                content: Text('Your Tree is Growing!, Back to work'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Close'),
                  ),
                ],
              );
            },
          );
        } else if (pomodoroSeconds == 0) {
          pomodoroMinutes--;
          pomodoroSeconds = 59;
        } else {
          pomodoroSeconds--;
        }
      });
    });
  }

  void startRestTimer() {
    // Start the rest timer
    pomodoroTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (pomodoroMinutes == 0 && pomodoroSeconds == 0) {
          // If the rest session is complete, start the normal timer again
          timer.cancel();
          pomodoroActive = true;
          pomodoroMinutes = 25;
          pomodoroSeconds = 0;
          startPomodoroTimer(); // Start the normal timer again
        } else if (pomodoroSeconds == 0) {
          pomodoroMinutes--;
          pomodoroSeconds = 59;
        } else {
          pomodoroSeconds--;
        }
      });
    });
  }

  void updatePomodoroTime(List<Task> tasks) {
    int totalMinutes = tasks.fold(0, (sum, task) {
      if (task.isActive) {
        return sum + task.duration;
      } else {
        return sum;
      }
    });
    int conc = tasks.fold(0,(sum,task)=>sum+= task.isActive? 1:0);
    setState(() {
      pomodoroMinutes = totalMinutes;
      if (totalMinutes >= 30 || conc>2) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Whoa There'),
              content: Text(
                  'You are adding too much work! Are you sure you can handle them all?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Close'),
                ),
              ],
            );
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Navigate to Notification Tab
              _showNotificationsDialog();
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 100,
            color: pomodoroActive ? Colors.grey : Colors.blue,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    if (!pomodoroActive && pomodoroMinutes != 0) {
                      pomodoroActive = true;
                      startPomodoroTimer();
                    } else {
                      pomodoroActive = false;
                      if (pomodoroTimer.isActive) {
                        pomodoroTimer.cancel();
                        if (treeState > 0){
                          setState(() {
                            treeState -= 20;
                          });
                        }
                        isWorking = !isWorking;
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Are you okay?'),
                              content: Text('Your Tree is Withering!'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Close'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                      pomodoroMinutes = 0;
                      pomodoroSeconds = 0;
                    }
                  });
                },
                child: Text(
                  pomodoroActive ? "End Pomodoro" : "Start Pomodoro",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: Center(
              child: Text(
                'Remaining Pomodoro Time: ${pomodoroMinutes.toString().padLeft(2, '0')}:${pomodoroSeconds.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(icon: Icon(Icons.book), text: 'Journal'),
              Tab(icon: Icon(Icons.task), text: 'Task Manager'),
              Tab(icon: Icon(Icons.access_time), text: 'Time Planner'),
              Tab(icon: Icon(Icons.image), text: 'Tree'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                MiniJournalTab(journalEntries: widget.journalEntries, addNotification: addNotification),
                TaskManagerTab(addNotification: addNotification),
                TimePlannerTab(
                  onTaskAdded: (tasks) {
                    if (!pomodoroActive) {
                      updatePomodoroTime(tasks);
                    }
                  },
                ),
                TreeTab(treeState: treeState, refreshTreeTab: refreshTreeTab),
              ],
            ),
          ),
        ],
      ),
    );
  }
}




