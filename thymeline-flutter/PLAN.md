# Thymeline - Implementation Plan

## Project Overview

Thymeline is a Flutter app for creating and presenting historical timelines. It renders timelines horizontally with support for multiple time scales (cosmological to modern history).

## Current Status: Scaffold Complete

### Completed Features
- [x] Project structure with organized folders (models, services, widgets, screens)
- [x] Data models for Timeline, Period, Event, Connector, and TimePoint
- [x] Time handling for multiple scales (mya, years-ago, BCE, CE, ISO dates)
- [x] JSON loading service for timeline data
- [x] State management with Provider (TimelineState)
- [x] Basic timeline canvas with CustomPainter
- [x] Zoom controls (scroll wheel + buttons)
- [x] Pan by dragging
- [x] Timeline selector dropdown
- [x] Info popup for period/event details
- [x] Basic period rendering as colored bars
- [x] Basic event rendering as circles
- [x] Basic connector rendering (sigmoid curves)
- [x] Time axis with adaptive tick intervals
- [x] Hover indicator (vertical time line)

## Implementation Roadmap

### Phase 1: Core Rendering (Next)
- [ ] **Hit testing for periods/events** - Click to select, show info popup
- [ ] **Improved period layout** - Smarter row assignment to minimize overlap
- [ ] **Period labels** - Better text positioning and overflow handling
- [ ] **Event positioning** - Connect events to related periods visually
- [ ] **Connector refinement** - Better start/end points, arrowheads optional

### Phase 2: Interaction Polish
- [ ] **Smooth zoom** - Zoom centered on cursor/pinch point
- [ ] **Keyboard shortcuts** - +/- for zoom, arrow keys for pan
- [ ] **Touch gestures** - Pinch to zoom for mobile
- [ ] **Hover tooltips** - Show name/date on hover
- [ ] **Selection highlight** - Visual feedback for selected items

### Phase 3: Time Axis Enhancement
- [ ] **Tick mark refinement** - Minor/major ticks
- [ ] **Era labels** - Show geological eras for deep time
- [ ] **Scale indicator** - Show current time scale visually
- [ ] **Jump to time** - Quick navigation to specific dates

### Phase 4: Visual Polish
- [ ] **Color theming** - User-customizable period colors
- [ ] **Period gradients** - Visual distinction for ongoing vs ended
- [ ] **Animation** - Smooth transitions on zoom/pan
- [ ] **Dark/light mode** - Full theme support
- [ ] **Event icons** - Custom icons per event type

### Phase 5: Backend Integration (Future)
- [ ] **API service** - Connect to Ruby on Rails backend
- [ ] **Timeline CRUD** - Create, edit, delete timelines
- [ ] **User authentication** - Login/logout
- [ ] **Cloud sync** - Save/load from server
- [ ] **Sharing** - Public timeline links

### Phase 6: Advanced Features (Future)
- [ ] **Multiple tracks** - Parallel timeline lanes
- [ ] **Filtering** - Show/hide by category
- [ ] **Search** - Find events/periods by name
- [ ] **Export** - PNG, PDF, SVG export
- [ ] **Embeddable widget** - For websites

## Project Structure

```
thymeline/
├── assets/
│   └── timelines/           # JSON timeline data files
├── lib/
│   ├── main.dart            # App entry point
│   ├── models/              # Data models
│   │   ├── time_point.dart      # Time handling (mya, BCE, etc.)
│   │   ├── timeline_event.dart  # Event model
│   │   ├── timeline_period.dart # Period model
│   │   ├── timeline_connector.dart # Connector model
│   │   └── timeline.dart        # Root timeline model
│   ├── services/            # Business logic
│   │   ├── timeline_service.dart # JSON loading
│   │   └── timeline_state.dart   # State management
│   ├── screens/             # Full-page views
│   │   └── home_screen.dart     # Main timeline screen
│   ├── widgets/             # Reusable UI components
│   │   ├── timeline_canvas.dart   # Main canvas widget
│   │   ├── timeline_selector.dart # Timeline dropdown
│   │   ├── zoom_controls.dart     # Zoom buttons
│   │   ├── info_popup.dart        # Detail popup
│   │   └── painters/
│   │       └── timeline_painter.dart # CustomPainter
│   └── utils/               # Utilities (future)
└── test/                    # Tests
```

## JSON Data Format

```json
{
  "events": [
    {
      "id": "event-id",
      "name": "Event Name",
      "time": { "value": 4540, "unit": "mya" },
      "info": "Description text",
      "relates_to": "period-id"  // optional
    }
  ],
  "periods": [
    {
      "id": "period-id",
      "name": "Period Name",
      "startTime": { "value": 4540, "unit": "mya" },
      "endTime": { "value": 4000, "unit": "mya" },  // optional, null = ongoing
      "info": "Description text"
    }
  ],
  "connectors": [
    {
      "id": "conn-id",
      "fromId": "period-id-1",
      "toId": "period-id-2",
      "type": "defined",  // or "undefined" for dotted
      "metadata": { "note": "Connection description" }
    }
  ]
}
```

### Time Units
- `mya` - Millions of years ago
- `years-ago` - Years before present
- `bce` - Before Common Era
- `ce` - Common Era
- ISO string - e.g., "1848-02-21"

## Running the App

```bash
cd thymeline
flutter pub get
flutter run -d chrome  # For web
flutter run            # For default device
```

## Dependencies

- `provider` - State management
- `json_annotation` - JSON serialization (for future code generation)
