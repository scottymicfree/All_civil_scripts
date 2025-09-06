-- Gang Management System
-- Handles player gangs and gang-related functionality

-- Track player gangs
local playerGangs = {}

-- Track gang territories
local gangTerritories = {
    ["ballas"] = {
        color = 7, -- Purple
        territories = {
            {name = "Davis", center = vector3(120.0, -1950.0, 20.0), radius = 100.0}
        }
    },
    ["families"] = {
        color = 2, -- Green
        territories = {
            {name = "Chamberlain Hills", center = vector3(-150.0, -1650.0, 30.0), radius = 100.0}
        }
    },
    ["vagos"] = {
        color = 5, -- Yellow
        territories = {
            {name = "Rancho", center = vector3(350.0, -2050.0, 22.0), radius = 100.0}
        }
    }
}

-- Set player gang
function setPlayerGang(source, gang, rank)
    if not source or not gang then return false end
    
    rank = rank or 1
    
    -- Store gang data
    playerGangs[source] = {
        name = gang,
        rank = rank,
        joinTime = os.time()
    }
    
    -- Notify player
    TriggerClientEvent('chat:addMessage', source, {
        color = {255, 0, 0},
        multiline = false,
        args = {"Gangs", "You are now a member of " .. gang .. " (Rank " .. rank .. ")"}
    })
    
    -- Log gang change
    exports['framework']:logAction(source, "GANG", "Gang set to " .. gang .. " (Rank " .. rank .. ")")
    
    -- Sync gang data to client
    TriggerClientEvent('cfw:syncGangData', source, gang, gangTerritories[gang] or {})
    
    return true
end

-- Get player gang
function getPlayerGang(source)
    if playerGangs[source] then
        return playerGangs[source].name
    end
    return nil
end

-- Get player gang rank
function getPlayerGangRank(source)
    if playerGangs[source] then
        return playerGangs[source].rank
    end
    return 0
end

-- Clean up player gang on disconnect
AddEventHandler('playerDropped', function()
    local source = source
    playerGangs[source] = nil
end)

-- Register gang commands
RegisterCommand('setgang', function(source, args, rawCommand)
    -- Check if command is run from console
    if source == 0 then
        if #args < 2 then
            print("Usage: setgang [playerId] [gang] [rank]")
            return
        end
        
        local targetId = tonumber(args[1])
        local gang = args[2]
        local rank = tonumber(args[3]) or 1
        
        if GetPlayerName(targetId) then
            setPlayerGang(targetId, gang, rank)
            print("Set " .. GetPlayerName(targetId) .. "'s gang to " .. gang .. " (Rank " .. rank .. ")")
        else
            print("Player not found")
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
                    args = {"Gangs", "Usage: /setgang [playerId] [gang] [rank]"}
                })
                return
            end
            
            local targetId = tonumber(args[1])
            local gang = args[2]
            local rank = tonumber(args[3]) or 1
            
            if GetPlayerName(targetId) then
                setPlayerGang(targetId, gang, rank)
                
                TriggerClientEvent('chat:addMessage', source, {
                    color = {0, 255, 0},
                    multiline = false,
                    args = {"Gangs", "Set " .. GetPlayerName(targetId) .. "'s gang to " .. gang .. " (Rank " .. rank .. ")"}
                })
            else
                TriggerClientEvent('chat:addMessage', source, {
                    color = {255, 0, 0},
                    multiline = false,
                    args = {"Gangs", "Player not found"}
                })
            end
        else
            TriggerClientEvent('chat:addMessage', source, {
                color = {255, 0, 0},
                multiline = false,
                args = {"Gangs", "You don't have permission to use this command"}
            })
        end
    end
end, false)

-- Register gang info command
RegisterCommand('gang', function(source, args, rawCommand)
    if source > 0 then
        local gang = getPlayerGang(source)
        
        if gang then
            local rank = getPlayerGangRank(source)
            
            TriggerClientEvent('chat:addMessage', source, {
                color = {255, 0, 0},
                multiline = false,
                args = {"Gangs", "You are a member of " .. gang .. " (Rank " .. rank .. ")"}
            })
        else
            TriggerClientEvent('chat:addMessage', source, {
                color = {255, 0, 0},
                multiline = false,
                args = {"Gangs", "You are not in a gang"}
            })
        end
    end
end, false)

-- Export functions
exports('setPlayerGang', setPlayerGang)
exports('getPlayerGang', getPlayerGang)
exports('getPlayerGangRank', getPlayerGangRank)
exports('getGangTerritories', function() return gangTerritories end)
