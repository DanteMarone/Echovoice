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
- [ ] **Engine Research & Selection**
  - [ ] Evaluate local TTS engines (e.g., Windows Speech API) vs. cloud-based TTS.
  - [ ] Decide on primary and fallback TTS options based on quality and latency.
- [ ] **TTS Processing Module**
  - [ ] Develop an asynchronous module to handle TTS conversion.
  - [ ] Ensure non-blocking operation to avoid in-game lag.
- [ ] **Voice Mapping Engine**
  - [ ] Create a database/mapping of NPC metadata to voice parameters.
  - [ ] Allow customization and future voice pack extensions.
- [ ] **Audio Caching**
  - [ ] Implement caching for common phrases to reduce processing delays.
  - [ ] Design cache invalidation and update strategies.

---

## 4. Companion Application (Windows)
- [ ] **Companion App Development**
  - [ ] Build a lightweight app to handle heavy TTS processing outside WoW's sandbox.
  - [ ] Ensure compatibility with Windows 11.
- [ ] **Local Communication Protocol**
  - [ ] Develop secure protocols (e.g., named pipes, local sockets) for data exchange.
- [ ] **Audio Playback & Synchronization**
  - [ ] Implement robust audio playback synchronized with in-game events.
  - [ ] Include features such as volume adjustment and environmental effects.
- [ ] **Error Handling & Fallbacks**
  - [ ] Provide error management for TTS failures.
  - [ ] Implement fallback strategies (e.g., revert to text display).

---

## 5. User Interface & Customization
- [ ] **In-Game Configuration Panel**
  - [ ] Design a user-friendly UI for toggling features (quest narration, chat reading).
  - [ ] Integrate settings for voice customization (volume, speed, pitch).
- [ ] **Advanced Options**
  - [ ] Allow selection between local and cloud TTS.
  - [ ] Implement filters for chat channels and event prioritization.
  - [ ] Provide auto-pausing options during combat or high-stress gameplay.
- [ ] **Accessibility Features**
  - [ ] Integrate subtitles/transcripts alongside audio output.
  - [ ] Enable voice prompt commands for pause, repeat, and skip functions.

---

## 6. Integration & Testing
- [ ] **Unit Testing**
  - [ ] Write tests for event handling, TTS conversion, and metadata extraction.
- [ ] **Integration Testing**
  - [ ] Ensure seamless communication between the addon and the companion app.
  - [ ] Test asynchronous processing and caching under live gameplay conditions.
- [ ] **Performance Testing**
  - [ ] Evaluate the addon's impact on game performance (latency, resource usage).
  - [ ] Stress-test the TTS pipeline during high-volume events.
- [ ] **Beta Testing**
  - [ ] Conduct closed beta testing with select players.
  - [ ] Gather feedback on voice quality, timing, and user experience.
  - [ ] Iterate and refine based on tester feedback.

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