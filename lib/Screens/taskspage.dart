import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:roundcheckbox/roundcheckbox.dart';
import 'package:todoapp/theme/colors.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key, required this.catname});
  final String catname;

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final TasckController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          widget.catname,
          style: const TextStyle(
              color: AppColors.black,
              fontSize: 25,
              fontWeight: FontWeight.w500),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: Icon(
              Icons.search,
              size: 35,
            ),
          )
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 30),
            const Text(
              'Today',
              style: TextStyle(
                  color: Color.fromARGB(255, 131, 133, 134), fontSize: 18),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('tasks')
                    .where('Category', isEqualTo: widget.catname)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No tasks found'));
                  }

                  var docs = snapshot.data!.docs;
                  docs.sort((a, b) => (b['createdAt'] as Timestamp)
                      .compareTo(a['createdAt'] as Timestamp));

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      var task = docs[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            DottedBorder(
                              color: Colors.green,
                              borderType: BorderType.Circle,
                              child: RoundCheckBox(
                                onTap: (selected) {},
                                // onTap: (selected) async {
                                //   if (selected == true) {
                                //     await FirebaseFirestore.instance
                                //         .collection('tasks')
                                //         .doc(task.id)
                                //         .delete();
                                //   }
                                // },
                                size: 40,
                                border: Border.all(
                                    width: 2,
                                    color: Colors.green,
                                    style: BorderStyle.none),
                                uncheckedColor: Colors.transparent,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Text(
                                task['Tasck'],
                                style: const TextStyle(
                                    color: AppColors.black, fontSize: 22),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                showOptionsMenu(context, task.id);
                              },
                              icon: const Icon(Icons.more_vert),
                            )
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addToDo();
        },
        backgroundColor: AppColors.blue,
        child: const Icon(
          Icons.add,
          color: AppColors.white,
          size: 40,
        ),
      ),
    );
  }

  void showOptionsMenu(BuildContext context, String taskId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  await FirebaseFirestore.instance
                      .collection('tasks')
                      .doc(taskId)
                      .delete();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<dynamic> _addToDo() {
    return showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: Colors.black12,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.black54,
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: TasckController,
                  decoration: const InputDecoration(
                    hintText: 'Title',
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Title is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () async {
                    if (_formKey.currentState!.validate()) {
                      await FirebaseFirestore.instance.collection('tasks').add({
                        'Tasck': TasckController.text,
                        'Category': widget.catname,
                        'createdAt': Timestamp.now(),
                        'completed': false,
                      });

                      TasckController.clear();
                      Navigator.pop(context);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: AppColors.blue),
                    child: const Text(
                      'Add Task',
                      style: TextStyle(color: AppColors.white, fontSize: 20),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
