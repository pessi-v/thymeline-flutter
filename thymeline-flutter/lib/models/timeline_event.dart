import 'time_point.dart';

/// Represents a single event in a timeline.
/// Events are rendered as circles with text labels.
class TimelineEvent {
  final String id;
  final String name;
  final TimePoint time;
  final String info;
  final String? relatesTo; // Optional reference to a period ID

  const TimelineEvent({
    required this.id,
    required this.name,
    required this.time,
    required this.info,
    this.relatesTo,
  });

  factory TimelineEvent.fromJson(Map<String, dynamic> json) {
    return TimelineEvent(
      id: json['id'] as String,
      name: json['name'] as String,
      time: TimePoint.fromJson(json['time']),
      info: json['info'] as String,
      relatesTo: json['relates_to'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'time': time.toJson(),
      'info': info,
      if (relatesTo != null) 'relates_to': relatesTo,
    };
  }

  TimelineEvent copyWith({
    String? id,
    String? name,
    TimePoint? time,
    String? info,
    String? relatesTo,
  }) {
    return TimelineEvent(
      id: id ?? this.id,
      name: name ?? this.name,
      time: time ?? this.time,
      info: info ?? this.info,
      relatesTo: relatesTo ?? this.relatesTo,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TimelineEvent && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'TimelineEvent(id: $id, name: $name)';
}
