-- UI/ConfigUI.lua
-- Configuration UI for Echovoice addon

local ECHOVOICE, Echovoice = ...
local ConfigUI = Echovoice:NewModule("ConfigUI", "AceConsole-3.0")
local Constants = Echovoice.Constants
local Utils = Echovoice.Utils

-- Local references to commonly used UI libraries
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceDBOptions = LibStub("AceDBOptions-3.0")

-- Initialize the module
function ConfigUI:OnInitialize()
    -- Create configuration options
    self:CreateConfig()
    
    -- Register slash command for opening the config
    self:RegisterChatCommand("evconfig", "OpenConfig")
    
    Utils:LogDebug("ConfigUI module initialized")
end

-- Enable the module
function ConfigUI:OnEnable()
    Utils:LogDebug("ConfigUI module enabled")
end

-- Disable the module
function ConfigUI:OnDisable()
    Utils:LogDebug("ConfigUI module disabled")
end

-- Open the configuration UI
function ConfigUI:OpenConfig(input)
    -- Handle input for specific panels
    if input and input:trim() ~= "" then
        AceConfigDialog:SelectGroup("Echovoice", strsplit(" ", input))
    end
    
    -- Open the main config dialog
    AceConfigDialog:Open("Echovoice")
end

-- Create the configuration options
function ConfigUI:CreateConfig()
    -- Main options table
    local options = {
        name = "Echovoice",
        type = "group",
        args = {
            general = {
                order = 1,
                type = "group",
                name = "General",
                desc = "General settings for Echovoice",
                args = {
                    header1 = {
                        order = 1,
                        type = "header",
                        name = "General Settings",
                    },
                    enabled = {
                        order = 2,
                        type = "toggle",
                        name = "Enable Echovoice",
                        desc = "Enable or disable the addon's functionality",
                        width = "full",
                        get = function() return Echovoice.db.profile.enabled end,
                        set = function(_, value)
                            Echovoice.db.profile.enabled = value
                            if value then
                                Echovoice:OnEnable()
                            else
                                Echovoice:OnDisable()
                            end
                        end,
                    },
                    questNarration = {
                        order = 3,
                        type = "toggle",
                        name = "Quest Narration",
                        desc = "Enable text-to-speech for quest dialogues",
                        width = "full",
                        get = function() return Echovoice.db.profile.questNarration end,
                        set = function(_, value)
                            Echovoice.db.profile.questNarration = value
                            -- Refresh event hooks if module exists
                            if Echovoice.eventHandler then
                                Echovoice.eventHandler:RegisterEvents()
                            end
                        end,
                        disabled = function() return not Echovoice.db.profile.enabled end,
                    },
                    chatNarration = {
                        order = 4,
                        type = "toggle",
                        name = "Chat Narration",
                        desc = "Enable text-to-speech for chat messages",
                        width = "full",
                        get = function() return Echovoice.db.profile.chatNarration end,
                        set = function(_, value)
                            Echovoice.db.profile.chatNarration = value
                            -- Refresh event hooks if module exists
                            if Echovoice.eventHandler then
                                Echovoice.eventHandler:RegisterEvents()
                            end
                        end,
                        disabled = function() return not Echovoice.db.profile.enabled end,
                    },
                    header2 = {
                        order = 5,
                        type = "header",
                        name = "Voice Settings",
                    },
                    volume = {
                        order = 6,
                        type = "range",
                        name = "Volume",
                        desc = "Adjust the volume of the text-to-speech voice",
                        min = 0.1,
                        max = 1.0,
                        step = 0.1,
                        get = function() return Echovoice.db.profile.voice.volume end,
                        set = function(_, value) Echovoice.db.profile.voice.volume = value end,
                        disabled = function() return not Echovoice.db.profile.enabled end,
                    },
                    speed = {
                        order = 7,
                        type = "range",
                        name = "Speed",
                        desc = "Adjust the speed of the text-to-speech voice",
                        min = 0.5,
                        max = 2.0,
                        step = 0.1,
                        get = function() return Echovoice.db.profile.voice.speed end,
                        set = function(_, value) Echovoice.db.profile.voice.speed = value end,
                        disabled = function() return not Echovoice.db.profile.enabled end,
                    },
                    pitch = {
                        order = 8,
                        type = "range",
                        name = "Pitch",
                        desc = "Adjust the pitch of the text-to-speech voice",
                        min = 0.5,
                        max = 2.0,
                        step = 0.1,
                        get = function() return Echovoice.db.profile.voice.pitch end,
                        set = function(_, value) Echovoice.db.profile.voice.pitch = value end,
                        disabled = function() return not Echovoice.db.profile.enabled end,
                    },
                },
            },
            tts = {
                order = 2,
                type = "group",
                name = "TTS Settings",
                desc = "Configure the text-to-speech engine",
                args = {
                    header1 = {
                        order = 1,
                        type = "header",
                        name = "TTS Engine Settings",
                    },
                    useLocal = {
                        order = 2,
                        type = "toggle",
                        name = "Use Local TTS",
                        desc = "Use local text-to-speech engine (requires companion app)",
                        width = "full",
                        get = function() return Echovoice.db.profile.tts.useLocal end,
                        set = function(_, value) 
                            Echovoice.db.profile.tts.useLocal = value 
                            -- Update TTS engine if module exists
                            if Echovoice.ttsEngine then
                                Echovoice.ttsEngine:LoadSettings()
                            end
                        end,
                        disabled = function() return not Echovoice.db.profile.enabled end,
                    },
                    useCloud = {
                        order = 3,
                        type = "toggle",
                        name = "Use Cloud TTS",
                        desc = "Use cloud-based text-to-speech engine for higher quality (requires API key)",
                        width = "full",
                        get = function() return Echovoice.db.profile.tts.useCloud end,
                        set = function(_, value) 
                            Echovoice.db.profile.tts.useCloud = value 
                            -- Update TTS engine if module exists
                            if Echovoice.ttsEngine then
                                Echovoice.ttsEngine:LoadSettings()
                            end
                        end,
                        disabled = function() return not Echovoice.db.profile.enabled end,
                    },
                    cloudApiKey = {
                        order = 4,
                        type = "input",
                        name = "Cloud API Key",
                        desc = "API key for cloud-based text-to-speech service",
                        width = "full",
                        get = function() return Echovoice.db.profile.tts.cloudApiKey end,
                        set = function(_, value) 
                            Echovoice.db.profile.tts.cloudApiKey = value 
                            -- Update TTS engine if module exists
                            if Echovoice.ttsEngine then
                                Echovoice.ttsEngine:LoadSettings()
                            end
                        end,
                        disabled = function() return not Echovoice.db.profile.enabled or not Echovoice.db.profile.tts.useCloud end,
                    },
                    autoFallback = {
                        order = 5,
                        type = "toggle",
                        name = "Auto Fallback",
                        desc = "Automatically fall back to local TTS if cloud TTS fails",
                        width = "full",
                        get = function() return Echovoice.db.profile.tts.autoFallback end,
                        set = function(_, value) Echovoice.db.profile.tts.autoFallback = value end,
                        disabled = function() return not Echovoice.db.profile.enabled or not Echovoice.db.profile.tts.useCloud end,
                    },
                    header2 = {
                        order = 6,
                        type = "header",
                        name = "Cache Settings",
                    },
                    cacheEnabled = {
                        order = 7,
                        type = "toggle",
                        name = "Enable Cache",
                        desc = "Cache speech audio to reduce processing time for repeated phrases",
                        width = "full",
                        get = function() return Echovoice.db.profile.tts.cacheEnabled end,
                        set = function(_, value) 
                            Echovoice.db.profile.tts.cacheEnabled = value 
                            -- Update cache settings if module exists
                            if Echovoice.audioCache then
                                Echovoice.audioCache:LoadSettings()
                            end
                        end,
                        disabled = function() return not Echovoice.db.profile.enabled end,
                    },
                    cacheSize = {
                        order = 8,
                        type = "range",
                        name = "Cache Size",
                        desc = "Number of phrases to keep in the cache",
                        min = 10,
                        max = 500,
                        step = 10,
                        get = function() return Echovoice.db.profile.tts.cacheSize end,
                        set = function(_, value) 
                            Echovoice.db.profile.tts.cacheSize = value 
                            -- Update cache settings if module exists
                            if Echovoice.audioCache then
                                Echovoice.audioCache:SetCacheSize(value)
                            end
                        end,
                        disabled = function() return not Echovoice.db.profile.enabled or not Echovoice.db.profile.tts.cacheEnabled end,
                    },
                    clearCache = {
                        order = 9,
                        type = "execute",
                        name = "Clear Cache",
                        desc = "Clear all cached audio data",
                        func = function()
                            if Echovoice.audioCache then
                                Echovoice.audioCache:Clear()
                                Utils:LogInfo("Audio cache cleared")
                            end
                        end,
                        disabled = function() return not Echovoice.db.profile.enabled or not Echovoice.db.profile.tts.cacheEnabled end,
                    },
                },
            },
            filters = {
                order = 3,
                type = "group",
                name = "Filters",
                desc = "Configure what text gets narrated",
                args = {
                    header1 = {
                        order = 1,
                        type = "header",
                        name = "Quest Filters",
                    },
                    ignoreRepeatableQuests = {
                        order = 2,
                        type = "toggle",
                        name = "Ignore Repeatable Quests",
                        desc = "Do not narrate repeatable quest text",
                        width = "full",
                        get = function() return Echovoice.db.profile.filters.quest.ignoreRepeatableQuests end,
                        set = function(_, value) Echovoice.db.profile.filters.quest.ignoreRepeatableQuests = value end,
                        disabled = function() return not Echovoice.db.profile.enabled or not Echovoice.db.profile.questNarration end,
                    },
                    ignoreQuestProgress = {
                        order = 3,
                        type = "toggle",
                        name = "Ignore Quest Progress",
                        desc = "Do not narrate quest progress text (only narrate initial quest text and turn-in text)",
                        width = "full",
                        get = function() return Echovoice.db.profile.filters.quest.ignoreQuestProgress end,
                        set = function(_, value) Echovoice.db.profile.filters.quest.ignoreQuestProgress = value end,
                        disabled = function() return not Echovoice.db.profile.enabled or not Echovoice.db.profile.questNarration end,
                    },
                    header2 = {
                        order = 4,
                        type = "header",
                        name = "Chat Filters",
                    },
                    enableSay = {
                        order = 5,
                        type = "toggle",
                        name = "Say Channel",
                        desc = "Narrate messages from the Say channel",
                        width = "full",
                        get = function() return Echovoice.db.profile.filters.chat.enableSay end,
                        set = function(_, value) 
                            Echovoice.db.profile.filters.chat.enableSay = value 
                            -- Refresh event hooks if module exists
                            if Echovoice.eventHandler then
                                Echovoice.eventHandler:RegisterEvents()
                            end
                        end,
                        disabled = function() return not Echovoice.db.profile.enabled or not Echovoice.db.profile.chatNarration end,
                    },
                    enableYell = {
                        order = 6,
                        type = "toggle",
                        name = "Yell Channel",
                        desc = "Narrate messages from the Yell channel",
                        width = "full",
                        get = function() return Echovoice.db.profile.filters.chat.enableYell end,
                        set = function(_, value) 
                            Echovoice.db.profile.filters.chat.enableYell = value 
                            -- Refresh event hooks if module exists
                            if Echovoice.eventHandler then
                                Echovoice.eventHandler:RegisterEvents()
                            end
                        end,
                        disabled = function() return not Echovoice.db.profile.enabled or not Echovoice.db.profile.chatNarration end,
                    },
                    enableWhisper = {
                        order = 7,
                        type = "toggle",
                        name = "Whisper Channel",
                        desc = "Narrate whispers from other players",
                        width = "full",
                        get = function() return Echovoice.db.profile.filters.chat.enableWhisper end,
                        set = function(_, value) 
                            Echovoice.db.profile.filters.chat.enableWhisper = value 
                            -- Refresh event hooks if module exists
                            if Echovoice.eventHandler then
                                Echovoice.eventHandler:RegisterEvents()
                            end
                        end,
                        disabled = function() return not Echovoice.db.profile.enabled or not Echovoice.db.profile.chatNarration end,
                    },
                    enableParty = {
                        order = 8,
                        type = "toggle",
                        name = "Party Channel",
                        desc = "Narrate messages from the Party channel",
                        width = "full",
                        get = function() return Echovoice.db.profile.filters.chat.enableParty end,
                        set = function(_, value) 
                            Echovoice.db.profile.filters.chat.enableParty = value 
                            -- Refresh event hooks if module exists
                            if Echovoice.eventHandler then
                                Echovoice.eventHandler:RegisterEvents()
                            end
                        end,
                        disabled = function() return not Echovoice.db.profile.enabled or not Echovoice.db.profile.chatNarration end,
                    },
                    enableRaid = {
                        order = 9,
                        type = "toggle",
                        name = "Raid Channel",
                        desc = "Narrate messages from the Raid channel",
                        width = "full",
                        get = function() return Echovoice.db.profile.filters.chat.enableRaid end,
                        set = function(_, value) 
                            Echovoice.db.profile.filters.chat.enableRaid = value 
                            -- Refresh event hooks if module exists
                            if Echovoice.eventHandler then
                                Echovoice.eventHandler:RegisterEvents()
                            end
                        end,
                        disabled = function() return not Echovoice.db.profile.enabled or not Echovoice.db.profile.chatNarration end,
                    },
                    enableGuild = {
                        order = 10,
                        type = "toggle",
                        name = "Guild Channel",
                        desc = "Narrate messages from the Guild channel",
                        width = "full",
                        get = function() return Echovoice.db.profile.filters.chat.enableGuild end,
                        set = function(_, value) 
                            Echovoice.db.profile.filters.chat.enableGuild = value 
                            -- Refresh event hooks if module exists
                            if Echovoice.eventHandler then
                                Echovoice.eventHandler:RegisterEvents()
                            end
                        end,
                        disabled = function() return not Echovoice.db.profile.enabled or not Echovoice.db.profile.chatNarration end,
                    },
                    enableOfficer = {
                        order = 11,
                        type = "toggle",
                        name = "Officer Channel",
                        desc = "Narrate messages from the Officer channel",
                        width = "full",
                        get = function() return Echovoice.db.profile.filters.chat.enableOfficer end,
                        set = function(_, value) 
                            Echovoice.db.profile.filters.chat.enableOfficer = value 
                            -- Refresh event hooks if module exists
                            if Echovoice.eventHandler then
                                Echovoice.eventHandler:RegisterEvents()
                            end
                        end,
                        disabled = function() return not Echovoice.db.profile.enabled or not Echovoice.db.profile.chatNarration end,
                    },
                    enableEmote = {
                        order = 12,
                        type = "toggle",
                        name = "Emote Channel",
                        desc = "Narrate emotes from other players",
                        width = "full",
                        get = function() return Echovoice.db.profile.filters.chat.enableEmote end,
                        set = function(_, value) 
                            Echovoice.db.profile.filters.chat.enableEmote = value 
                            -- Refresh event hooks if module exists
                            if Echovoice.eventHandler then
                                Echovoice.eventHandler:RegisterEvents()
                            end
                        end,
                        disabled = function() return not Echovoice.db.profile.enabled or not Echovoice.db.profile.chatNarration end,
                    },
                },
            },
            voiceMappings = {
                order = 4,
                type = "group",
                name = "Voice Mappings",
                desc = "Configure voice mappings for different races and genders",
                args = {
                    header = {
                        order = 1,
                        type = "header",
                        name = "Voice Mappings",
                    },
                    description = {
                        order = 2,
                        type = "description",
                        name = "Customize voice mappings for different races and genders. This allows you to assign specific voices to specific race/gender combinations.",
                    },
                    refreshVoices = {
                        order = 3,
                        type = "execute",
                        name = "Refresh Available Voices",
                        desc = "Query the companion app for available voices",
                        func = function()
                            if Echovoice.voiceMapping then
                                Echovoice.voiceMapping:RefreshAvailableVoices()
                                Utils:LogInfo("Refreshed available voices")
                            end
                        end,
                        disabled = function() return not Echovoice.db.profile.enabled end,
                    },
                    -- Dynamic voice mapping UI elements will be added in RefreshVoiceMappingsUI
                },
            },
            accessibility = {
                order = 5,
                type = "group",
                name = "Accessibility",
                desc = "Accessibility settings",
                args = {
                    header = {
                        order = 1,
                        type = "header",
                        name = "Accessibility Settings",
                    },
                    enableSubtitles = {
                        order = 2,
                        type = "toggle",
                        name = "Enable Subtitles",
                        desc = "Display subtitles for narrated text",
                        width = "full",
                        get = function() return Echovoice.db.profile.accessibility.enableSubtitles end,
                        set = function(_, value) Echovoice.db.profile.accessibility.enableSubtitles = value end,
                        disabled = function() return not Echovoice.db.profile.enabled end,
                    },
                    subtitleFontSize = {
                        order = 3,
                        type = "range",
                        name = "Subtitle Font Size",
                        desc = "Font size for subtitles",
                        min = 8,
                        max = 24,
                        step = 1,
                        get = function() return Echovoice.db.profile.accessibility.subtitleFontSize end,
                        set = function(_, value) Echovoice.db.profile.accessibility.subtitleFontSize = value end,
                        disabled = function() return not Echovoice.db.profile.enabled or not Echovoice.db.profile.accessibility.enableSubtitles end,
                    },
                    enableTranscripts = {
                        order = 4,
                        type = "toggle",
                        name = "Enable Transcripts",
                        desc = "Save transcripts of narrated text",
                        width = "full",
                        get = function() return Echovoice.db.profile.accessibility.enableTranscripts end,
                        set = function(_, value) Echovoice.db.profile.accessibility.enableTranscripts = value end,
                        disabled = function() return not Echovoice.db.profile.enabled end,
                    },
                    pauseDuringCombat = {
                        order = 5,
                        type = "toggle",
                        name = "Pause During Combat",
                        desc = "Pause narration during combat",
                        width = "full",
                        get = function() return Echovoice.db.profile.accessibility.pauseDuringCombat end,
                        set = function(_, value) Echovoice.db.profile.accessibility.pauseDuringCombat = value end,
                        disabled = function() return not Echovoice.db.profile.enabled end,
                    },
                    voiceCommands = {
                        order = 6,
                        type = "toggle",
                        name = "Voice Commands",
                        desc = "Enable voice commands for controlling narration (requires microphone)",
                        width = "full",
                        get = function() return Echovoice.db.profile.accessibility.voiceCommands end,
                        set = function(_, value) Echovoice.db.profile.accessibility.voiceCommands = value end,
                        disabled = function() return not Echovoice.db.profile.enabled end,
                    },
                },
            },
            about = {
                order = 6,
                type = "group",
                name = "About",
                desc = "About Echovoice",
                args = {
                    header = {
                        order = 1,
                        type = "header",
                        name = "About Echovoice",
                    },
                    version = {
                        order = 2,
                        type = "description",
                        name = function() return "Version: " .. Constants.ADDON_VERSION end,
                        width = "full",
                    },
                    description = {
                        order = 3,
                        type = "description",
                        name = "Echovoice is an immersive TTS narrator addon for World of Warcraft. It reads quest text and chat messages aloud using natural-sounding voices that match the gender and race of NPCs.",
                        width = "full",
                    },
                    credits = {
                        order = 4,
                        type = "description",
                        name = "Created by: Dante\n\nSpecial thanks to Claude and ChatGPT for their assistance in development.",
                        width = "full",
                    },
                },
            },
        },
    }
    
    -- Register the config options
    AceConfig:RegisterOptionsTable("Echovoice", options)
    
    -- Create the config panels
    self.configPanel = AceConfigDialog:AddToBlizOptions("Echovoice", "Echovoice")
    
    -- Create the profiles panel
    local profileOptions = AceDBOptions:GetOptionsTable(Echovoice.db)
    AceConfig:RegisterOptionsTable("Echovoice.Profiles", profileOptions)
    AceConfigDialog:AddToBlizOptions("Echovoice.Profiles", "Profiles", "Echovoice")
    
    -- Add voice mappings UI elements
    self:RefreshVoiceMappingsUI()
end

-- Refresh voice mappings UI elements
function ConfigUI:RefreshVoiceMappingsUI()
    -- Get the voice mappings config table
    local options = AceConfig.GetOptionsTable("Echovoice").args.voiceMappings.args
    
    -- Base order for dynamic elements
    local baseOrder = 4
    
    -- Add race sections
    local races = {
        "Human", "Dwarf", "NightElf", "Gnome", "Draenei", "Worgen",
        "Orc", "Undead", "Tauren", "Troll", "BloodElf", "Goblin",
        "Pandaren"
    }
    
    for raceIndex, race in ipairs(races) do
        local raceKey = "race_" .. race
        local order = baseOrder + (raceIndex - 1) * 3
        
        -- Add race header
        options[raceKey .. "_header"] = {
            order = order,
            type = "header",
            name = race,
        }
        
        -- Add male voice dropdown
        options[raceKey .. "_male"] = {
            order = order + 1,
            type = "select",
            name = "Male Voice",
            desc = "Select voice for male " .. race,
            width = "full",
            values = function()
                if Echovoice.voiceMapping then
                    return Echovoice.voiceMapping:GetAvailableVoicesMap()
                end
                return { ["default"] = "Default Voice" }
            end,
            get = function()
                if Echovoice.voiceMapping then
                    local voice = Echovoice.voiceMapping:GetCustomVoice(race, "Male")
                    return voice or "default"
                end
                return "default"
            end,
            set = function(_, value)
                if Echovoice.voiceMapping then
                    if value == "default" then
                        Echovoice.voiceMapping:RemoveCustomVoice(race, "Male")
                    else
                        Echovoice.voiceMapping:AddCustomVoice(race, "Male", value)
                    end
                end
            end,
            disabled = function() return not Echovoice.db.profile.enabled end,
        }
        
        -- Add female voice dropdown
        options[raceKey .. "_female"] = {
            order = order + 2,
            type = "select",
            name = "Female Voice",
            desc = "Select voice for female " .. race,
            width = "full",
            values = function()
                if Echovoice.voiceMapping then
                    return Echovoice.voiceMapping:GetAvailableVoicesMap()
                end
                return { ["default"] = "Default Voice" }
            end,
            get = function()
                if Echovoice.voiceMapping then
                    local voice = Echovoice.voiceMapping:GetCustomVoice(race, "Female")
                    return voice or "default"
                end
                return "default"
            end,
            set = function(_, value)
                if Echovoice.voiceMapping then
                    if value == "default" then
                        Echovoice.voiceMapping:RemoveCustomVoice(race, "Female")
                    else
                        Echovoice.voiceMapping:AddCustomVoice(race, "Female", value)
                    end
                end
            end,
            disabled = function() return not Echovoice.db.profile.enabled end,
        }
    end
    
    -- Reset options table to update UI
    AceConfig:NotifyChange("Echovoice")
end

-- Test function for the ConfigUI module
function ConfigUI:Test()
    Utils:LogInfo("Testing ConfigUI module")
    
    -- Open the config UI
    self:OpenConfig()
    
    Utils:LogInfo("ConfigUI test complete")
    return true
end