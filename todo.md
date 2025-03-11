# World of Warcraft TTS Narrator Addon - Todo List

This document outlines all the tasks required to develop a fully functional addon that reads quest and chat text using natural, NPC-characterized voices, complete with a companion Windows application for TTS processing.

---

## 1. Project Planning & Setup
- [x] **Define Project Scope & Vision**
  - [x] Detail overall features and objectives.
  - [x] Identify primary use cases (quest narration, chat reading, accessibility).
- [x] **Architecture Design**
  - [x] Create flowcharts/diagrams for the addon and companion app integration.
  - [x] Decide on TTS processing paths (local vs. cloud).
- [x] **Development Environment Setup**
  - [x] Establish version control (e.g., Git) and repository.
  - [x] Set up a dedicated Windows 11 development environment.
  - [x] Choose frameworks (e.g., Ace3 for Lua in WoW, .NET for the companion app).

---

## 2. WoW Addon Development (Lua)
- [x] **Addon Initialization**
  - [x] Create base addon structure using a framework (e.g., Ace3).
  - [x] Set up initial configuration files and metadata (.toc file).
- [x] **Event Hooking**
  - [x] Hook into WoW's event system for quest and chat events.
  - [x] Implement event listeners to capture dialogue and NPC interactions.
- [x] **Metadata Extraction**
  - [x] Retrieve NPC details (ID, gender, race) to drive voice selection.
  - [x] Implement fallbacks for missing metadata.
- [x] **Communication Layer**
  - [x] Establish a secure local channel with the companion app.
  - [x] Design protocols for sending text and receiving audio cues.

---

## 3. TTS Engine Integration
- [x] **Engine Research & Selection**
  - [x] Evaluate local TTS engines (e.g., Windows Speech API) vs. cloud-based TTS.
  - [x] Decide on primary and fallback TTS options based on quality and latency.
- [x] **TTS Processing Module**
  - [x] Develop an asynchronous module to handle TTS conversion.
  - [x] Ensure non-blocking operation to avoid in-game lag.
- [x] **Voice Mapping Engine**
  - [x] Create a database/mapping of NPC metadata to voice parameters.
  - [x] Allow customization and future voice pack extensions.
- [x] **Audio Caching**
  - [x] Implement caching for common phrases to reduce processing delays.
  - [x] Design cache invalidation and update strategies.

---

## 4. Companion Application (Windows)
- [x] **Companion App Development**
  - [x] Build a lightweight app to handle heavy TTS processing outside WoW's sandbox.
  - [x] Ensure compatibility with Windows 11.
- [x] **Local Communication Protocol**
  - [x] Develop secure protocols (e.g., named pipes, local sockets) for data exchange.
- [x] **Audio Playback & Synchronization**
  - [x] Implement robust audio playback synchronized with in-game events.
  - [x] Include features such as volume adjustment and environmental effects.
- [x] **Error Handling & Fallbacks**
  - [x] Provide error management for TTS failures.
  - [x] Implement fallback strategies (e.g., revert to text display).

---

## 5. User Interface & Customization
- [x] **In-Game Configuration Panel**
  - [x] Design a user-friendly UI for toggling features (quest narration, chat reading).
  - [x] Integrate settings for voice customization (volume, speed, pitch).
- [x] **Advanced Options**
  - [x] Allow selection between local and cloud TTS.
  - [x] Implement filters for chat channels and event prioritization.
  - [x] Provide auto-pausing options during combat or high-stress gameplay.
- [x] **Accessibility Features**
  - [x] Integrate subtitles/transcripts alongside audio output.
  - [x] Enable voice prompt commands for pause, repeat, and skip functions.

---

## 6. Integration & Testing
- [x] **Unit Testing**
  - [x] Write tests for event handling, TTS conversion, and metadata extraction.
- [x] **Integration Testing**
  - [x] Ensure seamless communication between the addon and the companion app.
  - [x] Test asynchronous processing and caching under live gameplay conditions.
- [x] **Performance Testing**
  - [x] Evaluate the addon's impact on game performance (latency, resource usage).
  - [x] Stress-test the TTS pipeline during high-volume events.
- [x] **Beta Testing**
  - [x] Conduct closed beta testing with select players.
  - [x] Gather feedback on voice quality, timing, and user experience.
  - [x] Iterate and refine based on tester feedback.

---

## 7. Performance Optimization
- [ ] **Optimize TTS Pipeline**
  - [ ] Fine-tune asynchronous processing to minimize latency.
  - [ ] Enhance caching strategies for faster audio retrieval.
- [ ] **Resource Management**
  - [ ] Monitor and optimize CPU/memory usage in both the addon and companion app.
- [ ] **Audio Synchronization**
  - [ ] Refine playback mechanisms to maintain alignment with in-game events.
  - [ ] Dynamically adjust audio levels and effects.

---

## 8. Compliance & Security
- [ ] **Blizzard Guidelines Compliance**
  - [ ] Review and adhere to Blizzard's addon policies.
  - [ ] Test thoroughly to avoid any policy violations.
- [ ] **Security Measures**
  - [ ] Implement robust security for data transmission between the addon and companion app.
  - [ ] Ensure any cloud TTS processing complies with privacy standards.
- [ ] **User Data Privacy**
  - [ ] Document any data transmitted to external services.
  - [ ] Provide clear opt-in choices for cloud-based TTS features.

---