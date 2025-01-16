import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/exam.dart';
import '../models/assignment.dart';
import '../database/database_helper.dart';

class AcademicScreen extends StatefulWidget {
  const AcademicScreen({super.key});

  @override
  State<AcademicScreen> createState() => _AcademicScreenState();
}

class _AcademicScreenState extends State<AcademicScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  List<Exam> _upcomingExams = [];
  List<Assignment> _assignments = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final db = await _databaseHelper.database;

      // Check if exams table exists
      final tables = await db.query('sqlite_master',
          where: 'type = ? AND name = ?', whereArgs: ['table', 'exams']);

      if (tables.isEmpty) {
        // Table doesn't exist, recreate database
        await _databaseHelper.deleteDatabase();
        // Get new database instance
        await _databaseHelper.database;
      }

      // Load upcoming exams
      final List<Map<String, dynamic>> examMaps = await db.query('exams',
          where: 'date >= ?',
          whereArgs: [DateTime.now().toIso8601String().split('T')[0]],
          orderBy: 'date ASC');

      // Load assignments
      final List<Map<String, dynamic>> assignmentMaps = await db.query(
          'assignments',
          where: 'dueDate >= ?',
          whereArgs: [DateTime.now().toIso8601String().split('T')[0]],
          orderBy: 'dueDate ASC');

      setState(() {
        _upcomingExams = examMaps.map((map) => Exam.fromMap(map)).toList();
        _assignments =
            assignmentMaps.map((map) => Assignment.fromMap(map)).toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Academics',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Text(
                'Exams',
                style: GoogleFonts.poppins(),
              ),
            ),
            Tab(
              child: Text(
                'Assignments',
                style: GoogleFonts.poppins(),
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildExamsTab(),
          _buildAssignmentsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _tabController.index == 0
              ? _showAddExamDialog()
              : _showAddAssignmentDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildExamsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _upcomingExams.length,
      itemBuilder: (context, index) {
        final exam = _upcomingExams[index];
        return Card(
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              exam.title,
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('MMM dd, yyyy').format(exam.date),
                      style: GoogleFonts.poppins(),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.timer, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      '${exam.duration} minutes',
                      style: GoogleFonts.poppins(),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.school, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      '${exam.subject} - ${exam.className}',
                      style: GoogleFonts.poppins(),
                    ),
                  ],
                ),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: Text('Edit', style: GoogleFonts.poppins()),
                  onTap: () {
                    // TODO: Implement edit exam
                  },
                ),
                PopupMenuItem(
                  child: Text('Delete', style: GoogleFonts.poppins()),
                  onTap: () {
                    // TODO: Implement delete exam
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAssignmentsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _assignments.length,
      itemBuilder: (context, index) {
        final assignment = _assignments[index];
        final daysLeft = assignment.dueDate.difference(DateTime.now()).inDays;

        return Card(
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              assignment.title,
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  assignment.description,
                  style: GoogleFonts.poppins(),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Due: ${DateFormat('MMM dd, yyyy').format(assignment.dueDate)}',
                      style: GoogleFonts.poppins(),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: daysLeft < 2
                            ? Colors.red
                            : daysLeft < 5
                                ? Colors.orange
                                : Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$daysLeft days left',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.school, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      '${assignment.subject} - ${assignment.className}',
                      style: GoogleFonts.poppins(),
                    ),
                  ],
                ),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: Text('Edit', style: GoogleFonts.poppins()),
                  onTap: () {
                    // TODO: Implement edit assignment
                  },
                ),
                PopupMenuItem(
                  child: Text('Delete', style: GoogleFonts.poppins()),
                  onTap: () {
                    // TODO: Implement delete assignment
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddExamDialog() {
    final formKey = GlobalKey<FormState>();
    String title = '';
    String subject = '';
    String className = '';
    int maxMarks = 100;
    int duration = 180;
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Add New Exam',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'Enter exam title',
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter title' : null,
                  onSaved: (value) => title = value ?? '',
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Subject',
                    hintText: 'Enter subject',
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter subject' : null,
                  onSaved: (value) => subject = value ?? '',
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Class',
                    hintText: 'Enter class',
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter class' : null,
                  onSaved: (value) => className = value ?? '',
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Maximum Marks',
                    hintText: 'Enter maximum marks',
                  ),
                  keyboardType: TextInputType.number,
                  initialValue: '100',
                  validator: (value) => value?.isEmpty ?? true
                      ? 'Please enter maximum marks'
                      : null,
                  onSaved: (value) =>
                      maxMarks = int.tryParse(value ?? '') ?? 100,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Duration (minutes)',
                    hintText: 'Enter duration in minutes',
                  ),
                  keyboardType: TextInputType.number,
                  initialValue: '180',
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter duration' : null,
                  onSaved: (value) =>
                      duration = int.tryParse(value ?? '') ?? 180,
                ),
                ListTile(
                  title: const Text('Date'),
                  subtitle: Text(
                    DateFormat('MMM dd, yyyy').format(selectedDate),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() => selectedDate = date);
                    }
                  },
                ),
                ListTile(
                  title: const Text('Time'),
                  subtitle: Text(selectedTime.format(context)),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (time != null) {
                      setState(() => selectedTime = time);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                formKey.currentState?.save();
                final exam = Exam(
                  title: title,
                  date: DateTime(
                    selectedDate.year,
                    selectedDate.month,
                    selectedDate.day,
                    selectedTime.hour,
                    selectedTime.minute,
                  ),
                  subject: subject,
                  className: className,
                  maxMarks: maxMarks,
                  duration: duration,
                );
                // TODO: Save exam to database
                setState(() {
                  _upcomingExams.add(exam);
                });
                Navigator.pop(context);
              }
            },
            child: Text('Save', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  void _showAddAssignmentDialog() {
    final formKey = GlobalKey<FormState>();
    String title = '';
    String description = '';
    String subject = '';
    String className = '';
    DateTime dueDate = DateTime.now().add(const Duration(days: 7));
    int maxPoints = 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Add New Assignment',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'Enter assignment title',
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter title' : null,
                  onSaved: (value) => title = value ?? '',
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter assignment description',
                  ),
                  maxLines: 3,
                  validator: (value) => value?.isEmpty ?? true
                      ? 'Please enter description'
                      : null,
                  onSaved: (value) => description = value ?? '',
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Subject',
                    hintText: 'Enter subject',
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter subject' : null,
                  onSaved: (value) => subject = value ?? '',
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Class',
                    hintText: 'Enter class',
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter class' : null,
                  onSaved: (value) => className = value ?? '',
                ),
                ListTile(
                  title: const Text('Due Date'),
                  subtitle: Text(
                    DateFormat('MMM dd, yyyy').format(dueDate),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: dueDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() => dueDate = date);
                    }
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Max Points',
                    hintText: 'Enter max points',
                  ),
                  keyboardType: TextInputType.number,
                  initialValue: '0',
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter max points' : null,
                  onSaved: (value) =>
                      maxPoints = int.tryParse(value ?? '') ?? 0,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                formKey.currentState?.save();
                final assignment = Assignment(
                  title: title,
                  description: description,
                  dueDate: dueDate,
                  subject: subject,
                  className: className,
                  maxPoints: maxPoints,
                );
                // TODO: Save assignment to database
                setState(() {
                  _assignments.add(assignment);
                });
                Navigator.pop(context);
              }
            },
            child: Text('Save', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
