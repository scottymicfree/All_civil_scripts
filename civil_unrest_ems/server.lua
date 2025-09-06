-- EMS System - Server Side
-- This script handles server-side EMS functionality

-- Debug mode
local debugMode = true

-- Helper function for debug logging
local function debugLog(message)
    if debugMode then
        print("^3[EMS SERVER DEBUG] " .. message .. "^7")
    end
end

-- Initialize
Citizen.CreateThread(function()
    debugLog("EMS Server script initialized")
end)

-- Handle medical help request
RegisterNetEvent("civil_unrest_ems:requestMedicalHelp")
AddEventHandler("civil_unrest_ems:requestMedicalHelp", function()
    local src = source
    
    debugLog("Medical help requested by " .. GetPlayerName(src))
    
    -- Check if player has enough money
    local healCost = 100 -- $100 for healing (fixed from 10 to match the comment)
    
    -- Safely get player money with error handling
    local playerMoney = 0
    local success, result = pcall(function()
        return exports['standalone-framework']:GetPlayerValue(src, 'money') or 0
    end)
    
    if success then
        playerMoney = result
    else
        debugLog("Error getting player money: " .. tostring(result))
        TriggerClientEvent('fxcode:utils:notify', src, "Error processing payment", "error")
        return
    end
    
    debugLog("Player money: $" .. playerMoney .. ", Cost: $" .. healCost)
    
    if playerMoney >= healCost then
        -- Remove money from player with error handling
        local paymentSuccess = false
        success, result = pcall(function()
            return exports['standalone-framework']:RemoveMoney(src, healCost)
        end)
        
        if success then
            paymentSuccess = result
        else
            debugLog("Error removing money: " .. tostring(result))
            TriggerClientEvent('fxcode:utils:notify', src, "Error processing payment", "error")
            return
        end
        
        if paymentSuccess then
            -- Heal player
            TriggerClientEvent('civil_unrest_ems:heal', src)
            
            -- Notify player
            TriggerClientEvent('fxcode:utils:notify', src, "You received medical treatment for $" .. healCost, "success")
            
            -- Log healing
            debugLog("Player " .. GetPlayerName(src) .. " received medical treatment for $" .. healCost)
        else
            TriggerClientEvent('fxcode:utils:notify', src, "Failed to process payment", "error")
            debugLog("Failed to process payment for " .. GetPlayerName(src))
        end
    else
        TriggerClientEvent('fxcode:utils:notify', src, "You don't have enough money for medical treatment", "error")
        debugLog("Player " .. GetPlayerName(src) .. " doesn't have enough money for treatment")
    end
end)

-- Handle volunteer request
RegisterNetEvent("civil_unrest_ems:volunteer")
AddEventHandler("civil_unrest_ems:volunteer", function()
    local src = source
    
    debugLog("Volunteer request from " .. GetPlayerName(src))
    
    -- Add XP for volunteering with error handling
    local success, result = pcall(function()
        return exports['xp_system']:AddPlayerXP(src, 50, "EMS Volunteering")
    end)
    
    if not success then
        debugLog("Error adding XP: " .. tostring(result))
    end
    
    -- Notify player
    TriggerClientEvent('fxcode:utils:notify', src, "Thank you for volunteering! You earned 50 XP", "success")
    
    -- Log volunteering
    debugLog("Player " .. GetPlayerName(src) .. " volunteered with EMS")
end)

-- Handle blood donation
RegisterNetEvent("civil_unrest_ems:donateBlood")
AddEventHandler("civil_unrest_ems:donateBlood", function()
    local src = source
    
    debugLog("Blood donation from " .. GetPlayerName(src))
    
    -- Add XP for donating blood with error handling
    local success, result = pcall(function()
        return exports['xp_system']:AddPlayerXP(src, 30, "Blood Donation")
    end)
    
    if not success then
        debugLog("Error adding XP: " .. tostring(result))
    end
    
    -- Give money reward with error handling
    local reward = 50 -- $50 for donating blood
    success, result = pcall(function()
        return exports['standalone-framework']:AddMoney(src, reward)
    end)
    
    if not success then
        debugLog("Error adding money: " .. tostring(result))
    end
    
    -- Notify player
    TriggerClientEvent('fxcode:utils:notify', src, "Thank you for donating blood! You received $" .. reward .. " and 30 XP", "success")
    
    -- Log blood donation
    debugLog("Player " .. GetPlayerName(src) .. " donated blood")
end)

-- Handle assistance request
RegisterNetEvent("civil_unrest_ems:requestAssistance")
AddEventHandler("civil_unrest_ems:requestAssistance", function(coords)
    local src = source
    
    -- Validate coordinates
    if not coords or type(coords) ~= "vector3" then
        debugLog("Invalid coordinates in assistance request from " .. GetPlayerName(src))
        return
    end
    
    debugLog("Assistance requested by " .. GetPlayerName(src) .. " at " .. tostring(coords))
    
    -- Broadcast assistance request to all players (for client-side NPC spawning)
    TriggerClientEvent('civil_unrest_ems:spawnAssistance', -1, coords)
    
    -- Notify player
    TriggerClientEvent('fxcode:utils:notify', src, "EMS assistance is on the way", "success")
    
    -- Log assistance request
    debugLog("Player " .. GetPlayerName(src) .. " requested EMS assistance at " .. tostring(coords))
end)

-- Check if player is EMS
function IsPlayerEMS(source)
    local isEMS = false
    
    -- Try to get player job with error handling
    local success, result = pcall(function()
        return exports['standalone-framework']:GetPlayerJob(source)
    end)
    
    if success then
        isEMS = (result == "ems" or result == "ambulance" or result == "doctor")
    else
        debugLog("Error checking player job: " .. tostring(result))
    end
    
    return isEMS
end

-- Handle revive request
RegisterNetEvent("civil_unrest_ems:revivePlayer")
AddEventHandler("civil_unrest_ems:revivePlayer", function(target)
    local src = source
    
    debugLog("Revive requested by " .. GetPlayerName(src) .. " for target " .. tostring(target))
    
    -- Check if target exists
    if not GetPlayerName(target) then
        TriggerClientEvent('fxcode:utils:notify', src, "Player not found", "error")
        debugLog("Target player not found")
        return
    end
    
    -- Check if source is EMS
    local isEMS = IsPlayerEMS(src)
    
    if isEMS then
        -- Revive target
        TriggerClientEvent('civil_unrest_ems:revive', target)
        
        -- Notify players
        TriggerClientEvent('fxcode:utils:notify', src, "You revived " .. GetPlayerName(target), "success")
        TriggerClientEvent('fxcode:utils:notify', target, "You were revived by " .. GetPlayerName(src), "success")
        
        -- Add XP for reviving with error handling
        local success, result = pcall(function()
            return exports['xp_system']:AddPlayerXP(src, 100, "Reviving Player")
        end)
        
        if not success then
            debugLog("Error adding XP: " .. tostring(result))
        end
        
        -- Log revive
        debugLog("Player " .. GetPlayerName(src) .. " revived " .. GetPlayerName(target))
    else
        TriggerClientEvent('fxcode:utils:notify', src, "You are not an EMS", "error")
        debugLog("Revive denied - player is not EMS")
    end
end)

-- Handle EMS heal event
RegisterNetEvent("civil_unrest_ems:heal")
AddEventHandler("civil_unrest_ems:heal", function(target)
    local src = source
    
    -- If no target specified, use source
    if not target then
        target = src
    end
    
    debugLog("Heal requested by " .. GetPlayerName(src) .. " for target " .. tostring(target))
    
    -- Check if target exists
    if not GetPlayerName(target) then
        TriggerClientEvent('fxcode:utils:notify', src, "Player not found", "error")
        debugLog("Target player not found")
        return
    end
    
    -- Check if source is EMS or self-healing
    local isEMS = IsPlayerEMS(src)
    
    if isEMS or src == target then
        -- Heal target
        TriggerClientEvent('civil_unrest_ems:heal', target)
        
        -- Notify players
        if src ~= target then
            TriggerClientEvent('fxcode:utils:notify', src, "You healed " .. GetPlayerName(target), "success")
        end
        TriggerClientEvent('fxcode:utils:notify', target, "You were healed", "success")
        
        -- Log healing
        debugLog("Player " .. GetPlayerName(target) .. " was healed by " .. GetPlayerName(src))
    else
        TriggerClientEvent('fxcode:utils:notify', src, "You are not authorized to heal others", "error")
        debugLog("Heal denied - player is not EMS")
    end
end)

-- Command to toggle debug mode
RegisterCommand("ems_server_debug", function(source, args, rawCommand)
    -- Only allow from console or admin
    if source == 0 then
        debugMode = not debugMode
        print("EMS server debug mode: " .. (debugMode and "Enabled" or "Disabled"))
    else
        -- Check if player is admin
        local isAdmin = false
        
        -- Try to check admin status with error handling
        local success, result = pcall(function()
            return exports['standalone-framework']:IsPlayerAdmin(source)
        end)
        
        if success then
            isAdmin = result
        end
        
        if isAdmin then
            debugMode = not debugMode
            TriggerClientEvent('fxcode:utils:notify', source, "EMS server debug mode: " .. (debugMode and "Enabled" or "Disabled"), "info")
        else
            TriggerClientEvent('fxcode:utils:notify', source, "You don't have permission to use this command", "error")
        end
    end
end, true)

-- Command to test EMS functionality
RegisterCommand("test_ems_server", function(source, args, rawCommand)
    -- Only allow from console or admin
    if source == 0 then
        print("Testing EMS server functionality...")
        -- Add test code here
    else
        -- Check if player is admin
        local isAdmin = false
        
        -- Try to check admin status with error handling
        local success, result = pcall(function()
            return exports['standalone-framework']:IsPlayerAdmin(source)
        end)
        
        if success then
            isAdmin = result
        end
        
        if isAdmin then
            TriggerClientEvent('fxcode:utils:notify', source, "Testing EMS server functionality...", "info")
            
            -- Test healing
            TriggerClientEvent('civil_unrest_ems:heal', source)
            
            -- Test assistance
            local playerCoords = GetEntityCoords(GetPlayerPed(source))
            TriggerClientEvent('civil_unrest_ems:spawnAssistance', -1, playerCoords)
        else
            TriggerClientEvent('fxcode:utils:notify', source, "You don't have permission to use this command", "error")
        end
    end
end, true)
