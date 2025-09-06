-- Fire Department System - Server Side
-- This script handles server-side fire department functionality

-- Handle fire report
RegisterNetEvent("civil_unrest_fire:reportFire")
AddEventHandler("civil_unrest_fire:reportFire", function()
    local src = source
    
    -- Get player position
    local playerPed = GetPlayerPed(src)
    local playerCoords = GetEntityCoords(playerPed)
    
    -- Broadcast fire response to all players (for client-side NPC spawning)
    TriggerClientEvent('civil_unrest_fire:triggerFireResponse', -1, playerCoords)
    
    -- Notify player
    TriggerClientEvent('fxcode:utils:notify', src, "Fire department has been notified", "success")
    
    -- Add XP for reporting fire
    exports['xp_system']:AddPlayerXP(src, 50, "Reporting Fire")
    
    -- Log report
    print("[FIRE] Player " .. GetPlayerName(src) .. " reported a fire")
end)

-- Handle safety check request
RegisterNetEvent("civil_unrest_fire:requestSafetyCheck")
AddEventHandler("civil_unrest_fire:requestSafetyCheck", function()
    local src = source
    
    -- Check if player has enough money
    local checkCost = 50 -- $50 for safety check
    local playerMoney = exports['standalone-framework']:GetPlayerValue(src, 'money') or 0
    
    if playerMoney >= checkCost then
        -- Remove money from player
        local success = exports['standalone-framework']:RemoveMoney(src, checkCost)
        
        if success then
            -- Notify player
            TriggerClientEvent('fxcode:utils:notify', src, "Fire safety check scheduled for $" .. checkCost, "success")
            
            -- Add XP for requesting safety check
            exports['xp_system']:AddPlayerXP(src, 20, "Fire Safety Check")
            
            -- Log safety check
            print("[FIRE] Player " .. GetPlayerName(src) .. " requested a fire safety check")
        else
            TriggerClientEvent('fxcode:utils:notify', src, "Failed to process payment", "error")
        end
    else
        TriggerClientEvent('fxcode:utils:notify', src, "You don't have enough money for a safety check", "error")
    end
end)

-- Handle volunteer request
RegisterNetEvent("civil_unrest_fire:volunteer")
AddEventHandler("civil_unrest_fire:volunteer", function()
    local src = source
    
    -- Add XP for volunteering
    exports['xp_system']:AddPlayerXP(src, 50, "Fire Department Volunteering")
    
    -- Notify player
    TriggerClientEvent('fxcode:utils:notify', src, "Thank you for volunteering! You earned 50 XP", "success")
    
    -- Log volunteering
    print("[FIRE] Player " .. GetPlayerName(src) .. " volunteered with the fire department")
end)

-- Handle assistance request
RegisterNetEvent("civil_unrest_fire:requestAssistance")
AddEventHandler("civil_unrest_fire:requestAssistance", function(coords)
    local src = source
    
    -- Broadcast assistance request to all players (for client-side NPC spawning)
    TriggerClientEvent('civil_unrest_fire:spawnAssistance', -1, coords)
    
    -- Notify player
    TriggerClientEvent('fxcode:utils:notify', src, "Fire department assistance is on the way", "success")
    
    -- Log assistance request
    print("[FIRE] Player " .. GetPlayerName(src) .. " requested fire department assistance")
end)

-- Handle fire-related death
RegisterNetEvent("civil_unrest_fire:triggerFireResponse")
AddEventHandler("civil_unrest_fire:triggerFireResponse", function(coords)
    local src = source
    
    -- Broadcast fire response to all players (for client-side NPC spawning)
    TriggerClientEvent('civil_unrest_fire:triggerFireResponse', -1, coords)
    
    -- Log fire response
    print("[FIRE] Fire department responding to fire at coordinates: " .. coords.x .. ", " .. coords.y .. ", " .. coords.z)
end)