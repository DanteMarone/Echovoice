-- UI/SubtitleUI.lua
-- Subtitle display for Echovoice addon

local ECHOVOICE, Echovoice = ...
local SubtitleUI = Echovoice:NewModule("SubtitleUI")
local Constants = Echovoice.Constants
local Utils = Echovoice.Utils

-- Local references
local subtitleFrame = nil
local activeSubtitles = {}
local maxSubtitles = 3 -- Maximum number of subtitles to display at once
local subtitleDuration = 5 -- Default duration in seconds
local fontSize = 12 -- Default font size

-- Initialize the module
function SubtitleUI:OnInitialize()
    -- Create subtitle display frame
    self:CreateSubtitleFrame()
    
    Utils:LogDebug("SubtitleUI module initialized")
end

-- Enable the module
function SubtitleUI:OnEnable()
    if subtitleFrame then
        subtitleFrame:Show()
    end
    
    Utils:LogDebug("SubtitleUI module enabled")
end

-- Disable the module
function SubtitleUI:OnDisable()
    if subtitleFrame then
        subtitleFrame:Hide()
    end
    
    Utils:LogDebug("SubtitleUI module disabled")
end

-- Create the subtitle display frame
function SubtitleUI:CreateSubtitleFrame()
    -- Create main frame
    subtitleFrame = CreateFrame("Frame", "EchovoiceSubtitleFrame", UIParent)
    subtitleFrame:SetSize(800, 200)
    subtitleFrame:SetPoint("BOTTOM", 0, 150)
    subtitleFrame:SetFrameStrata("HIGH")
    
    -- Create a background for better readability
    local bg = subtitleFrame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0, 0, 0, 0.5)
    
    -- Create subtitle text lines
    subtitleFrame.lines = {}
    for i = 1, maxSubtitles do
        local line = subtitleFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        line:SetWidth(780)
        line:SetHeight(0)
        line:SetJustifyH("CENTER")
        
        if i == 1 then
            line:SetPoint("BOTTOM", subtitleFrame, "BOTTOM", 0, 10)
        else
            line:SetPoint("BOTTOM", subtitleFrame.lines[i-1], "TOP", 0, 5)
        end
        
        subtitleFrame.lines[i] = line
    end
    
    -- Hide initially
    subtitleFrame:Hide()
    
    -- Apply settings
    self:ApplySettings()
end

-- Apply settings from saved variables
function SubtitleUI:ApplySettings()
    if not subtitleFrame then
        return
    end
    
    -- Check if subtitles are enabled
    local enabled = Echovoice.db.profile.accessibility.enableSubtitles
    if enabled then
        subtitleFrame:Show()
    else
        subtitleFrame:Hide()
    end
    
    -- Apply font size
    fontSize = Echovoice.db.profile.accessibility.subtitleFontSize or 12
    for i = 1, maxSubtitles do
        local line = subtitleFrame.lines[i]
        line:SetFont(line:GetFont(), fontSize, "OUTLINE")
    end
end

-- Display a subtitle
function SubtitleUI:DisplaySubtitle(text, speaker, duration)
    if not subtitleFrame or not Echovoice.db.profile.accessibility.enableSubtitles then
        return
    end
    
    -- Format the subtitle text
    local formattedText = text
    if speaker then
        formattedText = "|cFFFFFF00" .. speaker .. ":|r " .. formattedText
    end
    
    -- Create a new subtitle entry
    local subtitle = {
        text = formattedText,
        duration = duration or subtitleDuration,
        endTime = GetTime() + (duration or subtitleDuration),
    }
    
    -- Add to active subtitles
    table.insert(activeSubtitles, subtitle)
    
    -- Trim if we have too many
    while #activeSubtitles > maxSubtitles do
        table.remove(activeSubtitles, 1)
    end
    
    -- Update display
    self:UpdateSubtitles()
    
    -- Setup update handler if not already running
    if not subtitleFrame.updateHandler then
        subtitleFrame.updateHandler = C_Timer.NewTicker(0.1, function()
            self:UpdateSubtitles()
        end)
    end
end

-- Update subtitle display
function SubtitleUI:UpdateSubtitles()
    if not subtitleFrame then
        return
    end
    
    -- Current time
    local now = GetTime()
    
    -- Remove expired subtitles
    local i = 1
    while i <= #activeSubtitles do
        if activeSubtitles[i].endTime <= now then
            table.remove(activeSubtitles, i)
        else
            i = i + 1
        end
    end
    
    -- Update subtitle lines
    for i = 1, maxSubtitles do
        local line = subtitleFrame.lines[i]
        local subtitleIndex = #activeSubtitles - (maxSubtitles - i)
        
        if subtitleIndex > 0 and subtitleIndex <= #activeSubtitles then
            line:SetText(activeSubtitles[subtitleIndex].text)
            line:Show()
        else
            line:SetText("")
            line:Hide()
        end
    end
    
    -- If no active subtitles, cancel the update timer
    if #activeSubtitles == 0 and subtitleFrame.updateHandler then
        subtitleFrame.updateHandler:Cancel()
        subtitleFrame.updateHandler = nil
    end
end

-- Clear all subtitles
function SubtitleUI:ClearSubtitles()
    wipe(activeSubtitles)
    self:UpdateSubtitles()
end

-- Test function for the SubtitleUI module
function SubtitleUI:Test()
    Utils:LogInfo("Testing SubtitleUI module")
    
    -- Enable subtitles if not already enabled
    local wasEnabled = Echovoice.db.profile.accessibility.enableSubtitles
    Echovoice.db.profile.accessibility.enableSubtitles = true
    self:ApplySettings()
    
    -- Display test subtitles
    self:DisplaySubtitle("This is a test subtitle with no speaker.", nil, 3)
    C_Timer.After(1, function()
        self:DisplaySubtitle("Thrall says: For the Horde!", "Thrall", 3)
    end)
    C_Timer.After(2, function()
        self:DisplaySubtitle("Jaina Proudmoore says: For the Alliance!", "Jaina Proudmoore", 3)
    end)
    
    -- Restore previous setting
    C_Timer.After(5, function()
        Echovoice.db.profile.accessibility.enableSubtitles = wasEnabled
        self:ApplySettings()
    end)
    
    Utils:LogInfo("SubtitleUI test complete")
    return true
end