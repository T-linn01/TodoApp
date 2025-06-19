import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/todo_bloc.dart';
import '../bloc/event.dart';
import '../bloc/state.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final TextEditingController textController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo App'),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<TodoBloc, TodoState>(
              builder: (context, state) {
                if (state is TodoLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is TodoLoaded) {
                  if (state.todos.isEmpty) {
                    return const Center(child: Text("Tuyệt vời, không có việc gì để làm!"));
                  }
                  return ListView.builder(
                    itemCount: state.todos.length,
                    itemBuilder: (context, index) {
                      final todo = state.todos[index];
                      final String todoId = todo['id'];
                      final String todoText = todo['text'];

                      return ListTile(
                        title: Text(todoText),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
                          onPressed: () {
                            context.read<TodoBloc>().add(DeleteTodo(todoId));
                          },
                        ),
                      );
                    },
                  );
                }
                if (state is TodoError) {
                  return Center(child: Text('Lỗi: ${state.message}'));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textController,
                    decoration: const InputDecoration(
                      hintText: 'Thêm công việc mới...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  child: const Icon(Icons.add),
                  onPressed: () {
                    if (textController.text.trim().isNotEmpty) {
                      context.read<TodoBloc>().add(AddTodo(textController.text.trim()));
                      textController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}