import 'package:shared_preferences/shared_preferences.dart';

class Notification {
  late DateTime date;
  late String message;

  Notification({required this.date, required this.message});

  // Convert Notification to Map for storing in SharedPreferences
  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'message': message,
    };
  }

  // Create Notification from Map retrieved from SharedPreferences
  factory Notification.fromMap(Map<String, dynamic> map) {
    return Notification(
      date: DateTime.parse(map['date']),
      message: map['message'],
    );
  }
}

class NotificationManager {
  late SharedPreferences _prefs;

  // Initialize SharedPreferences
  Future<void> initializePrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Add a notification
  Future<void> addNotification(Notification notification) async {
    List<String> notifications =
        _prefs.getStringList('notifications') ?? [];

    // Convert Notification to Map
    Map<String, dynamic> notificationMap = notification.toMap();

    // Add Map to List
    notifications.add(notificationMap.toString());

    // Save List to SharedPreferences
    await _prefs.setStringList('notifications', notifications);
  }


  // Delete a notification by index
  Future<void> deleteNotification(int index) async {
    List<String> notifications =
        _prefs.getStringList('notifications') ?? [];

    // Remove notification at index
    notifications.removeAt(index);

    // Save updated list to SharedPreferences
    await _prefs.setStringList('notifications', notifications);
  }


  // Retrieve all notifications
  List<Notification> getNotifications() {
    List<String> notifications = _prefs.getStringList('notifications') ?? [];

    // Convert each string to a map, then create Notification objects
    return notifications.map((notif) {
      Map<String, dynamic> notifMap = Map<String, dynamic>.from(
          { for (var e in notif.substring(1, notif.length - 1).split(', ')) e.split(': ')[0] : e.split(': ')[1] });

      return Notification.fromMap(notifMap);
    }).toList();
  }

}
