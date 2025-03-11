-- UI/MinimapIcon.lua
-- Minimap icon for Echovoice

local ECHOVOICE, Echovoice = ...
local MinimapIcon = Echovoice:NewModule("MinimapIcon", "AceConsole-3.0")
local Constants = Echovoice.Constants
local Utils = Echovoice.Utils

-- Local references
local icon = nil
local LDBIcon = nil
local dataObject = nil

-- Initialize the module
function MinimapIcon:OnInitialize()
    -- Check for LibDBIcon
    if LibStub and LibStub:GetLibrary("LibDataBroker-1.1", true) and LibStub:GetLibrary("LibDBIcon-1.0", true) then
        -- Create the LDB
        local LDB = LibStub("LibDataBroker-1.1")
        LDBIcon = LibStub("LibDBIcon-1.0")
        
        -- Create data object
        dataObject = LDB:NewDataObject("Echovoice", {
            type = "launcher",
            text = "Echovoice",
            icon = "Interface\\AddOns\\Echovoice\\Textures\\icon.tga",
            OnClick = function(_, button)
                self:OnIconClick(button)
            end,
            OnTooltipShow = function(tooltip)
                self:OnTooltipShow(tooltip)
            end,
        })
        
        -- Initialize minimap button
        if not Echovoice.db.profile.minimap then
            Echovoice.db.profile.minimap = { hide = false }
        end
        
        LDBIcon:Register("Echovoice", dataObject, Echovoice.db.profile.minimap)
        
        Utils:LogDebug("MinimapIcon module initialized")
    else
        Utils:LogWarning("LibDBIcon not found - minimap icon not available")
    end
end

-- Enable the module
function MinimapIcon:OnEnable()
    if LDBIcon then
        LDBIcon:Show("Echovoice")
    end
    
    Utils:LogDebug("MinimapIcon module enabled")
end

-- Disable the module
function MinimapIcon:OnDisable()
    if LDBIcon then
        LDBIcon:Hide("Echovoice")
    end
    
    Utils:LogDebug("MinimapIcon module disabled")
end

-- Handle minimap icon click
function MinimapIcon:OnIconClick(button)
    if button == "LeftButton" then
        -- Toggle main config UI
        if Echovoice.configUI then
            Echovoice.configUI:OpenConfig()
        end
    elseif button == "RightButton" then
        -- Show context menu
        self:ShowContextMenu()
    end
end

-- Handle tooltip display
function MinimapIcon:OnTooltipShow(tooltip)
    tooltip:AddLine("Echovoice")
    tooltip:AddLine(" ")
    tooltip:AddLine("Left-Click: Open Configuration")
    tooltip:AddLine("Right-Click: Quick Options")
    tooltip:AddLine(" ")
    tooltip:AddLine("Status: " .. (Echovoice.db.profile.enabled and "|cFF00FF00Enabled|r" or "|cFFFF0000Disabled|r"))
    
    -- Show mode status
    if Echovoice.db.profile.enabled then
        tooltip:AddLine("Quest Narration: " .. (Echovoice.db.profile.questNarration and "|cFF00FF00On|r" or "|cFFFF0000Off|r"))
        tooltip:AddLine("Chat Narration: " .. (Echovoice.db.profile.chatNarration and "|cFF00FF00On|r" or "|cFFFF0000Off|r"))
    end
end

-- Show the context menu
function MinimapIcon:ShowContextMenu()
    -- Create the context menu if it doesn't exist
    if not LibStub("LibDropDown") then
        Utils:LogWarning("LibDropDown not found - context menu not available")
        return
    end
    
    local dropdown = LibStub("LibDropDown"):NewMenu()
    
    -- Add menu items
    dropdown:AddItem({
        text = "Enable Echovoice", 
        checked = Echovoice.db.profile.enabled, 
        func = function() 
            Echovoice.db.profile.enabled = not Echovoice.db.profile.enabled
            if Echovoice.db.profile.enabled then
                Echovoice:OnEnable()
            else
                Echovoice:OnDisable()
            end
        end
    })
    
    dropdown:AddItem({
        text = "Quest Narration", 
        checked = Echovoice.db.profile.questNarration,
        disabled = not Echovoice.db.profile.enabled,
        func = function() 
            Echovoice.db.profile.questNarration = not Echovoice.db.profile.questNarration
            -- Refresh event hooks if module exists
            if Echovoice.eventHandler then
                Echovoice.eventHandler:RegisterEvents()
            end
        end
    })
    
    dropdown:AddItem({
        text = "Chat Narration", 
        checked = Echovoice.db.profile.chatNarration,
        disabled = not Echovoice.db.profile.enabled,
        func = function() 
            Echovoice.db.profile.chatNarration = not Echovoice.db.profile.chatNarration
            -- Refresh event hooks if module exists
            if Echovoice.eventHandler then
                Echovoice.eventHandler:RegisterEvents()
            end
        end
    })
    
    dropdown:AddItem({
        text = "-",
        disabled = true
    })
    
    dropdown:AddItem({
        text = "Pause Narration", 
        func = function() 
            -- Pause narration logic
            Utils:LogInfo("Narration paused")
        end,
        disabled = not Echovoice.db.profile.enabled
    })
    
    dropdown:AddItem({
        text = "Show Transcript", 
        func = function() 
            if Echovoice.transcriptUI then
                Echovoice.transcriptUI:ShowTranscript()
            end
        end,
        disabled = not Echovoice.db.profile.enabled or not Echovoice.db.profile.accessibility.enableTranscripts
    })
    
    dropdown:AddItem({
        text = "-",
        disabled = true
    })
    
    dropdown:AddItem({
        text = "Configuration", 
        func = function() 
            if Echovoice.configUI then
                Echovoice.configUI:OpenConfig()
            end
        end
    })
    
    -- Show the dropdown
    dropdown:Toggle()
end

-- Test function for the MinimapIcon module
function MinimapIcon:Test()
    Utils:LogInfo("Testing MinimapIcon module")
    
    if not LDBIcon then
        Utils:LogWarning("LibDBIcon not found - minimap icon not available")
        return false
    end
    
    -- Show the minimap icon
    LDBIcon:Show("Echovoice")
    
    Utils:LogInfo("MinimapIcon test complete")
    return true
end