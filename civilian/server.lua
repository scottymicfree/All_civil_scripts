-- Track players who have the civilian job
local civilianPlayers = {}

-- Event to assign civilian job
RegisterServerEvent("civilian:assignJob")
AddEventHandler("civilian:assignJob", function()
    local src = source
    
    -- Check if player is already a civilian
    if civilianPlayers[src] then
        TriggerClientEvent("civilian:notify", src, "~y~You are already a civilian")
        return
    end
    
    -- Add player to civilians list
    civilianPlayers[src] = true
    
    -- Log and notify
    print(("[Civilian] Player %d assigned to civilian role"):format(src))
    TriggerClientEvent("civilian:notify", src, "You are now working as a civilian.")
    
    -- Trigger spawn after a short delay
    Citizen.Wait(500)
    TriggerClientEvent("civilian:spawn", src)
end)

-- Clean up when player disconnects
AddEventHandler('playerDropped', function()
    local src = source
    if civilianPlayers[src] then
        civilianPlayers[src] = nil
        print(("[Civilian] Player %d removed from civilian job (disconnected)."):format(src))
    end
end)

-- Server startup message
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        print('[Civilian] Job script started successfully')
    end
end)
