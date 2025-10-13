import '../../data/repositories_impl/task_repositories_impl.dart';
import '../model/task_entity.dart';

class AddTaskUseCase {
  final TaskRepository _repository;
  AddTaskUseCase(this._repository);

  Future<void> call(Task task) => _repository.addTask(task);
}

class UpdateTaskUseCase {
  final TaskRepository _repository;
  UpdateTaskUseCase(this._repository);

  Future<void> call(Task task) => _repository.updateTask(task);
}

class DeleteTaskUseCase {
  final TaskRepository _repository;
  DeleteTaskUseCase(this._repository);

  Future<void> call(String id) => _repository.deleteTask(id);
}

class GetTasksOnceUseCase {
  final TaskRepository _repository;
  GetTasksOnceUseCase(this._repository);

  Future<List<Task>> call() => _repository.getTasksOnce();
}

class GetTasksStreamUseCase {
  final TaskRepository _repository;
  GetTasksStreamUseCase(this._repository);

  Stream<List<Task>> call() => _repository.getTasksStream();
}
