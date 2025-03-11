-- Constants.lua
-- Contains all constant values for the Echovoice addon

local ECHOVOICE, Echovoice = ...
Echovoice.Constants = {}
local Constants = Echovoice.Constants

-- Addon info
Constants.ADDON_NAME = "Echovoice"
Constants.ADDON_VERSION = GetAddOnMetadata("Echovoice", "Version")

-- Event types
Constants.EVENT_TYPES = {
    QUEST_DETAIL = "QUEST_DETAIL",
    QUEST_PROGRESS = "QUEST_PROGRESS",
    QUEST_COMPLETE = "QUEST_COMPLETE",
    GOSSIP_SHOW = "GOSSIP_SHOW",
    CHAT_MSG_SAY = "CHAT_MSG_SAY",
    CHAT_MSG_YELL = "CHAT_MSG_YELL",
    CHAT_MSG_WHISPER = "CHAT_MSG_WHISPER",
    CHAT_MSG_PARTY = "CHAT_MSG_PARTY",
    CHAT_MSG_RAID = "CHAT_MSG_RAID",
    CHAT_MSG_GUILD = "CHAT_MSG_GUILD",
    CHAT_MSG_OFFICER = "CHAT_MSG_OFFICER",
    CHAT_MSG_EMOTE = "CHAT_MSG_EMOTE",
}

-- NPC race mapping for voice selection
Constants.RACE_MAP = {
    -- Alliance
    ["Human"] = 1,
    ["Dwarf"] = 2,
    ["NightElf"] = 3,
    ["Gnome"] = 4,
    ["Draenei"] = 5,
    ["Worgen"] = 6,
    ["VoidElf"] = 7,
    ["LightforgedDraenei"] = 8,
    ["DarkIronDwarf"] = 9,
    ["KulTiran"] = 10,
    ["Mechagnome"] = 11,
    
    -- Horde
    ["Orc"] = 12,
    ["Undead"] = 13,
    ["Tauren"] = 14,
    ["Troll"] = 15,
    ["BloodElf"] = 16,
    ["Goblin"] = 17,
    ["Nightborne"] = 18,
    ["HighmountainTauren"] = 19,
    ["MagharOrc"] = 20,
    ["ZandalariTroll"] = 21,
    ["Vulpera"] = 22,
    
    -- Other
    ["Pandaren"] = 23,
    ["Dracthyr"] = 24,
    
    -- Non-playable races
    ["Demon"] = 25,
    ["Dragon"] = 26,
    ["Elemental"] = 27,
    ["Giant"] = 28,
    ["Mechanical"] = 29,
    ["Undead"] = 30,
    ["Beast"] = 31,
}

-- Gender mapping
Constants.GENDER_MAP = {
    ["Male"] = 1,
    ["Female"] = 2,
    ["Neutral"] = 3,
}

-- Communication constants
Constants.COMPANION_APP = {
    PORT = 9876,
    HOST = "127.0.0.1",
    TIMEOUT = 5, -- seconds
    BUFFER_SIZE = 4096,
}

-- Debug levels
Constants.DEBUG_LEVELS = {
    NONE = 0,
    ERROR = 1,
    WARNING = 2,
    INFO = 3,
    DEBUG = 4,
    TRACE = 5,
}