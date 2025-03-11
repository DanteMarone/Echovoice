-- UI/TranscriptUI.lua
-- Transcript functionality for Echovoice addon

local ECHOVOICE, Echovoice = ...
local TranscriptUI = Echovoice:NewModule("TranscriptUI", "AceConsole-3.0")
local Constants = Echovoice.Constants
local Utils = Echovoice.Utils

-- Local variables
local transcriptEntries = {}
local maxTranscriptEntries = 100
local transcriptFrame = nil

-- Initialize the module
function TranscriptUI:OnInitialize()
    -- Create the transcript UI
    self:CreateTranscriptFrame()
    
    -- Register slash command
    self:RegisterChatCommand("evtranscript", "ShowTranscriptCommand")
    
    Utils:LogDebug("TranscriptUI module initialized")
end

-- Enable the module
function TranscriptUI:OnEnable()
    Utils:LogDebug("TranscriptUI module enabled")
end

-- Disable the module
function TranscriptUI:OnDisable()
    if transcriptFrame then
        transcriptFrame:Hide()
    end
    
    Utils:LogDebug("TranscriptUI module disabled")
end

-- Create the transcript frame
function TranscriptUI:CreateTranscriptFrame()
    -- Create main frame
    transcriptFrame = CreateFrame("Frame", "EchovoiceTranscriptFrame", UIParent, "UIPanelDialogTemplate")
    transcriptFrame:SetSize(600, 400)
    transcriptFrame:SetPoint("CENTER")
    transcriptFrame:SetMovable(true)
    transcriptFrame:EnableMouse(true)
    transcriptFrame:RegisterForDrag("LeftButton")
    transcriptFrame:SetScript("OnDragStart", transcriptFrame.StartMoving)
    transcriptFrame:SetScript("OnDragStop", transcriptFrame.StopMovingOrSizing)
    transcriptFrame:SetFrameStrata("DIALOG")
    transcriptFrame.Title:SetText("Echovoice Transcript")
    
    -- Close button
    transcriptFrame.CloseButton:SetScript("OnClick", function()
        transcriptFrame:Hide()
    end)
    
    -- Create scrollframe
    local scrollFrame = CreateFrame("ScrollFrame", nil, transcriptFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 12, -32)
    scrollFrame:SetPoint("BOTTOMRIGHT", -30, 40)
    
    -- Create content frame
    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(scrollFrame:GetSize())
    scrollFrame:SetScrollChild(content)
    
    -- Text display
    local text = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("TOPLEFT")
    text:SetWidth(scrollFrame:GetWidth())
    text:SetJustifyH("LEFT")
    text:SetJustifyV("TOP")
    text:SetTextColor(1, 1, 1)
    content.text = text
    
    -- Action buttons
    local clearButton = CreateFrame("Button", nil, transcriptFrame, "UIPanelButtonTemplate")
    clearButton:SetSize(100, 22)
    clearButton:SetPoint("BOTTOMLEFT", 12, 10)
    clearButton:SetText("Clear")
    clearButton:SetScript("OnClick", function()
        self:ClearTranscript()
    end)
    
    local exportButton = CreateFrame("Button", nil, transcriptFrame, "UIPanelButtonTemplate")
    exportButton:SetSize(100, 22)
    exportButton:SetPoint("BOTTOMRIGHT", -12, 10)
    exportButton:SetText("Export")
    exportButton:SetScript("OnClick", function()
        self:ExportTranscript()
    end)
    
    -- Hide initially
    transcriptFrame:Hide()
    
    -- Store references
    transcriptFrame.content = content
    transcriptFrame.scrollFrame = scrollFrame
    
    return transcriptFrame
end

-- Add an entry to the transcript
function TranscriptUI:AddEntry(text, speaker, category)
    if not Echovoice.db.profile.accessibility.enableTranscripts then
        return
    end
    
    -- Create timestamp
    local timestamp = date("%H:%M:%S")
    
    -- Format entry
    local entry = {
        timestamp = timestamp,
        speaker = speaker,
        text = text,
        category = category or "General",
        time = GetServerTime(),
    }
    
    -- Add to entries
    table.insert(transcriptEntries, entry)
    
    -- Trim if too many entries
    while #transcriptEntries > maxTranscriptEntries do
        table.remove(transcriptEntries, 1)
    end
    
    -- Update display if visible
    if transcriptFrame and transcriptFrame:IsShown() then
        self:UpdateTranscriptDisplay()
    end
end

-- Update the transcript display
function TranscriptUI:UpdateTranscriptDisplay()
    if not transcriptFrame or not transcriptFrame:IsShown() then
        return
    end
    
    local text = ""
    
    for i, entry in ipairs(transcriptEntries) do
        local line = "|cFF888888[" .. entry.timestamp .. "]|r "
        
        if entry.speaker then
            line = line .. "|cFFFFFF00" .. entry.speaker .. ":|r "
        end
        
        line = line .. entry.text .. "\n\n"
        text = text .. line
    end
    
    transcriptFrame.content.text:SetText(text)
end

-- Show the transcript UI
function TranscriptUI:ShowTranscript()
    if not transcriptFrame then
        self:CreateTranscriptFrame()
    end
    
    self:UpdateTranscriptDisplay()
    transcriptFrame:Show()
end

-- Clear the transcript
function TranscriptUI:ClearTranscript()
    wipe(transcriptEntries)
    self:UpdateTranscriptDisplay()
end

-- Export the transcript to a text file
function TranscriptUI:ExportTranscript()
    -- Export is not possible in-game, so we'll provide instructions
    
    -- Create a popup dialog
    StaticPopupDialogs["ECHOVOICE_EXPORT_TRANSCRIPT"] = {
        text = "To export the transcript, check the SavedVariables folder after logging out:\n\nWTF/Account/YOUR_ACCOUNT/SavedVariables/Echovoice.lua\n\nThe transcript will be stored in the EchovoiceDB.global.transcript table.",
        button1 = "OK",
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
    
    -- Show the dialog
    StaticPopup_Show("ECHOVOICE_EXPORT_TRANSCRIPT")
    
    -- Save transcript to global variable for export
    if not Echovoice.db.global.transcript then
        Echovoice.db.global.transcript = {}
    end
    
    -- Format the transcript for export
    local exportData = {
        title = "Echovoice Transcript - " .. date("%Y-%m-%d %H:%M:%S"),
        entries = Utils:DeepCopy(transcriptEntries),
    }
    
    -- Add to global DB
    table.insert(Echovoice.db.global.transcript, exportData)
    
    -- Limit the number of saved transcripts
    while #Echovoice.db.global.transcript > 10 do
        table.remove(Echovoice.db.global.transcript, 1)
    end
}

-- Handle the /evtranscript command
function TranscriptUI:ShowTranscriptCommand(input)
    if input and input:trim() == "clear" then
        self:ClearTranscript()
        Utils:LogInfo("Transcript cleared")
    else
        self:ShowTranscript()
    end
end

-- Test function for the TranscriptUI module
function TranscriptUI:Test()
    Utils:LogInfo("Testing TranscriptUI module")
    
    -- Enable transcripts if not already enabled
    local wasEnabled = Echovoice.db.profile.accessibility.enableTranscripts
    Echovoice.db.profile.accessibility.enableTranscripts = true
    
    -- Add some test entries
    self:AddEntry("Welcome to the Echovoice transcript test.", nil, "System")
    self:AddEntry("Greetings, traveler. The Horde needs your strength.", "Thrall", "Quest")
    self:AddEntry("Lok'tar ogar! Victory or death!", "Garrosh Hellscream", "NPC")
    self:AddEntry("The Light shall bring victory!", "Anduin Wrynn", "NPC")
    self:AddEntry("This is a test of the transcript system.", nil, "System")
    
    -- Show the transcript
    self:ShowTranscript()
    
    -- Restore previous setting
    Echovoice.db.profile.accessibility.enableTranscripts = wasEnabled
    
    Utils:LogInfo("TranscriptUI test complete")
    return true
end