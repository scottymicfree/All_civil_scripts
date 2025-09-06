-- Player Data Management System
-- Handles player statistics and persistent data

-- Track player data
local playerData = {}

-- Initialize player data
function initPlayerData(source)
    local identifiers = GetPlayerIdentifiers(source)
    local license = nil
    
    -- Find license identifier
    for _, id in ipairs(identifiers) do
        if string.find(id, "license:") then
            license = id
            break
        end
    end
    
    -- Create default player data
    playerData[source] = {
        name = GetPlayerName(source),
        license = license,
        kills = 0,
        deaths = 0,
        xp = 0,
        level = 1,
        money = 1000,
        bank = 5000,
        inventory = {},
        lastSeen = os.time()
    }
    
    -- In a real implementation, you would load this data from a database
    -- For example:
    -- MySQL.Async.fetchAll("SELECT * FROM players WHERE license = @license", {
    --     ["@license"] = license
    -- }, function(result)
    --     if result[1] then
    --         playerData[source] = result[1]
    --     else
    --         -- Create new player record
    --         MySQL.Async.execute("INSERT INTO players (license, name) VALUES (@license, @name)", {
    --             ["@license"] = license,
    --             ["@name"] = GetPlayerName(source)
    --         })
    --     end
    -- end)
    
    -- Log initialization
    exports['framework']:logAction(source, "DATA", "Player data initialized")
    
    return playerData[source]
end

-- Get player data
function getPlayerData(source)
    if not playerData[source] then
        return initPlayerData(source)
    end
    
    return playerData[source]
end

-- Update player data
function updatePlayerData(source, key, value)
    if not playerData[source] then
        initPlayerData(source)
    end
    
    playerData[source][key] = value
    
    -- In a real implementation, you would save this to a database
    -- For example:
    -- MySQL.Async.execute("UPDATE players SET " .. key .. " = @value WHERE license = @license", {
    --     ["@value"] = value,
    --     ["@license"] = playerData[source].license
    -- })
    
    return true
end

-- Add player XP
function addPlayerXP(source, amount)
    if not playerData[source] then
        initPlayerData(source)
    end
    
    playerData[source].xp = playerData[source].xp + amount
    
    -- Check for level up
    local newLevel = math.floor(playerData[source].xp / 1000) + 1
    
    if newLevel > playerData[source].level then
        playerData[source].level = newLevel
        
        -- Notify player of level up
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 255, 0},
            multiline = false,
            args = {"Level Up", "You are now level " .. newLevel .. "!"}
        })
    end
    
    return playerData[source].xp
end

-- Get player money
function getPlayerMoney(source)
    if not playerData[source] then
        initPlayerData(source)
    end
    
    return playerData[source].money
end

-- Add money to player
function addPlayerMoney(source, amount)
    if not playerData[source] then
        initPlayerData(source)
    end
    
    playerData[source].money = playerData[source].money + amount
    
    -- Notify player
    TriggerClientEvent('chat:addMessage', source, {
        color = {0, 255, 0},
        multiline = false,
        args = {"Money", "+" .. amount .. " cash"}
    })
    
    return playerData[source].money
end

-- Remove money from player
function removePlayerMoney(source, amount)
    if not playerData[source] then
        initPlayerData(source)
    end
    
    if playerData[source].money >= amount then
        playerData[source].money = playerData[source].money - amount
        
        -- Notify player
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            multiline = false,
            args = {"Money", "-" .. amount .. " cash"}
        })
        
        return true
    end
    
    return false
end

-- Clean up player data on disconnect
AddEventHandler('playerDropped', function()
    local source = source
    
    if playerData[source] then
        -- Update last seen time
        playerData[source].lastSeen = os.time()
        
        -- In a real implementation, you would save this to a database
        -- For example:
        -- MySQL.Async.execute("UPDATE players SET lastSeen = @lastSeen WHERE license = @license", {
        --     ["@lastSeen"] = playerData[source].lastSeen,
        --     ["@license"] = playerData[source].license
        -- })
        
        -- Clean up memory
        -- playerData[source] = nil
        -- We're keeping the data in memory for this example, but in a real server you might want to clean it up
    end
end)

-- Initialize player data on join
AddEventHandler('playerJoining', function()
    local source = source
    initPlayerData(source)
end)

-- Register money commands
RegisterCommand('givemoney', function(source, args, rawCommand)
    -- Check if command is run from console
    if source == 0 then
        if #args < 2 then
            print("Usage: givemoney [playerId] [amount]")
            return
        end
        
        local targetId = tonumber(args[1])
        local amount = tonumber(args[2])
        
        if GetPlayerName(targetId) and amount > 0 then
            addPlayerMoney(targetId, amount)
            print("Gave " .. GetPlayerName(targetId) .. " $" .. amount)
        else
            print("Player not found or invalid amount")
        end
    else
        -- Check if player has admin permissions
        -- This would connect to your permission system in a real implementation
        local isAdmin = true
        
        if isAdmin then
            if #args < 2 then
                TriggerClientEvent('chat:addMessage', source, {
                    color = {255, 0, 0},
                    multiline = false,
                    args = {"Money", "Usage: /givemoney [playerId] [amount]"}
                })
                return
            end
            
            local targetId = tonumber(args[1])
            local amount = tonumber(args[2])
            
            if GetPlayerName(targetId) and amount > 0 then
                addPlayerMoney(targetId, amount)
                
                TriggerClientEvent('chat:addMessage', source, {
                    color = {0, 255, 0},
                    multiline = false,
                    args = {"Money", "Gave " .. GetPlayerName(targetId) .. " $" .. amount}
                })
            else
                TriggerClientEvent('chat:addMessage', source, {
                    color = {255, 0, 0},
                    multiline = false,
                    args = {"Money", "Player not found or invalid amount"}
                })
            end
        else
            TriggerClientEvent('chat:addMessage', source, {
                color = {255, 0, 0},
                multiline = false,
                args = {"Money", "You don't have permission to use this command"}
            })
        end
    end
end, false)

-- Export functions
exports('getPlayerData', getPlayerData)
exports('updatePlayerData', updatePlayerData)
exports('addPlayerXP', addPlayerXP)
exports('getPlayerMoney', getPlayerMoney)
exports('addPlayerMoney', addPlayerMoney)
exports('removePlayerMoney', removePlayerMoney)
