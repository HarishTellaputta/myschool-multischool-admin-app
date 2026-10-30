class TeacherLeave {
  final int id;
  final int? teacherId;
  final String teacherName;
  final String leaveType;
  final String startDate;
  final String endDate;
  final String reason;
  final String status;
  final String? appliedAt;
  final String? createdAt;
  final String? updatedAt;

  const TeacherLeave({
    required this.id,
    this.teacherId,
    required this.teacherName,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
    this.appliedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory TeacherLeave.fromJson(Map<String, dynamic> json) {
    return TeacherLeave(
      id: _toInt(json['id']) ?? 0,
      teacherId: _toInt(json['teacherId']),
      teacherName: json['teacherName']?.toString() ?? 'Unknown Teacher',
      leaveType: json['leaveType']?.toString() ?? 'Leave',
      startDate: json['startDate']?.toString() ?? '',
      endDate: json['endDate']?.toString() ?? '',
      reason: json['reason']?.toString() ?? '',
      status: json['status']?.toString() ?? 'APPLIED',
      appliedAt: json['appliedAt']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}