import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/layout/home_layout.dart';
import 'package:todo_app/shared/bloc_observer.dart';

void main() {
  BlocOverrides.runZoned(
    () {
      runApp(const TodoApp());
    },
    blocObserver: MyBlocObserver(),
  );
}

class TodoApp extends StatelessWidget {
  const TodoApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeLayout(),
    );
  }
}
