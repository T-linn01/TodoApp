
abstract class TodoEvent {}

class LoadTodos extends TodoEvent {}

class AddTodo extends TodoEvent {
  final String taskText;
  AddTodo(this.taskText);
}


class DeleteTodo extends TodoEvent {
  final String taskId;
  DeleteTodo(this.taskId);
}
