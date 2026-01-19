# Qalby2Heart - Final Project Report

## Summary of Achieved Features

Qalby2Heart is a Flutter-based Islamic mental wellness app designed to provide faith-based support for emotional well-being. The following features have been successfully implemented:

### Core Features
- **User Authentication**: Email/password and Google Sign-In support for both mobile and web platforms
- **Mood Tracking**: Users can log their daily moods with intensity levels, triggers, locations, and notes
- **Journaling**: Private journal with categorized entries, prompts, and image attachments
- **Islamic Resources**: Curated Quran verses and Hadith for mental health support
- **Data Persistence**: All user data is stored in Firestore with proper user isolation

### User Interface
- Clean, intuitive navigation with bottom tab bar
- Responsive design with Islamic-themed UI elements
- Offline mode support for development and testing
- Platform-specific authentication handling (mobile vs web)

### Data Management
- **Firestore Collections**:
  - `user_profiles`: User account information
  - `mood_entries`: Daily mood logs with metadata
  - `journal_entries`: Journal posts with categories
  - `resource_searches`: Search history tracking
  - `resource_filters`: Filter preference tracking
- Secure data access with Firebase Authentication integration

## Technical Explanation

### Technology Stack
- **Framework**: Flutter (Dart)
- **Backend**: Firebase (Authentication, Firestore)
- **State Management**: Stateful widgets with setState
- **Networking**: HTTP package for direct Firestore REST API calls
- **Authentication**: Firebase Auth with platform-specific providers

### Architecture
- **MVVM-like Structure**: Screens handle UI, services manage data operations
- **Service Layer**: `FirestoreService` provides CRUD operations via REST API
- **Platform Detection**: Uses `kIsWeb` for conditional logic (web vs mobile auth)
- **Error Handling**: Comprehensive exception catching with user-friendly messages

### Key Technical Decisions
- **Direct REST API**: Bypassed Firebase SDK for Firestore to maintain control and avoid web compatibility issues
- **Document IDs**: User profiles use UID as document ID to prevent duplicates
- **Timestamp Handling**: UTC timestamps for consistent date filtering
- **Authentication Guards**: StreamBuilder monitors auth state for seamless UI transitions

### Firebase Integration
- **Authentication**: Supports email/password and Google OAuth
- **Firestore Rules**: Configured for authenticated user access
- **Platform Config**: Separate options for Android and web (web config needs manual update)

## Limitations and Future Enhancements

### Current Limitations
- **Web Configuration**: Firebase web options are placeholders and need manual configuration from Firebase Console
- **AI Chat**: Currently a static UI placeholder without actual AI integration
- **Offline Sync**: No local storage or sync when offline (beyond basic offline mode)
- **Data Validation**: Limited input validation and sanitization
- **Performance**: No caching or optimization for large datasets
- **Security**: Basic Firestore rules; may need refinement for production

### Future Enhancements
- **AI Integration**: Implement actual AI counseling using OpenAI or similar APIs
- **Push Notifications**: Reminders for mood tracking and journaling
- **Data Analytics**: User insights and progress tracking
- **Social Features**: Community support groups or sharing (with privacy controls)
- **Multilingual Support**: Arabic/English localization
- **Advanced Search**: Full-text search in journals and resources
- **Backup/Restore**: User data export/import functionality
- **Wearable Integration**: Mood tracking via smartwatches
- **Therapist Integration**: Professional referral system
- **Progressive Web App**: Enhanced PWA features for web version

### Technical Improvements
- **State Management**: Migrate to Provider or Riverpod for better scalability
- **Testing**: Add comprehensive unit and integration tests
- **CI/CD**: GitHub Actions for automated testing and deployment
- **Error Monitoring**: Integrate Crashlytics or similar for production monitoring
- **Performance Optimization**: Implement lazy loading and pagination for large lists

---

**Project Status**: Core functionality complete and deployed to GitHub  
**Repository**: https://github.com/jannahnaimah/Flutter-Islamic-Counseling-App.git  
**Date**: January 19, 2026</content>
<parameter name="filePath">C:\Users\njnna\AndroidStudioProjects\Qalby2Heart\REPORT.md
