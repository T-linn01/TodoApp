
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

// class UpdateTodo extends TodoEvent {
//   final String taskId;
//   final String newText;
//   UpdateTodo(this.taskId, this.newText);
// }
