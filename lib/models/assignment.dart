class Assignment {
  final int? id;
  final String title;
  final String description;
  final DateTime dueDate;
  final String subject;
  final String className;
  final int maxPoints;

  Assignment({
    this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.subject,
    required this.className,
    required this.maxPoints,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'subject': subject,
      'className': className,
      'maxPoints': maxPoints,
    };
  }

  factory Assignment.fromMap(Map<String, dynamic> map) {
    return Assignment(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      dueDate: DateTime.parse(map['dueDate']),
      subject: map['subject'],
      className: map['className'],
      maxPoints: map['maxPoints'],
    );
  }
}

class AssignmentSubmission {
  final int? id;
  final int assignmentId;
  final int studentId;
  final DateTime submissionDate;
  final String status; // 'pending', 'submitted', 'late', 'graded'
  final String? attachmentUrl;
  final String? remarks;

  AssignmentSubmission({
    this.id,
    required this.assignmentId,
    required this.studentId,
    required this.submissionDate,
    required this.status,
    this.attachmentUrl,
    this.remarks,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'assignmentId': assignmentId,
      'studentId': studentId,
      'submissionDate': submissionDate.toIso8601String(),
      'status': status,
      'attachmentUrl': attachmentUrl,
      'remarks': remarks,
    };
  }

  factory AssignmentSubmission.fromMap(Map<String, dynamic> map) {
    return AssignmentSubmission(
      id: map['id'] as int?,
      assignmentId: map['assignmentId'] as int,
      studentId: map['studentId'] as int,
      submissionDate: DateTime.parse(map['submissionDate'] as String),
      status: map['status'] as String,
      attachmentUrl: map['attachmentUrl'] as String?,
      remarks: map['remarks'] as String?,
    );
  }
}
