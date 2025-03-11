-- TTS/VoiceMapping.lua
-- Maps NPC metadata to specific voice parameters

local ECHOVOICE, Echovoice = ...
local VoiceMapping = Echovoice:NewModule("VoiceMapping")
local Constants = Echovoice.Constants
local Utils = Echovoice.Utils

-- Engine types
local TTS_ENGINE_LOCAL = 1
local TTS_ENGINE_CLOUD = 2

-- Voice maps by engine type
local voiceMaps = {
    -- Local (Windows SAPI) voices
    [TTS_ENGINE_LOCAL] = {
        -- Male voices by race
        Male = {
            ["Human"] = "Microsoft David",
            ["Dwarf"] = "Microsoft Mark",
            ["NightElf"] = "Microsoft David",
            ["Gnome"] = "Microsoft Mark",
            ["Draenei"] = "Microsoft David",
            ["Worgen"] = "Microsoft Mark",
            ["Orc"] = "Microsoft Mark",
            ["Undead"] = "Microsoft David",
            ["Tauren"] = "Microsoft Mark",
            ["Troll"] = "Microsoft David",
            ["BloodElf"] = "Microsoft David",
            ["Goblin"] = "Microsoft Mark",
            ["Pandaren"] = "Microsoft David",
            -- Add other races as needed
            -- Default for unspecified races
            ["Default"] = "Microsoft David",
        },
        -- Female voices by race
        Female = {
            ["Human"] = "Microsoft Zira",
            ["Dwarf"] = "Microsoft Zira",
            ["NightElf"] = "Microsoft Zira",
            ["Gnome"] = "Microsoft Zira",
            ["Draenei"] = "Microsoft Zira",
            ["Worgen"] = "Microsoft Zira",
            ["Orc"] = "Microsoft Zira",
            ["Undead"] = "Microsoft Zira",
            ["Tauren"] = "Microsoft Zira",
            ["Troll"] = "Microsoft Zira",
            ["BloodElf"] = "Microsoft Zira",
            ["Goblin"] = "Microsoft Zira",
            ["Pandaren"] = "Microsoft Zira",
            -- Add other races as needed
            -- Default for unspecified races
            ["Default"] = "Microsoft Zira",
        },
        -- Neutral voices (for non-gendered NPCs)
        Neutral = {
            ["Default"] = "Microsoft David",
        },
    },
    
    -- Cloud-based TTS voices (examples, would depend on the service used)
    [TTS_ENGINE_CLOUD] = {
        -- Male voices by race
        Male = {
            ["Human"] = "en-US-Neural2-D",
            ["Dwarf"] = "en-US-Neural2-A",
            ["NightElf"] = "en-US-Neural2-F",
            ["Gnome"] = "en-US-Neural2-A",
            ["Draenei"] = "en-US-Neural2-D",
            ["Worgen"] = "en-US-Neural2-A",
            ["Orc"] = "en-US-Neural2-I",
            ["Undead"] = "en-US-Neural2-D",
            ["Tauren"] = "en-US-Neural2-I",
            ["Troll"] = "en-US-Neural2-A",
            ["BloodElf"] = "en-US-Neural2-D",
            ["Goblin"] = "en-US-Neural2-A",
            ["Pandaren"] = "en-US-Neural2-D",
            -- Add other races as needed
            -- Default for unspecified races
            ["Default"] = "en-US-Neural2-D",
        },
        -- Female voices by race
        Female = {
            ["Human"] = "en-US-Neural2-F",
            ["Dwarf"] = "en-US-Neural2-E",
            ["NightElf"] = "en-US-Neural2-F",
            ["Gnome"] = "en-US-Neural2-E",
            ["Draenei"] = "en-US-Neural2-F",
            ["Worgen"] = "en-US-Neural2-E",
            ["Orc"] = "en-US-Neural2-E",
            ["Undead"] = "en-US-Neural2-F",
            ["Tauren"] = "en-US-Neural2-E",
            ["Troll"] = "en-US-Neural2-F",
            ["BloodElf"] = "en-US-Neural2-F",
            ["Goblin"] = "en-US-Neural2-E",
            ["Pandaren"] = "en-US-Neural2-F",
            -- Add other races as needed
            -- Default for unspecified races
            ["Default"] = "en-US-Neural2-F",
        },
        -- Neutral voices (for non-gendered NPCs)
        Neutral = {
            ["Default"] = "en-US-Neural2-D",
        },
    },
}

-- Voice modulation parameters by race
local voiceModulationParams = {
    -- Pitch modifiers by race (multiplier for base pitch)
    pitch = {
        ["Human"] = 1.0,
        ["Dwarf"] = 0.9,
        ["NightElf"] = 1.1,
        ["Gnome"] = 1.3,
        ["Draenei"] = 0.95,
        ["Worgen"] = 0.85,
        ["Orc"] = 0.8,
        ["Undead"] = 0.9,
        ["Tauren"] = 0.7,
        ["Troll"] = 0.9,
        ["BloodElf"] = 1.1,
        ["Goblin"] = 1.2,
        ["Pandaren"] = 1.0,
        -- Default for unspecified races
        ["Default"] = 1.0,
    },
    
    -- Speed modifiers by race (multiplier for base speed)
    speed = {
        ["Human"] = 1.0,
        ["Dwarf"] = 0.9,
        ["NightElf"] = 1.1,
        ["Gnome"] = 1.2,
        ["Draenei"] = 0.9,
        ["Worgen"] = 1.0,
        ["Orc"] = 0.9,
        ["Undead"] = 0.8,
        ["Tauren"] = 0.8,
        ["Troll"] = 0.9,
        ["BloodElf"] = 1.1,
        ["Goblin"] = 1.3,
        ["Pandaren"] = 0.9,
        -- Default for unspecified races
        ["Default"] = 1.0,
    },
}

-- Custom voice mappings (user-defined)
local customVoiceMappings = {}

-- Initialize the module
function VoiceMapping:OnInitialize()
    Utils:LogDebug("VoiceMapping module initialized")
end

-- Enable the module
function VoiceMapping:OnEnable()
    -- Load custom voice mappings from saved variables
    self:LoadCustomMappings()
    
    Utils:LogDebug("VoiceMapping module enabled")
end

-- Disable the module
function VoiceMapping:OnDisable()
    Utils:LogDebug("VoiceMapping module disabled")
end

-- Load custom voice mappings from saved variables
function VoiceMapping:LoadCustomMappings()
    if Echovoice.db and Echovoice.db.profile and Echovoice.db.profile.customVoices then
        customVoiceMappings = Utils:DeepCopy(Echovoice.db.profile.customVoices)
        Utils:LogDebug("Loaded %d custom voice mappings", #customVoiceMappings)
    end
end

-- Get voice for a given race and gender
function VoiceMapping:GetVoice(race, gender, engineType)
    -- Default to local engine if not specified
    engineType = engineType or TTS_ENGINE_LOCAL
    
    -- Check parameters
    if not race or not gender then
        Utils:LogWarning("Missing race or gender in GetVoice call")
        race = "Human"
        gender = "Male"
    end
    
    -- First, check for a custom mapping
    local customVoice = self:GetCustomVoice(race, gender, engineType)
    if customVoice then
        return customVoice
    end
    
    -- Get the appropriate voice map
    local voiceMap = voiceMaps[engineType]
    if not voiceMap then
        Utils:LogError("No voice map for engine type: %d", engineType)
        return nil
    end
    
    -- Get gender-specific voice map
    local genderMap = voiceMap[gender]
    if not genderMap then
        Utils:LogWarning("No voice map for gender: %s, using default", gender)
        genderMap = voiceMap["Male"] -- Default to male voices
    end
    
    -- Get race-specific voice
    local voice = genderMap[race]
    if not voice then
        Utils:LogWarning("No voice for race: %s, using default", race)
        voice = genderMap["Default"]
    end
    
    return voice
end

-- Get a custom voice mapping if one exists
function VoiceMapping:GetCustomVoice(race, gender, engineType)
    -- Check for a custom mapping that matches the criteria
    for _, mapping in ipairs(customVoiceMappings) do
        if mapping.race == race and 
           mapping.gender == gender and 
           mapping.engineType == engineType then
            return mapping.voice
        end
    end
    
    return nil
end

-- Add a custom voice mapping
function VoiceMapping:AddCustomVoice(race, gender, engineType, voice)
    -- Validate parameters
    if not race or not gender or not engineType or not voice then
        Utils:LogError("Missing parameters in AddCustomVoice call")
        return false
    end
    
    -- Check if mapping already exists
    for i, mapping in ipairs(customVoiceMappings) do
        if mapping.race == race and 
           mapping.gender == gender and 
           mapping.engineType == engineType then
            -- Update existing mapping
            mapping.voice = voice
            Utils:LogInfo("Updated custom voice mapping for %s %s to %s", race, gender, voice)
            
            -- Save to profile
            if Echovoice.db and Echovoice.db.profile then
                Echovoice.db.profile.customVoices = Utils:DeepCopy(customVoiceMappings)
            end
            
            return true
        end
    end
    
    -- Add new mapping
    table.insert(customVoiceMappings, {
        race = race,
        gender = gender,
        engineType = engineType,
        voice = voice,
    })
    
    Utils:LogInfo("Added custom voice mapping for %s %s: %s", race, gender, voice)
    
    -- Save to profile
    if Echovoice.db and Echovoice.db.profile then
        Echovoice.db.profile.customVoices = Utils:DeepCopy(customVoiceMappings)
    end
    
    return true
end

-- Remove a custom voice mapping
function VoiceMapping:RemoveCustomVoice(race, gender, engineType)
    -- Validate parameters
    if not race or not gender or not engineType then
        Utils:LogError("Missing parameters in RemoveCustomVoice call")
        return false
    end
    
    -- Find and remove mapping
    for i, mapping in ipairs(customVoiceMappings) do
        if mapping.race == race and 
           mapping.gender == gender and 
           mapping.engineType == engineType then
            -- Remove mapping
            table.remove(customVoiceMappings, i)
            Utils:LogInfo("Removed custom voice mapping for %s %s", race, gender)
            
            -- Save to profile
            if Echovoice.db and Echovoice.db.profile then
                Echovoice.db.profile.customVoices = Utils:DeepCopy(customVoiceMappings)
            end
            
            return true
        end
    end
    
    Utils:LogWarning("No custom voice mapping found for %s %s", race, gender)
    return false
end

-- Get modulation parameters for a race
function VoiceMapping:GetModulationParams(race)
    -- Default if race not specified
    race = race or "Human"
    
    -- Get pitch modifier
    local pitchMod = voiceModulationParams.pitch[race]
    if not pitchMod then
        pitchMod = voiceModulationParams.pitch["Default"]
    end
    
    -- Get speed modifier
    local speedMod = voiceModulationParams.speed[race]
    if not speedMod then
        speedMod = voiceModulationParams.speed["Default"]
    end
    
    return {
        pitch = pitchMod,
        speed = speedMod,
    }
end

-- Get a list of available voices for an engine type
function VoiceMapping:GetAvailableVoices(engineType)
    -- This would be implemented to query the companion app for available voices
    -- For demonstration, we'll return a static list
    
    if engineType == TTS_ENGINE_LOCAL then
        return {
            "Microsoft David",
            "Microsoft Mark",
            "Microsoft Zira",
            -- Additional voices would be detected from the system
        }
    elseif engineType == TTS_ENGINE_CLOUD then
        return {
            "en-US-Neural2-A",
            "en-US-Neural2-D",
            "en-US-Neural2-E",
            "en-US-Neural2-F",
            "en-US-Neural2-I",
            -- Additional voices would depend on the cloud service
        }
    else
        Utils:LogError("Unknown engine type: %d", engineType)
        return {}
    end
end

-- Test function for the VoiceMapping module
function VoiceMapping:Test()
    Utils:LogInfo("Testing VoiceMapping module")
    
    -- Test some voice mappings
    local races = {"Human", "Dwarf", "Orc", "Undead", "Tauren", "NonExistentRace"}
    local genders = {"Male", "Female"}
    
    for _, race in ipairs(races) do
        for _, gender in ipairs(genders) do
            local localVoice = self:GetVoice(race, gender, TTS_ENGINE_LOCAL)
            local cloudVoice = self:GetVoice(race, gender, TTS_ENGINE_CLOUD)
            
            Utils:LogInfo("%s %s: Local=%s, Cloud=%s", 
                         race, gender, localVoice or "None", cloudVoice or "None")
        end
    end
    
    -- Test modulation parameters
    for _, race in ipairs(races) do
        local params = self:GetModulationParams(race)
        Utils:LogInfo("%s modulation: Pitch=%.2f, Speed=%.2f", 
                     race, params.pitch, params.speed)
    end
    
    -- Test custom voice mappings
    self:AddCustomVoice("TestRace", "Male", TTS_ENGINE_LOCAL, "CustomVoice")
    local customVoice = self:GetVoice("TestRace", "Male", TTS_ENGINE_LOCAL)
    Utils:LogInfo("Custom voice test: %s", customVoice == "CustomVoice" and "PASSED" or "FAILED")
    
    -- Cleanup test data
    self:RemoveCustomVoice("TestRace", "Male", TTS_ENGINE_LOCAL)
    
    Utils:LogInfo("VoiceMapping test complete")
    return true
end