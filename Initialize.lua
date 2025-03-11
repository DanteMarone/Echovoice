-- Initialize.lua
-- Final initialization for the Echovoice addon

local ECHOVOICE, Echovoice = ...
local Constants = Echovoice.Constants
local Utils = Echovoice.Utils

-- Register addon loading message
local loadingFrame = CreateFrame("Frame")
loadingFrame:RegisterEvent("ADDON_LOADED")
loadingFrame:SetScript("OnEvent", function(self, event, addonName)
    if addonName == Constants.ADDON_NAME then
        Utils:LogInfo("%s v%s has been loaded. Type '/ev' or '/echovoice' for options.",
                    Constants.ADDON_NAME, Constants.ADDON_VERSION)
        
        self:UnregisterEvent("ADDON_LOADED")
    end
end)

-- Setup global Echovoice commands for easy debugging
-- (These would be removed in a production version)
_G.EchovoiceDebug = function()
    Echovoice:Debug()
end

_G.EchovoiceTest = function()
    Echovoice:Test()
end