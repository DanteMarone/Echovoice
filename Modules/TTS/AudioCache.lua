-- TTS/AudioCache.lua
-- Cache for TTS-generated audio to reduce processing time for repeated phrases

local ECHOVOICE, Echovoice = ...
local AudioCache = Echovoice:NewModule("AudioCache")
local Constants = Echovoice.Constants
local Utils = Echovoice.Utils

-- Local variables
local cacheEnabled = true
local cacheSize = 100 -- Maximum number of cached items
local currentCacheSize = 0
local cacheHits = 0
local cacheMisses = 0
local cacheItems = {} -- The actual cache
local cacheQueue = {} -- Queue for cache eviction (LRU)

-- Initialize the module
function AudioCache:OnInitialize()
    Utils:LogDebug("AudioCache module initialized")
end

-- Enable the module
function AudioCache:OnEnable()
    -- Load settings from saved variables
    self:LoadSettings()
    
    Utils:LogDebug("AudioCache module enabled")
end

-- Disable the module
function AudioCache:OnDisable()
    -- Clear cache when disabled
    self:Clear()
    
    Utils:LogDebug("AudioCache module disabled")
end

-- Load settings from saved variables
function AudioCache:LoadSettings()
    if Echovoice.db and Echovoice.db.profile then
        cacheEnabled = Echovoice.db.profile.tts.cacheEnabled
        cacheSize = Echovoice.db.profile.tts.cacheSize or 100
    end
end

-- Enable or disable caching
function AudioCache:SetEnabled(enabled)
    cacheEnabled = enabled
    
    -- Update saved variables
    if Echovoice.db and Echovoice.db.profile then
        Echovoice.db.profile.tts.cacheEnabled = enabled
    end
    
    Utils:LogInfo("Audio cache %s", enabled and "enabled" or "disabled")
    
    -- Clear cache if disabled
    if not enabled then
        self:Clear()
    end
    
    return true
end

-- Set maximum cache size
function AudioCache:SetCacheSize(size)
    if not size or size < 1 then
        Utils:LogError("Invalid cache size: %s", tostring(size))
        return false
    end
    
    cacheSize = size
    
    -- Update saved variables
    if Echovoice.db and Echovoice.db.profile then
        Echovoice.db.profile.tts.cacheSize = size
    end
    
    Utils:LogInfo("Audio cache size set to %d items", size)
    
    -- If new size is smaller than current cache size, trim the cache
    if currentCacheSize > cacheSize then
        self:TrimCache()
    end
    
    return true
end

-- Generate cache key from text and voice parameters
function AudioCache:GenerateCacheKey(text, voiceParams)
    if not text or not voiceParams then
        return nil
    end
    
    -- Create a deterministic key based on text and voice parameters
    local key = text
    
    -- Add voice parameters to key
    if voiceParams.voice then
        key = key .. "|voice=" .. voiceParams.voice
    end
    
    if voiceParams.pitch then
        key = key .. "|pitch=" .. tostring(voiceParams.pitch)
    end
    
    if voiceParams.speed then
        key = key .. "|speed=" .. tostring(voiceParams.speed)
    end
    
    if voiceParams.volume then
        key = key .. "|volume=" .. tostring(voiceParams.volume)
    end
    
    -- Add a hash to make the key shorter but still unique
    -- In a real implementation, this would use a proper hash function
    local hash = 0
    for i = 1, #key do
        hash = (hash * 31 + string.byte(key, i)) % 1000000
    end
    
    return tostring(hash)
end

-- Check if a text is in the cache
function AudioCache:Get(text, voiceParams)
    if not cacheEnabled then
        return nil
    end
    
    -- Generate cache key
    local key = self:GenerateCacheKey(text, voiceParams)
    if not key then
        return nil
    end
    
    -- Check if key exists in cache
    local cacheItem = cacheItems[key]
    if not cacheItem then
        cacheMisses = cacheMisses + 1
        return nil
    end
    
    -- Move item to front of queue (most recently used)
    self:UpdateCacheOrder(key)
    
    -- Increment hit counter
    cacheHits = cacheHits + 1
    
    -- Return cached audio data
    return cacheItem.audioData
end

-- Add an item to the cache
function AudioCache:Add(text, voiceParams, audioData)
    if not cacheEnabled or not text or not voiceParams or not audioData then
        return false
    end
    
    -- Generate cache key
    local key = self:GenerateCacheKey(text, voiceParams)
    if not key then
        return false
    end
    
    -- Check if key already exists in cache
    if cacheItems[key] then
        -- Update existing item
        cacheItems[key].audioData = audioData
        
        -- Move to front of queue
        self:UpdateCacheOrder(key)
        
        return true
    end
    
    -- Check if cache is full
    if currentCacheSize >= cacheSize then
        -- Evict least recently used item
        self:EvictOldestItem()
    end
    
    -- Add new item to cache
    cacheItems[key] = {
        text = text,
        voiceParams = voiceParams,
        audioData = audioData,
        timestamp = GetTime(),
    }
    
    -- Add to front of queue
    table.insert(cacheQueue, 1, key)
    
    -- Increment cache size
    currentCacheSize = currentCacheSize + 1
    
    Utils:LogDebug("Added item to audio cache: %s", text:sub(1, 20) .. "...")
    
    return true
end

-- Update cache order (move item to front of queue)
function AudioCache:UpdateCacheOrder(key)
    -- Find item in queue
    for i, queueKey in ipairs(cacheQueue) do
        if queueKey == key then
            -- Remove from current position
            table.remove(cacheQueue, i)
            
            -- Add to front of queue
            table.insert(cacheQueue, 1, key)
            
            -- Update timestamp
            cacheItems[key].timestamp = GetTime()
            
            break
        end
    end
end

-- Evict the oldest (least recently used) item from the cache
function AudioCache:EvictOldestItem()
    if #cacheQueue == 0 then
        return
    end
    
    -- Get key of oldest item
    local oldestKey = cacheQueue[#cacheQueue]
    
    -- Remove from queue
    table.remove(cacheQueue)
    
    -- Remove from cache
    cacheItems[oldestKey] = nil
    
    -- Decrement cache size
    currentCacheSize = currentCacheSize - 1
    
    Utils:LogDebug("Evicted oldest item from audio cache")
end

-- Trim cache to current size limit
function AudioCache:TrimCache()
    -- While cache is over size, evict items
    while currentCacheSize > cacheSize do
        self:EvictOldestItem()
    end
    
    Utils:LogInfo("Trimmed audio cache to %d items", currentCacheSize)
end

-- Clear the entire cache
function AudioCache:Clear()
    wipe(cacheItems)
    wipe(cacheQueue)
    currentCacheSize = 0
    cacheHits = 0
    cacheMisses = 0
    
    Utils:LogInfo("Audio cache cleared")
    
    return true
end

-- Get cache statistics
function AudioCache:GetStats()
    local hitRate = 0
    if (cacheHits + cacheMisses) > 0 then
        hitRate = cacheHits / (cacheHits + cacheMisses) * 100
    end
    
    return {
        enabled = cacheEnabled,
        size = cacheSize,
        currentSize = currentCacheSize,
        hits = cacheHits,
        misses = cacheMisses,
        hitRate = hitRate,
    }
end

-- Print cache statistics
function AudioCache:PrintStats()
    local stats = self:GetStats()
    
    Utils:LogInfo("Audio Cache Statistics:")
    Utils:LogInfo("  Enabled: %s", stats.enabled and "Yes" or "No")
    Utils:LogInfo("  Size: %d / %d items (%.1f%%)", 
                stats.currentSize, stats.size, (stats.currentSize / stats.size) * 100)
    Utils:LogInfo("  Hits: %d, Misses: %d", stats.hits, stats.misses)
    Utils:LogInfo("  Hit Rate: %.1f%%", stats.hitRate)
end

-- Test function for the AudioCache module
function AudioCache:Test()
    Utils:LogInfo("Testing AudioCache module")
    
    -- Enable cache for testing
    local originalEnabled = cacheEnabled
    self:SetEnabled(true)
    
    -- Clear cache
    self:Clear()
    
    -- Test adding items
    local testVoiceParams = {
        voice = "TestVoice",
        pitch = 1.0,
        speed = 1.0,
        volume = 1.0,
    }
    
    -- Add test items
    for i = 1, 5 do
        local testText = "Test text " .. i
        local testAudio = "Audio data " .. i -- Simulated audio data
        self:Add(testText, testVoiceParams, testAudio)
    end
    
    -- Test cache hits
    local cachedAudio = self:Get("Test text 3", testVoiceParams)
    Utils:LogInfo("Cache hit test: %s", 
                cachedAudio == "Audio data 3" and "PASSED" or "FAILED")
    
    -- Test cache order (LRU)
    -- Add more items to force eviction
    for i = 6, cacheSize + 5 do
        local testText = "Test text " .. i
        local testAudio = "Audio data " .. i
        self:Add(testText, testVoiceParams, testAudio)
    end
    
    -- Check if early items were evicted
    local shouldBeEvicted = self:Get("Test text 1", testVoiceParams)
    Utils:LogInfo("Cache eviction test: %s", 
                shouldBeEvicted == nil and "PASSED" or "FAILED")
    
    -- Test cache key generation
    local key1 = self:GenerateCacheKey("Same text", { voice = "Voice1" })
    local key2 = self:GenerateCacheKey("Same text", { voice = "Voice2" })
    Utils:LogInfo("Cache key test: %s", 
                key1 ~= key2 and "PASSED" or "FAILED")
    
    -- Print stats
    self:PrintStats()
    
    -- Restore original state
    self:SetEnabled(originalEnabled)
    self:Clear()
    
    Utils:LogInfo("AudioCache test complete")
    return true
end