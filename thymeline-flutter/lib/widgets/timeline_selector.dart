import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/services.dart';

/// Dropdown for selecting which timeline to display.
class TimelineSelector extends StatelessWidget {
  const TimelineSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<TimelineState>();
    final timelines = state.availableTimelines;
    final current = state.currentTimeline;

    if (timelines.isEmpty) {
      return const SizedBox.shrink();
    }

    return DropdownButton<int>(
      value: current != null ? timelines.indexOf(current) : 0,
      underline: const SizedBox.shrink(),
      borderRadius: BorderRadius.circular(8),
      items: timelines.asMap().entries.map((entry) {
        return DropdownMenuItem(
          value: entry.key,
          child: Text(entry.value.name ?? 'Untitled Timeline'),
        );
      }).toList(),
      onChanged: (index) {
        if (index != null) {
          state.selectTimelineByIndex(index);
        }
      },
    );
  }
}
