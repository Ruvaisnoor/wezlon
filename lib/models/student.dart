import 'package:hive/hive.dart';

part 'student.g.dart';

@HiveType(typeId: 0)
class Student {
  @HiveField(0)
  String name;

  @HiveField(1)
  String? domain;

  @HiveField(2)
  int age;

  @HiveField(3)
  String imagePath; 

  Student({
    required this.name,
    this.domain,
    required this.age,
    required this.imagePath, 
  });
}
