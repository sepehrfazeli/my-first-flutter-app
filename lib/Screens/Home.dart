import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todoapp/Screens/settings.dart';
import 'package:todoapp/Screens/taskspage.dart';
import 'package:todoapp/assets/images.dart';
import 'package:todoapp/theme/colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emojiController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const SettingsPage()));
          },
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundImage: AssetImage(AppImages.Profile),
            ),
          ),
        ),
        title: const Text(
          'Categories',
          style: TextStyle(
              color: AppColors.black,
              fontSize: 25,
              fontWeight: FontWeight.w500),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, size: 40, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        children: [
          Column(
            children: [
              const SizedBox(height: 50),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: AppColors.white,
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black26, spreadRadius: 1, blurRadius: 5)
                    ],
                    borderRadius: BorderRadius.circular(5)),
                padding: const EdgeInsets.symmetric(vertical: 25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage(AppImages.Profile),
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                            width: MediaQuery.of(context).size.width / 1.7,
                            child: Text(
                              '"It is important to learn that you can learn anything you want, and that you can get better quickly. This feels like an unlikely miracle the first few times it happens, but eventually you learn to trust that you can do it."',
                              style: GoogleFonts.oleoScript(
                                fontSize: 15,
                                color: AppColors.black,
                              ),
                            )),
                        const SizedBox(height: 10),
                        const Text(
                          'Sam Altman',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.grey,
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    width: 20,
                  ),
                  _addBox(),
                ],
              ),
              const SizedBox(height: 40),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('ToDo')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final tasks = snapshot.data!.docs;
                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      final title = task['title'];
                      final emoji = task['emoji'];
                      final tasksCount = task['tasksCount'].toString();

                      return _box(emoji, title, tasksCount);
                    },
                  );
                },
              ),
              const SizedBox(
                height: 50,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _box(String emoji, String title, String tasks) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => TasksPage(
                      catname: title,
                    )));
      },
      child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: const [
                BoxShadow(color: AppColors.grey, spreadRadius: 1, blurRadius: 5)
              ],
              borderRadius: BorderRadius.circular(5)),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 40),
              ),
              Text(
                title,
                style:
                    const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Text(
                    '$tasks tasks',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  PopupMenuButton(
                    icon: const Icon(Icons.more_vert),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) async {
                      if (value == 'delete') {
                        // Show confirmation dialog
                        bool? confirm = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Delete Category'),
                              content: Text(
                                  'Are you sure you want to delete "$title"?'),
                              actions: [
                                TextButton(
                                  child: const Text('Cancel'),
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                ),
                                TextButton(
                                  child: const Text('Delete',
                                      style: TextStyle(color: Colors.red)),
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                ),
                              ],
                            );
                          },
                        );

                        if (confirm == true) {
                          try {
                            // Query to find the document with matching title
                            QuerySnapshot querySnapshot =
                                await FirebaseFirestore.instance
                                    .collection('ToDo')
                                    .where('title', isEqualTo: title)
                                    .get();

                            // Delete the document if found
                            if (querySnapshot.docs.isNotEmpty) {
                              await querySnapshot.docs.first.reference.delete();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Category "$title" deleted successfully')),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Error deleting category')),
                            );
                          }
                        }
                      }
                    },
                  )
                ],
              )
            ],
          )),
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
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '😇',
                      style: TextStyle(fontSize: 70),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: nameController,
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
                TextFormField(
                  controller: emojiController,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    hintText: 'Emoji',
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || !_isEmoji(value)) {
                      return 'Only emojis are allowed.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                const Text(
                  '0 tasks',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () async {
                    if (_formKey.currentState!.validate()) {
                      await FirebaseFirestore.instance.collection('ToDo').add({
                        'title': nameController.text,
                        'emoji': emojiController.text,
                        'tasksCount': 0,
                        'createdAt': Timestamp.now(),
                      });

                      nameController.clear();
                      emojiController.clear();

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

  bool _isEmoji(String text) {
    final emojiRegExp = RegExp(
      r'^[\u{1F300}-\u{1F5FF}\u{1F600}-\u{1F64F}\u{1F900}-\u{1F9FF}\u{1F680}-\u{1F6FF}\u{2600}-\u{26FF}]$',
      unicode: true,
    );
    return emojiRegExp.hasMatch(text);
  }

  Widget _addBox() {
    return GestureDetector(
      onTap: () {
        _addToDo();
      },
      child: Container(
        height: 160,
        width: 160,
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: const [
            BoxShadow(color: AppColors.grey, spreadRadius: 1, blurRadius: 5)
          ],
          borderRadius: BorderRadius.circular(5),
        ),
        alignment: Alignment.center,
        child: const CircleAvatar(
          backgroundColor: AppColors.darckBackground,
          radius: 40,
          child: Icon(
            Icons.add,
            size: 40,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}
