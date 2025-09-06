-- Main Server Script
-- Handles core server functionality

-- Print startup message
print("^2Civil Unrest Framework ^7v" .. Config.Version .. " ^2initialized")

-- Track connected players
local connectedPlayers = {}

-- Player connection handler
AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local source = source
    local identifiers = GetPlayerIdentifiers(source)
    
    -- Begin connection process
    deferrals.defer()
    deferrals.update("Checking player data...")
    
    -- Wait a moment to simulate checking
    Citizen.Wait(1000)
    
    -- Allow connection
    deferrals.done()
    
    -- Log connection
    logAction(source, "CONNECTION", "Player connecting")
end)

-- Player joined handler
AddEventHandler('playerJoining', function(oldID)
    local source = source
    local name = GetPlayerName(source)
    
    -- Store player data
    connectedPlayers[source] = {
        name = name,
        joinTime = os.time(),
        identifiers = GetPlayerIdentifiers(source)
    }
    
    -- Log join
    logAction(source, "JOIN", "Player joined the server")
end)

-- Player drop handler
AddEventHandler('playerDropped', function(reason)
    local source = source
    
    if connectedPlayers[source] then
        local playTime = os.time() - connectedPlayers[source].joinTime
        
        -- Log disconnect
        logAction(source, "DISCONNECT", "Player left: " .. reason .. " (played for " .. playTime .. " seconds)")
        
        -- Clean up player data
        connectedPlayers[source] = nil
    end
end)

-- Get all connected players
function getConnectedPlayers()
    return connectedPlayers
end

-- Get player by identifier
function getPlayerByIdentifier(identifier)
    for source, data in pairs(connectedPlayers) do
        for _, id in ipairs(data.identifiers) do
            if id == identifier then
                return source
            end
        end
    end
    return nil
end

-- Log action with timestamp
function logAction(source, action, details)
    if Config.EnableLogging and Config.LogLevel >= 3 then
        local timestamp = os.date("%Y-%m-%d %H:%M:%S")
        local playerName = GetPlayerName(source) or "Unknown"
        local identifier = GetPlayerIdentifier(source, 0) or "Unknown"
        
        print(string.format("[%s] %s (%s) %s: %s", 
            timestamp, playerName, identifier, action, details or ""))
    end
end

-- Export functions
exports('getConnectedPlayers', getConnectedPlayers)
exports('getPlayerByIdentifier', getPlayerByIdentifier)
exports('logAction', logAction)
