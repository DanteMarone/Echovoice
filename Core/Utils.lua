-- Utils.lua
-- Utility functions for the Echovoice addon

local ECHOVOICE, Echovoice = ...
Echovoice.Utils = {}
local Utils = Echovoice.Utils
local Constants = Echovoice.Constants

-- Debugging utilities
local debugLevel = Constants.DEBUG_LEVELS.ERROR -- Default to ERROR level

-- Set debug level
function Utils:SetDebugLevel(level)
    if Constants.DEBUG_LEVELS[level] then
        debugLevel = Constants.DEBUG_LEVELS[level]
    else
        debugLevel = level
    end
end

-- Log message with specified level
function Utils:Log(level, message, ...)
    if type(level) == "string" then
        level = Constants.DEBUG_LEVELS[level] or Constants.DEBUG_LEVELS.INFO
    end
    
    if level <= debugLevel then
        local formattedMessage = string.format(message, ...)
        print(string.format("|cFF00CCFF[Echovoice]|r %s", formattedMessage))
    end
end

-- Log error
function Utils:LogError(message, ...)
    Utils:Log(Constants.DEBUG_LEVELS.ERROR, "|cFFFF0000ERROR:|r " .. message, ...)
end

-- Log warning
function Utils:LogWarning(message, ...)
    Utils:Log(Constants.DEBUG_LEVELS.WARNING, "|cFFFFCC00WARNING:|r " .. message, ...)
end

-- Log info
function Utils:LogInfo(message, ...)
    Utils:Log(Constants.DEBUG_LEVELS.INFO, message, ...)
end

-- Log debug
function Utils:LogDebug(message, ...)
    Utils:Log(Constants.DEBUG_LEVELS.DEBUG, "|cFF888888DEBUG:|r " .. message, ...)
end

-- String utilities
function Utils:Trim(s)
    return s:match("^%s*(.-)%s*$")
end

function Utils:SplitText(text, maxLength)
    local result = {}
    local length = 0
    local current = ""
    
    for word in text:gmatch("%S+") do
        if length + #word + 1 > maxLength and length > 0 then
            table.insert(result, current)
            current = word
            length = #word
        else
            if length > 0 then
                current = current .. " " .. word
                length = length + #word + 1
            else
                current = word
                length = #word
            end
        end
    end
    
    if length > 0 then
        table.insert(result, current)
    end
    
    return result
end

-- Table utilities
function Utils:DeepCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[Utils:DeepCopy(orig_key)] = Utils:DeepCopy(orig_value)
        end
        setmetatable(copy, Utils:DeepCopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

-- Safe execution with error handling
function Utils:SafeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        Utils:LogError("Error in function call: %s", result)
        return nil
    end
    return result
end

-- Test function for debugging
function Utils:Test()
    Utils:LogInfo("Echovoice test function called")
    return true
end