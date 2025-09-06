-- NPC Services Server Script

-- Handle service requests
RegisterNetEvent('npc_services:requestService')
AddEventHandler('npc_services:requestService', function(serviceType, service, price)
    local src = source
    
    -- Check if player can afford the service
    local canAfford = false
    
    -- Use standalone-framework to check player money
    if GetResourceState('standalone-framework') == 'started' then
        local playerMoney = exports['standalone-framework']:GetPlayerValue(src, 'money') or 0
        canAfford = playerMoney >= price
        
        if canAfford then
            -- Deduct money
            exports['standalone-framework']:RemoveMoney(src, price)
            
            -- Approve service
            TriggerClientEvent('npc_services:serviceApproved', src, serviceType, service)
            
            -- Log transaction
            print("[NPC Services] Player " .. GetPlayerName(src) .. " paid $" .. price .. " for " .. serviceType .. " service: " .. service)
        else
            -- Deny service
            TriggerClientEvent('npc_services:serviceDenied', src, "You don't have enough money. You need $" .. price .. ".")
        end
    else
        -- If framework is not available, approve anyway for testing
        TriggerClientEvent('npc_services:serviceApproved', src, serviceType, service)
        print("[NPC Services] WARNING: standalone-framework not found, service approved without payment")
    end
end)
