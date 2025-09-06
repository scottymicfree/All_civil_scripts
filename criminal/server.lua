-- Track criminal players
local criminals = {}

RegisterServerEvent("criminal:assignJob")
AddEventHandler("criminal:assignJob", function()
    local src = source
    
    -- Add player to criminals list
    criminals[src] = true
    
    -- Log assignment
    print(("[Criminal] Player %d assigned to criminal job."):format(src))
    
    -- Notify and teleport player
    TriggerClientEvent("criminal:notify", src, "You are now a criminal. Stay low!")
    TriggerClientEvent("criminal:spawn", src)
end)

-- Clean up when player disconnects
AddEventHandler('playerDropped', function(reason)
    local src = source
    if criminals[src] then
        criminals[src] = nil
        print(("[Criminal] Player %d is no longer a criminal (disconnected)."):format(src))
    end
end)
