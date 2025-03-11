-- UI/VoiceCommands.lua
-- Voice command integration for Echovoice

local ECHOVOICE, Echovoice = ...
local VoiceCommands = Echovoice:NewModule("VoiceCommands", "AceConsole-3.0")
local Constants = Echovoice.Constants
local Utils = Echovoice.Utils

-- Local variables
local isListening = false
local commandsEnabled = false

-- Initialize the module
function VoiceCommands:OnInitialize()
    Utils:LogDebug("VoiceCommands module initialized")
    
    -- Voice commands require the companion app
    -- This is a placeholder since the actual voice recognition would be handled there
end

-- Enable the module
function VoiceCommands:OnEnable()
    -- Load settings
    commandsEnabled = Echovoice.db.profile.accessibility.voiceCommands
    
    if commandsEnabled then
        self:StartListening()
    end
    
    Utils:LogDebug("VoiceCommands module enabled")
end

-- Disable the module
function VoiceCommands:OnDisable()
    self:StopListening()
    
    Utils:LogDebug("VoiceCommands module disabled")
end

-- Start listening for voice commands
function VoiceCommands:StartListening()
    if isListening or not commandsEnabled then
        return
    end
    
    -- In a real implementation, this would communicate with the companion app
    -- to start voice recognition
    
    isListening = true
    Utils:LogInfo("Voice command recognition started")
    
    -- Notify the user
    if Echovoice.subtitleUI then
        Echovoice.subtitleUI:DisplaySubtitle("Voice command recognition activated", "System", 3)
    end
end

-- Stop listening for voice commands
function VoiceCommands:StopListening()
    if not isListening then
        return
    end
    
    -- In a real implementation, this would communicate with the companion app
    -- to stop voice recognition
    
    isListening = false
    Utils:LogInfo("Voice command recognition stopped")
    
    -- Notify the user
    if Echovoice.subtitleUI then
        Echovoice.subtitleUI:DisplaySubtitle("Voice command recognition deactivated", "System", 3)
    end
end

-- Process a voice command
function VoiceCommands:ProcessCommand(command)
    if not commandsEnabled or not isListening then
        return
    end
    
    Utils:LogInfo("Processing voice command: %s", command)
    
    -- Convert to lowercase for easier matching
    command = command:lower()
    
    -- Handle different commands
    if command:match("pause") or command:match("stop") then
        Utils:LogInfo("Pausing narration")
        -- Logic to pause narration
        
        -- Notify the user
        if Echovoice.subtitleUI then
            Echovoice.subtitleUI:DisplaySubtitle("Narration paused", "System", 2)
        end
    elseif command:match("resume") or command:match("continue") or command:match("play") then
        Utils:LogInfo("Resuming narration")
        -- Logic to resume narration
        
        -- Notify the user
        if Echovoice.subtitleUI then
            Echovoice.subtitleUI:DisplaySubtitle("Narration resumed", "System", 2)
        end
    elseif command:match("repeat") then
        Utils:LogInfo("Repeating last narration")
        -- Logic to repeat last narration
        
        -- Notify the user
        if Echovoice.subtitleUI then
            Echovoice.subtitleUI:DisplaySubtitle("Repeating last narration", "System", 2)
        end
    elseif command:match("skip") or command:match("next") then
        Utils:LogInfo("Skipping current narration")
        -- Logic to skip current narration
        
        -- Notify the user
        if Echovoice.subtitleUI then
            Echovoice.subtitleUI:DisplaySubtitle("Skipping current narration", "System", 2)
        end
    elseif command:match("slower") then
        Utils:LogInfo("Decreasing voice speed")
        -- Decrease speed
        Echovoice.db.profile.voice.speed = math.max(0.5, Echovoice.db.profile.voice.speed - 0.1)
        
        -- Notify the user
        if Echovoice.subtitleUI then
            Echovoice.subtitleUI:DisplaySubtitle("Voice speed decreased to " .. math.floor(Echovoice.db.profile.voice.speed * 100) .. "%", "System", 2)
        end
    elseif command:match("faster") then
        Utils:LogInfo("Increasing voice speed")
        -- Increase speed
        Echovoice.db.profile.voice.speed = math.min(2.0, Echovoice.db.profile.voice.speed + 0.1)
        
        -- Notify the user
        if Echovoice.subtitleUI then
            Echovoice.subtitleUI:DisplaySubtitle("Voice speed increased to " .. math.floor(Echovoice.db.profile.voice.speed * 100) .. "%", "System", 2)
        end
    elseif command:match("louder") then
        Utils:LogInfo("Increasing voice volume")
        -- Increase volume
        Echovoice.db.profile.voice.volume = math.min(1.0, Echovoice.db.profile.voice.volume + 0.1)
        
        -- Notify the user
        if Echovoice.subtitleUI then
            Echovoice.subtitleUI:DisplaySubtitle("Voice volume increased to " .. math.floor(Echovoice.db.profile.voice.volume * 100) .. "%", "System", 2)
        end
    elseif command:match("quieter") then
        Utils:LogInfo("Decreasing voice volume")
        -- Decrease volume
        Echovoice.db.profile.voice.volume = math.max(0.1, Echovoice.db.profile.voice.volume - 0.1)
        
        -- Notify the user
        if Echovoice.subtitleUI then
            Echovoice.subtitleUI:DisplaySubtitle("Voice volume decreased to " .. math.floor(Echovoice.db.profile.voice.volume * 100) .. "%", "System", 2)
        end
    elseif command:match("disable") or command:match("turn off") then
        Utils:LogInfo("Disabling voice commands")
        -- Disable voice commands
        Echovoice.db.profile.accessibility.voiceCommands = false
        commandsEnabled = false
        self:StopListening()
        
        -- Notify the user
        if Echovoice.subtitleUI then
            Echovoice.subtitleUI:DisplaySubtitle("Voice commands disabled", "System", 2)
        end
    else
        Utils:LogWarning("Unknown voice command: %s", command)
        
        -- Notify the user
        if Echovoice.subtitleUI then
            Echovoice.subtitleUI:DisplaySubtitle("Unknown voice command: " .. command, "System", 2)
        end
    end
end

-- Simulate receiving a command from the companion app
function VoiceCommands:ReceiveCommand(command)
    -- This would be called when the companion app detects a voice command
    self:ProcessCommand(command)
end

-- Test function for the VoiceCommands module
function VoiceCommands:Test()
    Utils:LogInfo("Testing VoiceCommands module")
    
    -- Enable voice commands if not already enabled
    local wasEnabled = Echovoice.db.profile.accessibility.voiceCommands
    Echovoice.db.profile.accessibility.voiceCommands = true
    commandsEnabled = true
    
    -- Start listening
    self:StartListening()
    
    -- Simulate receiving commands
    C_Timer.After(1, function()
        self:ReceiveCommand("pause")
    end)
    
    C_Timer.After(2, function()
        self:ReceiveCommand("louder")
    end)
    
    C_Timer.After(3, function()
        self:ReceiveCommand("faster")
    end)
    
    C_Timer.After(4, function()
        self:ReceiveCommand("resume")
    end)
    
    -- Restore previous settings
    C_Timer.After(5, function()
        Echovoice.db.profile.accessibility.voiceCommands = wasEnabled
        if not wasEnabled then
            self:StopListening()
        end
    end)
    
    Utils:LogInfo("VoiceCommands test complete")
    return true
end