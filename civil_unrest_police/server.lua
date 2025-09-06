-- Police System - Server Side
-- This script handles server-side police functionality

-- Handle crime report
RegisterNetEvent("civil_unrest_police:reportCrime")
AddEventHandler("civil_unrest_police:reportCrime", function()
    local src = source
    
    -- Notify player
    TriggerClientEvent('fxcode:utils:notify', src, "You reported a crime to the police", "success")
    
    -- Log report
    print("[POLICE] Player " .. GetPlayerName(src) .. " reported a crime")
    
    -- Add XP for reporting crime
    exports['xp_system']:AddPlayerXP(src, 50, "Reporting Crime")
end)

-- Handle ticket payment
RegisterNetEvent("civil_unrest_police:payTicket")
AddEventHandler("civil_unrest_police:payTicket", function()
    local src = source
    
    -- Check if player has any tickets
    local hasTicket = math.random() < 0.5 -- 50% chance to have a ticket (replace with actual logic)
    
    if hasTicket then
        -- Calculate ticket amount
        local ticketAmount = math.random(100, 500)
        
        -- Check if player has enough money
        local playerMoney = exports['standalone-framework']:GetPlayerValue(src, 'money') or 0
        
        if playerMoney >= ticketAmount then
            -- Remove money from player
            local success = exports['standalone-framework']:RemoveMoney(src, ticketAmount)
            
            if success then
                -- Notify player
                TriggerClientEvent('fxcode:utils:notify', src, "You paid a ticket of $" .. ticketAmount, "success")
                
                -- Log payment
                print("[POLICE] Player " .. GetPlayerName(src) .. " paid a ticket of $" .. ticketAmount)
            else
                TriggerClientEvent('fxcode:utils:notify', src, "Failed to process ticket payment", "error")
            end
        else
            TriggerClientEvent('fxcode:utils:notify', src, "You don't have enough money to pay the ticket", "error")
        end
    else
        TriggerClientEvent('fxcode:utils:notify', src, "You don't have any outstanding tickets", "info")
    end
end)

-- Handle assistance request
RegisterNetEvent("civil_unrest_police:requestAssistance")
AddEventHandler("civil_unrest_police:requestAssistance", function(coords)
    local src = source
    
    -- Broadcast assistance request to all players (for client-side NPC spawning)
    TriggerClientEvent('civil_unrest_police:spawnAssistance', -1, coords)
    
    -- Notify player
    TriggerClientEvent('fxcode:utils:notify', src, "Police assistance is on the way", "success")
    
    -- Log assistance request
    print("[POLICE] Player " .. GetPlayerName(src) .. " requested police assistance")
end)

-- Handle bribe attempt
RegisterNetEvent("civil_unrest_police:attemptBribe")
AddEventHandler("civil_unrest_police:attemptBribe", function()
    local src = source
    
    -- Calculate bribe amount
    local bribeAmount = 1000 -- $1000 bribe
    
    -- Check if player has enough money
    local playerMoney = exports['standalone-framework']:GetPlayerValue(src, 'money') or 0
    
    if playerMoney >= bribeAmount then
        -- Check if bribe is successful (70% chance)
        local bribeSuccess = math.random() < 0.7
        
        if bribeSuccess then
            -- Remove money from player
            local success = exports['standalone-framework']:RemoveMoney(src, bribeAmount)
            
            if success then
                -- Clear wanted level
                TriggerClientEvent('civil_unrest_police:clearWantedLevel', src)
                
                -- Notify player
                TriggerClientEvent('fxcode:utils:notify', src, "Your bribe was accepted. Wanted level cleared.", "success")
                
                -- Log bribe
                print("[POLICE] Player " .. GetPlayerName(src) .. " successfully bribed police for $" .. bribeAmount)
            else
                TriggerClientEvent('fxcode:utils:notify', src, "Failed to process bribe payment", "error")
            end
        else
            -- Remove money from player (still takes the money but bribe fails)
            local success = exports['standalone-framework']:RemoveMoney(src, bribeAmount)
            
            if success then
                -- Increase wanted level
                TriggerClientEvent('civil_unrest_police:increaseWantedLevel', src)
                
                -- Notify player
                TriggerClientEvent('fxcode:utils:notify', src, "Your bribe was rejected! Wanted level increased.", "error")
                
                -- Log failed bribe
                print("[POLICE] Player " .. GetPlayerName(src) .. " failed to bribe police and lost $" .. bribeAmount)
            else
                TriggerClientEvent('fxcode:utils:notify', src, "Failed to process bribe payment", "error")
            end
        end
    else
        TriggerClientEvent('fxcode:utils:notify', src, "You don't have enough money to bribe the officer", "error")
    end
end)