import 'time_point.dart';

/// Represents a period (time span) in a timeline.
/// Periods are rendered as horizontal bars.
class TimelinePeriod {
  final String id;
  final String name;
  final TimePoint startTime;
  final TimePoint? endTime; // null means ongoing (extends to present)
  final String info;

  const TimelinePeriod({
    required this.id,
    required this.name,
    required this.startTime,
    this.endTime,
    required this.info,
  });

  /// Whether this period is ongoing (no end date).
  bool get isOngoing => endTime == null;

  /// Get the effective end time (current date if ongoing).
  TimePoint get effectiveEndTime {
    if (endTime != null) return endTime!;
    // Return current year as CE
    return TimePoint(
      value: DateTime.now().year.toDouble(),
      unit: TimeUnit.ce,
    );
  }

  /// Duration in years (approximate for geological time).
  double get durationYears {
    final startBP = startTime.toYearsBP();
    final endBP = effectiveEndTime.toYearsBP();
    return (startBP - endBP).abs();
  }

  factory TimelinePeriod.fromJson(Map<String, dynamic> json) {
    return TimelinePeriod(
      id: json['id'] as String,
      name: json['name'] as String,
      startTime: TimePoint.fromJson(json['startTime']),
      endTime: json['endTime'] != null
          ? TimePoint.fromJson(json['endTime'])
          : null,
      info: json['info'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'startTime': startTime.toJson(),
      if (endTime != null) 'endTime': endTime!.toJson(),
      'info': info,
    };
  }

  TimelinePeriod copyWith({
    String? id,
    String? name,
    TimePoint? startTime,
    TimePoint? endTime,
    bool clearEndTime = false,
    String? info,
  }) {
    return TimelinePeriod(
      id: id ?? this.id,
      name: name ?? this.name,
      startTime: startTime ?? this.startTime,
      endTime: clearEndTime ? null : (endTime ?? this.endTime),
      info: info ?? this.info,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TimelinePeriod && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'TimelinePeriod(id: $id, name: $name)';
}
