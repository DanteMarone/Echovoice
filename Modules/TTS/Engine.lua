-- TTS/Engine.lua
-- TTS Engine management for the Echovoice addon

local ECHOVOICE, Echovoice = ...
local TTSEngine = Echovoice:NewModule("TTSEngine")
local Constants = Echovoice.Constants
local Utils = Echovoice.Utils

-- Engine types
local TTS_ENGINE_LOCAL = 1
local TTS_ENGINE_CLOUD = 2

-- Local variables
local activeEngineType = TTS_ENGINE_LOCAL -- Default to local engine
local engineSettings = {
    local = {
        enabled = true,
        apiKey = nil, -- Local engines don't need API keys
        endpoint = "local://sapi", -- Pseudo URL for the Windows Speech API
        fallbackVoice = "Microsoft David", -- Default fallback voice for Windows SAPI
    },
    cloud = {
        enabled = false,
        apiKey = nil, -- Would be populated from settings
        endpoint = "https://api.tts.cloud/synthesize", -- Example cloud endpoint
        fallbackVoice = "en-US-Neural2-F", -- Example cloud voice ID
    }
}

-- Initialize the module
function TTSEngine:OnInitialize()
    Utils:LogDebug("TTSEngine module initialized")
end

-- Enable the module
function TTSEngine:OnEnable()
    -- Load settings from saved variables
    self:LoadSettings()
    
    Utils:LogDebug("TTSEngine module enabled")
end

-- Disable the module
function TTSEngine:OnDisable()
    Utils:LogDebug("TTSEngine module disabled")
end

-- Load engine settings from saved variables
function TTSEngine:LoadSettings()
    if Echovoice.db and Echovoice.db.profile then
        -- Local TTS settings
        engineSettings.local.enabled = Echovoice.db.profile.tts.useLocal
        
        -- Cloud TTS settings
        engineSettings.cloud.enabled = Echovoice.db.profile.tts.useCloud
        engineSettings.cloud.apiKey = Echovoice.db.profile.tts.cloudApiKey
        
        -- Determine active engine type based on settings
        if engineSettings.local.enabled then
            activeEngineType = TTS_ENGINE_LOCAL
        elseif engineSettings.cloud.enabled then
            activeEngineType = TTS_ENGINE_CLOUD
        else
            -- Default to local if nothing is enabled
            activeEngineType = TTS_ENGINE_LOCAL
            engineSettings.local.enabled = true
        end
    end
end

-- Get the current engine type
function TTSEngine:GetActiveEngineType()
    return activeEngineType
end

-- Set the active engine type
function TTSEngine:SetActiveEngineType(engineType)
    if engineType == TTS_ENGINE_LOCAL then
        activeEngineType = TTS_ENGINE_LOCAL
        engineSettings.local.enabled = true
        
        -- Update saved variables
        if Echovoice.db and Echovoice.db.profile then
            Echovoice.db.profile.tts.useLocal = true
        end
        
        Utils:LogInfo("Switched to local TTS engine")
    elseif engineType == TTS_ENGINE_CLOUD then
        -- Check if cloud TTS is configured
        if not engineSettings.cloud.apiKey then
            Utils:LogWarning("Cloud TTS is not configured (missing API key). Staying with current engine.")
            return false
        end
        
        activeEngineType = TTS_ENGINE_CLOUD
        engineSettings.cloud.enabled = true
        
        -- Update saved variables
        if Echovoice.db and Echovoice.db.profile then
            Echovoice.db.profile.tts.useCloud = true
        end
        
        Utils:LogInfo("Switched to cloud TTS engine")
    else
        Utils:LogError("Unknown engine type: %d", engineType)
        return false
    end
    
    return true
end

-- Process text for TTS conversion
function TTSEngine:ProcessText(text, metadata, callback)
    if not text or text == "" then
        Utils:LogWarning("Empty text passed to TTSEngine:ProcessText")
        return false
    end
    
    -- Determine which engine to use
    if activeEngineType == TTS_ENGINE_LOCAL then
        return self:ProcessLocalTTS(text, metadata, callback)
    elseif activeEngineType == TTS_ENGINE_CLOUD then
        return self:ProcessCloudTTS(text, metadata, callback)
    else
        Utils:LogError("No active TTS engine")
        return false
    end
end

-- Process text with local TTS engine (Windows SAPI)
function TTSEngine:ProcessLocalTTS(text, metadata, callback)
    Utils:LogDebug("Processing text with local TTS engine: %s", text:sub(1, 30) .. "...")
    
    -- In a real implementation, this would send the text to the companion app
    -- for processing with the Windows Speech API
    -- For demonstration purposes, we'll simulate sending to the companion app
    
    -- Prepare voice parameters based on metadata
    local voice = self:DetermineVoice(metadata, TTS_ENGINE_LOCAL)
    local voiceParams = {
        voice = voice,
        volume = Echovoice.db.profile.voice.volume,
        speed = Echovoice.db.profile.voice.speed,
        pitch = Echovoice.db.profile.voice.pitch,
    }
    
    -- Prepare request for companion app
    local request = {
        engineType = "local",
        text = text,
        voice = voiceParams,
        metadata = metadata,
    }
    
    -- Send to communication layer for processing by companion app
    Echovoice.communicationLayer:SendToCompanion("tts_request", request, function(response)
        if callback then
            callback(response.success, response.audioData, response.error)
        end
    end)
    
    return true
end

-- Process text with cloud TTS engine
function TTSEngine:ProcessCloudTTS(text, metadata, callback)
    Utils:LogDebug("Processing text with cloud TTS engine: %s", text:sub(1, 30) .. "...")
    
    -- Check if API key is available
    if not engineSettings.cloud.apiKey then
        Utils:LogError("Cloud TTS API key not configured")
        if callback then
            callback(false, nil, "Cloud TTS API key not configured")
        end
        return false
    end
    
    -- Prepare voice parameters based on metadata
    local voice = self:DetermineVoice(metadata, TTS_ENGINE_CLOUD)
    local voiceParams = {
        voice = voice,
        volume = Echovoice.db.profile.voice.volume,
        speed = Echovoice.db.profile.voice.speed,
        pitch = Echovoice.db.profile.voice.pitch,
    }
    
    -- Prepare request for companion app to send to cloud service
    local request = {
        engineType = "cloud",
        text = text,
        voice = voiceParams,
        metadata = metadata,
        apiKey = engineSettings.cloud.apiKey,
        endpoint = engineSettings.cloud.endpoint,
    }
    
    -- Send to communication layer for processing by companion app
    Echovoice.communicationLayer:SendToCompanion("tts_request", request, function(response)
        if callback then
            callback(response.success, response.audioData, response.error)
        end
    end)
    
    return true
end

-- Determine the voice to use based on metadata
function TTSEngine:DetermineVoice(metadata, engineType)
    -- Default fallback voices
    local fallbackVoice = (engineType == TTS_ENGINE_LOCAL) 
        and engineSettings.local.fallbackVoice 
        or engineSettings.cloud.fallbackVoice
    
    -- If no metadata, return fallback
    if not metadata then
        return fallbackVoice
    end
    
    -- Get race and gender
    local race = metadata.npcRace or "Human"
    local gender = metadata.npcGender or "Male"
    
    -- Pass to voice mapping module to get appropriate voice
    local voice = Echovoice.voiceMapping:GetVoice(race, gender, engineType)
    
    -- If no specific voice found, use fallback
    if not voice then
        voice = fallbackVoice
    end
    
    return voice
end

-- Test function for the TTSEngine module
function TTSEngine:Test()
    Utils:LogInfo("Testing TTSEngine module")
    
    -- Test local TTS
    local testText = "This is a test of the local TTS engine."
    local testMetadata = {
        npcName = "Test NPC",
        npcRace = "Human",
        npcGender = "Male",
    }
    
    Utils:LogInfo("Testing local TTS engine")
    self:SetActiveEngineType(TTS_ENGINE_LOCAL)
    self:ProcessText(testText, testMetadata, function(success, audioData, error)
        Utils:LogInfo("Local TTS test result: %s", success and "SUCCESS" or "FAILED")
        if error then
            Utils:LogError("Error: %s", error)
        end
    end)
    
    -- Only test cloud if API key is configured
    if engineSettings.cloud.apiKey then
        Utils:LogInfo("Testing cloud TTS engine")
        self:SetActiveEngineType(TTS_ENGINE_CLOUD)
        self:ProcessText(testText, testMetadata, function(success, audioData, error)
            Utils:LogInfo("Cloud TTS test result: %s", success and "SUCCESS" or "FAILED")
            if error then
                Utils:LogError("Error: %s", error)
            end
        end)
    else
        Utils:LogInfo("Skipping cloud TTS test (no API key configured)")
    end
    
    -- Reset to default engine
    self:SetActiveEngineType(TTS_ENGINE_LOCAL)
    
    Utils:LogInfo("TTSEngine test complete")
    return true
end