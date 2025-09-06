-- Dispatcher System
-- Handles emergency notifications and responses

-- Notification handlers
-- At the top of dispatcher.lua
local function showNotification(message, type)
    if exports['mythic_notify'] then
        exports['mythic_notify']:DoCustomHudText(type or 'inform', message, Config.NotificationDuration)
    else
        SetNotificationTextEntry('STRING')
        AddTextComponentString(message)
        DrawNotification(false, false)
    end
end


RegisterNetEvent('cfw:notifyDispatch')
AddEventHandler('cfw:notifyDispatch', function(message)
    -- Check if player has police job
    local playerJob = exports['standalone-framework']:GetPlayerJob(PlayerId())
    
    if playerJob == "police" then
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            multiline = true,
            args = {"Dispatch", message}
        })
        
        -- Play dispatch sound
        PlaySoundFrontend(-1, "Beep_Red", "DLC_HEIST_HACKING_SNAKE_SOUNDS", 1)
        
        -- Add blip to map (would need coordinates from server)
        -- This is a placeholder for actual implementation
        showNotification("New dispatch call received!", "inform")
    end
end)

RegisterNetEvent('cfw:notifyEMS')
AddEventHandler('cfw:notifyEMS', function(message)
    -- Check if player has EMS job
    local playerJob = exports['standalone-framework']:GetPlayerJob()
    
    if playerJob == "ems" then
        TriggerEvent('chat:addMessage', {
            color = {0, 255, 0},
            multiline = true,
            args = {"EMS", message}
        })
        
        -- Play EMS alert sound
        PlaySoundFrontend(-1, "Beep_Green", "DLC_HEIST_HACKING_SNAKE_SOUNDS", 1)
        
        -- Add blip to map (would need coordinates from server)
        -- This is a placeholder for actual implementation
        showNotification("New EMS call received!", "inform")
    end
end)

-- Healing system
RegisterNetEvent('cfw:healPlayer')
AddEventHandler('cfw:healPlayer', function()
    local playerPed = PlayerPedId()
    
    -- Healing animation
    RequestAnimDict("mini@cpr@char_a@cpr_str")
    while not HasAnimDictLoaded("mini@cpr@char_a@cpr_str") do
        Citizen.Wait(10)
    end
    
    TaskPlayAnim(playerPed, "mini@cpr@char_a@cpr_str", "cpr_pumpchest", 8.0, -8.0, 5000, 0, 0, false, false, false)
    
    -- Wait for animation
    Citizen.Wait(5000)
    
    -- Apply healing effects
    ClearPedBloodDamage(playerPed)
    ResetPedVisibleDamage(playerPed)
    ClearPedLastDamageBone(playerPed)
    SetEntityHealth(playerPed, GetEntityMaxHealth(playerPed))
    
    -- Notify player
    showNotification("You have been healed by EMS.", "success")
end)

-- Request backup function for police
RegisterNetEvent('cfw:requestBackup')
AddEventHandler('cfw:requestBackup', function(coords, reason)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    TriggerServerEvent('cfw:sendBackupRequest', playerCoords, reason or "Officer requesting backup")
end)

-- Command to request police backup
RegisterCommand('backup', function(source, args, rawCommand)
    local reason = table.concat(args, " ") or "Officer requesting backup"
    TriggerEvent('cfw:requestBackup', nil, reason)
end, false)

-- Command to request EMS
RegisterCommand('ems', function(source, args, rawCommand)
    local reason = table.concat(args, " ") or "Medical assistance needed"
    TriggerServerEvent('cfw:requestEMS', reason)
end, false)
