import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'event.dart';
import 'state.dart';

// Event nội bộ để cập nhật state, không để UI gọi
class _TodosUpdated extends TodoEvent {
  final List<Map<String, dynamic>> todos;
  _TodosUpdated(this.todos);
}

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final DatabaseReference _tasksRef = FirebaseDatabase.instance.ref('tasks');
  StreamSubscription? _tasksSubscription;

  TodoBloc() : super(TodoLoading()) {
    on<LoadTodos>(_onLoadTodos);
    on<AddTodo>(_onAddTodo);
    on<DeleteTodo>(_onDeleteTodo);
    on<_TodosUpdated>(_onTodosUpdated);// Đăng ký handler cho event nội bộ
  }

  // Hàm này chỉ có nhiệm vụ LẮNG NGHE và GỬI EVENT NỘI BỘ
  void _onLoadTodos(LoadTodos event, Emitter<TodoState> emit) {
    _tasksSubscription?.cancel();

    _tasksSubscription = _tasksRef.onValue.listen((databaseEvent) {
      if (databaseEvent.snapshot.value == null) {
        add(_TodosUpdated([])); // Gửi event nội bộ với danh sách rỗng
        return;
      }

      final data = databaseEvent.snapshot.value as Map<dynamic, dynamic>;

      final List<Map<String, dynamic>> todos = data.entries
          .where((entry) => entry.value is Map)
          .map((entry) {
        final taskData = entry.value as Map<dynamic, dynamic>;
        return {
          'id': entry.key,
          'text': taskData['text'] ?? 'Nội dung không có',
          'createdAt': taskData['createdAt'] ?? 0,
        };
      }).toList();

      // Gửi event nội bộ với dữ liệu đã xử lý
      add(_TodosUpdated(todos));
    });
  }

  // Hàm này chỉ nhận event nội bộ và EMIT STATE
  void _onTodosUpdated(_TodosUpdated event, Emitter<TodoState> emit) {
    final sortedTodos = List<Map<String, dynamic>>.from(event.todos);
    sortedTodos.sort((a, b) => (b['createdAt']).compareTo(a['createdAt']));
    emit(TodoLoaded(sortedTodos));
  }

  // Hàm này chỉ có nhiệm vụ GHI DỮ LIỆU
  Future<void> _onAddTodo(AddTodo event, Emitter<TodoState> emit) async {
    try {
      await _tasksRef.push().set({
        'text': event.taskText,
        'createdAt': ServerValue.timestamp,
      });
      // Không làm gì thêm ở đây!
    } catch (e) {
      // Có thể emit lỗi nếu muốn, nhưng cẩn thận
    }
  }

  // Hàm này chỉ có nhiệm vụ XÓA DỮ LIỆU
  Future<void> _onDeleteTodo(DeleteTodo event, Emitter<TodoState> emit) async {
    try {
      await _tasksRef.child(event.taskId).remove();
    } catch (e) {
      // Xử lý lỗi
    }
  }

  @override
  Future<void> close() {
    _tasksSubscription?.cancel();
    return super.close();
  }
}