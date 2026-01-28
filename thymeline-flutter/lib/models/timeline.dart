import 'time_point.dart';
import 'timeline_event.dart';
import 'timeline_period.dart';
import 'timeline_connector.dart';

/// Represents a complete timeline with events, periods, and connectors.
class Timeline {
  final String? name;
  final List<TimelineEvent> events;
  final List<TimelinePeriod> periods;
  final List<TimelineConnector> connectors;

  const Timeline({
    this.name,
    required this.events,
    required this.periods,
    required this.connectors,
  });

  /// Get the earliest time point in this timeline.
  TimePoint? get earliestTime {
    TimePoint? earliest;

    for (final event in events) {
      if (earliest == null || event.time.compareTo(earliest) > 0) {
        earliest = event.time;
      }
    }

    for (final period in periods) {
      if (earliest == null || period.startTime.compareTo(earliest) > 0) {
        earliest = period.startTime;
      }
    }

    return earliest;
  }

  /// Get the latest time point in this timeline.
  TimePoint? get latestTime {
    TimePoint? latest;

    for (final event in events) {
      if (latest == null || event.time.compareTo(latest) < 0) {
        latest = event.time;
      }
    }

    for (final period in periods) {
      final endTime = period.effectiveEndTime;
      if (latest == null || endTime.compareTo(latest) < 0) {
        latest = endTime;
      }
    }

    return latest;
  }

  /// Get a period by its ID.
  TimelinePeriod? getPeriodById(String id) {
    try {
      return periods.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get an event by its ID.
  TimelineEvent? getEventById(String id) {
    try {
      return events.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get all events related to a specific period.
  List<TimelineEvent> getEventsForPeriod(String periodId) {
    return events.where((e) => e.relatesTo == periodId).toList();
  }

  /// Get all connectors originating from a period.
  List<TimelineConnector> getConnectorsFrom(String periodId) {
    return connectors.where((c) => c.fromId == periodId).toList();
  }

  /// Get all connectors ending at a period.
  List<TimelineConnector> getConnectorsTo(String periodId) {
    return connectors.where((c) => c.toId == periodId).toList();
  }

  factory Timeline.fromJson(Map<String, dynamic> json, {String? name}) {
    return Timeline(
      name: name,
      events: (json['events'] as List<dynamic>?)
              ?.map((e) => TimelineEvent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      periods: (json['periods'] as List<dynamic>?)
              ?.map((p) => TimelinePeriod.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      connectors: (json['connectors'] as List<dynamic>?)
              ?.map((c) => TimelineConnector.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'events': events.map((e) => e.toJson()).toList(),
      'periods': periods.map((p) => p.toJson()).toList(),
      'connectors': connectors.map((c) => c.toJson()).toList(),
    };
  }

  Timeline copyWith({
    String? name,
    List<TimelineEvent>? events,
    List<TimelinePeriod>? periods,
    List<TimelineConnector>? connectors,
  }) {
    return Timeline(
      name: name ?? this.name,
      events: events ?? this.events,
      periods: periods ?? this.periods,
      connectors: connectors ?? this.connectors,
    );
  }

  @override
  String toString() =>
      'Timeline(name: $name, events: ${events.length}, periods: ${periods.length}, connectors: ${connectors.length})';
}
