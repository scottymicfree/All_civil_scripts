-- CIVIL UNREST SCRIPT
-- Author: Emma & Randy Webb (Updated by NinjaTech AI)
-- System: NPC Police - Client Main

print("[POLICE] Client loaded.")

-- Disable all native dispatch
CreateThread(function()
    for i = 1, 15 do
        EnableDispatchService(i, false)
    end
    print("[POLICE] Dispatch services disabled.")
end)

-- Configuration
local Config = {
    PoliceStations = {
        { name = "Mission Row PD", coords = vector3(441.75, -981.85, 31.69), radius = 30.0, officerCount = 6, vehicleCount = 3 },
        { name = "Vespucci PD", coords = vector3(-1095.02, -836.14, 19.0), radius = 30.0, officerCount = 4, vehicleCount = 2 },
        { name = "Sandy Shores PD", coords = vector3(1853.82, 3686.43, 34.27), radius = 30.0, officerCount = 3, vehicleCount = 2 },
        { name = "Paleto Bay PD", coords = vector3(-448.22, 6012.97, 31.72), radius = 30.0, officerCount = 3, vehicleCount = 2 },
        { name = "Davis Sheriff Station", coords = vector3(360.51, -1584.2, 29.29), radius = 25.0, officerCount = 4, vehicleCount = 2 },
        { name = "La Mesa PD", coords = vector3(826.8, -1290.16, 28.24), radius = 25.0, officerCount = 3, vehicleCount = 2 }
    },
    PatrolAreas = {
        { center = vector3(300.0, -900.0, 29.0), radius = 200.0, name = "Downtown", patrolDensity = 3 },
        { center = vector3(-1300.0, -1200.0, 4.0), radius = 200.0, name = "Vespucci Beach", patrolDensity = 2 },
        { center = vector3(1900.0, 3700.0, 32.0), radius = 200.0, name = "Sandy Shores", patrolDensity = 2 },
        { center = vector3(-500.0, -300.0, 35.0), radius = 150.0, name = "Rockford Hills", patrolDensity = 2 },
        { center = vector3(400.0, -1600.0, 29.0), radius = 180.0, name = "Davis", patrolDensity = 3 },
        { center = vector3(800.0, -1300.0, 26.0), radius = 150.0, name = "La Mesa", patrolDensity = 2 },
        { center = vector3(-100.0, 6400.0, 31.0), radius = 200.0, name = "Paleto Bay", patrolDensity = 2 },
        { center = vector3(1700.0, 4700.0, 42.0), radius = 180.0, name = "Grapeseed", patrolDensity = 1 }
    },
    PoliceModels = {
        "s_m_y_cop_01",
        "s_f_y_cop_01",
        "s_m_y_hwaycop_01",
        "s_m_y_sheriff_01",
        "s_f_y_sheriff_01"
    },
    PoliceVehicles = {
        "police",
        "police2",
        "police3",
        "police4",
        "sheriff",
        "sheriff2"
    },
    HighCrimeAreas = {
        { center = vector3(100.0, -1200.0, 29.0), radius = 150.0, name = "South Los Santos", patrolBoost = 2 },
        { center = vector3(1600.0, 3600.0, 35.0), radius = 120.0, name = "Sandy Shores Center", patrolBoost = 1 }
    },
    MaxPoliceNPCs = 40,       -- Maximum number of police NPCs to spawn
    MaxPoliceVehicles = 20,   -- Maximum number of police vehicles to spawn
    PatrolCheckInterval = 30, -- Seconds between patrol checks
    CleanupInterval = 60,     -- Seconds between cleanup checks
    EnableBlips = true,       -- Whether to show police blips on the map
    EnableDebugBlips = false  -- Whether to show debug blips for patrol areas
}

-- Variables
local policeNPCs = {}
local policeVehicles = {}
local activePatrols = {}
local playerWantedLevel = 0
local isPlayerInSafeZone = false
local debugMode = false
local lastPatrolCheck = 0
local lastCleanupCheck = 0
local totalPoliceNPCs = 0
local totalPoliceVehicles = 0
local areaActivityLevels = {}

-- Function to spawn police NPC
function SpawnPoliceNPC(coords, heading, stationName)
    -- Check if we've reached the maximum number of police NPCs
    if totalPoliceNPCs >= Config.MaxPoliceNPCs then
        if debugMode then
            print("Maximum police NPCs reached, not spawning more")
        end
        return nil
    end
    
    -- Select random police model
    local modelName = Config.PoliceModels[math.random(1, #Config.PoliceModels)]
    local model = GetHashKey(modelName)
    
    -- Request model
    RequestModel(model)
    local timeout = 5000
    local startTime = GetGameTimer()
    while not HasModelLoaded(model) do
        if GetGameTimer() - startTime > timeout then
            if debugMode then
                print("Failed to load police model: " .. modelName)
            end
            return nil
        end
        Citizen.Wait(100)
    end
    
    -- Spawn NPC
    local ped = CreatePed(4, model, coords.x, coords.y, coords.z, heading or 0.0, true, false)
    
    if not ped or not DoesEntityExist(ped) then
        if debugMode then
            print("Failed to create police ped")
        end
        return nil
    end
    
    -- Configure NPC
    SetPedArmour(ped, 100)
    SetPedAccuracy(ped, 60)
    SetPedCombatAttributes(ped, 46, true)
    SetPedFleeAttributes(ped, 0, false)
    SetPedCombatRange(ped, 2)
    SetPedCombatMovement(ped, 2)
    GiveWeaponToPed(ped, GetHashKey("WEAPON_PISTOL"), 100, false, true)
    SetPedCanSwitchWeapon(ped, true)
    
    -- Add blip if enabled
    local blip = nil
    if Config.EnableBlips then
        blip = AddBlipForEntity(ped)
        SetBlipSprite(blip, 1)
        SetBlipColour(blip, 3)
        SetBlipScale(blip, 0.8)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Police Officer")
        EndTextCommandSetBlipName(blip)
    end
    
    -- Store NPC data
    local npcData = {
        ped = ped,
        blip = blip,
        spawnTime = GetGameTimer(),
        station = stationName or "Patrol",
        model = modelName
    }
    
    table.insert(policeNPCs, npcData)
    totalPoliceNPCs = totalPoliceNPCs + 1
    
    -- Return the ped
    return ped
end

-- Function to spawn police vehicle with officers
function SpawnPoliceVehicle(coords, heading, areaName)
    -- Check if we've reached the maximum number of police vehicles
    if totalPoliceVehicles >= Config.MaxPoliceVehicles then
        if debugMode then
            print("Maximum police vehicles reached, not spawning more")
        end
        return nil
    }
    
    -- Select random police vehicle
    local vehicleModel = Config.PoliceVehicles[math.random(1, #Config.PoliceVehicles)]
    local model = GetHashKey(vehicleModel)
    
    -- Request model
    RequestModel(model)
    local timeout = 5000
    local startTime = GetGameTimer()
    while not HasModelLoaded(model) do
        if GetGameTimer() - startTime > timeout then
            if debugMode then
                print("Failed to load police vehicle model: " .. vehicleModel)
            end
            return nil
        end
        Citizen.Wait(100)
    end
    
    -- Spawn vehicle
    local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, heading or 0.0, true, false)
    
    if not vehicle or not DoesEntityExist(vehicle) then
        if debugMode then
            print("Failed to create police vehicle")
        end
        return nil
    end
    
    -- Configure vehicle
    SetVehicleOnGroundProperly(vehicle)
    SetVehicleEngineOn(vehicle, true, true, false)
    SetVehicleSiren(vehicle, false)
    SetVehicleDoorsLocked(vehicle, 1) -- Unlocked
    SetVehicleDirtLevel(vehicle, 0.0) -- Clean
    
    -- Add blip if enabled
    local blip = nil
    if Config.EnableBlips then
        blip = AddBlipForEntity(vehicle)
        SetBlipSprite(blip, 56)
        SetBlipColour(blip, 3)
        SetBlipScale(blip, 0.8)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Police Vehicle")
        EndTextCommandSetBlipName(blip)
    end
    
    -- Spawn driver
    local driver = SpawnPoliceNPC(coords, heading, areaName)
    if driver then
        SetPedIntoVehicle(driver, vehicle, -1)
        
        -- Set driving style based on area
        local drivingStyle = 786603 -- Normal
        if areaName and string.find(areaName, "Downtown") then
            drivingStyle = 786603 -- Normal
        elseif areaName and string.find(areaName, "Highway") then
            drivingStyle = 2883621 -- Rushed
        end
        
        TaskVehicleDriveWander(driver, vehicle, 20.0, drivingStyle)
    end
    
    -- Spawn passenger (70% chance)
    local passenger = nil
    if math.random() < 0.7 then
        passenger = SpawnPoliceNPC(coords, heading, areaName)
        if passenger then
            SetPedIntoVehicle(passenger, vehicle, 0)
        end
    end
    
    -- Store vehicle data
    local vehicleData = {
        vehicle = vehicle,
        blip = blip,
        driver = driver,
        passenger = passenger,
        spawnTime = GetGameTimer(),
        area = areaName or "Patrol",
        model = vehicleModel
    }
    
    table.insert(policeVehicles, vehicleData)
    totalPoliceVehicles = totalPoliceVehicles + 1
    
    -- Return the vehicle
    return vehicle
end

-- Function to start police patrol
function StartPolicePatrol(area)
    -- Check if patrol already exists for this area
    local existingPatrols = 0
    for i, patrol in ipairs(activePatrols) do
        if patrol.area.name == area.name then
            existingPatrols = existingPatrols + 1
        end
    end
    
    -- Check if we've reached the maximum patrols for this area
    local maxPatrols = area.patrolDensity or 1
    
    -- Check if this is a high crime area and boost patrol count
    for _, highCrimeArea in ipairs(Config.HighCrimeAreas) do
        if highCrimeArea.name == area.name then
            maxPatrols = maxPatrols + highCrimeArea.patrolBoost
            break
        end
    end
    
    if existingPatrols >= maxPatrols then
        if debugMode then
            print("Maximum patrols reached for area: " .. area.name)
        end
        return nil
    end
    
    -- Calculate spawn position (random point within area)
    local angle = math.random() * 2 * math.pi
    local radius = math.sqrt(math.random()) * area.radius
    local spawnX = area.center.x + radius * math.cos(angle)
    local spawnY = area.center.y + radius * math.sin(angle)
    local spawnZ = area.center.z
    
    -- Get ground Z
    local ground, groundZ = GetGroundZFor_3dCoord(spawnX, spawnY, spawnZ + 100.0, 0)
    if ground then
        spawnZ = groundZ
    end
    
    local spawnCoords = vector3(spawnX, spawnY, spawnZ)
    
    -- Spawn police vehicle
    local vehicle = SpawnPoliceVehicle(spawnCoords, math.random(0, 359), area.name)
    
    if vehicle then
        -- Create patrol data
        local patrolData = {
            area = area,
            vehicle = vehicle,
            startTime = GetGameTimer(),
            lastCheckTime = GetGameTimer()
        }
        
        -- Add to active patrols
        table.insert(activePatrols, patrolData)
        
        if debugMode then
            print("Started police patrol in area: " .. area.name)
        end
        
        -- Create debug blip for patrol area if enabled
        if Config.EnableDebugBlips and debugMode then
            local areaBlip = AddBlipForRadius(area.center.x, area.center.y, area.center.z, area.radius)
            SetBlipColour(areaBlip, 3)
            SetBlipAlpha(areaBlip, 128)
            
            local centerBlip = AddBlipForCoord(area.center.x, area.center.y, area.center.z)
            SetBlipSprite(centerBlip, 60)
            SetBlipColour(centerBlip, 3)
            SetBlipScale(centerBlip, 0.8)
            SetBlipAsShortRange(centerBlip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Patrol Area: " .. area.name)
            EndTextCommandSetBlipName(centerBlip)
            
            patrolData.debugBlips = {areaBlip, centerBlip}
        end
        
        return patrolData
    end
    
    return nil
end

-- Function to clean up old police NPCs and vehicles
function CleanupPoliceEntities()
    local currentTime = GetGameTimer()
    local newNPCs = {}
    local newVehicles = {}
    local newPatrols = {}
    
    -- Clean up NPCs
    for i, npc in ipairs(policeNPCs) do
        -- Check if NPC still exists and isn't too old (30 minutes)
        if DoesEntityExist(npc.ped) and (currentTime - npc.spawnTime) < 1800000 then
            table.insert(newNPCs, npc)
        else
            -- Delete the ped and blip if they exist
            if DoesEntityExist(npc.ped) then
                DeleteEntity(npc.ped)
                totalPoliceNPCs = totalPoliceNPCs - 1
            end
            
            if DoesBlipExist(npc.blip) then
                RemoveBlip(npc.blip)
            end
            
            if debugMode then
                print("Cleaned up police NPC from " .. npc.station)
            end
        end
    end
    
    -- Clean up vehicles
    for i, veh in ipairs(policeVehicles) do
        -- Check if vehicle still exists and isn't too old (30 minutes)
        if DoesEntityExist(veh.vehicle) and (currentTime - veh.spawnTime) < 1800000 then
            table.insert(newVehicles, veh)
        else
            -- Delete the vehicle and blip if they exist
            if DoesEntityExist(veh.vehicle) then
                DeleteEntity(veh.vehicle)
                totalPoliceVehicles = totalPoliceVehicles - 1
            end
            
            if DoesBlipExist(veh.blip) then
                RemoveBlip(veh.blip)
            end
            
            if debugMode then
                print("Cleaned up police vehicle from " .. veh.area)
            end
        end
    end
    
    -- Clean up patrols
    for i, patrol in ipairs(activePatrols) do
        -- Check if patrol vehicle still exists
        local vehicleExists = false
        for _, veh in ipairs(newVehicles) do
            if veh.vehicle == patrol.vehicle then
                vehicleExists = true
                break
            end
        end
        
        if vehicleExists then
            table.insert(newPatrols, patrol)
        else
            -- Clean up debug blips if they exist
            if patrol.debugBlips then
                for _, blip in ipairs(patrol.debugBlips) do
                    if DoesBlipExist(blip) then
                        RemoveBlip(blip)
                    end
                end
            end
            
            if debugMode then
                print("Cleaned up police patrol in area: " .. patrol.area.name)
            end
        end
    end
    
    policeNPCs = newNPCs
    policeVehicles = newVehicles
    activePatrols = newPatrols
    
    if debugMode then
        print("Cleanup complete. Active NPCs: " .. #policeNPCs .. ", Vehicles: " .. #policeVehicles .. ", Patrols: " .. #activePatrols)
    end
}

-- Function to handle police NPC interaction
function InteractWithPoliceNPC(ped)
    -- Show dialogue
    local dialogues = {
        "How can I help you, citizen?",
        "Is there something I can assist you with?",
        "Do you need police assistance?"
    }
    local dialogue = dialogues[math.random(1, #dialogues)]
    ShowNotification("Police Officer: " .. dialogue)
    
    -- Show police options
    TriggerEvent("civil_unrest_police:showOptions", ped)
}

-- Function to update area activity levels
function UpdateAreaActivityLevels()
    -- Reset activity levels
    areaActivityLevels = {}
    
    -- Calculate activity level for each patrol area
    for _, area in ipairs(Config.PatrolAreas) do
        local activityLevel = 0
        
        -- Check for player activity in area
        local players = GetActivePlayers()
        local playersInArea = 0
        
        for _, player in ipairs(players) do
            local playerPed = GetPlayerPed(player)
            local playerCoords = GetEntityCoords(playerPed)
            
            if #(playerCoords - area.center) < area.radius then
                playersInArea = playersInArea + 1
                
                -- Check if player is wanted
                local playerServerId = GetPlayerServerId(player)
                -- This would need server-side integration to get actual wanted levels
                -- For now, we'll just use a random value for demonstration
                local playerWanted = (math.random() < 0.2) -- 20% chance player is wanted
                
                if playerWanted then
                    activityLevel = activityLevel + 2
                else
                    activityLevel = activityLevel + 1
                end
            end
        end
        
        -- Check for recent crimes in area (placeholder)
        -- This would need integration with your crime system
        local recentCrimes = 0
        
        -- Set final activity level
        areaActivityLevels[area.name] = {
            level = activityLevel + recentCrimes,
            players = playersInArea
        }
    end
    
    -- Update high crime areas based on activity levels
    for i, area in ipairs(Config.HighCrimeAreas) do
        for areaName, activity in pairs(areaActivityLevels) do
            if areaName == area.name and activity.level > 5 then
                -- Increase patrol boost for high activity areas
                Config.HighCrimeAreas[i].patrolBoost = math.min(4, activity.level / 2)
                
                if debugMode then
                    print("High crime area " .. area.name .. " patrol boost updated to " .. Config.HighCrimeAreas[i].patrolBoost)
                end
            end
        end
    end
}

-- Function to check if player is in a safe zone
function UpdatePlayerSafeZoneStatus()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local wasInSafeZone = isPlayerInSafeZone
    isPlayerInSafeZone = false
    
    -- Check police stations
    for _, station in ipairs(Config.PoliceStations) do
        if #(playerCoords - station.coords) < station.radius then
            isPlayerInSafeZone = true
            break
        end
    end
    
    -- If safe zone status changed, trigger event
    if wasInSafeZone ~= isPlayerInSafeZone then
        TriggerEvent("civil_unrest_police:safeZoneChanged", isPlayerInSafeZone)
    }
    
    return isPlayerInSafeZone
}

-- Event handler for showing police options
RegisterNetEvent("civil_unrest_police:showOptions")
AddEventHandler("civil_unrest_police:showOptions", function(ped)
    -- Create menu using NativeUI
    local menuPool = NativeUI.CreatePool()
    local mainMenu = NativeUI.CreateMenu("Police Officer", "~b~Police Options")
    menuPool:Add(mainMenu)
    menuPool:MouseControlsEnabled(false)
    menuPool:MouseEdgeEnabled(false)
    menuPool:ControlDisablingEnabled(true)
    menuPool:ControllerEnabled(true)
    
    -- Add report crime option
    local reportCrimeItem = NativeUI.CreateItem("Report Crime", "Report a crime to the officer")
    mainMenu:AddItem(reportCrimeItem)
    reportCrimeItem.Activated = function(sender, item)
        TriggerServerEvent("civil_unrest_police:reportCrime")
        mainMenu:Visible(false)
    end
    
    -- Add pay ticket option
    local payTicketItem = NativeUI.CreateItem("Pay Ticket", "Pay an outstanding ticket")
    mainMenu:AddItem(payTicketItem)
    payTicketItem.Activated = function(sender, item)
        TriggerServerEvent("civil_unrest_police:payTicket")
        mainMenu:Visible(false)
    end
    
    -- Add ask directions option
    local askDirectionsItem = NativeUI.CreateItem("Ask for Directions", "Get directions to a location")
    mainMenu:AddItem(askDirectionsItem)
    askDirectionsItem.Activated = function(sender, item)
        TriggerEvent("civil_unrest_police:askDirections")
        mainMenu:Visible(false)
    end
    
    -- Add request assistance option
    local requestAssistanceItem = NativeUI.CreateItem("Request Assistance", "Request police assistance")
    mainMenu:AddItem(requestAssistanceItem)
    requestAssistanceItem.Activated = function(sender, item)
        local playerCoords = GetEntityCoords(PlayerPedId())
        TriggerServerEvent("civil_unrest_police:requestAssistance", playerCoords)
        mainMenu:Visible(false)
    end
    
    -- Add bribe option (if player has wanted level)
    if exports['civil_unrest_police']:GetWantedLevel() > 0 then
        local bribeItem = NativeUI.CreateItem("Attempt Bribe", "Try to bribe the officer")
        mainMenu:AddItem(bribeItem)
        bribeItem.Activated = function(sender, item)
            TriggerServerEvent("civil_unrest_police:attemptBribe")
            mainMenu:Visible(false)
        end
    end
    
    -- Add leave option
    local leaveItem = NativeUI.CreateItem("Leave", "Walk away")
    mainMenu:AddItem(leaveItem)
    leaveItem.Activated = function(sender, item)
        ShowNotification("You walk away from the officer")
        mainMenu:Visible(false)
    end
    
    -- Show menu
    menuPool:RefreshIndex()
    mainMenu:Visible(true)
    
    -- Process menu in a separate thread
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            menuPool:ProcessMenus()
            
            -- Break loop when menu is closed
            if not mainMenu:Visible() then
                break
            end
        end
    end)
end)

-- Main thread for police NPC management
Citizen.CreateThread(function()
    -- Initialize police stations
    for i, station in ipairs(Config.PoliceStations) do
        -- Create blip
        local blip = AddBlipForCoord(station.coords)
        SetBlipSprite(blip, 60)
        SetBlipColour(blip, 38)
        SetBlipScale(blip, 0.8)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(station.name)
        EndTextCommandSetBlipName(blip)
        
        -- Spawn officers at the station
        for j = 1, station.officerCount do
            local offsetX = math.random(-10, 10)
            local offsetY = math.random(-10, 10)
            local spawnCoords = vector3(station.coords.x + offsetX, station.coords.y + offsetY, station.coords.z)
            SpawnPoliceNPC(spawnCoords, math.random(0, 359), station.name)
            Citizen.Wait(50) -- Small delay to prevent resource spikes
        end
        
        -- Spawn police vehicles at the station
        for j = 1, station.vehicleCount do
            local vehicleOffsetX = math.random(-15, 15)
            local vehicleOffsetY = math.random(-15, 15)
            local vehicleCoords = vector3(station.coords.x + vehicleOffsetX, station.coords.y + vehicleOffsetY, station.coords.z)
            SpawnPoliceVehicle(vehicleCoords, math.random(0, 359), station.name)
            Citizen.Wait(50) -- Small delay to prevent resource spikes
        end
    end
    
    -- Start initial patrols
    for i, area in ipairs(Config.PatrolAreas) do
        for j = 1, area.patrolDensity do
            StartPolicePatrol(area)
            Citizen.Wait(50) -- Small delay to prevent resource spikes
        end
    end
    
    -- Main loop
    while true do
        local currentTime = GetGameTimer()
        
        -- Check if it's time to update patrols
        if currentTime - lastPatrolCheck > Config.PatrolCheckInterval * 1000 then
            -- Update area activity levels
            UpdateAreaActivityLevels()
            
            -- Start new patrols based on activity levels
            for i, area in ipairs(Config.PatrolAreas) do
                local activityLevel = areaActivityLevels[area.name] and areaActivityLevels[area.name].level or 0
                local patrolChance = 0.1 + (activityLevel * 0.05) -- Base 10% chance + 5% per activity level
                
                if math.random() < patrolChance then
                    StartPolicePatrol(area)
                end
            end
            
            lastPatrolCheck = currentTime
        end
        
        -- Check if it's time to clean up
        if currentTime - lastCleanupCheck > Config.CleanupInterval * 1000 then
            CleanupPoliceEntities()
            lastCleanupCheck = currentTime
        }
        
        -- Update player safe zone status
        UpdatePlayerSafeZoneStatus()
        
        -- Wait before next cycle
        Citizen.Wait(1000)
    end
end)

-- Thread for NPC interaction
Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local nearestPed = nil
        local nearestDistance = 3.0 -- Interaction distance
        local isNearPolice = false
        
        -- Check if player is near any police NPC
        for i, npc in ipairs(policeNPCs) do
            if DoesEntityExist(npc.ped) then
                local pedCoords = GetEntityCoords(npc.ped)
                local distance = #(playerCoords - pedCoords)
                
                if distance < nearestDistance then
                    nearestPed = npc.ped
                    nearestDistance = distance
                    isNearPolice = true
                end
            end
        end
        
        -- Show interaction prompt if near a police NPC
        if isNearPolice then
            BeginTextCommandDisplayHelp("STRING")
            AddTextComponentSubstringPlayerName("Press ~INPUT_FRONTEND_UP~ to interact with police officer")
            EndTextCommandDisplayHelp(0, false, true, -1)
            
            -- Check for D-pad up press (controller)
            if IsControlJustReleased(0, 172) then -- 172 is D-pad Up
                InteractWithPoliceNPC(nearestPed)
            end
            
            Citizen.Wait(0)
        else
            -- If not near any police NPC, wait longer to save resources
            Citizen.Wait(500)
        end
    end
end)

-- Register command for keyboard users
RegisterCommand("police_interact", function()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    local nearestPed = nil
    local nearestDistance = 3.0 -- Interaction distance
    
    for i, npc in ipairs(policeNPCs) do
        if DoesEntityExist(npc.ped) then
            local pedCoords = GetEntityCoords(npc.ped)
            local distance = #(playerCoords - pedCoords)
            
            if distance < nearestDistance then
                nearestPed = npc.ped
                nearestDistance = distance
            end
        end
    end
    
    if nearestPed then
        InteractWithPoliceNPC(nearestPed)
    end
end, false)

-- Register key mapping for keyboard users
RegisterKeyMapping("police_interact", "Interact with Police Officer", "keyboard", "E")

-- Notification function
function ShowNotification(message)
    BeginTextCommandThefeedPost("STRING")
    AddTextComponent

_Note: `safezones.lua`, `gangzones.lua`, `zones.lua`, and 24 more were excluded from the analysis due to size limit. Please upload again or start a new conversation if your question is related to them._
