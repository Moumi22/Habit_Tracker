Habit Tracker - Flutter App
A modern, feature-rich habit tracking application built with Flutter and Firebase. Track your daily habits, monitor progress, and stay motivated with inspirational quotes.


🚀 Features


📱 Core Functionality

Habit Management: Create, edit, and delete habits with custom categories

Progress Tracking: Monitor completion rates, streaks, and overall progress

Daily Overview: View today's habits and completion status

Category Filtering: Organize habits by categories (Health, Study, Fitness, etc.)

Streak Tracking: Track consecutive days of habit completion



🎨 User Interface

Modern Design: Clean, intuitive Material Design 3 interface

Dark/Light Mode: Toggle between light and dark themes

Responsive Layout: Optimized for various screen sizes

Pull-to-Refresh: Refresh data with smooth animations

Floating Action Button: Quick access to add new habits





![Image](https://github.com/user-attachments/assets/a71bc696-f416-473f-95af-ee6582dbf5f7)


![Image](https://github.com/user-attachments/assets/f29dc5e0-05a8-4b49-9b06-b5efd201e7b3)


![Image](https://github.com/user-attachments/assets/69173a8e-a883-491e-9610-8b01a0b98b14)


![Image](https://github.com/user-attachments/assets/7a8b0673-51a9-412b-899c-de6460ef7131)


![Image](https://github.com/user-attachments/assets/a59cecf3-2c78-4cbb-803a-36190f7a4caa)



📊 Analytics & Insights

Progress Charts: Visual representation of habit completion over time

Category Statistics: Breakdown of progress by habit category

Success Rates: Track completion percentages and trends

Streak Analytics: Monitor your longest and current streaks


💬 Motivation & Inspiration

Daily Quotes: Get inspired with motivational quotes

Quote Favorites: Save and manage your favorite quotes

Random Inspiration: Discover new quotes to stay motivated

Offline Support: Fallback quotes when internet is unavailable


🔐 Authentication & Security

Firebase Authentication: Secure user registration and login

Session Persistence: Stay logged in across app restarts

Profile Management: Update personal information and preferences

Password Reset: Recover account access if needed


🛠️ Technology Stack

Frontend

Flutter: Cross-platform mobile development framework

Dart: Programming language

Provider: State management solution

Material Design 3: UI/UX design system

Backend & Services

Firebase Authentication: User authentication and management

Cloud Firestore: NoSQL database for data storage

Firebase Hosting: Web deployment (if applicable)

External APIs

Quotable API: Fetch motivational quotes

ZenQuotes API: Fallback quote service

Offline Quotes: Built-in quote collection

Dependencies

firebase_core: Firebase initialization

firebase_auth: Authentication services

cloud_firestore: Database operations

provider: State management

shared_preferences: Local storage

pull_to_refresh: Pull-to-refresh functionality

flutter_slidable: Swipeable list items

fl_chart: Chart visualization

http: API requests



📋 Prerequisites

Before running this project, ensure you have:

Flutter SDK: Version 3.0.0 or higher

Dart SDK: Version 2.17.0 or higher

Android Studio or VS Code: IDE with Flutter extensions

Firebase Project: Configured Firebase project with Authentication and Firestore

Android Emulator or Physical Device: For testing


🚀 Installation & Setup

1. Clone the Repository
   
git clone https://github.com/Moumi22/Habit_Tracker
cd habit-tracker

2. Install Dependencies
flutter pub get

3. Firebase Configuration

Create Firebase Project

Go to Firebase Console

Create a new project or select existing one

Enable Authentication and Cloud Firestore

Configure Authentication

In Firebase Console, go to Authentication > Sign-in method

Enable Email/Password authentication

Configure additional providers if needed

Configure Firestore

Go to Firestore Database

Create database in test mode (for development)

Set up security rules for production

Add Firebase Configuration

Download google-services.json for Android

Place it in android/app/ directory

Update android/build.gradle with Firebase dependencies

4. Environment Setup

Create a .env file in the root directory:

FIREBASE_PROJECT_ID=your-project-id

FIREBASE_API_KEY=your-api-key

5. Run the Application

flutter run

📁 Project Structure

lib/

├── main.dart                 # App entry point

├── models/                   # Data models

│   ├── habit_model.dart      # Habit data structure

│   ├── user_model.dart       # User data structure

│   └── quote_model.dart      # Quote data structure

├── providers/                # State management

│   ├── auth_provider.dart    # Authentication state

│   ├── habit_provider.dart   # Habit data management

│   ├── quote_provider.dart   # Quote data management

│   └── theme_provider.dart   # Theme state management

├── services/                 # Business logic

│   ├── auth_service.dart      # Authentication operations

│   ├── habit_service.dart    # Habit CRUD operations

│   └── quote_service.dart    # Quote fetching

├── screens/                  # UI screens

│   ├── splash_screen.dart     # Loading screen

│   ├── main_screen.dart       # Main navigation

│   ├── auth/                  # Authentication screens

│   ├── home/                  # Home screen

│   ├── habits/                # Habit management

│   ├── progress/              # Progress analytics

│   ├── quotes/                # Quote management

│   └── profile/              # User profile

└── widgets/                  # Reusable components

    ├── habit_card.dart       # Habit display card
    
    ├── quote_card.dart       # Quote display card
    
    └── stats_card.dart       # Statistics card
    
    
🎯 Usage Guide

Getting Started

Launch the app and create an account or sign in

Add your first habit using the floating action button

Set habit details: title, category, frequency, and notes

Track daily progress by marking habits as complete

Managing Habits

Create: Tap the "+" button to add new habits

Edit: Swipe left on a habit to edit or delete

Complete: Tap the checkbox to mark as done

View Details: Tap on a habit to see full information

Tracking Progress

Daily View: See today's habits on the home screen

Progress Tab: View charts and statistics

Category Filter: Filter habits by category

Streak Tracking: Monitor your completion streaks

Staying Motivated

Daily Quotes: Get inspired with motivational quotes

Favorites: Save quotes that resonate with you

Random Quotes: Discover new inspiration

Offline Access: Quotes available without internet


🔧 Configuration

Firebase Security Rules

// Firestore security rules

rules_version = '2';

service cloud.firestore {

  match /databases/{database}/documents {
  
    // Users can only access their own data
    
    match /users/{userId} {
    
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      
      // Habits subcollection
      
      match /habits/{habitId} {
      
        allow read, write: if request.auth != null && request.auth.uid == userId;
        
      }
      
      
      // Quotes subcollection
      
      match /favorites/quotes/{quoteId} {
      
        allow read, write: if request.auth != null && request.auth.uid == userId;
        
      }
      
      
      // Daily quotes
      
      match /daily_quotes/{date} {
      
        allow read, write: if request.auth != null && request.auth.uid == userId;
        
      }
      
    }
    
  }
  
}

Environment Variables

// lib/config/app_config.dart

class AppConfig {

  static const String firebaseProjectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  
  static const String firebaseApiKey = String.fromEnvironment('FIREBASE_API_KEY');
  
  
  // API endpoints
  
  static const String quotableApiUrl = 'https://api.quotable.io';
  
  static const String zenQuotesApiUrl = 'https://zenquotes.io/api';
  
}

🧪 Testing

Unit Tests

flutter test

Widget Tests

flutter test test/widget_test.dart

Integration Tests

flutter drive --target=test_driver/app.dart


📱 Build & Deploy

Android Build

# Debug build

flutter build apk --debug


# Release build

flutter build apk --release


# App bundle for Play Store

flutter build appbundle --release

iOS Build

# Debug build

flutter build ios --debug


# Release build

flutter build ios --release

Web Build

flutter build web --release


🤝 Contributing

Fork the repository

Create a feature branch: git checkout -b feature/amazing-feature

Commit your changes: git commit -m 'Add amazing feature'

Push to the branch: git push origin feature/amazing-feature

Open a Pull Request

Development Guidelines

Follow Flutter coding conventions

Write meaningful commit messages

Add tests for new features

Update documentation as needed


🐛 Troubleshooting

Common Issues

Firebase Configuration

Issue: Firebase not initialized

Solution: Check google-services.json placement and Firebase initialization

Authentication Errors

Issue: Users can't sign in

Solution: Verify Firebase Authentication is enabled and configured

Data Not Loading

Issue: Habits or quotes not appearing

Solution: Check Firestore security rules and internet connectivity

Build Errors

Issue: Compilation fails

Solution: Run flutter clean and flutter pub get

Debug Mode

# Enable debug logging

flutter run --debug


# Check for issues

flutter doctor

flutter analyze

📄 License

This project is licensed under the MIT License - see the LICENSE file for details.


🙏 Acknowledgments

Flutter Team: For the amazing framework

Firebase Team: For the backend services

Material Design: For the design system

Open Source Community: For the libraries and tools



📞 Support
Issues: Report bugs on GitHub Issues

Discussions: Join community discussions

Documentation: Check the wiki for detailed guides

Email: Contact the development team


🔄 Changelog

Version 1.0.0

Initial release

Basic habit tracking functionality

Firebase integration

Modern UI design

Quote system

Progress analytics

Version 1.1.0 (Planned)

Offline support

Data export/import

Advanced analytics

Social features

Custom themes

Made with ❤️ using Flutter
