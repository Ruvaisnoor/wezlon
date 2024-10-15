import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import '../models/student.dart';
import '../storage/student_storage.dart';
import 'login.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StudentStorage _studentStorage = StudentStorage();
  List<Student> _students = [];

  @override
  void initState() {
    super.initState();
    _initializeStorage();
  }

  Future<void> _initializeStorage() async {
    await _studentStorage.init();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() {
      _students = _studentStorage.getStudents();
    });
  }

  Future<void> _addOrUpdateStudent({Student? student, int? index}) async {
    final nameController = TextEditingController(text: student?.name);
    final domainController = TextEditingController(text: student?.domain);
    final ageController = TextEditingController(text: student?.age.toString());
    String imagePath = student?.imagePath ?? '';

    showDialog<Student>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(student == null ? 'Add Student' : 'Update Student'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: imagePath.isNotEmpty
                          ? FileImage(File(imagePath))
                          : const AssetImage('assets/default_avatar.png') as ImageProvider,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                    TextField(
                      controller: domainController,
                      decoration: const InputDecoration(labelText: 'Domain'),
                    ),
                    TextField(
                      controller: ageController,
                      decoration: const InputDecoration(labelText: 'Age'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        TextButton(
                          onPressed: () async {
                            final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                            if (pickedFile != null) {
                              setState(() {
                                imagePath = pickedFile.path;  
                              });
                            }
                          },
                          child: const Text('Pick Image'),
                        ),
                        TextButton(
                          onPressed: () async {
                            final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
                            if (pickedFile != null) {
                              setState(() {
                                imagePath = pickedFile.path;  
                              });
                            }
                          },
                          child: const Text('Take Photo'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final name = nameController.text;
                final domain = domainController.text;
                final age = int.tryParse(ageController.text);

                if (name.isNotEmpty && domain.isNotEmpty && age != null && age >= 0) {
                  final studentToSave = Student(
                    name: name,
                    domain: domain,
                    age: age,
                    imagePath: imagePath,
                  );
                  if (index != null) {
                    _studentStorage.updateStudent(index, studentToSave);
                  } else {
                    _studentStorage.addStudent(studentToSave);
                  }
                  Navigator.of(context).pop();
                  _loadStudents();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter valid data.')),
                  );
                }
              },
              child: Text(student == null ? 'Add' : 'Update'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteStudent(int index) async {
    await _studentStorage.deleteStudent(index);
    _loadStudents();
  }

  void _signOut() {
    var box = Hive.box('userBox');
    box.clear();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const ScreenLogin()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Student Management',
          style: GoogleFonts.sail(
            color: Colors.white,
            fontSize: 35,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 180, 0, 0),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            color: Colors.white,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _students.length,
        itemBuilder: (context, index) {
          final student = _students[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            elevation: 4,
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: student.imagePath.isNotEmpty
                    ? FileImage(File(student.imagePath))
                    : const AssetImage('assets/default_avatar.png') as ImageProvider,
              ),
              title: Text(
                student.name,
                style: GoogleFonts.merriweather(fontSize: 20),
              ),
              subtitle: Text('Domain: ${student.domain}, Age: ${student.age}'),
              onTap: () => _addOrUpdateStudent(student: student, index: index),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _addOrUpdateStudent(student: student, index: index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteStudent(index),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrUpdateStudent(),
        backgroundColor: const Color.fromARGB(255, 180, 0, 0),
        child: const Icon(Icons.add),
      ),
    );
  }
}
