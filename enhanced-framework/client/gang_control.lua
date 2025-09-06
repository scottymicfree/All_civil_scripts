-- client/gang_control.lua
-- Gang control and territory system for Civil Unrest Core

-- Local variables
local playerGang = "none"
local currentZone = nil
local isCapturing = false
local captureProgress = 0
local captureBlip = nil
local gangBlips = {}
local territoryBlips = {}

-- Initialize gang control system
Citizen.CreateThread(function()
    -- Wait for player to load
    while not exports['standalone-framework']:IsPlayerLoaded() do
        Citizen.Wait(100)
    end
    
    -- Get player gang
    playerGang = exports['standalone-framework']:GetPlayerGang()
    
    -- Create territory blips
    CreateTerritoryBlips()
    
    -- Start zone check thread
    StartZoneCheckThread()
    
    print("[civil_unrest_core] Gang control system initialized")
end)

-- Create territory blips
function CreateTerritoryBlips()
    -- Remove any existing blips
    for _, blip in pairs(territoryBlips) do
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end
    territoryBlips = {}
    
    -- Create blips for each territory
    for i, zone in ipairs(Zones.Territories) do
        local blip = AddBlipForRadius(zone.center.x, zone.center.y, zone.center.z, zone.radius)
        
        -- Set blip properties
        local blipColor = 0 -- Default white for neutral
        
        if zone.gang ~= "neutral" and Config.Gangs[zone.gang] then
            if zone.gang == "ballas" then
                blipColor = 27 -- Purple
            elseif zone.gang == "vagos" then
                blipColor = 46 -- Yellow
            elseif zone.gang == "families" then
                blipColor = 25 -- Green
            elseif zone.gang == "lost" then
                blipColor = 1 -- Red
            elseif zone.gang == "marabunta" then
                blipColor = 3 -- Blue
            end
        end
        
        SetBlipColour(blip, blipColor)
        SetBlipAlpha(blip, 128)
        
        -- Create center blip
        local centerBlip = AddBlipForCoord(zone.center.x, zone.center.y, zone.center.z)
        SetBlipSprite(centerBlip, zone.blip.sprite)
        SetBlipColour(centerBlip, blipColor)
        SetBlipScale(centerBlip, zone.blip.scale)
        SetBlipAsShortRange(centerBlip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(zone.name .. " Territory")
        EndTextCommandSetBlipName(centerBlip)
        
        -- Store blips
        territoryBlips[i] = {
            radius = blip,
            center = centerBlip
        }
    end
end

-- Start zone check thread
function StartZoneCheckThread()
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(1000)
            
            -- Get player position
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            
            -- Check if player is in a territory
            local inZone = false
            for i, zone in ipairs(Zones.Territories) do
                if Zones.IsPointInZone(playerCoords, zone.center, zone.radius) then
                    inZone = true
                    
                    -- Check if zone changed
                    if currentZone ~= i then
                        -- Zone changed
                        currentZone = i
                        
                        -- Notify player
                        local zoneOwner = zone.gang ~= "neutral" and Config.Gangs[zone.gang].name or "Neutral"
                        TriggerEvent('civil_unrest_core:showNotification', "Entered " .. zone.name .. " Territory\nControlled by: " .. zoneOwner .. " (" .. zone.influence .. "%)")
                        
                        -- Check if this is enemy territory
                        if playerGang ~= "none" and zone.gang ~= "neutral" and zone.gang ~= playerGang then
                            TriggerEvent('civil_unrest_core:showNotification', "~r~Warning: You are in enemy territory!")
                        end
                    end
                    
                    break
                end
            end
            
            -- If not in any zone, reset current zone
            if not inZone and currentZone ~= nil then
                currentZone = nil
            end
        end
    end)
end

-- Start territory capture
function StartTerritoryCapture()
    -- Check if player is in a territory
    if not currentZone then
        TriggerEvent('civil_unrest_core:showNotification', "~r~You must be in a territory to start capturing.")
        return
    end
    
    -- Check if player is in a gang
    if playerGang == "none" then
        TriggerEvent('civil_unrest_core:showNotification', "~r~You must be in a gang to capture territory.")
        return
    end
    
    -- Get current zone
    local zone = Zones.Territories[currentZone]
    
    -- Check if zone is already owned by player's gang
    if zone.gang == playerGang and zone.influence >= 100 then
        TriggerEvent('civil_unrest_core:showNotification', "~r~This territory is already fully controlled by your gang.")
        return
    end
    
    -- Start capture process
    isCapturing = true
    captureProgress = 0
    
    -- Create capture blip
    captureBlip = AddBlipForRadius(zone.center.x, zone.center.y, zone.center.z, 50.0)
    SetBlipColour(captureBlip, 1) -- Red
    SetBlipAlpha(captureBlip, 128)
    
    -- Notify server
    TriggerServerEvent('civil_unrest_core:startCapture', currentZone, playerGang)
    
    -- Start capture thread
    Citizen.CreateThread(function()
        local startTime = GetGameTimer()
        local captureTime = 300000 -- 5 minutes
        
        -- Notify player
        TriggerEvent('civil_unrest_core:showNotification', "~g~Territory capture started. Stay in the area for 5 minutes.")
        
        while isCapturing do
            Citizen.Wait(1000)
            
            -- Get player position
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            
            -- Check if player is still in the zone
            if not Zones.IsPointInZone(playerCoords, zone.center, zone.radius) then
                -- Player left the zone, cancel capture
                isCapturing = false
                TriggerEvent('civil_unrest_core:showNotification', "~r~Territory capture failed. You left the area.")
                TriggerServerEvent('civil_unrest_core:cancelCapture', currentZone)
                
                -- Remove capture blip
                if DoesBlipExist(captureBlip) then
                    RemoveBlip(captureBlip)
                    captureBlip = nil
                end
                
                return
            end
            
            -- Check if player is dead
            if IsEntityDead(playerPed) then
                -- Player died, cancel capture
                isCapturing = false
                TriggerEvent('civil_unrest_core:showNotification', "~r~Territory capture failed. You died.")
                TriggerServerEvent('civil_unrest_core:cancelCapture', currentZone)
                
                -- Remove capture blip
                if DoesBlipExist(captureBlip) then
                    RemoveBlip(captureBlip)
                    captureBlip = nil
                end
                
                return
            end
            
            -- Update capture progress
            local elapsedTime = GetGameTimer() - startTime
            captureProgress = math.floor((elapsedTime / captureTime) * 100)
            
            -- Display capture progress
            DrawCaptureProgress(captureProgress)
            
            -- Check if capture is complete
            if captureProgress >= 100 then
