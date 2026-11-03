
## Habit Garden App
Secret Habit Garden is a mobile habit-tracking application built with Flutter and Dart. The idea behind the app is to give users a simple way to create habits, track their daily check-ins, and see how consistent they are over time.

Starting and maintaining new habits can be difficult. Traditional to-do lists and reminders can help organize tasks, but they don't always make it easy to keep track of individual habits and progress. Secret Habit Garden gives users a place to manage their habits and see their progress through a garden-themed interface.

## Features

- Create, edit, and delete habits.
- Record daily check-ins and prevent duplicate check-ins.
- View all habits from the Garden Dashboard.
- View individual habit details and weekly progress.
- Review and edit past check-ins.
- Manage settings and weekly targets.
- Use the Garden Guide to get a suggested weekly goal based on previous check-in activity. (must have three weeks of data)

## Database

The app uses SQLite through the sqflite package to store information locally. There are two main database tables: habits and check_ins.

The habits table stores information about each habit, while the check_ins table stores the dates users complete their habits. Both tables support creating, retrieving, updating, and deleting records.

The app is designed to work offline, and saved information remains available after restarting the application.

## Garden Guide

The Garden Guide is a local, rule-based helper. It looks at the user's three most recent completed weeks of check-in activity and calculates an average to suggest a weekly target.

The suggestion is based on the user's own activity. Users can choose to apply the suggested target or keep their original goal.

More information about the helper, its calculation, and testing can be found in AI_FEATURE.md.

## Technologies

Flutter and Dart  
SQLite and sqflite  
SharedPreferences

## Project Documentation

- ARCHITECTURE.md
- AI_FEATURE.md
- docs/Kanban_Contribution_Evidence.pdf

## Project Management

ClickUp Board: [(https://app.clickup.com/90141801146/v/b/2kydxenu-534)/]

## Running the Application

Clone the repository:

```bash
git clone https://github.com/laprexious/habit-secret-garden-app.git
```

Go into the project folder:

```bash
cd habit-secret-garden-app
```

Install the dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```
## Known Issues/ Future Enhancements
- ai helper can be considered counterproductive
- would like to remove ai helper and implement an insights feature for each habit for all time (but id like it to be on its own screen)
- better insight visualization



## Developer/License

Laprecious Sanders  
ITEC 4360 - Mobile App Development  
Georgia State University

GitHub: https://github.com/laprexious/habit-secret-garden-app