import 'package:flutter/foundation.dart';
import '../models/models.dart';
import 'timeline_service.dart';

/// State management for the timeline viewer.
class TimelineState extends ChangeNotifier {
  final TimelineService _service = TimelineService();

  List<Timeline> _availableTimelines = [];
  Timeline? _currentTimeline;
  bool _isLoading = false;
  String? _error;

  // View state
  double _zoom = 1.0;
  double _panOffset = 0.0; // Horizontal offset in logical pixels

  // Selection state
  TimelinePeriod? _selectedPeriod;
  TimelineEvent? _selectedEvent;

  // Hover state
  TimelinePeriod? _hoveredPeriod;
  TimelineEvent? _hoveredEvent;
  double? _hoverTimePosition; // X position for vertical time indicator

  // Getters
  List<Timeline> get availableTimelines => _availableTimelines;
  Timeline? get currentTimeline => _currentTimeline;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get zoom => _zoom;
  double get panOffset => _panOffset;
  TimelinePeriod? get selectedPeriod => _selectedPeriod;
  TimelineEvent? get selectedEvent => _selectedEvent;
  TimelinePeriod? get hoveredPeriod => _hoveredPeriod;
  TimelineEvent? get hoveredEvent => _hoveredEvent;
  double? get hoverTimePosition => _hoverTimePosition;

  /// Load all available timelines from assets.
  Future<void> loadTimelines() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _availableTimelines = await _service.loadAllTimelines();
      if (_availableTimelines.isNotEmpty && _currentTimeline == null) {
        _currentTimeline = _availableTimelines.first;
        _resetView();
      }
    } catch (e) {
      _error = 'Failed to load timelines: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Select a timeline to display.
  void selectTimeline(Timeline timeline) {
    if (_currentTimeline != timeline) {
      _currentTimeline = timeline;
      _clearSelection();
      _resetView();
      notifyListeners();
    }
  }

  /// Select a timeline by index.
  void selectTimelineByIndex(int index) {
    if (index >= 0 && index < _availableTimelines.length) {
      selectTimeline(_availableTimelines[index]);
    }
  }

  /// Reset view to fit the entire timeline.
  void _resetView() {
    _zoom = 1.0;
    _panOffset = 0.0;
  }

  /// Clear selection state.
  void _clearSelection() {
    _selectedPeriod = null;
    _selectedEvent = null;
  }

  // Zoom controls

  /// Zoom in by a factor.
  void zoomIn({double factor = 1.2}) {
    _zoom = (_zoom * factor).clamp(0.001, 1000.0);
    notifyListeners();
  }

  /// Zoom out by a factor.
  void zoomOut({double factor = 1.2}) {
    _zoom = (_zoom / factor).clamp(0.001, 1000.0);
    notifyListeners();
  }

  /// Set zoom to a specific level.
  void setZoom(double zoom) {
    _zoom = zoom.clamp(0.001, 1000.0);
    notifyListeners();
  }

  /// Zoom to fit a specific time range.
  void zoomToFit(double viewportWidth) {
    // Reset to show entire timeline
    _zoom = 1.0;
    _panOffset = 0.0;
    notifyListeners();
  }

  // Pan controls

  /// Pan by a delta amount.
  void pan(double delta) {
    _panOffset += delta;
    notifyListeners();
  }

  /// Set pan offset to a specific value.
  void setPanOffset(double offset) {
    _panOffset = offset;
    notifyListeners();
  }

  // Selection

  /// Select a period (opens info popup).
  void selectPeriod(TimelinePeriod? period) {
    _selectedPeriod = period;
    _selectedEvent = null;
    notifyListeners();
  }

  /// Select an event (opens info popup).
  void selectEvent(TimelineEvent? event) {
    _selectedEvent = event;
    _selectedPeriod = null;
    notifyListeners();
  }

  /// Clear all selection.
  void clearSelection() {
    _clearSelection();
    notifyListeners();
  }

  // Hover state

  /// Set hovered period.
  void setHoveredPeriod(TimelinePeriod? period) {
    if (_hoveredPeriod != period) {
      _hoveredPeriod = period;
      notifyListeners();
    }
  }

  /// Set hovered event.
  void setHoveredEvent(TimelineEvent? event) {
    if (_hoveredEvent != event) {
      _hoveredEvent = event;
      notifyListeners();
    }
  }

  /// Set the hover time position for vertical indicator.
  void setHoverTimePosition(double? position) {
    if (_hoverTimePosition != position) {
      _hoverTimePosition = position;
      notifyListeners();
    }
  }

  /// Clear hover state.
  void clearHover() {
    _hoveredPeriod = null;
    _hoveredEvent = null;
    _hoverTimePosition = null;
    notifyListeners();
  }
}
