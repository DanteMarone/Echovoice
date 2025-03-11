-- EventHandler.lua
-- Handles WoW events and processes text to be narrated

local ECHOVOICE, Echovoice = ...
local EventHandler = Echovoice:NewModule("EventHandler", "AceEvent-3.0")
local Constants = Echovoice.Constants
local Utils = Echovoice.Utils

-- Local variables
local activeEvents = {}
local lastProcessedTexts = {} -- Used to avoid duplicate processing

-- Initialize the module
function EventHandler:OnInitialize()
    Utils:LogDebug("EventHandler module initialized")
end

-- Enable the module
function EventHandler:OnEnable()
    self:RegisterEvents()
    Utils:LogDebug("EventHandler module enabled")
end

-- Disable the module
function EventHandler:OnDisable()
    self:UnregisterAllEvents()
    Utils:LogDebug("EventHandler module disabled")
end

-- Register for events based on user settings
function EventHandler:RegisterEvents()
    -- Quest events
    if Echovoice.db.profile.questNarration then
        self:RegisterEvent("QUEST_DETAIL")
        self:RegisterEvent("QUEST_PROGRESS")
        self:RegisterEvent("QUEST_COMPLETE")
        self:RegisterEvent("GOSSIP_SHOW")
        activeEvents.QUEST_DETAIL = true
        activeEvents.QUEST_PROGRESS = true
        activeEvents.QUEST_COMPLETE = true
        activeEvents.GOSSIP_SHOW = true
    end
    
    -- Chat events
    if Echovoice.db.profile.chatNarration then
        local filters = Echovoice.db.profile.filters.chat
        
        if filters.enableSay then 
            self:RegisterEvent("CHAT_MSG_SAY")
            activeEvents.CHAT_MSG_SAY = true
        end
        
        if filters.enableYell then 
            self:RegisterEvent("CHAT_MSG_YELL")
            activeEvents.CHAT_MSG_YELL = true
        end
        
        if filters.enableWhisper then 
            self:RegisterEvent("CHAT_MSG_WHISPER")
            activeEvents.CHAT_MSG_WHISPER = true
        end
        
        if filters.enableParty then 
            self:RegisterEvent("CHAT_MSG_PARTY")
            activeEvents.CHAT_MSG_PARTY = true
        end
        
        if filters.enableRaid then 
            self:RegisterEvent("CHAT_MSG_RAID")
            activeEvents.CHAT_MSG_RAID = true
        end
        
        if filters.enableGuild then 
            self:RegisterEvent("CHAT_MSG_GUILD")
            activeEvents.CHAT_MSG_GUILD = true
        end
        
        if filters.enableOfficer then 
            self:RegisterEvent("CHAT_MSG_OFFICER")
            activeEvents.CHAT_MSG_OFFICER = true
        end
        
        if filters.enableEmote then 
            self:RegisterEvent("CHAT_MSG_EMOTE")
            activeEvents.CHAT_MSG_EMOTE = true
        end
    end
end

-- Handle all registered events
function EventHandler:OnEvent(event, ...)
    if not Echovoice.db.profile.enabled or not activeEvents[event] then
        return
    end
    
    Utils:LogDebug("Event received: %s", event)
    
    -- Handle different event types
    if event == "QUEST_DETAIL" then
        self:HandleQuestDetail(...)
    elseif event == "QUEST_PROGRESS" then
        self:HandleQuestProgress(...)
    elseif event == "QUEST_COMPLETE" then
        self:HandleQuestComplete(...)
    elseif event == "GOSSIP_SHOW" then
        self:HandleGossipShow(...)
    elseif event:match("^CHAT_MSG_") then
        self:HandleChatMessage(event, ...)
    end
end

-- Handle QUEST_DETAIL event
function EventHandler:HandleQuestDetail()
    if not QuestFrame:IsShown() then
        return
    end
    
    local questInfo = {
        title = QuestInfoTitleHeader:GetText(),
        text = QuestInfoDescriptionText:GetText(),
        objective = QuestInfoObjectivesText:GetText(),
    }
    
    -- Check if we already processed this quest text recently
    local questKey = questInfo.title .. "_detail"
    if lastProcessedTexts[questKey] and GetTime() - lastProcessedTexts[questKey] < 5 then
        Utils:LogDebug("Skipping duplicate quest detail: %s", questInfo.title)
        return
    end
    
    Utils:LogInfo("Processing quest detail: %s", questInfo.title)
    lastProcessedTexts[questKey] = GetTime()
    
    -- Extract NPC metadata for the questgiver
    local npcID, npcName, npcRace, npcGender = Echovoice.metadataExtractor:GetQuestgiver()
    
    -- Process quest text for narration
    if questInfo.text and questInfo.text ~= "" then
        self:ProcessTextForNarration(questInfo.text, npcID, npcName, npcRace, npcGender)
    end
    
    -- Process objectives text if present
    if questInfo.objective and questInfo.objective ~= "" then
        self:ProcessTextForNarration(questInfo.objective, npcID, npcName, npcRace, npcGender)
    end
end

-- Handle QUEST_PROGRESS event
function EventHandler:HandleQuestProgress()
    if not QuestFrame:IsShown() or Echovoice.db.profile.filters.quest.ignoreQuestProgress then
        return
    end
    
    local questInfo = {
        title = QuestInfoTitleHeader:GetText(),
        text = QuestProgressText:GetText(),
    }
    
    -- Check if we already processed this quest text recently
    local questKey = questInfo.title .. "_progress"
    if lastProcessedTexts[questKey] and GetTime() - lastProcessedTexts[questKey] < 5 then
        Utils:LogDebug("Skipping duplicate quest progress: %s", questInfo.title)
        return
    end
    
    Utils:LogInfo("Processing quest progress: %s", questInfo.title)
    lastProcessedTexts[questKey] = GetTime()
    
    -- Extract NPC metadata for the questgiver
    local npcID, npcName, npcRace, npcGender = Echovoice.metadataExtractor:GetQuestgiver()
    
    -- Process quest text for narration
    if questInfo.text and questInfo.text ~= "" then
        self:ProcessTextForNarration(questInfo.text, npcID, npcName, npcRace, npcGender)
    end
end

-- Handle QUEST_COMPLETE event
function EventHandler:HandleQuestComplete()
    if not QuestFrame:IsShown() then
        return
    end
    
    local questInfo = {
        title = QuestInfoTitleHeader:GetText(),
        text = QuestInfoRewardText:GetText(),
    }
    
    -- Check if we already processed this quest text recently
    local questKey = questInfo.title .. "_complete"
    if lastProcessedTexts[questKey] and GetTime() - lastProcessedTexts[questKey] < 5 then
        Utils:LogDebug("Skipping duplicate quest complete: %s", questInfo.title)
        return
    end
    
    Utils:LogInfo("Processing quest complete: %s", questInfo.title)
    lastProcessedTexts[questKey] = GetTime()
    
    -- Extract NPC metadata for the questgiver
    local npcID, npcName, npcRace, npcGender = Echovoice.metadataExtractor:GetQuestgiver()
    
    -- Process quest text for narration
    if questInfo.text and questInfo.text ~= "" then
        self:ProcessTextForNarration(questInfo.text, npcID, npcName, npcRace, npcGender)
    end
end

-- Handle GOSSIP_SHOW event
function EventHandler:HandleGossipShow()
    if not GossipFrame:IsShown() then
        return
    end
    
    -- Get gossip text
    local gossipText = GossipGreetingText:GetText()
    if not gossipText or gossipText == "" then
        return
    end
    
    -- Check if we already processed this gossip text recently
    local gossipKey = gossipText:sub(1, 20) -- Use first 20 chars as key
    if lastProcessedTexts[gossipKey] and GetTime() - lastProcessedTexts[gossipKey] < 5 then
        Utils:LogDebug("Skipping duplicate gossip text")
        return
    end
    
    Utils:LogInfo("Processing gossip text")
    lastProcessedTexts[gossipKey] = GetTime()
    
    -- Extract NPC metadata for the gossip NPC
    local npcID, npcName, npcRace, npcGender = Echovoice.metadataExtractor:GetGossipTarget()
    
    -- Process gossip text for narration
    self:ProcessTextForNarration(gossipText, npcID, npcName, npcRace, npcGender)
end

-- Handle chat message events
function EventHandler:HandleChatMessage(event, text, playerName, _, _, _, _, _, _, _, _, _, guid)
    if not text or text == "" then
        return
    end
    
    -- Check if we already processed this chat message recently
    local chatKey = playerName .. "_" .. text:sub(1, 20) -- Use name + first 20 chars as key
    if lastProcessedTexts[chatKey] and GetTime() - lastProcessedTexts[chatKey] < 5 then
        Utils:LogDebug("Skipping duplicate chat message from %s", playerName)
        return
    end
    
    Utils:LogInfo("Processing chat message from %s", playerName)
    lastProcessedTexts[chatKey] = GetTime()
    
    -- Extract metadata for the chat sender
    local senderID, senderName, senderRace, senderGender = Echovoice.metadataExtractor:GetPlayerInfoFromGUID(guid)
    
    -- Process chat text for narration
    self:ProcessTextForNarration(text, senderID, senderName, senderRace, senderGender)
end

-- Process text for narration
function EventHandler:ProcessTextForNarration(text, npcID, npcName, npcRace, npcGender)
    if not text or text == "" then
        return
    end
    
    Utils:LogDebug("Processing text for narration: %s (NPC: %s, Race: %s, Gender: %s)", 
                  text:sub(1, 30) .. "...", npcName or "Unknown", npcRace or "Unknown", npcGender or "Unknown")
    
    -- Prepare text by cleaning it up
    text = self:PrepareTextForNarration(text)
    
    -- Split text into manageable chunks if needed
    local textChunks = Utils:SplitText(text, 200) -- Split into ~200 char chunks
    
    -- Send each chunk to the communication layer for TTS processing
    for _, chunk in ipairs(textChunks) do
        Echovoice.communicationLayer:SendTextForNarration(chunk, npcID, npcName, npcRace, npcGender)
    end
end

-- Prepare text for narration by cleaning it up
function EventHandler:PrepareTextForNarration(text)
    -- Remove color codes and other UI formatting
    text = text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
    
    -- Remove excessive whitespace
    text = text:gsub("%s+", " ")
    
    -- Trim leading/trailing whitespace
    text = Utils:Trim(text)
    
    return text
end

-- Test function for the EventHandler module
function EventHandler:Test()
    Utils:LogInfo("Testing EventHandler module")
    
    -- Simulate quest detail event
    local testText = "This is a test quest text for Echovoice. The narration system should process this text and send it to the TTS engine."
    local testNpcName = "Test NPC"
    local testNpcRace = "Human"
    local testNpcGender = "Male"
    
    Utils:LogInfo("Simulating quest text processing")
    self:ProcessTextForNarration(testText, nil, testNpcName, testNpcRace, testNpcGender)
    
    Utils:LogInfo("EventHandler test complete")
    return true
end