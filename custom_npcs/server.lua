-- Handle giving money to homeless
RegisterServerEvent("custom_npcs:giveMoney")
AddEventHandler("custom_npcs:giveMoney", function(amount)
    local src = source
    
    -- Check if player has enough money (using your framework)
    if exports['standalone-framework']:GetPlayerMoney(src) >= amount then
        -- Remove money from player
        exports['standalone-framework']:RemoveMoney(src, amount)
        
        -- Add karma or reputation (optional)
        exports['standalone-framework']:AddPlayerStat(src, "karma", 1)
        
        -- Notify player
        TriggerClientEvent("chat:addMessage", src, {
            color = {0, 255, 0},
            multiline = false,
            args = {"System", "You gave $" .. amount .. " to the homeless man. You feel good about yourself."}
        })
    else
        -- Not enough money
        TriggerClientEvent("chat:addMessage", src, {
            color = {255, 0, 0},
            multiline = false,
            args = {"System", "You don't have enough money."}
        })
    end
end)

-- Handle vehicle repair
RegisterServerEvent("custom_npcs:repairVehicle")
AddEventHandler("custom_npcs:repairVehicle", function(price)
    local src = source
    
    -- Check if player has enough money
    if exports['standalone-framework']:GetPlayerMoney(src) >= price then
        -- Remove money from player
        exports['standalone-framework']:RemoveMoney(src, price)
        
        -- Repair vehicle on client
        TriggerClientEvent("custom_npcs:repairVehicleClient", src)
        
        -- Notify player
        TriggerClientEvent("chat:addMessage", src, {
            color = {0, 255, 0},
            multiline = false,
            args = {"Mechanic", "Your vehicle has been repaired for $" .. price .. "."}
        })
    else
        -- Not enough money
        TriggerClientEvent("chat:addMessage", src, {
            color = {255, 0, 0},
            multiline = false,
            args = {"Mechanic", "You don't have enough money for repairs."}
        })
    end
end)
