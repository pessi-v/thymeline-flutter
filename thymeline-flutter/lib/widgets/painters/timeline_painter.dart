import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/models.dart';

/// Custom painter for rendering the timeline.
class TimelinePainter extends CustomPainter {
  final Timeline timeline;
  final double zoom;
  final double panOffset;
  final double viewportWidth;
  final double viewportHeight;
  final TimelinePeriod? hoveredPeriod;
  final TimelineEvent? hoveredEvent;
  final double? hoverTimePosition;
  final ColorScheme colorScheme;

  // Layout constants
  static const double axisHeight = 50.0;
  static const double periodRowHeight = 40.0;
  static const double periodSpacing = 8.0;
  static const double eventRadius = 8.0;
  static const double connectorCurveHeight = 30.0;

  TimelinePainter({
    required this.timeline,
    required this.zoom,
    required this.panOffset,
    required this.viewportWidth,
    required this.viewportHeight,
    this.hoveredPeriod,
    this.hoveredEvent,
    this.hoverTimePosition,
    required this.colorScheme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (timeline.periods.isEmpty && timeline.events.isEmpty) {
      _drawEmptyState(canvas, size);
      return;
    }

    // Calculate time range
    final earliest = timeline.earliestTime;
    final latest = timeline.latestTime;
    if (earliest == null || latest == null) return;

    final startBP = earliest.toYearsBP();
    final endBP = latest.toYearsBP();
    final timeSpan = startBP - endBP;
    if (timeSpan <= 0) return;

    // Calculate layout
    final layout = _TimelineLayout(
      startBP: startBP,
      endBP: endBP,
      timeSpan: timeSpan,
      zoom: zoom,
      panOffset: panOffset,
      viewportWidth: viewportWidth,
      viewportHeight: viewportHeight,
    );

    // Draw layers from back to front
    _drawBackground(canvas, size);
    _drawConnectors(canvas, layout);
    _drawPeriods(canvas, layout);
    _drawEvents(canvas, layout);
    _drawTimeAxis(canvas, layout);
    _drawHoverIndicator(canvas, layout);
  }

  void _drawEmptyState(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'No data to display',
        style: TextStyle(
          color: colorScheme.onSurface.withOpacity(0.5),
          fontSize: 16,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );
  }

  void _drawBackground(Canvas canvas, Size size) {
    final paint = Paint()..color = colorScheme.surface;
    canvas.drawRect(Offset.zero & size, paint);
  }

  void _drawTimeAxis(Canvas canvas, _TimelineLayout layout) {
    final axisPaint = Paint()
      ..color = colorScheme.outline
      ..strokeWidth = 1;

    // Draw axis line
    canvas.drawLine(
      Offset(0, axisHeight),
      Offset(viewportWidth, axisHeight),
      axisPaint,
    );

    // Calculate appropriate tick interval based on zoom
    final tickInterval = _calculateTickInterval(layout.timeSpan / zoom);

    // Draw ticks and labels
    final startTick = (layout.endBP / tickInterval).floor() * tickInterval;
    final endTick = (layout.startBP / tickInterval).ceil() * tickInterval;

    for (double bp = startTick; bp <= endTick; bp += tickInterval) {
      final x = layout.timeToX(bp);
      if (x < -50 || x > viewportWidth + 50) continue;

      // Draw tick
      canvas.drawLine(
        Offset(x, axisHeight - 8),
        Offset(x, axisHeight),
        axisPaint,
      );

      // Draw label
      final label = _formatAxisLabel(bp);
      final textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 11,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, axisHeight - 24),
      );
    }
  }

  double _calculateTickInterval(double visibleTimeSpan) {
    // Choose interval based on visible span
    final intervals = [
      1.0,
      5.0,
      10.0,
      25.0,
      50.0,
      100.0,
      250.0,
      500.0,
      1000.0,
      5000.0,
      10000.0,
      50000.0,
      100000.0,
      500000.0,
      1000000.0,
      10000000.0,
      100000000.0,
      1000000000.0,
    ];

    // Aim for roughly 8-12 ticks visible
    final targetTicks = 10;
    final idealInterval = visibleTimeSpan / targetTicks;

    for (final interval in intervals) {
      if (interval >= idealInterval) return interval;
    }
    return intervals.last;
  }

  String _formatAxisLabel(double yearsBP) {
    if (yearsBP >= 1000000000) {
      return '${(yearsBP / 1000000000).toStringAsFixed(1)} Ga';
    }
    if (yearsBP >= 1000000) {
      return '${(yearsBP / 1000000).toStringAsFixed(yearsBP >= 10000000 ? 0 : 1)} Ma';
    }
    if (yearsBP >= 1000) {
      return '${(yearsBP / 1000).toStringAsFixed(0)} ka';
    }
    if (yearsBP > 2000) {
      return '${yearsBP.toStringAsFixed(0)} BP';
    }
    // Convert to CE/BCE for recent times
    final year = 2000 - yearsBP;
    if (year < 0) {
      return '${(-year).toStringAsFixed(0)} BCE';
    }
    return '${year.toStringAsFixed(0)} CE';
  }

  void _drawPeriods(Canvas canvas, _TimelineLayout layout) {
    // Assign periods to rows (simple stacking for now)
    final sortedPeriods = List<TimelinePeriod>.from(timeline.periods)
      ..sort((a, b) => b.startTime.compareTo(a.startTime));

    for (var i = 0; i < sortedPeriods.length; i++) {
      final period = sortedPeriods[i];
      final row = i % 8; // Cycle through 8 rows for now
      _drawPeriod(canvas, layout, period, row);
    }
  }

  void _drawPeriod(
    Canvas canvas,
    _TimelineLayout layout,
    TimelinePeriod period,
    int row,
  ) {
    final startX = layout.timeToX(period.startTime.toYearsBP());
    final endX = layout.timeToX(period.effectiveEndTime.toYearsBP());

    if (endX < 0 || startX > viewportWidth) return;

    final y = axisHeight + 20 + row * (periodRowHeight + periodSpacing);
    final width = (endX - startX).abs();
    final height = periodRowHeight;

    // Determine color based on period index
    final colorIndex = timeline.periods.indexOf(period) % _periodColors.length;
    final baseColor = _periodColors[colorIndex];

    final isHovered = period == hoveredPeriod;
    final fillColor = isHovered
        ? baseColor.withOpacity(0.9)
        : baseColor.withOpacity(0.7);

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        math.min(startX, endX),
        y,
        math.max(width, 2), // Minimum width for visibility
        height,
      ),
      const Radius.circular(4),
    );

    // Draw fill
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rect, fillPaint);

    // Draw border
    final borderPaint = Paint()
      ..color = baseColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = isHovered ? 2 : 1;
    canvas.drawRRect(rect, borderPaint);

    // Draw label if there's room
    if (width > 50) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: period.name,
          style: TextStyle(
            color: _getContrastColor(baseColor),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '...',
      );
      textPainter.layout(maxWidth: width - 8);
      textPainter.paint(
        canvas,
        Offset(
          math.min(startX, endX) + 4,
          y + (height - textPainter.height) / 2,
        ),
      );
    }
  }

  void _drawEvents(Canvas canvas, _TimelineLayout layout) {
    for (final event in timeline.events) {
      _drawEvent(canvas, layout, event);
    }
  }

  void _drawEvent(
    Canvas canvas,
    _TimelineLayout layout,
    TimelineEvent event,
  ) {
    final x = layout.timeToX(event.time.toYearsBP());
    if (x < -20 || x > viewportWidth + 20) return;

    // Position events at the bottom of the canvas
    final y = viewportHeight - 60;

    final isHovered = event == hoveredEvent;
    final radius = isHovered ? eventRadius * 1.3 : eventRadius;

    // Draw circle
    final circlePaint = Paint()
      ..color = isHovered
          ? colorScheme.primary
          : colorScheme.primary.withOpacity(0.8)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(x, y), radius, circlePaint);

    // Draw border
    final borderPaint = Paint()
      ..color = colorScheme.onPrimary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset(x, y), radius, borderPaint);

    // Draw label
    final textPainter = TextPainter(
      text: TextSpan(
        text: event.name,
        style: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 10,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 2,
      ellipsis: '...',
    );
    textPainter.layout(maxWidth: 100);

    // Alternate label position to avoid overlap
    final labelY = y + radius + 4;
    textPainter.paint(
      canvas,
      Offset(x - textPainter.width / 2, labelY),
    );
  }

  void _drawConnectors(Canvas canvas, _TimelineLayout layout) {
    for (final connector in timeline.connectors) {
      _drawConnector(canvas, layout, connector);
    }
  }

  void _drawConnector(
    Canvas canvas,
    _TimelineLayout layout,
    TimelineConnector connector,
  ) {
    final fromPeriod = timeline.getPeriodById(connector.fromId);
    final toPeriod = timeline.getPeriodById(connector.toId);
    if (fromPeriod == null || toPeriod == null) return;

    // Get positions (simplified - connecting end of from to start of to)
    final fromX = layout.timeToX(fromPeriod.effectiveEndTime.toYearsBP());
    final toX = layout.timeToX(toPeriod.startTime.toYearsBP());

    if ((fromX < 0 && toX < 0) ||
        (fromX > viewportWidth && toX > viewportWidth)) {
      return;
    }

    // Find row positions (simplified)
    final fromRow = timeline.periods.indexOf(fromPeriod) % 8;
    final toRow = timeline.periods.indexOf(toPeriod) % 8;

    final fromY = axisHeight + 20 + fromRow * (periodRowHeight + periodSpacing) +
        periodRowHeight / 2;
    final toY = axisHeight + 20 + toRow * (periodRowHeight + periodSpacing) +
        periodRowHeight / 2;

    // Draw sigmoid curve
    final path = Path();
    path.moveTo(fromX, fromY);

    // Control points for sigmoid
    final midX = (fromX + toX) / 2;
    path.cubicTo(
      midX,
      fromY,
      midX,
      toY,
      toX,
      toY,
    );

    final paint = Paint()
      ..color = colorScheme.outline.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    if (connector.type == ConnectorType.undefined) {
      // Dotted line for undefined connections
      paint.strokeWidth = 1.5;
      _drawDashedPath(canvas, path, paint);
    } else {
      canvas.drawPath(path, paint);
    }
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0;
      const dashLength = 5.0;
      const gapLength = 4.0;
      bool draw = true;

      while (distance < metric.length) {
        final length = draw ? dashLength : gapLength;
        if (draw) {
          final extractPath = metric.extractPath(
            distance,
            math.min(distance + length, metric.length),
          );
          canvas.drawPath(extractPath, paint);
        }
        distance += length;
        draw = !draw;
      }
    }
  }

  void _drawHoverIndicator(Canvas canvas, _TimelineLayout layout) {
    if (hoverTimePosition == null) return;

    final paint = Paint()
      ..color = colorScheme.primary.withOpacity(0.5)
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(hoverTimePosition!, axisHeight),
      Offset(hoverTimePosition!, viewportHeight),
      paint,
    );

    // Show time at cursor position
    final bp = layout.xToTime(hoverTimePosition!);
    final label = _formatAxisLabel(bp);
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: colorScheme.primary,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    // Background for label
    final bgPaint = Paint()..color = colorScheme.surface;
    canvas.drawRect(
      Rect.fromLTWH(
        hoverTimePosition! - textPainter.width / 2 - 4,
        axisHeight + 4,
        textPainter.width + 8,
        textPainter.height + 4,
      ),
      bgPaint,
    );

    textPainter.paint(
      canvas,
      Offset(hoverTimePosition! - textPainter.width / 2, axisHeight + 6),
    );
  }

  Color _getContrastColor(Color background) {
    // Calculate luminance and return black or white for contrast
    final luminance = background.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }

  @override
  bool shouldRepaint(TimelinePainter oldDelegate) {
    return oldDelegate.zoom != zoom ||
        oldDelegate.panOffset != panOffset ||
        oldDelegate.timeline != timeline ||
        oldDelegate.hoveredPeriod != hoveredPeriod ||
        oldDelegate.hoveredEvent != hoveredEvent ||
        oldDelegate.hoverTimePosition != hoverTimePosition;
  }

  // Color palette for periods
  static const _periodColors = [
    Color(0xFF5C6BC0), // Indigo
    Color(0xFF26A69A), // Teal
    Color(0xFFEF5350), // Red
    Color(0xFFAB47BC), // Purple
    Color(0xFF42A5F5), // Blue
    Color(0xFF66BB6A), // Green
    Color(0xFFFFA726), // Orange
    Color(0xFF8D6E63), // Brown
    Color(0xFF78909C), // Blue Grey
    Color(0xFFEC407A), // Pink
  ];
}

/// Helper class for timeline layout calculations.
class _TimelineLayout {
  final double startBP;
  final double endBP;
  final double timeSpan;
  final double zoom;
  final double panOffset;
  final double viewportWidth;
  final double viewportHeight;

  _TimelineLayout({
    required this.startBP,
    required this.endBP,
    required this.timeSpan,
    required this.zoom,
    required this.panOffset,
    required this.viewportWidth,
    required this.viewportHeight,
  });

  /// Convert a time (years BP) to an X coordinate.
  double timeToX(double yearsBP) {
    // Normalize to 0-1 range (1 = earliest, 0 = latest)
    final normalized = (yearsBP - endBP) / timeSpan;
    // Apply zoom and pan
    final baseWidth = viewportWidth;
    final scaledWidth = baseWidth * zoom;
    // Map to screen coordinates (flip so earlier times are on left)
    return (1 - normalized) * scaledWidth + panOffset;
  }

  /// Convert an X coordinate to time (years BP).
  double xToTime(double x) {
    final scaledWidth = viewportWidth * zoom;
    final normalized = 1 - ((x - panOffset) / scaledWidth);
    return normalized * timeSpan + endBP;
  }
}
