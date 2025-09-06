-- Add to server.lua
-- Enhanced XP System with Analytics and Leaderboards

-- XP Leaderboard
local xpLeaderboard = {}
local lastLeaderboardUpdate = 0

-- XP Analytics
local serverXPStats = {
    totalXPAwarded = 0,
    xpBySource = {},
    xpByLevel = {},
    levelUps = 0
}
-- Function to update XP leaderboard
function UpdateXPLeaderboard()
    -- Only update every 5 minutes to save resources
    if os.time() - lastLeaderboardUpdate < 300 then
        return
    end
    
    -- Reset leaderboard
    xpLeaderboard = {}
    
    -- Build leaderboard from player data
    for identifier, data in pairs(playerXP) do
        -- Calculate total XP (current XP + XP from previous levels)
        local totalXP = data.xp
        for i = 1, data.level - 1 do
            totalXP = totalXP + (1000 * i)
        end
        
-- Get player name if online
local playerName = "Unknown" for _, playerId in ipairs ,GetPlayers() do
     local playerIdentifier = 'GetPlayerIdentifier'tonumber (playerId)() -- Fixed syntax
                    'd0' if playerIdentifier == identifier then
                    playerName = GetPlayerName 'tonumber' (playerId) -- Fixed syntax
                break
             end
        end
        table.insert(xpLeaderboard, {
            identifier = identifier,
            name = playerName,
            level = data.level,
            xp = data.xp,
            totalXP = totalXP,
            lastUpdate = data.lastUpdate
        })
    end
    
    -- Sort by level first, then by XP
    table.sort(xpLeaderboard, function(a, b)
        if a.level == b.level then
            return a.xp > b.xp
        end
        return a.level > b.level
    end)
    
    lastLeaderboardUpdate = os.time()
end

-- Enhanced AddPlayerXP function with analytics
function AddPlayerXP(source, amount, reason)
    local identifier = GetPlayerIdentifier(source, 0)
    if identifier and playerXP[identifier] then
        -- Track XP analytics
        serverXPStats.totalXPAwarded = serverXPStats.totalXPAwarded + amount
        
        -- Track by source
        if not serverXPStats.xpBySource[reason] then
            serverXPStats.xpBySource[reason] = 0
        end
        serverXPStats.xpBySource[reason] = serverXPStats.xpBySource[reason] + amount
        
        -- Track by level
        local level = playerXP[identifier].level
        if not serverXPStats.xpByLevel[level] then
            serverXPStats.xpByLevel[level] = 0
        end
        serverXPStats.xpByLevel[level] = serverXPStats.xpByLevel[level] + amount
        
        -- Trigger client to handle XP addition and level calculation
        TriggerClientEvent('xp_system:addXP', source, amount, reason)
        
        -- Log XP gain if significant
        if amount >= 500 then
            print("^3[XP_SYSTEM]^0 Player " .. GetPlayerName(source) .. " gained " .. amount .. " XP from " .. reason)
        end
    end
end

-- Enhanced level up handler with rewards based on level
RegisterNetEvent('xp_system:levelUp')
AddEventHandler('xp_system:levelUp', function (oldLevel, newLevel)
    -- Track level ups
    serverXPStats.levelUps = serverXPStats.levelUps + 1
    
    -- Broadcast level up to all players
    TriggerClientEvent('fxcode:utils:notify', -1, GetPlayerName 'source' .. " reached level " .. newLevel .. "!", "info")
    
    -- Update leaderboard on level up
    UpdateXPLeaderboard()
    
    -- Special rewards for milestone levels
    if newLevel % 10 == 0 then -- Every 10 levels
        -- Announce server-wide
        TriggerClientEvent('chat:addMessage', -1, {
            color = {255, 215, 0}, -- Gold color
            multiline = true,
            args = {"SERVER", GetPlayerName 'source' .. " has reached the impressive level " .. newLevel .. "!"}
        })
        
        -- Give special title or badge (only if the export exists)
        if exports['standalone-framework'] then
            exports['standalone-framework']:AddPlayerBadge(source, "level_" .. newLevel)
        end
    end
end)

-- Command to view XP leaderboard
RegisterCommand('xpleaderboard',function(source, args, rawCommand)
-- Update leaderboard
    UpdateXPLeaderboard()
    
    if source == 0 then
-- Console output
        print("XP Leaderboard:")
        for i, player in ipairs(xpLeaderboard) do
            if i <= 10 then -- Show top 10
                print(i .. ". " .. player.name .. " - Level " .. player.level .. " (" .. player.xp .. "/" .. (1000 * player.level) .. " XP)")
            end
        end
    else
-- Player output
        TriggerClientEvent('chat:addMessage', source, {
            color = {0, 150, 255},
            multiline = true,
            args = {"XP System", "XP Leaderboard:"}
        })
        
        for i, player in ipairs(xpLeaderboard) do
            if i <= 10 then -- Show top 10
                local message = i .. ". " .. player.name .. " - Level " .. player.level .. " (" .. player.xp .. "/" .. (1000 * player.level) .. " XP)"
                
                -- Highlight if it's the requesting player
                local playerIdentifier = GetPlayerIdentifier(source, 0)
                if playerIdentifier and player.identifier == playerIdentifier then
                    message = "^2" .. message .. "^7 (You)"
                end
                
                TriggerClientEvent('chat:addMessage', source, {
                    color = {255, 255, 255},
                    args = {"", message}
                })
            end
        end
        
        -- Show player's own position if not in top 10
        local playerIdentifier = GetPlayerIdentifier(source, 0)
        if playerIdentifier then
            local playerPosition = 0
            
            for i, player in ipairs(xpLeaderboard) do
                if player.identifier == playerIdentifier then
                    playerPosition = i
                    break
                end
            end
            
            if playerPosition > 10 then
                -- Check if player data exists before accessing it
                if playerXP[playerIdentifier] then
                    TriggerClientEvent('chat:addMessage', source, {
                        color = {255, 255, 255},
                        args = {"", "Your position: " .. playerPosition .. " - Level " .. playerXP[playerIdentifier].level .. " (" .. playerXP[playerIdentifier].xp .. "/" .. (1000 * playerXP[playerIdentifier].level) .. " XP)"}
                    })
                else
                    TriggerClientEvent('chat:addMessage', source, {
                        color = {255, 255, 255},
                        args = {"", "Your position: " .. playerPosition .. " - XP data not found"}
                    })
                end
            end
        else
            TriggerClientEvent('chat:addMessage', source, {
                color = {255, 0, 0},
                args = {"XP System", "Could not retrieve your identifier"}
            })
        end
    end
end, false)

-- Export enhanced functions
exports('AddPlayerXP', AddPlayerXP)
exports('GetXPLeaderboard', function() 
    UpdateXPLeaderboard()
    return xpLeaderboard
end)
exports('GetServerXPStats', function() 
    return serverXPStats
end)
