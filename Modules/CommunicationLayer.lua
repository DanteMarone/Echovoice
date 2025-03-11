-- CommunicationLayer.lua
-- Handles communication between the WoW addon and the companion app

local ECHOVOICE, Echovoice = ...
local CommunicationLayer = Echovoice:NewModule("CommunicationLayer")
local Constants = Echovoice.Constants
local Utils = Echovoice.Utils

-- Local variables
local isConnected = false
local connectionAttempts = 0
local maxConnectionAttempts = 5
local reconnectTimer = nil
local messageQueue = {}
local messageIdCounter = 0

-- Initialize the module
function CommunicationLayer:OnInitialize()
    Utils:LogDebug("CommunicationLayer module initialized")
end

-- Enable the module
function CommunicationLayer:OnEnable()
    self:Connect()
    Utils:LogDebug("CommunicationLayer module enabled")
end

-- Disable the module
function CommunicationLayer:OnDisable()
    self:Disconnect()
    Utils:LogDebug("CommunicationLayer module disabled")
end

-- Connect to the companion app
function CommunicationLayer:Connect()
    if isConnected then
        Utils:LogDebug("Already connected to companion app")
        return
    end
    
    Utils:LogInfo("Attempting to connect to companion app...")
    
    -- In a real implementation, this would use a custom C function or library to connect
    -- to the local companion app via named pipes or sockets
    -- For demonstration purposes, we'll simulate a connection
    
    -- Simulate connection attempt
    connectionAttempts = connectionAttempts + 1
    
    -- Simulate successful connection (in a real implementation this would check for actual connection)
    local success = true
    
    if success then
        isConnected = true
        connectionAttempts = 0
        Utils:LogInfo("Connected to companion app")
        
        -- Process any queued messages
        self:ProcessQueue()
    else
        Utils:LogWarning("Failed to connect to companion app (attempt %d/%d)", 
                        connectionAttempts, maxConnectionAttempts)
        
        -- Try to reconnect if we haven't exceeded the maximum attempts
        if connectionAttempts < maxConnectionAttempts then
            -- Schedule reconnect attempt
            if reconnectTimer then
                Utils:LogDebug("Cancelling previous reconnect timer")
                self:CancelTimer(reconnectTimer)
            end
            
            reconnectTimer = self:ScheduleTimer("Connect", 5) -- Try again in 5 seconds
            Utils:LogDebug("Scheduled reconnect attempt in 5 seconds")
        else
            Utils:LogError("Failed to connect to companion app after %d attempts. Is it running?", 
                          maxConnectionAttempts)
                          
            -- Reset connection attempts after a longer delay
            reconnectTimer = self:ScheduleTimer(function()
                connectionAttempts = 0
                self:Connect()
            end, 60) -- Try again in 1 minute
            
            Utils:LogInfo("Will try connecting again in 1 minute")
        end
    end
end

-- Disconnect from the companion app
function CommunicationLayer:Disconnect()
    if not isConnected then
        Utils:LogDebug("Not connected to companion app")
        return
    end
    
    Utils:LogInfo("Disconnecting from companion app...")
    
    -- In a real implementation, this would close the connection to the companion app
    -- For demonstration purposes, we'll simulate disconnection
    
    isConnected = false
    
    -- Cancel any pending reconnect timer
    if reconnectTimer then
        self:CancelTimer(reconnectTimer)
        reconnectTimer = nil
    end
    
    Utils:LogInfo("Disconnected from companion app")
end

-- Send text to be narrated
function CommunicationLayer:SendTextForNarration(text, npcID, npcName, npcRace, npcGender)
    if not text or text == "" then
        Utils:LogWarning("Empty text passed to SendTextForNarration")
        return
    end
    
    -- Create message with metadata
    local message = {
        id = self:GetNextMessageId(),
        text = text,
        metadata = {
            npcID = npcID,
            npcName = npcName,
            npcRace = npcRace,
            npcGender = npcGender,
            timestamp = GetServerTime(),
        },
        settings = {
            volume = Echovoice.db.profile.voice.volume,
            speed = Echovoice.db.profile.voice.speed,
            pitch = Echovoice.db.profile.voice.pitch,
        },
    }
    
    Utils:LogDebug("Prepared message for narration: %s", text:sub(1, 30) .. "...")
    
    -- If connected, send the message directly
    if isConnected then
        self:SendMessage(message)
    else
        -- Otherwise, queue the message and try to connect
        self:QueueMessage(message)
        self:Connect()
    end
end

-- Send a message to the companion app
function CommunicationLayer:SendMessage(message)
    if not isConnected then
        Utils:LogWarning("Not connected to companion app, queueing message")
        self:QueueMessage(message)
        return
    end
    
    -- In a real implementation, this would serialize the message and send it to the companion app
    -- For demonstration purposes, we'll simulate sending the message
    
    Utils:LogDebug("Sending message to companion app: %s", message.text:sub(1, 30) .. "...")
    
    -- Simulate successful send (in a real implementation this would check for success)
    local success = true
    
    if not success then
        Utils:LogWarning("Failed to send message to companion app, queueing")
        self:QueueMessage(message)
        
        -- Connection might be lost, try to reconnect
        isConnected = false
        self:Connect()
    else
        Utils:LogDebug("Message sent successfully")
    end
end

-- Queue a message for later sending
function CommunicationLayer:QueueMessage(message)
    -- Add message to queue
    table.insert(messageQueue, message)
    
    -- Limit queue size to prevent memory issues
    if #messageQueue > 100 then
        Utils:LogWarning("Message queue is getting large (%d items), removing oldest message", #messageQueue)
        table.remove(messageQueue, 1)
    end
    
    Utils:LogDebug("Message queued for later sending (queue size: %d)", #messageQueue)
end

-- Process the message queue
function CommunicationLayer:ProcessQueue()
    if not isConnected then
        Utils:LogWarning("Not connected to companion app, cannot process queue")
        return
    end
    
    if #messageQueue == 0 then
        Utils:LogDebug("No messages in queue to process")
        return
    end
    
    Utils:LogInfo("Processing message queue (%d items)", #messageQueue)
    
    -- Process up to 10 messages at a time to avoid overloading
    local processCount = math.min(10, #messageQueue)
    
    for i = 1, processCount do
        local message = table.remove(messageQueue, 1)
        self:SendMessage(message)
    end
    
    -- If there are more messages, schedule another processing
    if #messageQueue > 0 then
        self:ScheduleTimer("ProcessQueue", 1) -- Process more in 1 second
    end
end

-- Get next message ID (simple counter)
function CommunicationLayer:GetNextMessageId()
    messageIdCounter = messageIdCounter + 1
    return messageIdCounter
end

-- Test function for the CommunicationLayer module
function CommunicationLayer:Test()
    Utils:LogInfo("Testing CommunicationLayer module")
    
    -- Test connection
    if not isConnected then
        Utils:LogInfo("Not connected, attempting to connect...")
        self:Connect()
    else
        Utils:LogInfo("Already connected to companion app")
    end
    
    -- Test sending a message
    local testText = "This is a test message from Echovoice addon."
    Utils:LogInfo("Sending test message: %s", testText)
    
    self:SendTextForNarration(testText, nil, "Test NPC", "Human", "Male")
    
    Utils:LogInfo("CommunicationLayer test complete")
    return true
end