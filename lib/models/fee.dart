class Fee {
  final int? id;
  final int studentId;
  final double amount;
  final DateTime dueDate;
  final String status; // 'pending', 'paid', 'overdue'
  final String? description;

  Fee({
    this.id,
    required this.studentId,
    required this.amount,
    required this.dueDate,
    required this.status,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'amount': amount,
      'dueDate': dueDate.toIso8601String(),
      'status': status,
      'description': description,
    };
  }

  factory Fee.fromMap(Map<String, dynamic> map) {
    return Fee(
      id: map['id'] as int?,
      studentId: map['studentId'] as int,
      amount: map['amount'] as double,
      dueDate: DateTime.parse(map['dueDate'] as String),
      status: map['status'] as String,
      description: map['description'] as String?,
    );
  }
}
