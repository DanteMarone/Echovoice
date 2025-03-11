-- Core.lua
-- Main addon functionality for Echovoice

local ECHOVOICE, Echovoice = ...
local Constants = Echovoice.Constants
local Utils = Echovoice.Utils

-- Initialize Ace3 libraries
Echovoice = LibStub("AceAddon-3.0"):NewAddon(Echovoice, Constants.ADDON_NAME, "AceConsole-3.0", "AceEvent-3.0")

-- Default configuration options
local defaults = {
    profile = {
        enabled = true,
        questNarration = true,
        chatNarration = false,
        debug = {
            level = Constants.DEBUG_LEVELS.ERROR,
        },
        voice = {
            volume = 1.0,
            speed = 1.0,
            pitch = 1.0,
        },
        tts = {
            useLocal = true, -- Use local TTS by default
            useCloud = false, -- Cloud TTS is off by default
            cloudApiKey = "", -- API key for cloud TTS service
            cloudEndpoint = "https://api.tts.cloud/synthesize", -- Default cloud endpoint
            cacheEnabled = true,
            cacheSize = 100, -- Number of cached phrases
            autoFallback = true, -- Automatically fall back to local TTS if cloud fails
        },
        customVoices = {}, -- Custom voice mappings by race/gender
        filters = {
            quest = {
                ignoreRepeatableQuests = false,
                ignoreQuestProgress = false,
            },
            chat = {
                enableSay = true,
                enableYell = true,
                enableWhisper = true,
                enableParty = true,
                enableRaid = false,
                enableGuild = false,
                enableOfficer = false,
                enableEmote = false,
            },
        },
    },
}

-- Module references
Echovoice.eventHandler = nil
Echovoice.metadataExtractor = nil
Echovoice.communicationLayer = nil
Echovoice.ttsEngine = nil
Echovoice.voiceMapping = nil
Echovoice.audioCache = nil

-- OnInitialize: Called when the addon is loaded
function Echovoice:OnInitialize()
    -- Initialize database
    self.db = LibStub("AceDB-3.0"):New("EchovoiceDB", defaults, true)
    
    -- Set debug level from saved settings
    Utils:SetDebugLevel(self.db.profile.debug.level)
    
    -- Register slash commands
    self:RegisterChatCommand("echovoice", "HandleSlashCommand")
    self:RegisterChatCommand("ev", "HandleSlashCommand")
    
    Utils:LogInfo("Echovoice version %s initialized.", Constants.ADDON_VERSION)
end

-- OnEnable: Called when the addon is enabled
function Echovoice:OnEnable()
    -- Initialize modules
    self.eventHandler = self:GetModule("EventHandler")
    self.metadataExtractor = self:GetModule("MetadataExtractor")
    self.communicationLayer = self:GetModule("CommunicationLayer")
    self.ttsEngine = self:GetModule("TTSEngine")
    self.voiceMapping = self:GetModule("VoiceMapping")
    self.audioCache = self:GetModule("AudioCache")
    
    -- Enable TTS modules first since other modules depend on them
    if self.audioCache then self.audioCache:Enable() end
    if self.voiceMapping then self.voiceMapping:Enable() end
    if self.ttsEngine then self.ttsEngine:Enable() end
    
    -- Enable remaining modules
    if self.communicationLayer then self.communicationLayer:Enable() end
    if self.metadataExtractor then self.metadataExtractor:Enable() end
    if self.eventHandler then self.eventHandler:Enable() end
    
    Utils:LogInfo("Echovoice enabled.")
end

-- OnDisable: Called when the addon is disabled
function Echovoice:OnDisable()
    -- Disable modules in reverse order of enabling
    if self.eventHandler then self.eventHandler:Disable() end
    if self.metadataExtractor then self.metadataExtractor:Disable() end
    if self.communicationLayer then self.communicationLayer:Disable() end
    if self.ttsEngine then self.ttsEngine:Disable() end
    if self.voiceMapping then self.voiceMapping:Disable() end
    if self.audioCache then self.audioCache:Disable() end
    
    Utils:LogInfo("Echovoice disabled.")
end

-- HandleSlashCommand: Process slash commands
function Echovoice:HandleSlashCommand(input)
    if not input or input:trim() == "" then
        -- Show options panel if no arguments
        self:OpenConfigUI()
        return
    end
    
    local command, args = self:GetArgs(input, 2)
    command = command and command:lower() or ""
    
    if command == "toggle" then
        self.db.profile.enabled = not self.db.profile.enabled
        if self.db.profile.enabled then
            self:OnEnable()
            Utils:LogInfo("Echovoice enabled.")
        else
            self:OnDisable()
            Utils:LogInfo("Echovoice disabled.")
        end
    elseif command == "quest" then
        self.db.profile.questNarration = not self.db.profile.questNarration
        Utils:LogInfo("Quest narration %s.", self.db.profile.questNarration and "enabled" or "disabled")
    elseif command == "chat" then
        self.db.profile.chatNarration = not self.db.profile.chatNarration
        Utils:LogInfo("Chat narration %s.", self.db.profile.chatNarration and "enabled" or "disabled")
    elseif command == "debug" then
        local level = tonumber(args) or Constants.DEBUG_LEVELS.INFO
        self.db.profile.debug.level = level
        Utils:SetDebugLevel(level)
        Utils:LogInfo("Debug level set to %d.", level)
    elseif command == "test" then
        self:Test()
    elseif command == "help" then
        self:PrintHelp()
    else
        Utils:LogInfo("Unknown command: %s. Type '/ev help' for available commands.", command)
    end
end

-- PrintHelp: Show available slash commands
function Echovoice:PrintHelp()
    print("|cFF00CCFF[Echovoice]|r Command Help:")
    print("  /echovoice OR /ev - Open configuration panel")
    print("  /ev toggle - Toggle addon on/off")
    print("  /ev quest - Toggle quest narration")
    print("  /ev chat - Toggle chat narration")
    print("  /ev debug [level] - Set debug level (0-5)")
    print("  /ev test - Run test function")
    print("  /ev help - Show this help")
end

-- OpenConfigUI: Open the configuration UI
function Echovoice:OpenConfigUI()
    Utils:LogInfo("Configuration UI not yet implemented.")
    -- Will be implemented in Phase 5
end

-- Test: Run test function for debugging
function Echovoice:Test()
    Utils:LogInfo("Running Echovoice test...")
    
    -- Test TTS modules
    if self.audioCache then
        Utils:LogInfo("Testing AudioCache module...")
        self.audioCache:Test()
    end
    
    if self.voiceMapping then
        Utils:LogInfo("Testing VoiceMapping module...")
        self.voiceMapping:Test()
    end
    
    if self.ttsEngine then
        Utils:LogInfo("Testing TTSEngine module...")
        self.ttsEngine:Test()
    end
    
    -- Test other modules
    if self.communicationLayer then
        Utils:LogInfo("Testing CommunicationLayer module...")
        self.communicationLayer:Test()
    end
    
    if self.metadataExtractor then
        Utils:LogInfo("Testing MetadataExtractor module...")
        self.metadataExtractor:Test()
    end
    
    if self.eventHandler then
        Utils:LogInfo("Testing EventHandler module...")
        self.eventHandler:Test()
    end
    
    Utils:LogInfo("Test complete.")
end

-- Debug: Run debug function
function Echovoice:Debug()
    local oldLevel = self.db.profile.debug.level
    Utils:SetDebugLevel(Constants.DEBUG_LEVELS.DEBUG)
    Utils:LogInfo("Running Echovoice debug...")
    
    Utils:LogDebug("Current config: %s", self.db.profile)
    
    -- Reset debug level to previous
    Utils:SetDebugLevel(oldLevel)
end