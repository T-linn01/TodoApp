import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'event.dart';
import 'state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final String currentUserId = "default_user";
  final DatabaseReference _tasksRef =
  FirebaseDatabase.instance.ref('user_tasks/default_user');

  TodoBloc() : super(TodoLoading()) {
    on<AddTodo>(_onAddTodo);
    on<LoadTodos>(_onLoadTodos);
    on<DeleteTodo>(_onDeleteTodo);
  }
  //AddTodos
  Future<void> _onAddTodo(AddTodo event, Emitter<TodoState> emit) async {
    await _tasksRef.push().set({
      'text': event.taskText,
      'createdAt': ServerValue.timestamp,
    });
    add(LoadTodos());
  }

  //LoadTodos
  Future<void> _onLoadTodos(LoadTodos event, Emitter<TodoState> emit) async {
    emit(TodoLoading());

    final snapshot = await _tasksRef.get();

    if (!snapshot.exists || snapshot.value == null) {
      emit(TodoLoaded([]));
      return;
    }

    final rawData = snapshot.value;
    if (rawData is! Map) {
      emit(TodoLoaded([]));
      return;
    }

    final Map<String, dynamic> data = Map<String, dynamic>.from(rawData);

    final List<Map<String, dynamic>> todos = [];
    for (var entry in data.entries) {
      final value = entry.value;
      if (value is Map && value['text'] != null) {
        todos.add({
          'id': entry.key,
          'text': value['text'],
          'createdAt': value['createdAt'] ?? 0,
        });
      }
    }

    todos.sort((a, b) => (a['createdAt'] as int).compareTo(b['createdAt'] as int));
    emit(TodoLoaded(todos.reversed.toList()));
  }

  //DeleteTodo
  Future<void> _onDeleteTodo(DeleteTodo event, Emitter<TodoState> emit) async {
    await _tasksRef.child(event.taskId).remove();
    add(LoadTodos());
  }
}

