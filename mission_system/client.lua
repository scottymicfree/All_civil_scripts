-- mission_system/mission_system.lua
print("[Mission System] Client loaded.")

-- Mission data
local activeMission = nil
local missionBlips = {}
local missionMarkers = {}
local missionObjectives = {}
local missionTimer = 0
local missionTimerActive = false

-- Initialize when resource starts
AddEventHandler('onClientResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        print("[Mission System] Resource started")
        TriggerServerEvent('mission_system:playerReady')
    end
end)

-- Start a mission
function StartMission(missionData)
    if activeMission then
        print("[Mission System] Cannot start mission, another mission is already active")
        return false
    end
    
    -- Set active mission
    activeMission = missionData
    
    -- Create mission blips
    if missionData.blips then
        for i, blipData in ipairs(missionData.blips) do
            local blip = AddBlipForCoord(blipData.coords.x, blipData.coords.y, blipData.coords.z)
            SetBlipSprite(blip, blipData.sprite or 1)
            SetBlipColour(blip, blipData.color or 5)
            SetBlipScale(blip, blipData.scale or 1.0)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(blipData.name or "Mission Objective")
            EndTextCommandSetBlipName(blip)
            
            table.insert(missionBlips, blip)
        end
    end
    
    -- Create mission markers
    if missionData.markers then
        for i, markerData in ipairs(missionData.markers) do
            table.insert(missionMarkers, markerData)
        end
    end
    
    -- Set mission objectives
    missionObjectives = missionData.objectives or {}
    
    -- Start mission timer if needed
    if missionData.timeLimit and missionData.timeLimit > 0 then
        missionTimer = missionData.timeLimit
        missionTimerActive = true
    end
    
    -- Trigger mission start event
    TriggerEvent("mission_system:missionStarted", missionData)
    
    -- Show mission notification
    ShowMissionNotification("Mission Started", missionData.name, "Mission started: " .. missionData.name)
    
    return true
end

-- Complete mission
function CompleteMission()
    if not activeMission then
        return false
    end
    
    -- Clean up mission resources
    CleanupMissionResources()
    
    -- Trigger mission complete event
    TriggerEvent("mission_system:missionCompleted", activeMission)
    TriggerServerEvent("mission_system:missionCompleted", activeMission.id)
    
    -- Show mission notification
    ShowMissionNotification("Mission Completed", activeMission.name, "Mission completed: " .. activeMission.name)
    
    -- Reset active mission
    activeMission = nil
    
    return true
end

-- Fail mission
function FailMission(reason)
    if not activeMission then
        return false
    end
    
    -- Clean up mission resources
    CleanupMissionResources()
    
    -- Trigger mission failed event
    TriggerEvent("mission_system:missionFailed", activeMission, reason)
    TriggerServerEvent("mission_system:missionFailed", activeMission.id, reason)
    
    -- Show mission notification
    ShowMissionNotification("Mission Failed", activeMission.name, "Mission failed: " .. (reason or "Unknown reason"))
    
    -- Reset active mission
    activeMission = nil
    
    return true
end

-- Clean up mission resources
function CleanupMissionResources()
    -- Remove blips
    for i, blip in ipairs(missionBlips) do
        RemoveBlip(blip)
    end
    missionBlips = {}
    
    -- Clear markers
    missionMarkers = {}
    
    -- Reset timer
    missionTimerActive = false
    missionTimer = 0
end

-- Get active mission
function GetActiveMission()
    return activeMission
end

-- Show mission notification
function ShowMissionNotification(title, subtitle, message)
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandThefeedPostTicker(true, true)
end

-- Mission timer thread
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        
        if missionTimerActive and missionTimer > 0 then
            missionTimer = missionTimer - 1
            
            -- Time's up
            if missionTimer <= 0 then
                missionTimerActive = false
                FailMission("Time's up")
            end
        end
    end
end)

-- Mission marker thread
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        if activeMission and #missionMarkers > 0 then
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            
            for i, markerData in ipairs(missionMarkers) do
                local distance = #(playerCoords - markerData.coords)
                
                -- Draw marker
                DrawMarker(
                    markerData.type or 1,
                    markerData.coords.x, markerData.coords.y, markerData.coords.z - 1.0,
                    0.0, 0.0, 0.0,
                    0.0, 0.0, 0.0,
                    markerData.size or 1.0, markerData.size or 1.0, markerData.size or 1.0,
                    markerData.color.r or 255, markerData.color.g or 255, markerData.color.b or 0, 100,
                    false, true, 2, false, nil, nil, false
                )
                
                -- Check if player is in marker
                if distance < (markerData.size or 1.0) then
                    if markerData.onEnter then
                        markerData.onEnter()
                    end
                end
            end
        end
    end
end)

-- Register event handlers
RegisterNetEvent("mission_system:startMission")
AddEventHandler("mission_system:startMission", function(missionData)
    StartMission(missionData)
end)

RegisterNetEvent("mission_system:completeMission")
AddEventHandler("mission_system:completeMission", function()
    CompleteMission()
end)

RegisterNetEvent("mission_system:failMission")
AddEventHandler("mission_system:failMission", function(reason)
    FailMission(reason)
end)

-- Export functions
exports('StartMission', StartMission)
exports('CompleteMission', CompleteMission)
exports('FailMission', FailMission)
exports('GetActiveMission', GetActiveMission)