import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/services.dart';

/// Floating zoom controls for the timeline.
class ZoomControls extends StatelessWidget {
  const ZoomControls({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<TimelineState>();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => state.zoomIn(),
              icon: const Icon(Icons.add),
              tooltip: 'Zoom in',
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                '${(state.zoom * 100).toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            IconButton(
              onPressed: () => state.zoomOut(),
              icon: const Icon(Icons.remove),
              tooltip: 'Zoom out',
            ),
            const Divider(height: 8),
            IconButton(
              onPressed: () => state.zoomToFit(
                MediaQuery.of(context).size.width,
              ),
              icon: const Icon(Icons.fit_screen),
              tooltip: 'Fit to screen',
            ),
          ],
        ),
      ),
    );
  }
}
