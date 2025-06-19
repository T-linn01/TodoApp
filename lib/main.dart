import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/todo_bloc.dart';
import 'bloc/event.dart';
import 'firebase_options.dart';
import 'ui/screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TodoBloc()..add(LoadTodos()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter BLoC Todo (Simple)',
        theme: ThemeData.dark().copyWith(
          primaryColor: Colors.amber,
          scaffoldBackgroundColor: const Color(0xFF1c1c1e),
        ),
        home: const HomePage(),
      ),
    );
  }
}
