import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/services.dart';
import '../widgets/timeline_canvas.dart';
import '../widgets/timeline_selector.dart';
import '../widgets/zoom_controls.dart';
import '../widgets/info_popup.dart';

/// Main screen displaying the timeline viewer.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<TimelineState>(
        builder: (context, state, child) {
          if (state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading timelines',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(state.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => state.loadTimelines(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state.availableTimelines.isEmpty) {
            return const Center(
              child: Text('No timelines available'),
            );
          }

          return Stack(
            children: [
              // Main timeline canvas
              const Positioned.fill(
                child: TimelineCanvas(),
              ),

              // Top bar with timeline selector
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surface
                        .withOpacity(0.9),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Row(
                      children: [
                        Text(
                          'Thymeline',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 24),
                        const Expanded(child: TimelineSelector()),
                      ],
                    ),
                  ),
                ),
              ),

              // Zoom controls
              const Positioned(
                bottom: 16,
                right: 16,
                child: ZoomControls(),
              ),

              // Info popup (shown when period/event is selected)
              if (state.selectedPeriod != null ||
                  state.selectedEvent != null)
                const Positioned.fill(
                  child: InfoPopup(),
                ),
            ],
          );
        },
      ),
    );
  }
}
