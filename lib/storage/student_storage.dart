import 'package:hive/hive.dart';
import '../models/student.dart';

class StudentStorage {
  late Box<Student> _studentBox;

  Future<void> init() async {
    _studentBox = await Hive.openBox<Student>('studentsBox');
  }

  List<Student> getStudents() {
    return _studentBox.values.toList();
  }

  Future<void> addStudent(Student student) async {
    await _studentBox.add(student);
  }

  Future<void> updateStudent(int index, Student student) async {
    await _studentBox.putAt(index, student);
  }

  Future<void> deleteStudent(int index) async {
    await _studentBox.deleteAt(index);
  }
}
