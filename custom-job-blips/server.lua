print('[CUSTOM-JOB-BLIPS] Server script loaded.')

-- Player jobs table
local playerJobs = {}

-- Event to get player job
RegisterNetEvent('custom-job-blips:getPlayerJob')
AddEventHandler('custom-job-blips:getPlayerJob', function()
    local src = source
    local job = playerJobs[tostring(src)] or "unemployed"
    -- Send job to client
    TriggerClientEvent('custom-job-blips:setJob', src, job)
end)

-- Event to set player job
RegisterNetEvent('custom-job-blips:setJob')
AddEventHandler('custom-job-blips:setJob', function(job)
    local src = source
    -- Validate job (you can add more validation here)
    if type(job) == "string" then
        -- Store job
        playerJobs[tostring(src)] = job
        -- Send job to client
        TriggerClientEvent('custom-job-blips:setJob', src, job)
        -- Log job change
        print(string.format("[CUSTOM-JOB-BLIPS] Player %s (%d) job set to: %s", GetPlayerName(src), src, job))
    end
end)

-- Register command to set job
RegisterCommand("setjob", function(source, args, rawCommand)
    if source > 0 and args[1] then
        -- Set job
        local job = args[1]
        playerJobs[tostring(source)] = job
        -- Send job to client
        TriggerClientEvent('custom-job-blips:setJob', source, job)
        -- Log job change
        print(string.format("[CUSTOM-JOB-BLIPS] Player %s (%d) job set to: %s", GetPlayerName(source), source, job))
    end
end, false)

-- Listen for job wheel job changes
RegisterNetEvent('jobwheel:setJob')
AddEventHandler('jobwheel:setJob', function(job)
    local src = source
    if type(job) == "string" then
        -- Store job
        playerJobs[tostring(src)] = job
        -- Send job to client
        TriggerClientEvent('custom-job-blips:setJob', src, job)
        -- Broadcast job change to all clients
        TriggerClientEvent('jobwheel:jobChanged', -1, job)
        -- Log job change
        print(string.format("[CUSTOM-JOB-BLIPS] Player %s (%d) job set to: %s via job wheel", GetPlayerName(src), src, job))
    end
end)

-- Player disconnected
AddEventHandler('playerDropped', function()
    local src = source
    -- Clean up player job
    playerJobs[tostring(src)] = nil
end)
-- Add this to the end of your custom-job-blips/server.lua file

-- Integration with base_resource
AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        -- Check if base_resource is available
        if GetResourceState('base_resource') == 'started' then
            print('[Custom Job Blips] Base resource detected, registering integration.')
            
            -- Register job blips with base_resource
            TriggerEvent('base_resource:registerJobBlips')
        end
    end
end)

-- Event to notify base_resource of job blip updates
RegisterNetEvent('custom-job-blips:notifyBaseResource')
AddEventHandler('custom-job-blips:notifyBaseResource', function(job)
    local src = source
    
    -- Check if base_resource is available
    if GetResourceState('base_resource') == 'started' then
        -- Notify base_resource of job blip update
        TriggerEvent('base_resource:jobBlipsUpdated', src, job)
    end
end)


print('[CUSTOM-JOB-BLIPS] Server initialized.')
