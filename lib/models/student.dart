class Student {
  final int? id;
  final String name;
  final String rollNumber;
  final String className;
  final String contactInfo;
  final String? email;
  final String? address;
  final String? parentName;
  final String? parentContact;
  final String? bloodGroup;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? photoUrl;
  final Map<String, dynamic>? academicDetails;

  Student({
    this.id,
    required this.name,
    required this.rollNumber,
    required this.className,
    required this.contactInfo,
    this.email,
    this.address,
    this.parentName,
    this.parentContact,
    this.bloodGroup,
    this.dateOfBirth,
    this.gender,
    this.photoUrl,
    this.academicDetails,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'rollNumber': rollNumber,
      'className': className,
      'contactInfo': contactInfo,
      'email': email,
      'address': address,
      'parentName': parentName,
      'parentContact': parentContact,
      'bloodGroup': bloodGroup,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'photoUrl': photoUrl,
      'academicDetails':
          academicDetails != null ? academicDetails.toString() : null,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'] as int?,
      name: map['name'] as String,
      rollNumber: map['rollNumber'] as String,
      className: map['className'] as String,
      contactInfo: map['contactInfo'] as String,
      email: map['email'] as String?,
      address: map['address'] as String?,
      parentName: map['parentName'] as String?,
      parentContact: map['parentContact'] as String?,
      bloodGroup: map['bloodGroup'] as String?,
      dateOfBirth: map['dateOfBirth'] != null
          ? DateTime.parse(map['dateOfBirth'] as String)
          : null,
      gender: map['gender'] as String?,
      photoUrl: map['photoUrl'] as String?,
      academicDetails: map['academicDetails'] != null
          ? Map<String, dynamic>.from(
              map['academicDetails'] as Map<String, dynamic>)
          : null,
    );
  }

  Student copyWith({
    int? id,
    String? name,
    String? rollNumber,
    String? className,
    String? contactInfo,
    String? email,
    String? address,
    String? parentName,
    String? parentContact,
    String? bloodGroup,
    DateTime? dateOfBirth,
    String? gender,
    String? photoUrl,
    Map<String, dynamic>? academicDetails,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      rollNumber: rollNumber ?? this.rollNumber,
      className: className ?? this.className,
      contactInfo: contactInfo ?? this.contactInfo,
      email: email ?? this.email,
      address: address ?? this.address,
      parentName: parentName ?? this.parentName,
      parentContact: parentContact ?? this.parentContact,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      photoUrl: photoUrl ?? this.photoUrl,
      academicDetails: academicDetails ?? this.academicDetails,
    );
  }
}
