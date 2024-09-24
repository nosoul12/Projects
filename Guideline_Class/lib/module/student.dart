import 'dart:convert';

import 'package:flutter/foundation.dart';

class Student {
  String fullName;
  String guardianName;
  String studentClass;
  String subject;
  String board;

  DateTime joiningDate;
  String phoneNumber;
  String parentsNumber;
  String coachingCenter;
  double feePaid;
  double feeDue;
  double totalFees;
  double scholarship;
  List<Map<String, dynamic>> feeRecords;

  Student(
      {required this.fullName,
      required this.guardianName,
      required this.studentClass,
      required this.subject,
      required this.board,
      required this.joiningDate,
      required this.phoneNumber,
      required this.parentsNumber,
      required this.coachingCenter,
      required this.feePaid,
      required this.feeDue,
      this.totalFees = 0.0,
      this.scholarship = 0.0,
      this.feeRecords = const []});

  Student copyWith({
    String? fullName,
    String? guardianName,
    String? studentClass,
    String? subject,
    String? board,
    String? batch,
    DateTime? joiningDate,
    String? phoneNumber,
    String? parentsNumber,
    String? coachingCenter,
    double? feePaid,
    double? feeDue,
    double? totalFees,
    double? scholarship,
    List<Map<String, dynamic>>? feeRecords,
  }) {
    return Student(
      fullName: fullName ?? this.fullName,
      guardianName: guardianName ?? this.guardianName,
      studentClass: studentClass ?? this.studentClass,
      subject: subject ?? this.subject,
      board: board ?? this.board,
      joiningDate: joiningDate ?? this.joiningDate,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      parentsNumber: parentsNumber ?? this.parentsNumber,
      coachingCenter: coachingCenter ?? this.coachingCenter,
      feePaid: feePaid ?? this.feePaid,
      feeDue: feeDue ?? this.feeDue,
      totalFees: totalFees ?? this.totalFees,
      scholarship: scholarship ?? this.scholarship,
      feeRecords: feeRecords ?? this.feeRecords,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'guardianName': guardianName,
      'studentClass': studentClass,
      'subject': subject,
      'board': board,
      'joiningDate': joiningDate.millisecondsSinceEpoch,
      'phoneNumber': phoneNumber,
      'parentsNumber': parentsNumber,
      'coachingCenter': coachingCenter,
      'feePaid': feePaid,
      'feeDue': feeDue,
      'totalFees': totalFees,
      'scholarship': scholarship,
      'feeRecords': feeRecords,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      fullName: map['fullName'] ?? '',
      guardianName: map['guardianName'] ?? '',
      studentClass: map['studentClass'] ?? '',
      subject: map['subject'] ?? '',
      board: map['board'] ?? '',
      joiningDate: DateTime.fromMillisecondsSinceEpoch(map['joiningDate']),
      phoneNumber: map['phoneNumber'] ?? '',
      parentsNumber: map['parentsNumber'] ?? '',
      coachingCenter: map['coachingCenter'] ?? '',
      feePaid: map['feePaid']?.toDouble() ?? 0.0,
      feeDue: map['feeDue']?.toDouble() ?? 0.0,
      totalFees: map['totalFees']?.toDouble() ?? 0.0,
      scholarship: map['scholarship']?.toDouble() ?? 0.0,
      feeRecords: List<Map<String, dynamic>>.from(map['feeRecords'] ?? []),
    );
  }

  String toJson() => json.encode(toMap());

  factory Student.fromJson(String source) =>
      Student.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Student(fullName: $fullName, guardianName: $guardianName, studentClass: $studentClass, subject: $subject, board: $board,, joiningDate: $joiningDate, phoneNumber: $phoneNumber, parentsNumber: $parentsNumber, coachingCenter: $coachingCenter, feePaid: $feePaid, feeDue: $feeDue, totalFees: $totalFees, scholarship: $scholarship, feeRecords: $feeRecords)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Student &&
        other.fullName == fullName &&
        other.guardianName == guardianName &&
        other.studentClass == studentClass &&
        other.subject == subject &&
        other.board == board &&
        other.joiningDate == joiningDate &&
        other.phoneNumber == phoneNumber &&
        other.parentsNumber == parentsNumber &&
        other.coachingCenter == coachingCenter &&
        other.feePaid == feePaid &&
        other.feeDue == feeDue &&
        other.totalFees == totalFees &&
        other.scholarship == scholarship &&
        listEquals(other.feeRecords, feeRecords);
  }

  @override
  int get hashCode {
    return fullName.hashCode ^
        guardianName.hashCode ^
        studentClass.hashCode ^
        subject.hashCode ^
        board.hashCode ^
        joiningDate.hashCode ^
        phoneNumber.hashCode ^
        parentsNumber.hashCode ^
        coachingCenter.hashCode ^
        feePaid.hashCode ^
        feeDue.hashCode ^
        totalFees.hashCode ^
        scholarship.hashCode ^
        feeRecords.hashCode;
  }
}
