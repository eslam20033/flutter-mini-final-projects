# Simple To-Do List App

A clean and modern To-Do List application built with Flutter. This app helps you manage your daily tasks efficiently with a user-friendly interface, using **BLoC** for predictable state management.

## ✨ Features
- **Add Tasks:** Quickly add new tasks using the text input field[cite: 1].
- **Mark as Done:** Toggle task completion status with interactive checkboxes[cite: 1, 2].
- **Delete Tasks:** Remove unwanted tasks easily using the red delete icon[cite: 1, 2].
- **Empty State Handling:** Displays a beautiful illustration and a "No tasks yet!" message when the list is empty[cite: 2].
- **In-Memory Storage:** Tasks are kept in memory during the app's lifecycle[cite: 1].

## 🛠️ Tech Stack & Concepts
- **Framework:** Flutter / Dart
- **State Management:** BLoC (Business Logic Component)
- **Key Widgets Used:** `TextField`, `ListView.builder`, `IconButton`, `Checkbox`[cite: 1].

## 📱 UI Overview
The application features a modern UI with:
- A prominent blue header with the motivational subtitle "Small steps, big progress ✨"[cite: 2].
- An intuitive input field with a floating `+` button to submit tasks[cite: 2].
- A clean list view for tasks, clearly distinguishing between pending and completed items[cite: 2].

## 🚀 Getting Started

1. Clone the repository.
2. Run `flutter pub get` to install dependencies (including `flutter_bloc`).
3. Run the app using `flutter run`.
