import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final int completedTasksCount;
  final String personName;
  final IconData profileIcon;
  final int totalTasksCount;

  const ProfilePage({Key? key, 
    required this.completedTasksCount,
    required this.personName,
    required this.profileIcon,
    required this.totalTasksCount,
  }) : super(key: key);

  int calculateStreak(int a) {
    int result;
    if (a > 0) {
      result = 1;
    } else {
      result = 0;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    double completionPercentage = (completedTasksCount / totalTasksCount) * 100;
    int streak = calculateStreak(completedTasksCount);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Display profile icon
              Icon(
                profileIcon,
                size: 128,
                color: Colors.red,
              ),
              const SizedBox(height: 20),
              // Display person's name
              Text(
                personName,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              // Display "Progress Today" section
              const Text(
                'Progress Today',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Completed Tasks: $completedTasksCount',
                style: const TextStyle(fontSize: 18),
              ),
              Text(
                'Total Tasks: $totalTasksCount',
                style: const TextStyle(fontSize: 18),
              ),
              Text(
                'Completion Percentage: ${completionPercentage.toStringAsFixed(2)}%',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              Text(
                'Streak: $streak day${streak == 1 ? '' : 's'}',
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
