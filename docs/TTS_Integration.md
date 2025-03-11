# Echovoice TTS Integration Documentation

This document provides technical details about the Text-to-Speech (TTS) integration in the Echovoice addon.

## Architecture Overview

The TTS integration in Echovoice follows a layered architecture:

1. **Event Handlers** - Capture text from quests and chat events
2. **Metadata Extraction** - Determine NPC characteristics (race, gender)
3. **TTS Engine** - Processes text into speech, with local and cloud options
4. **Voice Mapping** - Maps NPC metadata to specific voice characteristics
5. **Audio Cache** - Stores frequently used phrases to reduce latency
6. **Communication Layer** - Facilitates data transfer with the companion app

## TTS Engine

The TTS Engine module (`Modules/TTS/Engine.lua`) provides two main methods of speech synthesis:

### Local TTS (Windows Speech API)

- Uses Microsoft Speech API (SAPI) via the companion application
- Lower latency but more limited voice options
- No internet connectivity required
- Ideal for most gameplay situations

### Cloud TTS

- Uses cloud-based TTS services for higher quality voices
- Requires internet connectivity and API keys
- Higher latency but significantly better voice quality
- Ideal for important story moments or cutscenes

## Voice Mapping System

The Voice Mapping module (`Modules/TTS/VoiceMapping.lua`) handles:

- Mapping NPC race and gender to appropriate voices
- Modifying voice parameters (pitch, speed) based on race characteristics
- Supporting custom voice assignments for specific NPCs or races
- Providing fallback voices when specific mappings aren't available

### Default Voice Mappings

The default voice mappings try to match appropriate voices to each race:

- Deeper voices for larger races (Tauren, Orcs)
- Higher-pitched voices for smaller races (Gnomes, Goblins)
- Ethereal voices for mystical races (Night Elves, Blood Elves)
- Rougher voices for rugged races (Dwarves, Trolls)

### Voice Modulation

Voice parameters are adjusted based on racial characteristics:

- **Pitch**: Modified to match the physical size and demeanor of races
- **Speed**: Adjusted to match the typical speaking cadence of races
- **Volume**: Standard across races but adjustable by users

## Audio Caching

The Audio Cache module (`Modules/TTS/AudioCache.lua`) implements:

- LRU (Least Recently Used) caching strategy
- Configurable cache size (default: 100 items)
- Automatic cache invalidation for older entries
- Cache hit/miss statistics for performance monitoring

Caching provides significant performance benefits for:
- Repeated NPC dialogue (quest turn-ins, vendors)
- Common emotes and phrases in chat
- Standard system messages

## Integration with Communication Layer

TTS requests follow this flow:

1. Text captured from WoW events (quests, chat)
2. NPC metadata extracted and voice determined
3. Cache checked for existing audio of the phrase
4. If not cached, request sent to companion app
5. TTS processing occurs outside of WoW process
6. Audio data returned and played through companion app
7. Audio data cached for future use

## Configuration Options

Users can configure the TTS system through slash commands or the UI:

- Toggle between local and cloud TTS
- Adjust voice parameters (pitch, speed, volume)
- Set cache size and enable/disable caching
- Create custom voice mappings for races

## Performance Considerations

The TTS system is designed to minimize impact on gameplay:

- Asynchronous processing ensures no game lag
- Audio processing happens in the companion app, not in WoW
- Caching reduces redundant TTS processing
- Automatic throttling during high-activity periods (combat)