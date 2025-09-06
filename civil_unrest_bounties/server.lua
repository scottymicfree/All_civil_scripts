-- Server-side bounty hunter system for Civil Unrest RP
local playerXP = {} -- In-memory XP storage

-- Get player's bounty hunter XP
function GetPlayerBountyXP(source)
    return playerXP[source] or 0
end

-- Add XP to player
function AddPlayerBountyXP(source, amount)
    playerXP[source] = (playerXP[source] or 0) + amount
    return playerXP[source]
end

-- Request a bounty mission
RegisterServerEvent('civil_unrest_bounties:requestMission')
AddEventHandler('civil_unrest_bounties:requestMission', function()
    local src = source
    local xp = GetPlayerBountyXP(src)
    local level = 1
    
    -- Determine level based on XP
    if xp >= 100 then 
        level = 3
    elseif xp >= 50 then 
        level = 2 
    end
    
    -- Get targets for this level
    local targets = Config.Levels[level].targets
    local target = targets[math.random(#targets)]
    
    -- Add some randomization to position
    local pos = target.pos
    local randomOffset = vector3(
        math.random(-20, 20) / 10,
        math.random(-20, 20) / 10,
        0.0
    )
    target.pos = pos + randomOffset
    
    -- Send mission to client
    TriggerClientEvent('civil_unrest_bounties:startMission', src, level, target)
end)

-- Complete a bounty mission
RegisterServerEvent('civil_unrest_bounties:completeMission')
AddEventHandler('civil_unrest_bounties:completeMission', function(level, alive)
    local src = source
    local reward = Config.Levels[level].reward
    
    -- Bonus for bringing target in alive
    if alive then
        reward = reward * 1.5
    end
    
    -- Add XP
    local newXP = AddPlayerBountyXP(src, reward)
    
    -- Add money reward through framework
    exports['standalone-framework']:AddMoney(src, reward * 20) -- $20 per XP point
    
    -- Notify player
    local message = string.format("Mission complete! +%d XP. Total: %d XP", reward, newXP)
    TriggerClientEvent('civil_unrest_bounties:notify', src, message)
    
    -- Check for level up
    if (newXP - reward) < 50 and newXP >= 50 then
        TriggerClientEvent('civil_unrest_bounties:notify', src, "Level up! You're now an Intermediate Bounty Hunter.")
    elseif (newXP - reward) < 100 and newXP >= 100 then
        TriggerClientEvent('civil_unrest_bounties:notify', src, "Level up! You're now an Advanced Bounty Hunter.")
    end
end)

-- Save XP when player disconnects (optional, for persistence)
AddEventHandler('playerDropped', function(reason)
    local src = source
    -- Here you could save playerXP[src] to a database
    -- For example: MySQL.Async.execute('UPDATE players SET bounty_xp = @xp WHERE identifier = @id', {['@xp'] = playerXP[src], ['@id'] = GetPlayerIdentifier(src)})
end)
