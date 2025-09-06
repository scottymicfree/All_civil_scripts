print('[Base Resource] Server loaded.')

-- Initialize framework (with error handling)
AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        -- Try to load the framework, but don't crash if it's not available
        local frameworkLoaded = false
        local attempts = 0
        local maxAttempts = 10
        
        while not frameworkLoaded and attempts < maxAttempts do
            attempts = attempts + 1
            
            -- Check if the export exists
            if exports['standalone-framework'] then
                Framework = exports['standalone-framework']
                frameworkLoaded = true
                if Config and Config.Settings and Config.Settings.debug then
                    print('[Base Resource] Framework loaded.')
                end
            else
                Citizen.Wait(1000)
            end
        end
        
        if not frameworkLoaded then
            print('[Base Resource] Warning: Could not load framework after multiple attempts.')
        end
        
        -- Register for job change events
        RegisterForJobChangeEvents()
    end
end)

-- Register for job change events
function RegisterForJobChangeEvents()
    -- Check if job_wheel resource is available
    if GetResourceState('job_wheel') == 'started' then
        print('[Base Resource] Job wheel resource detected, registering for events.')
    else
        print('[Base Resource] Job wheel resource not detected.')
    end
    
    -- Check if custom-job-blips resource is available
    if GetResourceState('custom-job-blips') == 'started' then
        print('[Base Resource] Custom job blips resource detected, registering for events.')
    else
        print('[Base Resource] Custom job blips resource not detected.')
    end
end

-- Job change event handler
RegisterNetEvent('jobwheel:setJob')
AddEventHandler('jobwheel:setJob', function(job)
    local src = source
    
    -- Check if Config exists before using it
    if Config and Config.Settings and Config.Settings.debug then
        print(string.format('[Base Resource] Job change detected for player %d: %s', src, job))
    end
    
    -- Notify the player
    TriggerClientEvent('base:jobChanged', src, job)
    
    -- Forward to custom-job-blips if available
    if GetResourceState('custom-job-blips') == 'started' then
        TriggerEvent('custom-job-blips:setJob', src, job)
    end
end)

-- Example server event
RegisterServerEvent('base:serverEvent')
AddEventHandler('base:serverEvent', function(data)
    local src = source
    
    -- Check if Config exists before using it
    if Config and Config.Settings and Config.Settings.debug then
        print(string.format('[Base Resource] Server event from %d: %s', src, json.encode(data)))
    end
    
    TriggerClientEvent('chat:addMessage', src, {
        color = {255, 0, 0},
        args = {'Server', 'Event received: ' .. json.encode(data)}
    })
end)

-- Open job wheel command
RegisterCommand('jobwheel', function(source, args, rawCommand)
    if source > 0 then
        -- Check if job_wheel resource is available
        if GetResourceState('job_wheel') == 'started' then
            -- Get player gender (default to male)
            local gender = "male"
            
            -- Try to get gender from framework if available
            if Framework and Framework.GetPlayerGender then
                gender = Framework.GetPlayerGender(source) or "male"
            end
            
            -- Trigger job wheel
            exports['job_wheel']:TriggerJobWheel(source, gender)
        else
            TriggerClientEvent('chat:addMessage', source, {
                color = {255, 0, 0},
                args = {'Server', 'Job wheel resource is not available'}
            })
        end
    end
end, false)

-- Cleanup on player disconnect
AddEventHandler('playerDropped', function()
    local src = source
    
    -- Check if Config exists before using it
    if Config and Config.Settings and Config.Settings.debug then
        print(string.format('[Base Resource] Player %d disconnected', src))
    end
end)
