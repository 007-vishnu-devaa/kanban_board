import '../../domain/model/task_entity.dart';

class TaskRepository {
  // Dummy data
  final List<Task> _tasks = [
    Task(id: '1', title: 'Task 1', description: 'Description 1', status: 'To Do'),
    Task(id: '2', title: 'Task 2', description: 'Description 2', status: 'To Do'),
    Task(id: '3', title: 'Task 3', description: 'Description 3', status: 'To Do'),
    Task(id: '4', title: 'Task 4', description: 'Description 4', status: 'To Do'),
    Task(id: '5', title: 'Task 5', description: 'Description 5', status: 'To Do'),
    Task(id: '6', title: 'Task 6', description: 'Description 6', status: 'To Do'),
    Task(id: '7', title: 'Task 7', description: 'Description 7', status: 'To Do'),
    Task(id: '8', title: 'Task 8', description: 'Description 8', status: 'In Progress'),
    Task(id: '9', title: 'Task 9', description: 'Description 9', status: 'Completed'),
  ];

  List<Task> getTasks() => _tasks;
}
