-- job_wheel/server.lua
local playerData = {} -- {playerSrc = {lastJobUpdate}}

function HasBountyPermission(src)
    if not src or type(src) ~= "number" then
        print("[Job Wheel] Error: Invalid src value: " .. tostring(src))
        return false
    end
    return IsPlayerAceAllowed(src, 'bounty.hunter')
end

RegisterServerEvent('jobwheel:setJob')
AddEventHandler('jobwheel:setJob', function(job)
    local src = source
    if not src then
        print("[Job Wheel] Error: No source for jobwheel:setJob")
        return
    end
    
    -- Check permission
    if not HasBountyPermission(src) then
        TriggerClientEvent('jobwheel:notify', src, 'You lack permission for job selection.')
        return
    end
    
    -- Validate job
    if not job or type(job) ~= "string" then
        print("[Job Wheel] Error: Invalid job: " .. tostring(job))
        TriggerClientEvent('jobwheel:notify', src, 'Invalid job selection.')
        return
    end
    
    -- Set job
    local success = exports['standalone-framework']:SetPlayerJob(src, job)
    if success then
        playerData[src] = playerData[src] or {}
        playerData[src].lastJobUpdate = GetGameTimer()
        TriggerClientEvent('jobwheel:setupJob', src, job)
        
        -- Notify custom-job-blips about job change if the resource is running
        if GetResourceState('custom-job-blips') == 'started' then
            TriggerClientEvent('custom-job-blips:setJob', src, job)
            -- Broadcast job change to all clients for custom-job-blips
            TriggerClientEvent('jobwheel:jobChanged', -1, job)
        end
        
        print("[Job Wheel] Player " .. GetPlayerName(src) .. " set job to: " .. job)
    else
        TriggerClientEvent('jobwheel:notify', src, 'Failed to set job: ' .. job)
        print("[Job Wheel] Failed to set job for player " .. GetPlayerName(src) .. ": " .. job)
    end
end)

function TriggerJobWheel(src, gender)
    if not src then
        print("[Job Wheel] Error: No src provided to TriggerJobWheel")
        return
    end
    
    -- Check permission
    if not HasBountyPermission(src) then
        TriggerClientEvent('jobwheel:notify', src, 'You lack permission for job selection.')
        return
    end
    
    -- Validate gender
    if not gender then
        print("[Job Wheel] Error: No gender provided for src " .. src)
        TriggerClientEvent('jobwheel:notify', src, 'Error: Gender not set.')
        return
    end
    
    -- Trigger job wheel
    TriggerClientEvent('jobwheel:showJobWheel', src, gender)
end

-- Register server event to handle job wheel job changes for custom-job-blips
RegisterServerEvent('jobwheel:notifyJobBlips')
AddEventHandler('jobwheel:notifyJobBlips', function(job)
    local src = source
    if GetResourceState('custom-job-blips') == 'started' then
        -- Notify custom-job-blips about job change
        TriggerEvent('custom-job-blips:setJob', src, job)
    end
end)

-- Clean up disconnected players and expired job blips
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60000)
        for src, data in pairs(playerData) do
            if not GetPlayerEndpoint(src) then -- Check if player is still connected
                playerData[src] = nil
                print("[Job Wheel] Cleaned up data for disconnected player: " .. src)
            elseif data.lastJobUpdate and (GetGameTimer() - data.lastJobUpdate) > 300000 then
                TriggerClientEvent('jobwheel:clearJobBlips', src)
                data.lastJobUpdate = nil
                print("[Job Wheel] Cleared job blips for player: " .. src)
            end
        end
    end
end)

-- Add this to the end of your job_wheel/server.lua file

-- Integration with base_resource
AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        -- Check if base_resource is available
        if GetResourceState('base_resource') == 'started' then
            print('[Job Wheel] Base resource detected, registering integration.')
            
            -- Register job wheel with base_resource
            TriggerEvent('base_resource:registerJobWheel')
        end
    end
end)

-- Event to notify base_resource of job changes
RegisterNetEvent('jobwheel:notifyBaseResource')
AddEventHandler('jobwheel:notifyBaseResource', function(job)
    local src = source
    
    -- Check if base_resource is available
    if GetResourceState('base_resource') == 'started' then
        -- Notify base_resource of job change
        TriggerEvent('base_resource:jobChanged', src, job)
    end
end)


-- Export the function
exports('TriggerJobWheel', TriggerJobWheel)
