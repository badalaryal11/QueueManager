# Reorderable Queue Manager

A robust Flutter application for managing task queues with persistent reordering, background processing, and native thermal monitoring.

<img src="https://via.placeholder.com/800x400?text=App+Screenshot+Placeholder" alt="App Banner" width="100%"/>

## 🚀 Features

*   **Persistent Reordering**: Drag-and-drop tasks with optimized data persistence (`O(1)` writes using fractional indexing).
*   **Background Processing**: Tasks are processed sequentially in a dedicated background **Isolate**, keeping the UI silky smooth.
*   **Thermal Throttling**: 
    *   **Android**: Monitors CPU temperature via native channels (`EventChannel`) and auto-pauses processing if the device overheats (> 80°C).
    *   **iOS**: Monitors thermal state (`ProcessInfo.thermalState`) to prevent overheating.
*   **State Management**: Built with **Flutter Bloc** for predictable state transitions.
*   **Local Database**: Powered by **Drift** (SQLite) for type-safe and reactive data storage.

## 🛠️ Tech Stack

*   **Framework**: Flutter & Dart
*   **State Management**: [flutter_bloc](https://pub.dev/packages/flutter_bloc)
*   **Database**: [Drift](https://pub.dev/packages/drift) (SQLite)
*   **Concurrency**: Dart Isolates (Background Worker)
*   **Native Modules**:
    *   **Android**: Kotlin (Method/Event Channels for CPU Temp)
    *   **iOS**: Swift (Thermal State Monitoring)

## 🏗️ Architecture

The app follows a Clean Architecture approach:

*   **UI Layer**: Widgets and Screens (MainScreen, ControlPanel).
*   **Logic Layer**: `QueueBloc` bridges the UI and Data/Background layers.
*   **Data Layer**: `QueueRepository` handles database operations and reordering logic.
*   **Service Layer**: `TemperatureService` consumes streams from native platform channels.
*   **Background Layer**: `BackgroundProcessor` manages the worker isolate lifecycle.

## ⚡ Database Optimization

To ensure a smooth reordering experience with minimal database writes, we implemented **Fractional Indexing**. 
Instead of updating the indices of all items when a task is moved, we calculate a new floating-point `sortOrder` between the adjacent items.

> **Example**: Moving Item C between A (`1.0`) and B (`2.0`) results in C getting `1.5`. 
> This keeps write operations to **O(1)**.

## 📦 Getting Started

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/badalaryal11/QueueManager.git
    cd QueueManager
    ```

2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Run the code generator** (for Drift):
    ```bash
    dart run build_runner build
    ```

4.  **Run the app**:
    ```bash
    flutter run
    ```
