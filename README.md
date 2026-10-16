# Simple To-Do List App

A clean and modern To-Do List application built with Flutter. This app helps you manage your daily tasks efficiently with a user-friendly interface, using **BLoC** for predictable state management.

## ✨ Features
- **Add Tasks:** Quickly add new tasks using the text input field.
- **Mark as Done:** Toggle task completion status with interactive checkboxes.
- **Delete Tasks:** Remove unwanted tasks easily using the red delete icon.
- **Empty State Handling:** Displays a beautiful illustration and a "No tasks yet!" message when the list is empty.
- **In-Memory Storage:** Tasks are kept in memory during the app's lifecycle.

## 🛠️ Tech Stack & Concepts
- **Framework:** Flutter / Dart
- **State Management:** BLoC (Business Logic Component)
- **Key Widgets Used:** `TextField`, `ListView.builder`, `IconButton`, `Checkbox`.

## 📱 UI Overview
The application features a modern UI with:
- A prominent blue header with the motivational subtitle "Small steps, big progress ✨".
- An intuitive input field with a floating `+` button to submit tasks.
- A clean list view for tasks, clearly distinguishing between pending and completed items.

## 🚀 Getting Started

1. Clone the repository.
2. Run `flutter pub get` to install dependencies (including `flutter_bloc`).
3. Run the app using `flutter run`.
