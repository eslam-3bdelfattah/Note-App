import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/shared/cubit/cubit.dart';

Widget taskField({
  TextInputType? keyBoardType,
  TextEditingController? controller,
  String? text,
  IconData? icon,
  required  Function() funcOnTap,
})
{
 return TextFormField(
   keyboardType: keyBoardType,
   controller: controller,
   onTap: funcOnTap,
   decoration: InputDecoration(
     label: Text('$text'),
     prefixIcon: Icon(icon),
     border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0)),

   ),
 );
}
//tasks layout
Widget newTaskItem(Map task,context)=> Dismissible(
  key: Key(task['id'].toString()),
  child:   Padding(
    padding: const EdgeInsets.all(20),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children:
      [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.black,
          child: CircleAvatar(
            radius: 29,
            backgroundColor: Colors.white,
            child: Text(
              '${task['date']}',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 12.0,
                  color: Colors.black
              ),
            ),
          ),
        ),
        SizedBox(
          width: 20,),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${task['title']}',
                maxLines: 2,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
              Text(
                '${task['time']}',
                style: TextStyle(
                    color: Colors.grey[150]
                ),
              ),
            ],
          ),
        ),
        Wrap(
          alignment: WrapAlignment.end,
          spacing : -15.0,
          children:
          [
            IconButton(onPressed: ()
            {
              AppCubit.get(context).updateDataFromDatabase(status: 'done', id: task['id']);
            },
              icon: const Icon(Icons.check_box),
              color: Colors.green,iconSize: 20,),
            IconButton(onPressed: ()
            {
              AppCubit.get(context).updateDataFromDatabase(status: 'archived', id: task['id']);
            },
              icon: const Icon(Icons.archive_outlined,
                color: Colors.black45, size: 20,),),
          ],
        )
      ],
    ),
  ),
  onDismissed: (direction){
    AppCubit.get(context).deleteFromDatabase(id: task['id']);
  },
);
//when there is no tasks
Widget buildTask({
  List<Map>? task
}){
  return ConditionalBuilder(condition: task!.isNotEmpty,
      builder: (context) => ListView.separated(itemBuilder: (context,index)=> newTaskItem(task[index], context),
          separatorBuilder: (context,index)=> Container(
            width: double.infinity,
            height: 2.0,
            color: Colors.grey[300],
          ),
          itemCount: task.length
      ),
      fallback: (context)=> Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:
          const [
            Icon(
              Icons.menu,
              size: 80,
              color: Colors.grey,
            ),
            Text(
              'No tasks for today yet!',
              style: TextStyle(
                fontSize: 20,
                color: Colors.black45
              ),
            ),
          ],
        ),
      )
  );
}