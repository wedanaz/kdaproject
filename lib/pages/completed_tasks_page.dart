import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';

class CompletedTasksPage extends StatefulWidget {
  final List<Task> completedTasks;
  final Function(Task) onUncheckTask;

  const CompletedTasksPage({
    Key? key,
    required this.completedTasks,
    required this.onUncheckTask,
  }) : super(key: key);

  @override
  _CompletedTasksPageState createState() => _CompletedTasksPageState();
}

class _CompletedTasksPageState extends State<CompletedTasksPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Completed Tasks'),
      ),
      body: ListView.builder(
        itemCount: widget.completedTasks.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: TaskTile(
              task: widget.completedTasks[index],
              onChanged: (value) {
                if (value == false) {
                  widget.onUncheckTask(widget.completedTasks[index]);
                  setState(() {}); // Trigger a rebuild after task unchecking
                }
              },
              completedTasks: widget.completedTasks,
              onRemoveTask: (task) {
                setState(() {
                  widget.onUncheckTask(task);
                  widget.completedTasks.remove(task);
                });
              },
            ),
          );
        },
      ),
    );
  }
}
