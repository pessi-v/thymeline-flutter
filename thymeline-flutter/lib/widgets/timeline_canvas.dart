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
                state.zoomIn(factor: 1.1);
              } else {
                state.zoomOut(factor: 1.1);
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
    // TODO: Implement hit testing for periods and events
    // This will require calculating the screen positions of each element
    // based on zoom and pan, then overlaying transparent GestureDetectors
    return const SizedBox.expand();
  }
}
