-- MetadataExtractor.lua
-- Extracts metadata about NPCs and players for voice selection

local ECHOVOICE, Echovoice = ...
local MetadataExtractor = Echovoice:NewModule("MetadataExtractor")
local Constants = Echovoice.Constants
local Utils = Echovoice.Utils

-- NPC cache to avoid repeated lookups
local npcCache = {}

-- Initialize the module
function MetadataExtractor:OnInitialize()
    Utils:LogDebug("MetadataExtractor module initialized")
end

-- Enable the module
function MetadataExtractor:OnEnable()
    Utils:LogDebug("MetadataExtractor module enabled")
end

-- Disable the module
function MetadataExtractor:OnDisable()
    Utils:LogDebug("MetadataExtractor module disabled")
end

-- Get information about the current questgiver
function MetadataExtractor:GetQuestgiver()
    local npcID, npcName, npcRace, npcGender
    
    -- Try to get the target (questgiver) information
    if UnitExists("target") and UnitIsVisible("target") then
        local guid = UnitGUID("target")
        npcID = self:ExtractNPCID(guid)
        npcName = UnitName("target")
        
        -- Get cached race and gender or determine them
        if npcID and npcCache[npcID] then
            npcRace = npcCache[npcID].race
            npcGender = npcCache[npcID].gender
        else
            npcRace, npcGender = self:DetermineNPCRaceAndGender(npcID, guid)
            
            -- Cache the result for future use
            if npcID then
                npcCache[npcID] = {
                    name = npcName,
                    race = npcRace,
                    gender = npcGender
                }
            end
        end
    end
    
    -- Fallback if we couldn't determine race or gender
    npcRace = npcRace or self:GetFallbackRace()
    npcGender = npcGender or self:GetFallbackGender()
    
    Utils:LogDebug("Questgiver info - ID: %s, Name: %s, Race: %s, Gender: %s", 
                  npcID or "Unknown", npcName or "Unknown", npcRace or "Unknown", npcGender or "Unknown")
    
    return npcID, npcName, npcRace, npcGender
end

-- Get information about the current gossip target
function MetadataExtractor:GetGossipTarget()
    -- Gossip targets are essentially the same as questgivers in WoW UI context
    return self:GetQuestgiver()
end

-- Extract NPC ID from GUID
function MetadataExtractor:ExtractNPCID(guid)
    if not guid then return nil end
    
    local type, _, _, _, _, npcID = strsplit("-", guid)
    if type == "Creature" or type == "Vehicle" then
        return tonumber(npcID)
    end
    
    return nil
end

-- Determine NPC race and gender based on ID and model information
function MetadataExtractor:DetermineNPCRaceAndGender(npcID, guid)
    if not npcID then return nil, nil end
    
    -- This would ideally use a database of NPC information
    -- For demonstration, we'll use some heuristics and fallbacks
    
    local race, gender
    
    -- Try to determine race and gender from model info (difficult in WoW API)
    -- This would need a separate database of NPC model mappings
    
    -- For demonstration, implement some basic deterministic logic based on NPC ID
    -- In a real implementation, this would be replaced with actual NPC database lookups
    
    -- Pseudo-deterministic algorithm for demonstration purposes
    -- Uses the NPC ID to generate a consistent but arbitrary race and gender
    -- This is NOT how a real implementation would work!
    local idSum = 0
    for i = 1, #tostring(npcID) do
        idSum = idSum + tonumber(string.sub(tostring(npcID), i, i))
    end
    
    -- Determine race (very simplified for demonstration)
    local raceKeys = {}
    for k in pairs(Constants.RACE_MAP) do
        table.insert(raceKeys, k)
    end
    table.sort(raceKeys) -- Sort for consistency
    
    local raceIndex = (idSum % #raceKeys) + 1
    race = raceKeys[raceIndex]
    
    -- Determine gender (simplified)
    local genderKeys = {}
    for k in pairs(Constants.GENDER_MAP) do
        table.insert(genderKeys, k)
    end
    table.sort(genderKeys) -- Sort for consistency
    
    local genderIndex = ((idSum * 13) % #genderKeys) + 1
    gender = genderKeys[genderIndex]
    
    Utils:LogDebug("Determined race and gender for NPC %s: %s, %s", npcID, race, gender)
    
    return race, gender
end

-- Get player information from GUID
function MetadataExtractor:GetPlayerInfoFromGUID(guid)
    if not guid then return nil, nil, nil, nil end
    
    local type = strsplit("-", guid)
    if type ~= "Player" then
        return nil, nil, nil, nil
    end
    
    local playerID = guid
    local playerName = select(6, GetPlayerInfoByGUID(guid))
    
    -- Try to determine race and gender for players
    local playerRace, playerGender
    
    -- For players in your group, you can get more info
    for i = 1, GetNumGroupMembers() do
        local unit = (IsInRaid() and "raid" or "party") .. i
        if UnitExists(unit) and UnitGUID(unit) == guid then
            local _, race = UnitRace(unit)
            local gender = UnitSex(unit) == 2 and "Male" or "Female"
            
            playerRace = race
            playerGender = gender
            break
        end
    end
    
    -- For players not in your group
    if not playerRace then
        -- Limited options for players not in your group
        -- Could be expanded with player database or other means
        playerRace = self:GetFallbackRace()
        playerGender = self:GetFallbackGender()
    end
    
    Utils:LogDebug("Player info - Name: %s, Race: %s, Gender: %s", 
                  playerName or "Unknown", playerRace or "Unknown", playerGender or "Unknown")
    
    return playerID, playerName, playerRace, playerGender
end

-- Get fallback race if determination fails
function MetadataExtractor:GetFallbackRace()
    -- Use player's race as fallback
    local _, race = UnitRace("player")
    return race or "Human"
end

-- Get fallback gender if determination fails
function MetadataExtractor:GetFallbackGender()
    -- Use player's gender as fallback
    local gender = UnitSex("player") == 2 and "Male" or "Female"
    return gender
end

-- Clear the NPC cache
function MetadataExtractor:ClearCache()
    wipe(npcCache)
    Utils:LogDebug("NPC metadata cache cleared")
end

-- Test function for the MetadataExtractor module
function MetadataExtractor:Test()
    Utils:LogInfo("Testing MetadataExtractor module")
    
    -- Test NPC ID extraction
    local testNpcID = 123456
    local testGuid = "Creature-0-0000-0000-00000-" .. testNpcID .. "-0000000000"
    local extractedID = self:ExtractNPCID(testGuid)
    
    Utils:LogInfo("NPC ID extraction test: " .. (extractedID == testNpcID and "PASSED" or "FAILED"))
    
    -- Test race and gender determination
    local race, gender = self:DetermineNPCRaceAndGender(testNpcID, testGuid)
    
    Utils:LogInfo("Race determination test: " .. (race ~= nil and "PASSED" or "FAILED"))
    Utils:LogInfo("Gender determination test: " .. (gender ~= nil and "PASSED" or "FAILED"))
    
    -- Test fallbacks
    local fallbackRace = self:GetFallbackRace()
    local fallbackGender = self:GetFallbackGender()
    
    Utils:LogInfo("Fallback race: %s", fallbackRace)
    Utils:LogInfo("Fallback gender: %s", fallbackGender)
    
    Utils:LogInfo("MetadataExtractor test complete")
    return true
end