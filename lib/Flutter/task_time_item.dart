import 'package:flutter/material.dart';

class TaskTimeItem extends StatelessWidget {
  final String time;
  final String task;
  final String duration;

  TaskTimeItem({
    required this.time,
    required this.task,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey)),
      ),
      child: Row(
        children: [
          Expanded(child: Text(time)),
          Expanded(child: Text(task)),
          Expanded(child: Text(duration)),
        ],
      ),
    );
  }
}
