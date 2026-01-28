/// Represents a connection between two periods.
/// Rendered as sigmoid curves (solid for defined, dotted for undefined).
class TimelineConnector {
  final String id;
  final String fromId;
  final String toId;
  final ConnectorType type;
  final Map<String, dynamic>? metadata;

  const TimelineConnector({
    required this.id,
    required this.fromId,
    required this.toId,
    required this.type,
    this.metadata,
  });

  /// Get the note from metadata, if present.
  String? get note => metadata?['note'] as String?;

  factory TimelineConnector.fromJson(Map<String, dynamic> json) {
    return TimelineConnector(
      id: json['id'] as String,
      fromId: json['fromId'] as String,
      toId: json['toId'] as String,
      type: ConnectorType.fromString(json['type'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromId': fromId,
      'toId': toId,
      'type': type.toJsonString(),
      if (metadata != null) 'metadata': metadata,
    };
  }

  TimelineConnector copyWith({
    String? id,
    String? fromId,
    String? toId,
    ConnectorType? type,
    Map<String, dynamic>? metadata,
  }) {
    return TimelineConnector(
      id: id ?? this.id,
      fromId: fromId ?? this.fromId,
      toId: toId ?? this.toId,
      type: type ?? this.type,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TimelineConnector && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'TimelineConnector(id: $id, $fromId -> $toId)';
}

enum ConnectorType {
  defined,   // Solid line - clear historical connection
  undefined; // Dotted line - uncertain or indirect connection

  static ConnectorType fromString(String str) {
    switch (str.toLowerCase()) {
      case 'defined':
        return ConnectorType.defined;
      case 'undefined':
        return ConnectorType.undefined;
      default:
        throw ArgumentError('Unknown connector type: $str');
    }
  }

  String toJsonString() {
    switch (this) {
      case ConnectorType.defined:
        return 'defined';
      case ConnectorType.undefined:
        return 'undefined';
    }
  }
}
