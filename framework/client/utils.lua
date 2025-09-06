-- Utility functions for the framework
-- This file contains shared functions used across the framework

-- Debug logging
function debugLog(message)
    if Config.Debug then
        print("^3[DEBUG] " .. message .. "^7")
    end
end

-- Draw 3D text in the world
function draw3DText(coords, text, size, font)
    local onScreen, _x, _y = World3dToScreen2d(coords.x, coords.y, coords.z)
    local scale = (size or 0.35) / (GetGameplayCamFov() / 100)
    
    if onScreen then
        SetTextScale(scale, scale)
        SetTextFont(font or 4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(true)
        AddTextComponentString(text)
        DrawText(_x, _y)
        local factor = (string.len(text)) / 370
        DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 0, 0, 0, 120)
    end
end

-- Show notification to player
function showNotification(message, type)
    if exports['mythic_notify'] then
        exports['mythic_notify']:DoCustomHudText(type or 'inform', message, Config.NotificationDuration)
    else
        SetNotificationTextEntry('STRING')
        AddTextComponentString(message)
        DrawNotification(false, false)
    end
end

-- Load a model with timeout
function loadModel(model)
    local timeout = 5000 -- 5 seconds timeout
    local startTime = GetGameTimer()
    local modelHash = GetHashKey(model)
    
    RequestModel(modelHash)
    
    -- Wait for model to load with timeout
    while not HasModelLoaded(modelHash) do
        Citizen.Wait(10)
        if GetGameTimer() - startTime > timeout then
            debugLog("Model load timeout: " .. model)
            return false
        end
    end
    
    return modelHash
end

-- Check if player is in a vehicle
function isPlayerInVehicle()
    return IsPedInAnyVehicle(PlayerPedId(), false)
end

-- Get closest vehicle with validation
function getClosestVehicle(coords, radius)
    local vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, radius or 5.0, 0, 70)
    
    if vehicle and vehicle ~= 0 and DoesEntityExist(vehicle) then
        return vehicle
    end
    
    return nil
end

-- Check cooldown status
local cooldowns = {}
function checkCooldown(action)
    if not cooldowns[action] then
        cooldowns[action] = 0
    end
    
    local currentTime = GetGameTimer()
    if currentTime < cooldowns[action] then
        return false, math.ceil((cooldowns[action] - currentTime) / 1000)
    end
    
    return true
end

-- Set cooldown for an action
function setCooldown(action, duration)
    cooldowns[action] = GetGameTimer() + (duration or 0)
end
