import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/models.dart';

/// Service for loading and managing timeline data.
class TimelineService {
  /// Load a timeline from an asset file.
  Future<Timeline> loadFromAsset(String assetPath) async {
    final jsonString = await rootBundle.loadString(assetPath);
    final json = jsonDecode(jsonString) as Map<String, dynamic>;

    // Extract name from filename
    final name = assetPath.split('/').last.replaceAll('.json', '');
    final displayName = _formatName(name);

    return Timeline.fromJson(json, name: displayName);
  }

  /// Load all timelines from the assets/timelines directory.
  Future<List<Timeline>> loadAllTimelines() async {
    // For now, we'll hardcode the known timeline files
    // In production, you might use a manifest file or directory listing
    final timelineFiles = [
      'assets/timelines/civilizations.json',
      'assets/timelines/evolution-of-life.json',
      'assets/timelines/history-of-socialism.json',
    ];

    final timelines = <Timeline>[];
    for (final file in timelineFiles) {
      try {
        final timeline = await loadFromAsset(file);
        timelines.add(timeline);
      } catch (e) {
        // Log error but continue loading other timelines
        print('Error loading timeline $file: $e');
      }
    }

    return timelines;
  }

  /// Format a filename into a display name.
  String _formatName(String filename) {
    return filename
        .replaceAll('-', ' ')
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1)}'
            : '')
        .join(' ');
  }

  /// Load a timeline from a JSON string.
  Timeline loadFromJsonString(String jsonString, {String? name}) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return Timeline.fromJson(json, name: name);
  }

  /// Convert a timeline to a JSON string.
  String toJsonString(Timeline timeline) {
    return const JsonEncoder.withIndent('  ').convert(timeline.toJson());
  }
}
