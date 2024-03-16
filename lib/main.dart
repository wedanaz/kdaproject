import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/completed_tasks_page.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_1/pages/profile_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';

class ThemeNotifier extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeNotifier(),
      child: const MyApp(),
    ),
  );
}

final lightTheme = ThemeData(
  primarySwatch: Colors.red,
  visualDensity: VisualDensity.adaptivePlatformDensity,
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: Colors.red,
  visualDensity: VisualDensity.adaptivePlatformDensity,
);

bool _isDarkMode = false;

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeNotifier = context.watch<ThemeNotifier>();

    return MaterialApp(
      title: 'Daily Planner',
      debugShowCheckedModeBanner: false,
      theme: context.watch<ThemeNotifier>().isDarkMode ? darkTheme : lightTheme,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

// ------------------- Demo Content ------------------------
final List<Task> _completedTasks = [];
final List<Task> _tasks = [
  Task(
    name: "Morning Workout",
    description: "100 pushups, 100 squats, 10k run",
    isDone: false,
    repeatType: RepeatType.Daily,
    color: Colors.grey,
  ),
  Task(
    name: "Daily Meeting",
    description: "try not to fall asleep",
    isDone: false,
    color: Colors.grey,
  ),
  Task(
    name: "Lunch with Jeff",
    description: "order nuggets",
    isDone: false,
    color: Colors.grey,
  ),
];

class _MyHomePageState extends State<MyHomePage> {
  void _addTaskCallback(Task task) {
    setState(() {
      _tasks.add(task);
    });
  }

  late String _personName = '';

  void _removeCompletedTask(Task task) {
    setState(() {
      _tasks.remove(task);
    });
  }

  @override
  void initState() {
    super.initState();
    // Schedule the _showNameInputDialog after build completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showNameInputDialog();
    });
  }

  // Calculate the count of completed tasks
  int _calculateCompletedTasksCount() {
    int count = 0;
    for (var task in _completedTasks) {
      count++;
    }
    return count;
  }

  void _navigateToProfilePage(BuildContext context) {
    int completedTasksCount = _calculateCompletedTasksCount();
    int totalTasksCount = _tasks.length +
        _completedTasks.length; // Calculate the total tasks count

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage(
            completedTasksCount: completedTasksCount,
            personName: _personName, // Pass the person's name
            profileIcon: Icons.person,
            totalTasksCount: totalTasksCount, // Pass the total tasks count
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate =
        DateFormat('EEEE, MMM d, yyyy').format(DateTime.now());

    _tasks.sort((a, b) {
      return TaskPriority.values.indexOf(b.priority) -
          TaskPriority.values.indexOf(a.priority);
    });

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              children: [
                Text(
                  formattedDate,
                  style: const TextStyle(fontSize: 16),
                ),
                IconButton(
                  icon: context.watch<ThemeNotifier>().isDarkMode
                      ? const Icon(Icons.light_mode)
                      : const Icon(Icons.dark_mode),
                  onPressed: () {
                    context.read<ThemeNotifier>().toggleTheme();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add Task',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check),
            label: 'Completed',
          ),
        ],
        onTap: _onItemTapped,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Hello, $_personName',
                  style: Theme.of(context).textTheme.headlineMedium,
                )),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8), // Add padding and vertical spacing
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(
                      bottom: 8), // Adjust vertical spacing between tasks
                  child: TaskTile(
                    task: _tasks[index],
                    onChanged: (bool? value) {
                      setState(() {
                        _tasks[index].isDone = value!;
                      });
                    },
                    completedTasks: _completedTasks,
                    onRemoveTask: _removeCompletedTask,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Function to show a dialog to input the person's name
  Future<void> _showNameInputDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Your Name'),
          content: TextField(
            onChanged: (value) {
              setState(() {
                _personName = value;
              });
            },
            decoration: const InputDecoration(hintText: 'Your Name'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _addTask() async {
    final TextEditingController taskController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    RepeatType repeatType = RepeatType.None;
    Color selectedColor = Colors.red;
    TaskPriority priority = TaskPriority.Normal;

    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Add New Task',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: taskController,
                      decoration: const InputDecoration(
                        hintText: 'Enter task name',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        hintText: 'Enter task description',
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<RepeatType>(
                      value: repeatType,
                      onChanged: (newValue) {
                        setState(() {
                          repeatType = newValue!;
                        });
                      },
                      items: RepeatType.values
                          .map<DropdownMenuItem<RepeatType>>(
                            (type) => DropdownMenuItem<RepeatType>(
                              value: type,
                              child: Text(type.toString().split('.').last),
                            ),
                          )
                          .toList(),
                      decoration: const InputDecoration(
                        labelText: 'Repeat Type',
                      ),
                    ),
                    DropdownButtonFormField<TaskPriority>(
                      value: priority,
                      onChanged: (newValue) {
                        setState(() {
                          priority = newValue!;
                        });
                      },
                      items: TaskPriority.values
                          .map<DropdownMenuItem<TaskPriority>>(
                            (priority) => DropdownMenuItem<TaskPriority>(
                              value: priority,
                              child: Text(priority.toString().split('.').last),
                            ),
                          )
                          .toList(),
                      decoration: const InputDecoration(
                        labelText: 'Priority',
                      ),
                    ),
                    const SizedBox(height: 16),
                    MaterialColorPicker(
                      allowShades: true,
                      onMainColorChange: (color) {
                        setState(() {
                          selectedColor = color as Color;
                        });
                      },
                      selectedColor: selectedColor,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Task newTask = Task(
                          name: taskController.text,
                          description: descriptionController.text,
                          repeatType: repeatType,
                          color: selectedColor,
                          priority: priority,
                        );

                        _addTaskCallback(newTask);

                        Navigator.pop(context);
                      },
                      child: const Text('Add Task'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        _navigateToProfilePage(context);
        break;
      case 1:
        _addTask();
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CompletedTasksPage(
              completedTasks: _completedTasks,
              onUncheckTask: _uncheckCompletedTask,
            ),
          ),
        );
        break;
    }
  }

  void _uncheckCompletedTask(Task task) {
    if (mounted) {
      setState(() {
        _completedTasks.remove(task);
        _tasks.add(task);
        task.isDone = false;
      });
    }
  }
}

class Task {
  String name;
  String description;
  bool isDone;
  RepeatType repeatType;
  Color color;
  TaskPriority priority;

  Task(
      {required this.name,
      required this.description,
      this.isDone = false,
      this.repeatType = RepeatType.None,
      required this.color,
      this.priority = TaskPriority.Normal //Standardprio
      });
}

enum TaskPriority {
  Low,
  Normal,
  High,
}

enum RepeatType {
  None,
  Daily,
  Weekly,
  Monthly,
}

class TaskTile extends StatefulWidget {
  final Task task;
  final ValueChanged<bool?> onChanged;
  final List<Task> completedTasks;
  final Function(Task) onRemoveTask;

  const TaskTile({
    Key? key,
    required this.task,
    required this.onChanged,
    required this.completedTasks,
    required this.onRemoveTask,
  }) : super(key: key);

  @override
  _TaskTileState createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile> {
  bool showDescription = false;

  @override
  Widget build(BuildContext context) {
    String getRepeatTypeText() {
      switch (widget.task.repeatType) {
        case RepeatType.None:
          return 'Once';
        case RepeatType.Daily:
          return 'Daily';
        case RepeatType.Weekly:
          return 'Weekly';
        case RepeatType.Monthly:
          return 'Monthly';
        default:
          return 'Unknown';
      }
    }

    Color adjustColorSaturation(Color color, double saturationFactor) {
      final HSLColor hslColor = HSLColor.fromColor(color);
      final HSLColor adjustedHSLColor =
          hslColor.withSaturation(hslColor.saturation * saturationFactor);
      return adjustedHSLColor.toColor();
    }

    Color getContrastingTextColor(Color backgroundColor) {
      return backgroundColor.computeLuminance() > 0.5
          ? Colors.black
          : Colors.white;
    }

    Widget _buildPriorityWidget(TaskPriority priority, Color backgroundColor) {
      IconData icon;
      Color iconColor;

      switch (priority) {
        case TaskPriority.Low:
          icon = Icons.arrow_downward;
          iconColor = Colors.green;
          break;
        case TaskPriority.Normal:
          icon = Icons.arrow_forward;
          iconColor = Colors.orange;
          break;
        case TaskPriority.High:
          icon = Icons.arrow_upward;
          iconColor = Colors.red;
          break;
      }

      Color textColor = backgroundColor.computeLuminance() > 0.5
          ? Colors.black
          : Colors
              .white; // Use white text color for bright backgrounds, and black for dark backgrounds

      return Row(
        children: [
          Icon(
            icon,
            color: textColor,
            size: 18, // Adjust the size as needed
          ),
          SizedBox(width: 4),
          Text(
            priority.toString().split('.').last,
            style: TextStyle(
              color: textColor,
              fontSize: 12, // Adjust the size as needed
            ),
          ),
        ],
      );
    }

    return Dismissible(
        key: UniqueKey(),
        direction: DismissDirection.endToStart,
        confirmDismiss: (_) async {
          return await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Confirm'),
                content: Text('Are you sure you want to delete this task?'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text('Delete'),
                  ),
                ],
              );
            },
          );
        },
        onDismissed: (_) {
          widget.onRemoveTask(widget.task);
          _tasks.remove(widget.task);
        },
        background: Container(
          alignment: Alignment.centerRight,
          color: Colors.red,
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Icon(Icons.delete, color: Colors.white),
        ),
        child: ListTile(
          onTap: () {
            setState(() {
              showDescription = !showDescription;
            });
          },
          tileColor: adjustColorSaturation(widget.task.color, 0.8),
          contentPadding: EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          leading: Checkbox(
            value: widget.task.isDone,

            onChanged: (value) {
              setState(() {
                widget.task.isDone = value!;
              });
              widget.onChanged(value);
              if (value == true) {
                setState(() {
                  widget.completedTasks.add(widget.task);
                  widget.onRemoveTask(widget.task);
                });
              }
            },
            checkColor: getContrastingTextColor(
                widget.task.color), // Set the checkbox color dynamically
            activeColor: widget.task.color,
          ),
          title: Row(
            children: [
              Text(
                widget.task.name,
                style: TextStyle(
                  color: getContrastingTextColor(widget.task.color),
                ),
              ),
              SizedBox(width: 8),
              _buildPriorityWidget(widget.task.priority, widget.task.color),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showDescription)
                Text(
                  widget.task.description,
                  style: TextStyle(
                    color: getContrastingTextColor(widget.task.color),
                  ),
                ),
              if (widget.task.repeatType != RepeatType.None)
                Text(
                  'Repeat: ${getRepeatTypeText()}',
                  style: TextStyle(
                    color: getContrastingTextColor(widget.task.color),
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ));
  }
}
