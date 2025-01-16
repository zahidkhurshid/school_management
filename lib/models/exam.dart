class Exam {
  final int? id;
  final String title;
  final DateTime date;
  final String subject;
  final String className;
  final int maxMarks;
  final int duration; // in minutes

  Exam({
    this.id,
    required this.title,
    required this.date,
    required this.subject,
    required this.className,
    required this.maxMarks,
    required this.duration,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'subject': subject,
      'className': className,
      'maxMarks': maxMarks,
      'duration': duration,
    };
  }

  factory Exam.fromMap(Map<String, dynamic> map) {
    return Exam(
      id: map['id'],
      title: map['title'],
      date: DateTime.parse(map['date']),
      subject: map['subject'],
      className: map['className'],
      maxMarks: map['maxMarks'],
      duration: map['duration'],
    );
  }
}

class ExamResult {
  final int? id;
  final int examId;
  final int studentId;
  final double marksObtained;
  final String? remarks;

  ExamResult({
    this.id,
    required this.examId,
    required this.studentId,
    required this.marksObtained,
    this.remarks,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'examId': examId,
      'studentId': studentId,
      'marksObtained': marksObtained,
      'remarks': remarks,
    };
  }

  factory ExamResult.fromMap(Map<String, dynamic> map) {
    return ExamResult(
      id: map['id'] as int?,
      examId: map['examId'] as int,
      studentId: map['studentId'] as int,
      marksObtained: map['marksObtained'] as double,
      remarks: map['remarks'] as String?,
    );
  }
}
