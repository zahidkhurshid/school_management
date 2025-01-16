import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/student.dart';
import '../models/timetable.dart';
import '../models/fee.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'school_management.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('school_management.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 4,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        rollNumber TEXT NOT NULL,
        className TEXT NOT NULL,
        contactInfo TEXT NOT NULL,
        email TEXT,
        address TEXT,
        parentName TEXT,
        parentContact TEXT,
        bloodGroup TEXT,
        dateOfBirth TEXT,
        gender TEXT,
        photoUrl TEXT,
        academicDetails TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE attendance (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        studentId INTEGER NOT NULL,
        date TEXT NOT NULL,
        status INTEGER NOT NULL,
        FOREIGN KEY (studentId) REFERENCES students (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE timetable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        startTime TEXT NOT NULL,
        endTime TEXT NOT NULL,
        subject TEXT NOT NULL,
        teacher TEXT NOT NULL,
        room TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE exams (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        date TEXT NOT NULL,
        subject TEXT NOT NULL,
        className TEXT NOT NULL,
        maxMarks INTEGER NOT NULL,
        duration INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE exam_results (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        examId INTEGER NOT NULL,
        studentId INTEGER NOT NULL,
        marksObtained REAL NOT NULL,
        remarks TEXT,
        FOREIGN KEY (examId) REFERENCES exams (id),
        FOREIGN KEY (studentId) REFERENCES students (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE assignments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        dueDate TEXT NOT NULL,
        subject TEXT NOT NULL,
        className TEXT NOT NULL,
        maxPoints INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE assignment_submissions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        assignmentId INTEGER NOT NULL,
        studentId INTEGER NOT NULL,
        submissionDate TEXT NOT NULL,
        status TEXT NOT NULL,
        attachmentUrl TEXT,
        remarks TEXT,
        FOREIGN KEY (assignmentId) REFERENCES assignments (id),
        FOREIGN KEY (studentId) REFERENCES students (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE fees (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        studentId INTEGER NOT NULL,
        amount REAL NOT NULL,
        dueDate TEXT NOT NULL,
        status TEXT NOT NULL,
        description TEXT NOT NULL,
        FOREIGN KEY (studentId) REFERENCES students (id)
      )
    ''');

    // Insert sample data
    await db.insert('students', {
      'name': 'John Doe',
      'rollNumber': '2023001',
      'className': 'Class X-A',
      'contactInfo': '+1234567890',
      'email': 'john.doe@example.com',
      'parentName': 'Jane Doe',
      'parentContact': '+1987654321'
    });

    // Sample Exams
    await db.insert('exams', {
      'title': 'Mid-Term Mathematics',
      'date': DateTime.now().add(const Duration(days: 5)).toIso8601String().split('T')[0],
      'subject': 'Mathematics',
      'className': 'Class X-A',
      'maxMarks': 100,
      'duration': 180  // 3 hours in minutes
    });

    await db.insert('exams', {
      'title': 'Physics Practical',
      'date': DateTime.now().add(const Duration(days: 7)).toIso8601String().split('T')[0],
      'subject': 'Physics',
      'className': 'Class X-A',
      'maxMarks': 50,
      'duration': 120  // 2 hours in minutes
    });

    // Sample Assignments
    await db.insert('assignments', {
      'title': 'Mathematics Problem Set',
      'description': 'Complete exercises from Chapter 5: Quadratic Equations',
      'dueDate': DateTime.now().add(const Duration(days: 3)).toIso8601String().split('T')[0],
      'subject': 'Mathematics',
      'className': 'Class X-A',
      'maxPoints': 20
    });

    await db.insert('assignments', {
      'title': 'Science Project',
      'description': 'Prepare a working model demonstrating renewable energy sources',
      'dueDate': DateTime.now().add(const Duration(days: 10)).toIso8601String().split('T')[0],
      'subject': 'Science',
      'className': 'Class X-A',
      'maxPoints': 50
    });

    // Sample Fees data
    await db.insert('fees', {
      'studentId': 1,
      'amount': 5000.0,
      'dueDate': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
      'status': 'PENDING',
      'description': 'First Term Fee'
    });

    await db.insert('fees', {
      'studentId': 1,
      'amount': 3000.0,
      'dueDate': DateTime.now().add(const Duration(days: 14)).toIso8601String(),
      'status': 'PENDING',
      'description': 'Lab Fee'
    });
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('DROP TABLE IF EXISTS timetable');
      await db.execute('''
        CREATE TABLE timetable (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date TEXT NOT NULL,
          startTime TEXT NOT NULL,
          endTime TEXT NOT NULL,
          subject TEXT NOT NULL,
          teacher TEXT NOT NULL,
          room TEXT NOT NULL
        )
      ''');
    }
    
    if (oldVersion < 3) {
      await db.execute('DROP TABLE IF EXISTS exams');
      await db.execute('DROP TABLE IF EXISTS exam_results');
      await db.execute('DROP TABLE IF EXISTS assignments');
      await db.execute('DROP TABLE IF EXISTS assignment_submissions');
      await db.execute('DROP TABLE IF EXISTS fees');
      
      // Recreate tables with correct schema
      await db.execute('''
        CREATE TABLE exams (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          date TEXT NOT NULL,
          subject TEXT NOT NULL,
          className TEXT NOT NULL,
          maxMarks INTEGER NOT NULL,
          duration INTEGER NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE exam_results (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          examId INTEGER NOT NULL,
          studentId INTEGER NOT NULL,
          marksObtained REAL NOT NULL,
          remarks TEXT,
          FOREIGN KEY (examId) REFERENCES exams (id),
          FOREIGN KEY (studentId) REFERENCES students (id)
        )
      ''');

      await db.execute('''
        CREATE TABLE assignments (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          description TEXT NOT NULL,
          dueDate TEXT NOT NULL,
          subject TEXT NOT NULL,
          className TEXT NOT NULL,
          maxPoints INTEGER NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE assignment_submissions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          assignmentId INTEGER NOT NULL,
          studentId INTEGER NOT NULL,
          submissionDate TEXT NOT NULL,
          status TEXT NOT NULL,
          remarks TEXT,
          FOREIGN KEY (assignmentId) REFERENCES assignments (id),
          FOREIGN KEY (studentId) REFERENCES students (id)
        )
      ''');

      await db.execute('''
        CREATE TABLE fees (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          studentId INTEGER NOT NULL,
          amount REAL NOT NULL,
          dueDate TEXT NOT NULL,
          status TEXT NOT NULL,
          description TEXT NOT NULL,
          FOREIGN KEY (studentId) REFERENCES students (id)
        )
      ''');
    }

    if (oldVersion < 4) {
      // Add sample data after schema is correct
      await db.insert('exams', {
        'title': 'Mid-Term Mathematics',
        'date': DateTime.now().add(const Duration(days: 5)).toIso8601String().split('T')[0],
        'subject': 'Mathematics',
        'className': 'Class X-A',
        'maxMarks': 100,
        'duration': 180
      });

      await db.insert('exams', {
        'title': 'Physics Practical',
        'date': DateTime.now().add(const Duration(days: 7)).toIso8601String().split('T')[0],
        'subject': 'Physics',
        'className': 'Class X-A',
        'maxMarks': 50,
        'duration': 120
      });

      await db.insert('assignments', {
        'title': 'Mathematics Problem Set',
        'description': 'Complete exercises from Chapter 5: Quadratic Equations',
        'dueDate': DateTime.now().add(const Duration(days: 3)).toIso8601String().split('T')[0],
        'subject': 'Mathematics',
        'className': 'Class X-A',
        'maxPoints': 20
      });

      await db.insert('assignments', {
        'title': 'Science Project',
        'description': 'Prepare a working model demonstrating renewable energy sources',
        'dueDate': DateTime.now().add(const Duration(days: 10)).toIso8601String().split('T')[0],
        'subject': 'Science',
        'className': 'Class X-A',
        'maxPoints': 50
      });
    }
  }

  // Student CRUD operations
  Future<int> insertStudent(Student student) async {
    final db = await database;
    return await db.insert('students', student.toMap());
  }

  Future<List<Student>> getAllStudents() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('students');
    return List.generate(maps.length, (i) => Student.fromMap(maps[i]));
  }

  Future<int> updateStudent(Student student) async {
    final db = await database;
    return await db.update(
      'students',
      student.toMap(),
      where: 'id = ?',
      whereArgs: [student.id],
    );
  }

  Future<int> deleteStudent(int id) async {
    final db = await database;
    await db.delete('attendance', where: 'studentId = ?', whereArgs: [id]);
    return await db.delete('students', where: 'id = ?', whereArgs: [id]);
  }

  // Attendance operations
  Future<Map<int, bool>> getAttendanceForDate(String date) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'attendance',
      where: 'date = ?',
      whereArgs: [date],
    );
    
    return {
      for (var record in result)
        record['studentId'] as int: record['status'] == 1
    };
  }

  Future<void> saveAttendance(String date, Map<int, bool> attendance) async {
    final db = await database;
    await db.transaction((txn) async {
      // Delete existing attendance for the date
      await txn.delete(
        'attendance',
        where: 'date = ?',
        whereArgs: [date],
      );

      // Insert new attendance records
      for (var entry in attendance.entries) {
        await txn.insert('attendance', {
          'studentId': entry.key,
          'date': date,
          'status': entry.value ? 1 : 0,
        });
      }
    });
  }

  // Timetable operations
  Future<List<TimetableEntry>> getTimetableForDate(DateTime date) async {
    final db = await database;
    final dateStr = date.toIso8601String().split('T')[0];
    final List<Map<String, dynamic>> result = await db.query(
      'timetable',
      where: 'date = ?',
      whereArgs: [dateStr],
      orderBy: 'startTime ASC',
    );
    
    return result.map((map) => TimetableEntry.fromMap(map)).toList();
  }

  Future<int> insertTimetableEntry(TimetableEntry entry) async {
    final db = await database;
    final dateStr = entry.date.toIso8601String().split('T')[0];
    final map = entry.toMap();
    map['date'] = dateStr;
    return await db.insert('timetable', map);
  }

  Future<int> updateTimetableEntry(TimetableEntry entry) async {
    final db = await database;
    final dateStr = entry.date.toIso8601String().split('T')[0];
    final map = entry.toMap();
    map['date'] = dateStr;
    return await db.update(
      'timetable',
      map,
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<int> deleteTimetableEntry(int id) async {
    final db = await database;
    return await db.delete('timetable', where: 'id = ?', whereArgs: [id]);
  }

  // Fee operations
  Future<List<Fee>> getAllFees() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('fees');
    return List.generate(maps.length, (i) {
      return Fee(
        id: maps[i]['id'],
        studentId: maps[i]['studentId'],
        amount: maps[i]['amount'],
        dueDate: DateTime.parse(maps[i]['dueDate']),
        status: maps[i]['status'],
        description: maps[i]['description'],
      );
    });
  }

  Future<List<Fee>> getFees(int studentId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'fees',
      where: 'studentId = ?',
      whereArgs: [studentId],
    );
    return List.generate(maps.length, (i) {
      return Fee(
        id: maps[i]['id'],
        studentId: maps[i]['studentId'],
        amount: maps[i]['amount'],
        dueDate: DateTime.parse(maps[i]['dueDate']),
        status: maps[i]['status'],
        description: maps[i]['description'],
      );
    });
  }

  Future<int> insertFee(Fee fee) async {
    final db = await database;
    return await db.insert('fees', fee.toMap());
  }

  Future<int> updateFee(Fee fee) async {
    final db = await database;
    return await db.update(
      'fees',
      fee.toMap(),
      where: 'id = ?',
      whereArgs: [fee.id],
    );
  }

  Future<int> deleteFee(int id) async {
    final db = await database;
    return await db.delete(
      'fees',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Exam results operations
  Future<List<Map<String, dynamic>>> getExamResults(int studentId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT 
        er.*,
        e.title,
        e.subject,
        e.maxMarks,
        e.date
      FROM exam_results er
      JOIN exams e ON er.examId = e.id
      WHERE er.studentId = ?
      ORDER BY e.date DESC
    ''', [studentId]);
  }

  // Assignment operations
  Future<List<Map<String, dynamic>>> getAssignments(int studentId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT 
        a.*,
        COALESCE(s.status, 'pending') as submission_status,
        s.submissionDate,
        s.remarks
      FROM assignments a
      LEFT JOIN assignment_submissions s ON 
        a.id = s.assignmentId AND 
        s.studentId = ?
      ORDER BY a.dueDate DESC
    ''', [studentId]);
  }
}
