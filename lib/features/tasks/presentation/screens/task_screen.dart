import 'package:flutter/material.dart';
import 'package:task_manager/components/custom_header.dart';
import 'package:task_manager/components/background_pattern.dart';

class TaskScreen extends StatelessWidget {
  const TaskScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomHeader(
        title: 'Tasks',
        showBackArrow: false,
      ),
      body: BackgroundPattern(
        child: Center(
          child: Text('Task Screen Body'),
        ),
      ),
    );
  }
}
