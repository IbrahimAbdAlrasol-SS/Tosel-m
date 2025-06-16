class AccountLockStatus {
  final DateTime registrationTime;
  final bool isApproved;
  final bool isRejected;
  final bool hasExpired;

  AccountLockStatus({
    required this.registrationTime,
    this.isApproved = false,
    this.isRejected = false,
    this.hasExpired = false,
  });

  Duration get remainingTime {
    final now = DateTime.now();
    final deadline = registrationTime.add(const Duration(hours: 24));
    final remaining = deadline.difference(now);
    return remaining.isNegative ? Duration.zero : remaining;
  }

  bool get isExpired {
    return remainingTime == Duration.zero;
  }

  Map<String, dynamic> toJson() {
    return {
      'registrationTime': registrationTime.toIso8601String(),
      'isApproved': isApproved,
      'isRejected': isRejected,
      'hasExpired': hasExpired,
    };
  }

  // إنشاء من JSON
  factory AccountLockStatus.fromJson(Map<String, dynamic> json) {
    return AccountLockStatus(
      registrationTime: DateTime.parse(json['registrationTime']),
      isApproved: json['isApproved'] ?? false,
      isRejected: json['isRejected'] ?? false,
      hasExpired: json['hasExpired'] ?? false,
    );
  }

  // إنشاء نسخة محدثة
  AccountLockStatus copyWith({
    DateTime? registrationTime,
    bool? isApproved,
    bool? isRejected,
    bool? hasExpired,
  }) {
    return AccountLockStatus(
      registrationTime: registrationTime ?? this.registrationTime,
      isApproved: isApproved ?? this.isApproved,
      isRejected: isRejected ?? this.isRejected,
      hasExpired: hasExpired ?? this.hasExpired,
    );
  }
}
