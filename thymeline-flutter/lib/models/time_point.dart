/// Represents a point in time with support for various time scales.
///
/// Supports:
/// - Millions of years ago (mya)
/// - Years ago
/// - BCE/CE dates
/// - ISO date strings (e.g., "1848-02-21")
class TimePoint implements Comparable<TimePoint> {
  final double value;
  final TimeUnit unit;

  const TimePoint({
    required this.value,
    required this.unit,
  });

  /// Parse a time point from JSON.
  /// Can be either an object with value/unit or an ISO date string.
  factory TimePoint.fromJson(dynamic json) {
    if (json is String) {
      return TimePoint._fromIsoString(json);
    }

    if (json is Map<String, dynamic>) {
      final value = (json['value'] as num).toDouble();
      final unitStr = json['unit'] as String;
      final unit = TimeUnit.fromString(unitStr);
      return TimePoint(value: value, unit: unit);
    }

    throw ArgumentError('Invalid time format: $json');
  }

  factory TimePoint._fromIsoString(String iso) {
    // Handle dates like "1848-02-21" or "0476-09-04"
    final parts = iso.split('-');
    final year = int.parse(parts[0]);
    final month = parts.length > 1 ? int.parse(parts[1]) : 1;
    final day = parts.length > 2 ? int.parse(parts[2]) : 1;

    // Convert to decimal year for easier comparison
    final decimalYear = year + (month - 1) / 12 + (day - 1) / 365;
    return TimePoint(value: decimalYear, unit: TimeUnit.ce);
  }

  /// Convert this time point to years before present (BP) for comparison.
  /// Uses 2000 CE as the reference point.
  double toYearsBP() {
    const referenceYear = 2000.0;

    switch (unit) {
      case TimeUnit.mya:
        return value * 1000000;
      case TimeUnit.yearsAgo:
        return value;
      case TimeUnit.bce:
        return referenceYear + value;
      case TimeUnit.ce:
        return referenceYear - value;
    }
  }

  /// Get a human-readable string representation.
  String toDisplayString() {
    switch (unit) {
      case TimeUnit.mya:
        if (value >= 1000) {
          return '${(value / 1000).toStringAsFixed(1)} billion years ago';
        }
        return '${value.toStringAsFixed(value == value.roundToDouble() ? 0 : 1)} million years ago';
      case TimeUnit.yearsAgo:
        if (value >= 1000000) {
          return '${(value / 1000000).toStringAsFixed(1)} million years ago';
        }
        if (value >= 1000) {
          return '${(value / 1000).toStringAsFixed(0)},000 years ago';
        }
        return '${value.toStringAsFixed(0)} years ago';
      case TimeUnit.bce:
        return '${value.toStringAsFixed(0)} BCE';
      case TimeUnit.ce:
        if (value < 0) {
          return '${(-value).toStringAsFixed(0)} BCE';
        }
        return '${value.toStringAsFixed(0)} CE';
    }
  }

  @override
  int compareTo(TimePoint other) {
    // Earlier times (more years BP) should come first
    return toYearsBP().compareTo(other.toYearsBP());
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TimePoint && other.toYearsBP() == toYearsBP();
  }

  @override
  int get hashCode => toYearsBP().hashCode;

  Map<String, dynamic> toJson() {
    if (unit == TimeUnit.ce && value == value.roundToDouble()) {
      // For simple CE dates, could return ISO string
      return {'value': value, 'unit': unit.toJsonString()};
    }
    return {'value': value, 'unit': unit.toJsonString()};
  }
}

enum TimeUnit {
  mya,      // Millions of years ago
  yearsAgo, // Years ago
  bce,      // Before Common Era
  ce;       // Common Era

  static TimeUnit fromString(String str) {
    switch (str.toLowerCase()) {
      case 'mya':
        return TimeUnit.mya;
      case 'years-ago':
        return TimeUnit.yearsAgo;
      case 'bce':
        return TimeUnit.bce;
      case 'ce':
        return TimeUnit.ce;
      default:
        throw ArgumentError('Unknown time unit: $str');
    }
  }

  String toJsonString() {
    switch (this) {
      case TimeUnit.mya:
        return 'mya';
      case TimeUnit.yearsAgo:
        return 'years-ago';
      case TimeUnit.bce:
        return 'bce';
      case TimeUnit.ce:
        return 'ce';
    }
  }
}
