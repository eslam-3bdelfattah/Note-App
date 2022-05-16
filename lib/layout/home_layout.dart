import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/shared/components/components.dart';
import 'package:todo_app/shared/cubit/cubit.dart';
import 'package:todo_app/shared/cubit/states.dart';

class HomeLayout extends StatelessWidget
{
  var scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController titleController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController dateController = TextEditingController();

  @override
  Widget build(BuildContext context)
  {
    return BlocProvider(
      create: (context)=> AppCubit()..createDatabase(),
      child: BlocConsumer<AppCubit, AppStates>(
        listener: (BuildContext context, AppStates state)
        {
          if(state is InsertToDatabase){Navigator.pop(context);}
        },
        builder: (BuildContext context, AppStates state)
        {
          AppCubit cubit = AppCubit.get(context);
          return Scaffold(
            key: scaffoldKey,
            appBar: AppBar(
              title: Text(cubit.title[cubit.currentIndex]),
            ),
            body: ConditionalBuilder(
              condition: state is! LoadingIndicatorState,
              builder:(context) =>cubit.screens[cubit.currentIndex],
              fallback: (context)=> Center(child: CircularProgressIndicator()),

            ),
            floatingActionButton: FloatingActionButton(
              onPressed: ()
              {
                if (cubit.isBottomSheetVisible == true)
                {
                  cubit.insertToDatabase(
                      title: titleController.text,
                      time: timeController.text,
                      date: dateController.text);
                } else
                {
                  scaffoldKey.currentState!.showBottomSheet(
                    (context) => Container(
                      color: Colors.white,
                      width: double.infinity,
                      padding:  const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children:
                        [
                          Container(
                            height: 50,
                            width: 200,
                            child: taskField(
                                text: 'Title',
                                controller: titleController,
                                icon: Icons.title,
                                keyBoardType: TextInputType.text,
                                funcOnTap: () {}
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                            height: 50,
                            width: 200,
                            child: taskField(
                                text: 'Task time', //label
                                controller: timeController, //content of the field
                                icon: Icons.watch,
                                keyBoardType: TextInputType.datetime,
                                funcOnTap: () {
                                  showTimePicker(
                                      context: context,
                                      initialEntryMode: TimePickerEntryMode.input,
                                      initialTime: TimeOfDay.now())
                                      .then((value) {
                                      timeController.text =
                                        value!.format(context).toString();
                                  });
                                }),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                            height: 50,
                            width: 200,
                            child: taskField(
                                text: 'Task date',
                                controller: dateController,
                                icon: Icons.title,
                                keyBoardType: TextInputType.text,
                                funcOnTap: () {
                                  showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.parse('2022-09-02'))
                                      .then((value) {
                                      dateController.text =
                                        DateFormat.yMMMd().format(value!);
                                  });
                                }),
                          ),
                        ],
                      ),
                    ),
                    elevation: 100.0,
                  ).closed.then((value)
                  {
                    cubit.changeBottomSheet(isShow: false,fabIcon: Icons.edit);
                  });
                  cubit.changeBottomSheet(isShow: true,fabIcon: Icons.add);
                }
              },
              child: Icon(cubit.fabIcon),
            ),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: cubit.currentIndex,
              elevation: 20.0,
              onTap: (index)
              {
                cubit.changeIndex(index);
              },
              items:  const [
                BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'New'),
                BottomNavigationBarItem(icon: Icon(Icons.check), label: 'Done'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.archive_outlined), label: 'Archived'),
              ],
            ),
          );
        },
      ),
    );
  }
}

//future => داتا هتيجي فى المستقبل وبحدد نوع الداتا الى مستنيها بين القوسين الى بعد الكلمة,