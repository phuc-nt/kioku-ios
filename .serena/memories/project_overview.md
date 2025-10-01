# Kioku - Project Overview

## Purpose
AI-powered personal journaling iOS app with intelligent chat assistance. Helps users reflect on their thoughts through AI conversations that understand their journal history.

## Current Status
**Sprint 10 Completed** - AI Chat Integration fully functional

## Core Features
- 📅 **Calendar-based Journaling**: Write and organize entries by date
- 🤖 **AI Chat Integration**: Context-aware AI conversations with OpenRouter API
- 📖 **Historical Context**: AI accesses current + historical entries (same day across months)
- 🔒 **Privacy-First**: All data stored locally with encryption
- 🎨 **Tab Navigation**: Calendar ↔ Chat seamless switching

## Tech Stack
- **UI Framework**: SwiftUI (iOS 18+)
- **Data**: SwiftData with local SQLite + encryption
- **AI**: OpenRouter API integration
- **Architecture**: Tab-based navigation with @Observable pattern
- **Testing**: XcodeBuildMCP automation + Swift Testing framework

## Key Architecture
- **Workspace + SPM Structure**: App shell + Feature package separation
- **Local-First**: No cloud sync, all data local
- **Context-Aware AI**: Date-aware chat with historical pattern recognition
- **Buildable Folders**: Xcode 16 feature for auto-discovery