# Echovoice - Immersive TTS Narrator for World of Warcraft

## Overview
Echovoice is a World of Warcraft addon designed to transform the way you experience in-game dialogue. It reads quest text and chat messages aloud using natural-sounding voices that mimic the gender and race of NPCs, enhancing immersion and accessibility. Whether you're a role-player looking for a deeper narrative experience or a player requiring accessibility tools, Echovoice brings your game to life.

## Features
- **Dynamic TTS Narration:**  
  Real-time text-to-speech conversion for quest dialogues and chat messages.
- **Voice Mapping Engine:**  
  Automatically selects voice characteristics based on NPC metadata (e.g., gender and race).
- **Dual-Mode Operation:**  
  Separate modes for quest narration and chat, with customizable filters to prevent overload.
- **Local & Cloud TTS Options:**  
  Uses the Windows Speech API for responsive local processing, with an optional premium cloud-based TTS service for ultra-realistic voices.
- **Companion Application:**  
  A dedicated Windows 11 application handles heavy TTS processing outside of WoW's sandbox, ensuring smooth performance.
- **Audio Caching & Asynchronous Processing:**  
  Caches frequently-used phrases to reduce latency, with non-blocking TTS conversion.
- **Voice Customization:**  
  Adjust voice parameters (volume, speed, pitch) and create custom voice mappings for specific races or NPCs.
- **Intelligent Voice Selection:**  
  Automatically selects appropriate voices based on NPC characteristics, with race-specific modulation to enhance immersion.
- **User Interface & Customization:**  
  An in-game configuration panel allows for toggling features, adjusting voice parameters, and setting advanced options.
- **Accessibility Enhancements:**  
  Supports subtitles, transcripts, and voice commands for a fully accessible experience.

## Installation

### WoW Addon
1. **Download & Extract:**  
   Place the Echovoice addon files (including the `.toc`, `.lua`, and any required XML files) into your World of Warcraft `Interface/AddOns/Echovoice` folder.
2. **Enable the Addon:**  
   Launch World of Warcraft and enable Echovoice from the AddOns menu at the character selection screen.

### Companion Application (Windows)
1. **Download & Install:**  
   Obtain the Echovoice Companion Application (provided separately) and install it on your Windows 11 machine.
2. **Run the Application:**  
   Ensure the companion app is running before launching World of Warcraft to allow seamless TTS processing.
3. **Configure Communication:**  
   Follow the provided instructions to ensure a secure local communication channel is established between the addon and the companion application.

## Configuration & Usage
- **In-Game Settings Panel:**  
  Access the Echovoice configuration menu in-game to:
  - Toggle quest narration and chat reading.
  - Customize voice settings such as volume, speed, and pitch.
  - Choose between local and cloud TTS processing.
  - Set up chat filters and auto-pause options during combat.
- **Accessibility Options:**  
  Enable subtitles/transcripts alongside audio output and use voice commands for pause, repeat, or skip functions.
- **Fallback Mechanism:**  
  If TTS processing fails, Echovoice will revert to standard text display.

## Requirements
- **Operating System:**  
  Windows 11 (for the companion application).
- **World of Warcraft Version:**  
  Compatible with [specify supported WoW version here].
- **Dependencies:**  
  - WoW Addon: Ace3 framework.
  - Companion App: Windows Speech API (SAPI) and optionally a cloud TTS service.

## Roadmap
- **Phase 1:** Project Planning & Setup (Completed)
- **Phase 2:** WoW Addon Development (Event hooking, metadata extraction) (Completed)
- **Phase 3:** TTS Engine Integration & Voice Mapping (Completed)
- **Phase 4:** Companion Application Development & Communication Setup
- **Phase 5:** User Interface Customization & Accessibility Enhancements
- **Phase 6:** Integration, Testing, and Performance Optimization
- **Phase 7:** Compliance, Security Audits, and Final Polish

## Contributing
Contributions, suggestions, and feedback are welcome! Please see our [CONTRIBUTING.md](CONTRIBUTING.md) file for guidelines on how to contribute to Echovoice.

## Acknowledgements
- **Special Thanks:**  
  We would like to express our gratitude to **Claude** and **ChatGPT** for their invaluable assistance throughout the project planning phase. Their support helped shape this addon with modern design patterns and innovative ideas.
- **Created with Vibe Coding:**  
  This project was built with the principles of vibe coding, ensuring a flexible, creative, and user-focused development process.

## License
Echovoice is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.

---

Echovoice aims to revolutionize your World of Warcraft experience by merging cutting-edge text-to-speech technology with immersive, interactive gameplay. Enjoy a truly vocal adventure!