import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/services.dart';
import '../models/models.dart';
import 'painters/timeline_painter.dart';

/// Main canvas widget for displaying the timeline.
/// Handles pan and zoom gestures.
class TimelineCanvas extends StatefulWidget {
  const TimelineCanvas({super.key});

  @override
  State<TimelineCanvas> createState() => _TimelineCanvasState();
}

class _TimelineCanvasState extends State<TimelineCanvas> {
  // For tracking pan gestures
  double _lastPanX = 0;
  // For tracking double-tap position
  Offset? _doubleTapPosition;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<TimelineState>();
    final timeline = state.currentTimeline;

    if (timeline == null) {
      return const Center(
        child: Text('Select a timeline'),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Listener(
          // Handle mouse scroll for zooming
          onPointerSignal: (event) {
            if (event is PointerScrollEvent) {
              if (event.scrollDelta.dy < 0) {
                state.zoomIn(factor: 1.1, viewportWidth: constraints.maxWidth);
              } else {
                state.zoomOut(factor: 1.1, viewportWidth: constraints.maxWidth);
              }
            }
          },
          child: GestureDetector(
            // Pan gesture
            onPanStart: (details) {
              _lastPanX = details.localPosition.dx;
            },
            onPanUpdate: (details) {
              final delta = details.localPosition.dx - _lastPanX;
              _lastPanX = details.localPosition.dx;
              state.pan(delta);
            },
            // Tap to clear selection
            onTap: () {
              state.clearSelection();
            },
            // Double-tap to zoom in and center on that point
            onDoubleTapDown: (details) {
              _doubleTapPosition = details.localPosition;
            },
            onDoubleTap: () {
              if (_doubleTapPosition != null) {
                state.zoomInAtPoint(
                  _doubleTapPosition!.dx,
                  constraints.maxWidth,
                );
                _doubleTapPosition = null;
              }
            },
            child: MouseRegion(
              onHover: (event) {
                state.setHoverTimePosition(event.localPosition.dx);
              },
              onExit: (_) {
                state.clearHover();
              },
              child: CustomPaint(
                size: Size(constraints.maxWidth, constraints.maxHeight),
                painter: TimelinePainter(
                  timeline: timeline,
                  zoom: state.zoom,
                  panOffset: state.panOffset,
                  viewportWidth: constraints.maxWidth,
                  viewportHeight: constraints.maxHeight,
                  hoveredPeriod: state.hoveredPeriod,
                  hoveredEvent: state.hoveredEvent,
                  hoverTimePosition: state.hoverTimePosition,
                  colorScheme: Theme.of(context).colorScheme,
                ),
                child: _buildInteractiveLayer(
                  context,
                  state,
                  timeline,
                  constraints,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Build transparent hit-test areas for periods and events.
  Widget _buildInteractiveLayer(
    BuildContext context,
    TimelineState state,
    Timeline timeline,
    BoxConstraints constraints,
  ) {
    final earliest = timeline.earliestTime;
    final latest = timeline.latestTime;
    if (earliest == null || latest == null) {
      return const SizedBox.expand();
    }

    final startBP = earliest.toYearsBP();
    final endBP = latest.toYearsBP();
    final timeSpan = startBP - endBP;
    if (timeSpan <= 0) {
      return const SizedBox.expand();
    }

    final viewportWidth = constraints.maxWidth;
    final viewportHeight = constraints.maxHeight;

    // Layout constants (must match TimelinePainter)
    const axisHeight = 50.0;
    const periodRowHeight = 40.0;
    const periodSpacing = 8.0;
    const eventRadius = 8.0;

    // Helper to convert time to X coordinate
    double timeToX(double yearsBP) {
      final normalized = (yearsBP - endBP) / timeSpan;
      final scaledWidth = viewportWidth * state.zoom;
      return (1 - normalized) * scaledWidth + state.panOffset;
    }

    final children = <Widget>[];

    // Build period hit areas
    final sortedPeriods = List<TimelinePeriod>.from(timeline.periods)
      ..sort((a, b) => b.startTime.compareTo(a.startTime));

    for (var i = 0; i < sortedPeriods.length; i++) {
      final period = sortedPeriods[i];
      final row = i % 8;

      final startX = timeToX(period.startTime.toYearsBP());
      final periodEndX = timeToX(period.effectiveEndTime.toYearsBP());
      final left = startX < periodEndX ? startX : periodEndX;
      final width = (periodEndX - startX).abs();
      final top = axisHeight + 20 + row * (periodRowHeight + periodSpacing);

      // Skip if off screen
      if (left + width < 0 || left > viewportWidth) continue;

      children.add(
        Positioned(
          left: left,
          top: top,
          width: width < 2 ? 2 : width,
          height: periodRowHeight,
          child: MouseRegion(
            onEnter: (_) => state.setHoveredPeriod(period),
            onExit: (_) => state.setHoveredPeriod(null),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => state.selectPeriod(period),
              child: const SizedBox.expand(),
            ),
          ),
        ),
      );
    }

    // Build event hit areas
    for (final event in timeline.events) {
      final x = timeToX(event.time.toYearsBP());
      final y = viewportHeight - 60;

      // Skip if off screen
      if (x < -20 || x > viewportWidth + 20) continue;

      // Make hit area larger than visual for easier clicking
      const hitRadius = eventRadius * 2;

      children.add(
        Positioned(
          left: x - hitRadius,
          top: y - hitRadius,
          width: hitRadius * 2,
          height: hitRadius * 2,
          child: MouseRegion(
            onEnter: (_) => state.setHoveredEvent(event),
            onExit: (_) => state.setHoveredEvent(null),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => state.selectEvent(event),
              child: const SizedBox.expand(),
            ),
          ),
        ),
      );
    }

    return Stack(children: children);
  }
}
