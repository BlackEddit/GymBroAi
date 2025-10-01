<!-- Use this file to provide workspace-specific custom instructions to Copilot. For more details, visit https://code.visualstudio.com/docs/copilot/copilot-customization#_use-a-githubcopilotinstructionsmd-file -->

# GymAI - Flutter App with Computer Vision

This is a Flutter mobile application for gym equipment recognition and workout assistance using computer vision.

## Features
- Camera-based equipment recognition using ML Kit
- Workout tracking and progress monitoring  
- Exercise recommendations based on detected equipment
- Gym layout mapping
- Local database for offline functionality
- Real-time object detection and overlay
- Progress statistics and achievements
- Modern Material Design 3 UI

## Project Status
- [x] Project structure created
- [x] Dependencies configured
- [x] Navigation setup (5 main screens)
- [x] Camera and CV implementation
- [x] Database schema (SQLite with 8 tables)
- [x] UI/UX design (6 custom widgets)
- [x] State management (Provider pattern)
- [x] Services architecture (Camera, ML, Database)
- [x] Data models (Equipment, Exercise, Workout, Session)
- [x] Complete documentation

## Technical Architecture
- **Frontend**: Flutter with Material Design 3
- **Computer Vision**: Google ML Kit + TensorFlow Lite
- **Database**: SQLite for offline storage  
- **State Management**: Provider pattern
- **Camera**: Camera plugin with real-time processing
- **Permissions**: Camera, storage, location

## Development Guidelines
- Use Flutter best practices
- Implement computer vision with ML Kit and TensorFlow Lite
- Focus on user experience and performance
- Maintain clean architecture with proper separation of concerns
- Follow Material Design 3 guidelines
- Ensure offline functionality with local database