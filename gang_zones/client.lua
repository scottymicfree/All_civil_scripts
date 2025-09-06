local debugMode = false
local zoneBlips = {}
local currentZone = nil

local function debugLog(msg)
    if debugMode then
        print('[GangZones] ' .. msg)
    end
end

-- Create blips for gang zones (optional, toggleable)
local function createZoneBlips()
    for _, zone in ipairs(GangZones) do
        local blip = AddBlipForRadius(zone.center.x, zone.center.y, zone.center.z, zone.radius)
        SetBlipColour(blip, zone.color)
        SetBlipAlpha(blip, 128)
        SetBlipAsShortRange(blip, true)
        table.insert(zoneBlips, blip)

        local markerBlip = AddBlipForCoord(zone.center.x, zone.center.y, zone.center.z)
        SetBlipSprite(markerBlip, zone.jobs[1] == "police" and 60 or zone.jobs[1] == "ems" and 153 or zone.jobs[1] == "drugdealer" and 51 or 436)
        SetBlipColour(markerBlip, zone.color)
        SetBlipAsShortRange(markerBlip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(zone.name)
        EndTextCommandSetBlipName(markerBlip)
        table.insert(zoneBlips, markerBlip)
    end
    debugLog("Created blips for " .. #GangZones .. " gang zones")
end

-- Remove zone blips
local function removeZoneBlips()
    for _, blip in ipairs(zoneBlips) do
        RemoveBlip(blip)
    end
    zoneBlips = {}
    debugLog("Removed all zone blips")
end

-- Check player's zone and trigger events
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        local playerPed = PlayerPedId()
        if playerPed and playerPed ~= -1 then
            local coords = GetEntityCoords(playerPed)
            local newZone = GetPlayerZone(coords)
            
            if newZone and newZone ~= currentZone then
                TriggerEvent('civil_unrest_core:onEnterZone', newZone.name, newZone.owner)
                exports['standalone-framework']:ShowNotification("Entered " .. newZone.name .. " (" .. newZone.owner .. " territory)")
                currentZone = newZone
            elseif not newZone and currentZone then
                TriggerEvent('civil_unrest_core:onExitZone', currentZone.name, currentZone.owner)
                exports['standalone-framework']:ShowNotification("Left " .. currentZone.name)
                currentZone = nil
            end
        end
    end
end)

-- Handle job setup from job wheel
RegisterNetEvent('jobwheel:setupJob')
AddEventHandler('jobwheel:setupJob', function(job)
    debugLog("Received jobwheel:setupJob for job: " .. job)
    removeZoneBlips() -- Clear existing blips to avoid overlap
    for _, zone in ipairs(GangZones) do
        if table.contains(zone.jobs, job) then
            local blip = AddBlipForCoord(zone.center.x, zone.center.y, zone.center.z)
            SetBlipSprite(blip, job == "police" and 60 or job == "ems" and 153 or job == "drugdealer" and 51 or 436)
            SetBlipColour(blip, zone.color)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentSubstringPlayerName(job == "police" and "Wanted Criminal" or job == "ems" and "Injured Person" or job == "drugdealer" and "Dealing Spot" or "Fire Incident")
            EndTextCommandSetBlipName(blip)
            table.insert(zoneBlips, blip)
        end
    end
end)

-- Clear blips on job timeout
RegisterNetEvent('jobwheel:clearJobBlips')
AddEventHandler('jobwheel:clearJobBlips', function()
    debugLog("Received jobwheel:clearJobBlips")
    removeZoneBlips()
end)

-- Initialize blips on player spawn
AddEventHandler('playerSpawned', function()
    if #zoneBlips == 0 then
        createZoneBlips()
    end
end)

-- Debug command
RegisterCommand("gangzones_debug", function()
    debugMode = not debugMode
    print("[GangZones] Debug mode " .. (debugMode and "enabled" or "disabled"))
end, false)

-- Utility function to check if a table contains a value
function table.contains(table, element)
    for _, value in ipairs(table) do
        if value == element then
            return true
        end
    end
    return false
end