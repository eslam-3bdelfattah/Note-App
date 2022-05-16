import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/modules/arch_tasks/arch_tasks.dart';
import 'package:todo_app/modules/done_tasks/done_tasks.dart';
import 'package:todo_app/modules/new_tasks/new_tasks.dart';
import 'package:todo_app/shared/cubit/states.dart';

class AppCubit extends Cubit<AppStates>{
  AppCubit() : super(AppInitialState());
  //taking object from me :).
  //to access all the vars and methods in the class.
  static AppCubit get(context) => BlocProvider.of(context);

  int currentIndex = 0;
  List<Widget> screens =
  [
     const NewTasks(),
     const DoneTasks(),
     const ArchivedTasks()
  ];
  List<String> title =
  [
    'New Tasks',
    'Done Tasks',
    'Archived Tasks',
  ];

  //get the index of the bottom navbar
  void changeIndex(index)
  {
    currentIndex = index;
    emit(ChangeNavBarItem());
  }
  //============================================================================
  //Dealing with database
  //first we create the database and the tables in it.
  Database? database;
  List<Map> newTasks = [];
  List<Map> doneTasks = [];
  List<Map> archivedTasks = [];
  void createDatabase()
  {
    openDatabase('todo.db', version: 1,
        onCreate: (database, version)
        {
          print('db created successfully');
          database.execute(
              'CREATE TABLE task (id INTEGER PRIMARY KEY, title TEXT, date TEXT, time TEXT, status TEXT)').then((value)
          {
            print('table created successfully');
          }).catchError((error) {
            print('erorr: ${error.toString()}');
          });
        }, onOpen: (database)
        {
          print('database opened');
          getDataFromDatabase(database);
        }
    ).then((value){
      database = value;
      emit(CreateDatabaseState());
    });
  }

  //inserting data to the database
   insertToDatabase({
    String? title,
    String? time,
    String? date,
  }) async
  {
    await database!.transaction((txn) async {
      await txn.rawInsert(
          'INSERT INTO task(title, time, date, status) VALUES("$title","$time","$date","new")').then((value)
      {
        emit(InsertToDatabase());
        print('$value inserted successfully');
        getDataFromDatabase(database);
      }).catchError((error) {
        print('error: ${error.toString()}');
      });
    });

  }

  void getDataFromDatabase(database)
  {
    newTasks = [];
    doneTasks = [];
    archivedTasks = [];
    emit(LoadingIndicatorState());

    database.rawQuery('SELECT * FROM task').then((value)
    {
      value.forEach((element){
        if(element['status'] == 'new')
        {
          newTasks.add(element);
        }else if(element['status'] == 'done')
        {
          doneTasks.add(element);
        }else
          {
          archivedTasks.add(element);
          }
      });

      emit(GetDataFromDatabase());//change the state when getting the data in the task list.
    });
  }
  void updateDataFromDatabase({
    required String status,
    required int id
})
  {
     database!.rawUpdate(
        'UPDATE task SET status = ? WHERE id = ?',
        ['$status', id]).then((value)
     {
       getDataFromDatabase(database);
       emit(UpdateDataFromDatabase());
    });
  }

  void deleteFromDatabase({required int id}){
    database!.rawDelete('DELETE FROM task WHERE id = ?', [id]).then((value){
      emit(RemoveDataFromDatabase());
      getDataFromDatabase(database);
    });
  }
  //====================================================================
  //the state of the Bottom sheet when it is closed
  bool? isBottomSheetVisible;
  IconData fabIcon = Icons.edit;
  void changeBottomSheet({
    required bool isShow,
    IconData fabIcon = Icons.add,
  })
  {
    this.isBottomSheetVisible = isShow;
    this.fabIcon = fabIcon;
    emit(ChangeBottomShowState());

  }
}