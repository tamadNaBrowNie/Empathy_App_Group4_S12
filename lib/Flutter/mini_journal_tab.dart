import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:dart_sentiment/dart_sentiment.dart';
import 'journal_Responses.dart';


class MiniJournalTab extends StatefulWidget {
  final List<String> journalEntries;
  final Function(DateTime, String) addNotification; // Add this line
  MiniJournalTab({required this.journalEntries, required this.addNotification}); // Update constructor

  @override
  _MiniJournalTabState createState() => _MiniJournalTabState();
}

class _MiniJournalTabState extends State<MiniJournalTab> {
  final journalEntryController = TextEditingController();
  int indexToEdit = -1;
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _initSharedPreferences();
    _checkWeeklyJournals();
    // Add a notification when the Mini Journal tab loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.addNotification(DateTime.now(), "You opened the Mini Journal!");
    });
  }


  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    // Load saved journal entries only if the widget's entries list is empty
    if (widget.journalEntries.isEmpty) {
      List<String>? savedEntries = _prefs.getStringList('journal_entries');
      if (savedEntries != null) {
        setState(() {
          widget.journalEntries.addAll(savedEntries);
        });
      }
    }
  }

  Future<void> _checkWeeklyJournals() async {
    // print("Checking for weekly Journal notifications...");

    // Create a timer that fires every 5 seconds
    Timer.periodic(Duration(minutes: 5), (Timer timer) async {
      final Journal_lastNotificationTime = _prefs.getInt('last_notification_time') ?? 0;
      final Journal_currentTime = DateTime.now().millisecondsSinceEpoch;

      // If 5 seconds have passed since the last notification, show the notification
      if (Journal_currentTime - Journal_lastNotificationTime >= Duration(days: 7).inMilliseconds) {
        // print("Passed 5 seconds");
        await _prefs.setInt('last_notification_time', Journal_currentTime);
        _notifyJournal();
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mini-Journal'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: journalEntryController,
              decoration: InputDecoration(
                labelText: indexToEdit == -1
                    ? 'Enter your journal entry'
                    : 'Edit your journal entry',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (indexToEdit == -1) {
                  saveJournalEntry(journalEntryController.text);
                } else {
                  updateJournalEntry(journalEntryController.text);
                }
                clearController();
                setState(() {
                  indexToEdit = -1;
                });
              },
              child: Text(indexToEdit == -1 ? 'Save Entry' : 'Update Entry'),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: widget.journalEntries.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title:
                      Text('${index + 1}. ${widget.journalEntries[index]}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              journalEntryController.text =
                              widget.journalEntries[index];
                              setState(() {
                                indexToEdit = index;
                              });
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              deleteJournalEntry(index);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void saveJournalEntry(String entry) async {
    setState(() {
      widget.journalEntries.add(entry);
    });
    await _prefs.setStringList('journal_entries', widget.journalEntries);
  }

  void updateJournalEntry(String entry) async {
    setState(() {
      widget.journalEntries[indexToEdit] = entry;
    });
    await _prefs.setStringList('journal_entries', widget.journalEntries);
  }

  void deleteJournalEntry(int index) async {
    setState(() {
      widget.journalEntries.removeAt(index);
    });
    await _prefs.setStringList('journal_entries', widget.journalEntries);
  }

  void clearController() {
    journalEntryController.clear();
  }



  void _notifyJournal() {
    print("Calculating average sentiment...");

    // Calculate the average sentiment value
    double totalSentiment = 0;
    for (String entry in widget.journalEntries) {
      Sentiment sentiment = Sentiment();
      Map<String, dynamic> analysis = sentiment.analysis(entry);
      totalSentiment += analysis['score'];
    }
    double averageSentiment = totalSentiment / widget.journalEntries.length;
    int resultSentiment = averageSentiment.round();

    print("Average Value: ${resultSentiment}");
    String notificationMessage = msg(resultSentiment);

    // Trigger the notification
    widget.addNotification(DateTime.now(), notificationMessage);
  }

}