import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/services.dart';
import '../models/models.dart';

/// Popup displaying information about a selected period or event.
class InfoPopup extends StatelessWidget {
  const InfoPopup({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<TimelineState>();
    final period = state.selectedPeriod;
    final event = state.selectedEvent;

    if (period == null && event == null) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () => state.clearSelection(),
      child: Container(
        color: Colors.black.withOpacity(0.3),
        child: Center(
          child: GestureDetector(
            onTap: () {}, // Prevent tap from closing popup
            child: Card(
              margin: const EdgeInsets.all(32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: period != null
                      ? _buildPeriodContent(context, period, state)
                      : _buildEventContent(context, event!, state),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodContent(
    BuildContext context,
    TimelinePeriod period,
    TimelineState state,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                period.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            IconButton(
              onPressed: () => state.clearSelection(),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          _formatTimeRange(period),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 16),
        Text(
          period.info,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildEventContent(
    BuildContext context,
    TimelineEvent event,
    TimelineState state,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                event.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            IconButton(
              onPressed: () => state.clearSelection(),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          event.time.toDisplayString(),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 16),
        Text(
          event.info,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  String _formatTimeRange(TimelinePeriod period) {
    final start = period.startTime.toDisplayString();
    if (period.isOngoing) {
      return '$start - Present';
    }
    return '$start - ${period.endTime!.toDisplayString()}';
  }
}
