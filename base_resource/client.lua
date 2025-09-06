print('[Base Resource] Client loaded.')

-- Initialize framework (with error handling)
Citizen.CreateThread(function()
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
end)

-- Example command handler
RegisterCommand('base', function(source, args, rawCommand)
    local action = args[1] or 'test'
    
    -- Check if Config exists before using it
    if Config and Config.Settings and Config.Settings.debug then
        print(string.format('[Base Resource] Command executed: /base %s', action))
    end

    if action == 'test' then
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        ShowNotification(string.format('Position: X: %.2f, Y: %.2f, Z: %.2f', coords.x, coords.y, coords.z))
    elseif action == 'jobwheel' then
        -- Trigger job wheel if available
        if GetResourceState('job_wheel') == 'started' then
            exports['job_wheel']:TriggerJobWheel()
        else
            ShowNotification('Job wheel resource is not available')
        end
    elseif action == 'blips' then
        -- Request job blips update if available
        if GetResourceState('custom-job-blips') == 'started' then
            TriggerServerEvent('custom-job-blips:getPlayerJob')
        else
            ShowNotification('Custom job blips resource is not available')
        end
    end
end, false)

-- Job wheel integration
RegisterNetEvent('base:openJobWheel')
AddEventHandler('base:openJobWheel', function()
    if GetResourceState('job_wheel') == 'started' then
        exports['job_wheel']:TriggerJobWheel()
    else
        ShowNotification('Job wheel resource is not available')
    end
end)

-- Job change notification
RegisterNetEvent('base:jobChanged')
AddEventHandler('base:jobChanged', function(job)
    ShowNotification('Job changed to: ' .. job)
    
    -- Update job blips if available
    if GetResourceState('custom-job-blips') == 'started' then
        TriggerServerEvent('custom-job-blips:getPlayerJob')
    end
end)

-- Controller input for job wheel
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        -- D-pad Right: Open job wheel (if not already handled by job_wheel resource)
        if IsControlJustPressed(0, 307) then -- D-pad right
            TriggerEvent('base:openJobWheel')
        end
    end
end)

-- Example update loop
Citizen.CreateThread(function()
    -- Wait for Config to be loaded
    Citizen.Wait(1000)
    
    while true do
        -- Check if Config exists before using it
        if Config and Config.Settings and Config.Settings.debug then
            -- Reduced debug spam
            -- print('[Base Resource] Running update loop...')
        end
        
        -- Use a default value if Config doesn't exist
        local interval = Config and Config.Settings and Config.Settings.updateInterval or 5000
        Citizen.Wait(interval)
    end
end)

-- Notification function
function ShowNotification(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandThefeedPostTicker(true, false)
end
