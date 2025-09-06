-- bounty_mission/server.lua
local playerData = {} -- {playerSrc = {gender, xp, missionActive}}

function HasBountyPermission(src)
    if not src or type(src) ~= "number" then
        print("[Bounty Mission] Error: Invalid src value: " .. tostring(src))
        return false
    end
    return IsPlayerAceAllowed(src, 'bounty.hunter')
end

RegisterServerEvent('bounty:getGender')
AddEventHandler('bounty:getGender', function()
    local src = source
    if not src then
        print("[Bounty Mission] Error: No source for bounty:getGender")
        return
    end
    
    -- Check permission
    if not HasBountyPermission(src) then
        TriggerClientEvent('bounty:notify', src, 'You lack permission for bounty hunting.')
        return
    end

    -- Get or set gender
    local gender = playerData[src] and playerData[src].gender or nil
    if not gender then
        TriggerClientEvent('bounty:selectGender', src)
    else
        TriggerClientEvent('bounty:startBountyMission', src, gender)
    end
end)

RegisterServerEvent('bounty:setGender')
AddEventHandler('bounty:setGender', function(gender)
    local src = source
    if not src then
        print("[Bounty Mission] Error: No source for bounty:setGender")
        return
    end
    
    -- Check permission
    if not HasBountyPermission(src) then
        TriggerClientEvent('bounty:notify', src, 'You lack permission for bounty hunting.')
        return
    end
    
    -- Validate gender
    if not gender or (gender ~= "male" and gender ~= "female") then
        print("[Bounty Mission] Error: Invalid gender: " .. tostring(gender))
        TriggerClientEvent('bounty:notify', src, 'Invalid gender selection.')
        return
    }
    
    -- Set gender and start mission
    playerData[src] = playerData[src] or {}
    playerData[src].gender = gender
    TriggerClientEvent('bounty:startBountyMission', src, gender)
end)

RegisterServerEvent('bounty:acceptMission')
AddEventHandler('bounty:acceptMission', function()
    local src = source
    if not src then
        print("[Bounty Mission] Error: No source for bounty:acceptMission")
        return
    end
    
    -- Check permission and data
    if not HasBountyPermission(src) or not playerData[src] then
        TriggerClientEvent('bounty:notify', src, 'You lack permission or data not found.')
        return
    }
    
    -- Set mission active
    playerData[src].missionActive = true

    -- Determine mission level based on XP
    local xp = playerData[src].xp or 0
    local level = 1
    if xp >= 100 then
        level = 3
    elseif xp >= 50 then
        level = 2
    end

    -- Define target locations
    local targets = {
        { model = 'a_m_y_hiker_01',    pos = vector3(100.0, 100.0, 30.0) },
        { model = 'a_m_y_business_02', pos = vector3(200.0, 200.0, 30.0) },
        { model = 'a_m_y_mexthug_01',  pos = vector3(300.0, 300.0, 30.0) }
    }
    local target = targets[level]

    -- Start mission
    TriggerClientEvent('bounty:runMission', src, level, target)
end)

RegisterServerEvent('bounty:completeMission')
AddEventHandler('bounty:completeMission', function()
    local src = source
    if not src then
        print("[Bounty Mission] Error: No source for bounty:completeMission")
        return
    end
    
    -- Check permission and mission state
    if not HasBountyPermission(src) or not playerData[src] or not playerData[src].missionActive then
        TriggerClientEvent('bounty:notify', src, 'Invalid mission state.')
        return
    }
    
    -- Award XP and reset mission state
    playerData[src].xp = (playerData[src].xp or 0) + 25
    playerData[src].missionActive = false
    TriggerClientEvent('bounty:notify', src, 'Mission complete! +25 XP. Total: ' .. playerData[src].xp)
    
    -- Trigger job wheel
    if playerData[src].gender then
        exports['job_wheel']:TriggerJobWheel(src, playerData[src].gender)
    else
        print("[Bounty Mission] Error: No gender for src " .. src .. " during job wheel trigger")
        TriggerClientEvent('bounty:notify', src, 'Error: Gender not set.')
    end
end)

RegisterServerEvent('bounty:playerDied')
AddEventHandler('bounty:playerDied', function()
    local src = source
    if not src then
        print("[Bounty Mission] Error: No source for bounty:playerDied")
        return
    end
    
    -- Check permission and mission state
    if not HasBountyPermission(src) or not playerData[src] or not playerData[src].missionActive then
        TriggerClientEvent('bounty:notify', src, 'Invalid mission state.')
        return
    }
    
    -- Reset mission state
    playerData[src].missionActive = false
    TriggerClientEvent('bounty:notify', src, 'You died. Mission failed.')
    
    -- Trigger job wheel
    if playerData[src].gender then
        exports['job_wheel']:TriggerJobWheel(src, playerData[src].gender)
    else
        print("[Bounty Mission] Error: No gender for src " .. src .. " during job wheel trigger")
        TriggerClientEvent('bounty:notify', src, 'Error: Gender not set.')
    end
end)

-- Clean up disconnected players
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60000)
        for src, _ in pairs(playerData) do
            if not GetPlayerEndpoint(src) then -- Check if player is still connected
                playerData[src] = nil
                print("[Bounty Mission] Cleaned up data for disconnected player: " .. src)
            end
        end
    end
end)
