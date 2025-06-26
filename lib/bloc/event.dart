
abstract class TodoEvent {}
class AddTodo extends TodoEvent {
  final String taskText;
  AddTodo(this.taskText);
}

class LoadTodos extends TodoEvent {}

class DeleteTodo extends TodoEvent {
  final String taskId;
  DeleteTodo(this.taskId);
}


