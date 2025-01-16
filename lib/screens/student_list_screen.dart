import 'package:flutter/material.dart';
import '../models/student.dart';
import '../database/database_helper.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  List<Student> _students = [];
  bool _isLoading = true;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() => _isLoading = true);
    try {
      final students = await _databaseHelper.getAllStudents();
      setState(() {
        _students = students;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading students: $e');
      setState(() {
        _students = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteStudent(Student student) async {
    try {
      await _databaseHelper.deleteStudent(student.id!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student deleted successfully')),
      );
      _loadStudents();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete student')),
      );
    }
  }

  void _showStudentDialog({Student? student}) {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController(text: student?.name);
    final _rollNumberController =
        TextEditingController(text: student?.rollNumber);
    final _classController = TextEditingController(text: student?.className);
    final _contactController =
        TextEditingController(text: student?.contactInfo);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(student == null ? 'Add Student' : 'Edit Student'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Name is required' : null,
                ),
                TextFormField(
                  controller: _rollNumberController,
                  decoration: const InputDecoration(labelText: 'Roll Number'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Roll Number is required' : null,
                ),
                TextFormField(
                  controller: _classController,
                  decoration: const InputDecoration(labelText: 'Class'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Class is required' : null,
                ),
                TextFormField(
                  controller: _contactController,
                  decoration:
                      const InputDecoration(labelText: 'Contact Information'),
                  validator: (value) => value?.isEmpty ?? true
                      ? 'Contact Information is required'
                      : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (_formKey.currentState?.validate() ?? false) {
                final newStudent = Student(
                  id: student?.id,
                  name: _nameController.text,
                  rollNumber: _rollNumberController.text,
                  className: _classController.text,
                  contactInfo: _contactController.text,
                );

                try {
                  if (student == null) {
                    await _databaseHelper.insertStudent(newStudent);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Student added successfully')),
                    );
                  } else {
                    await _databaseHelper.updateStudent(newStudent);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Student updated successfully')),
                    );
                  }
                  Navigator.pop(context);
                  _loadStudents();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to save student'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text(student == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  List<Student> get _filteredStudents => _students
      .where((student) =>
          student.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          student.rollNumber
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          student.className.toLowerCase().contains(_searchQuery.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Students'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search students...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredStudents.isEmpty
              ? const Center(child: Text('No students found'))
              : ListView.builder(
                  itemCount: _filteredStudents.length,
                  itemBuilder: (context, index) {
                    final student = _filteredStudents[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(student.name[0].toUpperCase()),
                        ),
                        title: Text(student.name),
                        subtitle: Text(
                            'Roll No: ${student.rollNumber} | Class: ${student.className}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () =>
                                  _showStudentDialog(student: student),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Student'),
                                  content: const Text(
                                      'Are you sure you want to delete this student?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _deleteStudent(student);
                                      },
                                      child: const Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StudentListScreen(),
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showStudentDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
