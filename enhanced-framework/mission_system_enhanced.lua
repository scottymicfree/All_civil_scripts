-- =============================================================
-- [ mission_system_enhanced.lua ]
-- Enhanced Mission System for all job and gang types
-- =============================================================

local MissionSystem = {}
MissionSystem.ActiveMissions = {}
MissionSystem.MissionTypes = {
    POLICE = "police",
    EMS = "ems",
    FIRE = "firefighter",
    GANG = "gang",
    DRUG = "drug",
    MECHANIC = "mechanic",
    TAXI = "taxi",
    DELIVERY = "delivery",
    HEIST = "heist",
    ASSASSINATION = "assassination",
    RACE = "race",
    CUSTOM = "custom"
}

-- Mission templates by type
MissionSystem.MissionTemplates = {
    [MissionSystem.MissionTypes.POLICE] = {
        {
            name = "Patrol Area",
            description = "Patrol the assigned area for a period of time.",
            duration = 300, -- 5 minutes
            checkpoints = 5,
            rewards = {
                money = 200,
                xp = 100
            }
        },
        {
            name = "Respond to Robbery",
            description = "Respond to a robbery in progress and arrest the suspects.",
            duration = 600, -- 10 minutes
            enemies = 3,
            rewards = {
                money = 500,
                xp = 250
            }
        },
        {
            name = "High-Speed Pursuit",
            description = "Chase down and arrest a fleeing suspect.",
            duration = 300, -- 5 minutes
            vehicle = true,
            rewards = {
                money = 350,
                xp = 150
            }
        }
    },
    [MissionSystem.MissionTypes.EMS] = {
        {
            name = "Medical Emergency",
            description = "Respond to a medical emergency and treat the patient.",
            duration = 300, -- 5 minutes
            checkpoints = 1,
            rewards = {
                money = 200,
                xp = 100
            }
        },
        {
            name = "Mass Casualty Incident",
            description = "Respond to a major accident with multiple casualties.",
            duration = 600, -- 10 minutes
            checkpoints = 3,
            rewards = {
                money = 500,
                xp = 250
            }
        },
        {
            name = "Medical Transport",
            description = "Transport a patient to the hospital safely.",
            duration = 300, -- 5 minutes
            vehicle = true,
            checkpoints = 2,
            rewards = {
                money = 250,
                xp = 125
            }
        }
    },
    [MissionSystem.MissionTypes.FIRE] = {
        {
            name = "Building Fire",
            description = "Respond to a building fire and extinguish it.",
            duration = 600, -- 10 minutes
            checkpoints = 1,
            rewards = {
                money = 400,
                xp = 200
            }
        },
        {
            name = "Vehicle Fire",
            description = "Respond to a vehicle fire and extinguish it.",
            duration = 300, -- 5 minutes
            checkpoints = 1,
            rewards = {
                money = 200,
                xp = 100
            }
        },
        {
            name = "Rescue Mission",
            description = "Rescue civilians trapped in a burning building.",
            duration = 600, -- 10 minutes
            checkpoints = 3,
            rewards = {
                money = 500,
                xp = 250
            }
        }
    },
    [MissionSystem.MissionTypes.GANG] = {
        {
            name = "Turf War",
            description = "Defend your turf from rival gang members.",
            duration = 900, -- 15 minutes
            enemies = 10,
            rewards = {
                money = 1000,
                xp = 500
            }
        },
        {
            name = "Drug Shipment",
            description = "Protect a drug shipment from rivals and police.",
            duration = 600, -- 10 minutes
            vehicle = true,
            enemies = 5,
            rewards = {
                money = 800,
                xp = 400,
                items = {
                    drugs = 10
                }
            }
        },
        {
            name = "Gang Hit",
            description = "Eliminate a high-ranking member of a rival gang.",
            duration = 600, -- 10 minutes
            enemies = 1,
            bodyguards = 4,
            rewards = {
                money = 1500,
                xp = 750
            }
        }
    },
    [MissionSystem.MissionTypes.DRUG] = {
        {
            name = "Drug Deal",
            description = "Complete a drug deal without getting caught.",
            duration = 300, -- 5 minutes
            checkpoints = 1,
            rewards = {
                money = 500,
                xp = 250
            }
        },
        {
            name = "Drug Lab Setup",
            description = "Set up a new drug lab in a secure location.",
            duration = 900, -- 15 minutes
            checkpoints = 3,
            rewards = {
                money = 1000,
                xp = 500,
                items = {
                    lab_equipment = 1
                }
            }
        },
        {
            name = "Drug Smuggling",
            description = "Smuggle drugs across the city without getting caught.",
            duration = 600, -- 10 minutes
            vehicle = true,
            checkpoints = 5,
            rewards = {
                money = 1500,
                xp = 750,
                items = {
                    drugs = 20
                }
            }
        }
    },
    [MissionSystem.MissionTypes.MECHANIC] = {
        {
            name = "Vehicle Repair",
            description = "Repair a damaged vehicle for a client.",
            duration = 300, -- 5 minutes
            checkpoints = 1,
            rewards = {
                money = 200,
                xp = 100
            }
        },
        {
            name = "Vehicle Recovery",
            description = "Recover a broken-down vehicle and bring it to the garage.",
            duration = 600, -- 10 minutes
            vehicle = true,
            checkpoints = 2,
            rewards = {
                money = 350,
                xp = 175
            }
        },
        {
            name = "Custom Modification",
            description = "Install custom modifications on a client's vehicle.",
            duration = 900, -- 15 minutes
            checkpoints = 1,
            rewards = {
                money = 500,
                xp = 250,
                items = {
                    vehicle_parts = 1
                }
            }
        }
    }
}

-- Function to get a random location in the city
function MissionSystem.GetRandomLocation()
    local locations = {
        vector3(200.0, -800.0, 30.0),
        vector3(-100.0, -900.0, 29.0),
        vector3(300.0, -600.0, 43.0),
        vector3(-200.0, -700.0, 33.0),
        vector3(400.0, -500.0, 28.0),
        vector3(-300.0, -600.0, 31.0),
        vector3(500.0, -400.0, 27.0),
        vector3(-400.0, -500.0, 25.0),
        vector3(600.0, -300.0, 35.0),
        vector3(-500.0, -400.0, 32.0)
    }

    return locations[math.random(#locations)]
end

-- Function to get random locations for checkpoints
function MissionSystem.GetRandomCheckpoints(count)
    local checkpoints = {}
    for i = 1, count do
        table.insert(checkpoints, MissionSystem.GetRandomLocation())
    end
    return checkpoints
end

-- Function to create a new mission
function MissionSystem.CreateMission(missionType, playerId)
    -- Check if mission type is valid
    if not MissionSystem.MissionTypes[missionType] and not MissionSystem.MissionTemplates[missionType] then
        print("Error: Invalid mission type: " .. missionType)
        return nil
    end

    -- Get a random mission template for this type
    local templates = MissionSystem.MissionTemplates[missionType]
    if not templates or #templates == 0 then
        print("Error: No templates found for mission type: " .. missionType)
        return nil
    end

    local template = templates[math.random(#templates)]

    -- Create mission data
    local missionId = "MISSION-" .. math.random(100000, 999999)
    local startLocation = MissionSystem.GetRandomLocation()
    local checkpoints = template.checkpoints and MissionSystem.GetRandomCheckpoints(template.checkpoints) or {}

    local mission = {
        id = missionId,
        type = missionType,
        name = template.name,
        description = template.description,
        playerId = playerId,
        startTime = os.time(),
        endTime = os.time() + template.duration,
        duration = template.duration,
        startLocation = startLocation,
        checkpoints = checkpoints,
        currentCheckpoint = 0,
        enemies = template.enemies or 0,
        bodyguards = template.bodyguards or 0,
        vehicle = template.vehicle or false,
        rewards = template.rewards,
        completed = false,
        success = false
    }

    -- Add mission to active missions
    MissionSystem.ActiveMissions[missionId] = mission

    -- Notify player
    TriggerClientEvent('missionsystem:missionCreated', playerId, mission)

    print("Mission created: " .. missionId .. " for player " .. playerId)
    return mission
end

-- Function to start a mission
function MissionSystem.StartMission(missionId, playerId)
    local mission = MissionSystem.ActiveMissions[missionId]
    if not mission then
        print("Error: Mission not found: " .. missionId)
        return false
    end

    if mission.playerId ~= playerId then
        print("Error: Mission " .. missionId .. " does not belong to player " .. playerId)
        return false
    end

    -- Set mission as started
    mission.started = true
    mission.startTime = os.time()
    mission.endTime = os.time() + mission.duration

    -- Create mission elements
    if mission.vehicle then
        -- Spawn a mission vehicle
        TriggerClientEvent('missionsystem:spawnMissionVehicle', playerId, mission.startLocation)
    end

    if mission.enemies > 0 then
        -- Spawn mission enemies
        local enemyLocations = {}
        for i = 1, mission.enemies do
            table.insert(enemyLocations, MissionSystem.GetRandomLocation())
        end
        TriggerClientEvent('missionsystem:spawnMissionEnemies', playerId, enemyLocations, mission.bodyguards or 0)
    end

    -- Create mission blips and markers
    TriggerClientEvent('missionsystem:createMissionElements', playerId, mission)

    -- Notify player
    TriggerClientEvent('missionsystem:missionStarted', playerId, mission)

    print("Mission started: " .. missionId .. " for player " .. playerId)
    return true
end

-- Function to update mission progress
function MissionSystem.UpdateMissionProgress(missionId, playerId, progress)
    local mission = MissionSystem.ActiveMissions[missionId]
    if not mission then
        print("Error: Mission not found: " .. missionId)
        return false
    end

    if mission.playerId ~= playerId then
        print("Error: Mission " .. missionId .. " does not belong to player " .. playerId)
        return false
    end

    -- Update mission progress
    if progress.checkpoint then
        mission.currentCheckpoint = progress.checkpoint
    end

    if progress.enemiesKilled then
        mission.enemiesKilled = (mission.enemiesKilled or 0) + progress.enemiesKilled
    end

    -- Check if mission is complete
    local isComplete = false

    if mission.checkpoints and #mission.checkpoints > 0 then
        isComplete = mission.currentCheckpoint >= #mission.checkpoints
    end

    if mission.enemies > 0 then
        isComplete = (mission.enemiesKilled or 0) >= mission.enemies
    end

    -- If mission is complete, finish it
    if isComplete then
        MissionSystem.CompleteMission(missionId, playerId, true)
    else
        -- Notify player of progress
        TriggerClientEvent('missionsystem:missionUpdated', playerId, mission)
    end

    return true
end

-- Function to complete a mission
function MissionSystem.CompleteMission(missionId, playerId, success)
    local mission = MissionSystem.ActiveMissions[missionId]
    if not mission then
        print("Error: Mission not found: " .. missionId)
        return false
    end

    if mission.playerId ~= playerId then
        print("Error: Mission " .. missionId .. " does not belong to player " .. playerId)
        return false
    end

    -- Set mission as completed
    mission.completed = true
    mission.success = success
    mission.completedAt = os.time()

    -- Process rewards if successful
    if success then
        -- Give rewards to player
        if mission.rewards.money then
            TriggerEvent('myframework:addMoney', playerId, mission.rewards.money)
        end
        
        if mission.rewards.xp then
            TriggerEvent('myframework:addXP', playerId, mission.rewards.xp)
        end
        
        if mission.rewards.items then
            for item, amount in pairs(mission.rewards.items) do
                TriggerEvent('myframework:addItem', playerId, item, amount)
            end
        end
    end

    -- Remove mission from active missions
    MissionSystem.ActiveMissions[missionId] = nil

    -- Notify player
    TriggerClientEvent('missionsystem:missionCompleted', playerId, mission)

    print("Mission completed: " .. missionId .. " for player " .. playerId .. " (Success: " .. tostring(success) .. ")")
    return true
end

-- Function to fail a mission
function MissionSystem.FailMission(missionId, playerId, reason)
    return MissionSystem.CompleteMission(missionId, playerId, false)
end

-- Function to cancel a mission
function MissionSystem.CancelMission(missionId, playerId)
    local mission = MissionSystem.ActiveMissions[missionId]
    if not mission then
        print("Error: Mission not found: " .. missionId)
        return false
    end

    if mission.playerId ~= playerId then
        print("Error: Mission " .. missionId .. " does not belong to player " .. playerId)
        return false
    end

    -- Set mission as cancelled
    mission.completed = true
    mission.success = false
    mission.cancelled = true
    mission.completedAt = os.time()

    -- Remove mission from active missions
    MissionSystem.ActiveMissions[missionId] = nil

    -- Notify player
    TriggerClientEvent('missionsystem:missionCancelled', playerId, mission)

    print("Mission cancelled: " .. missionId .. " for player " .. playerId)
    return true
end

-- Function to get all active missions
function MissionSystem.GetActiveMissions()
    return MissionSystem.ActiveMissions
end

-- Function to get a player's active missions
function MissionSystem.GetPlayerActiveMissions(playerId)
    local playerMissions = {}
    for id, mission in pairs(MissionSystem.ActiveMissions) do
        if mission.playerId == playerId then
            playerMissions[id] = mission
        end
    end
    return playerMissions
end

-- Function to get a mission by ID
function MissionSystem.GetMission(missionId)
    return MissionSystem.ActiveMissions[missionId]
end

-- Function to check if a mission exists
function MissionSystem.MissionExists(missionId)
    return MissionSystem.ActiveMissions[missionId] ~= nil
end

-- Function to check if a player has an active mission
function MissionSystem.PlayerHasActiveMission(playerId)
    for _, mission in pairs(MissionSystem.ActiveMissions) do
        if mission.playerId == playerId then
            return true
        end
    end
    return false
end

-- Function to get available mission types for a player
function MissionSystem.GetAvailableMissionTypes(playerId)
    -- Get player job and gang info
    local playerJob = "unemployed"
    local playerGang = "none"

    -- Try to get player job from server
    TriggerEvent('myframework:getPlayerJob', playerId, function(job)
        playerJob = job
    end)

    -- Try to get player gang from server
    TriggerEvent('myframework:getPlayerGang', playerId, function(gang)
        playerGang = gang
    end)

    local availableTypes = {}

    -- Check job-based missions
    if playerJob == "police" then
        table.insert(availableTypes, MissionSystem.MissionTypes.POLICE)
    elseif playerJob == "ems" then
        table.insert(availableTypes, MissionSystem.MissionTypes.EMS)
    elseif playerJob == "firefighter" then
        table.insert(availableTypes, MissionSystem.MissionTypes.FIRE)
    elseif playerJob == "mechanic" then
        table.insert(availableTypes, MissionSystem.MissionTypes.MECHANIC)
    elseif playerJob == "taxi" then
        table.insert(availableTypes, MissionSystem.MissionTypes.TAXI)
    end

    -- Check gang-based missions
    if playerGang ~= "none" then
        table.insert(availableTypes, MissionSystem.MissionTypes.GANG)
    end

    -- Everyone can do delivery missions
    table.insert(availableTypes, MissionSystem.MissionTypes.DELIVERY)

    -- Criminal activities based on gang membership or job
    if playerGang ~= "none" or playerJob == "drug_dealer" then
        table.insert(availableTypes, MissionSystem.MissionTypes.DRUG)
        table.insert(availableTypes, MissionSystem.MissionTypes.HEIST)
        table.insert(availableTypes, MissionSystem.MissionTypes.ASSASSINATION)
    end

    -- Racing missions
    table.insert(availableTypes, MissionSystem.MissionTypes.RACE)

    return availableTypes
end

-- Register client events
RegisterNetEvent('missionsystem:requestMission')
AddEventHandler('missionsystem:requestMission', function(missionType)
    local source = source

    -- Check if player already has an active mission
    if MissionSystem.PlayerHasActiveMission(source) then
        TriggerClientEvent('missionsystem:notification', source, "Mission", "You already have an active mission.")
        return
    end

    -- Check if mission type is available for this player
    local availableTypes = MissionSystem.GetAvailableMissionTypes(source)
    local isAvailable = false
    for _, availableType in ipairs(availableTypes) do
        if availableType == missionType then
            isAvailable = true
            break
        end
    end

    if not isAvailable then
        TriggerClientEvent('missionsystem:notification', source, "Mission", "This mission type is not available for you.")
        return
    end

    -- Create the mission
    local mission = MissionSystem.CreateMission(missionType, source)
    if mission then
        -- Start the mission
        MissionSystem.StartMission(mission.id, source)
    else
        TriggerClientEvent('missionsystem:notification', source, "Mission", "Failed to create mission.")
    end
end)

RegisterNetEvent('missionsystem:updateProgress')
AddEventHandler('missionsystem:updateProgress', function(missionId, progress)
    local source = source
    MissionSystem.UpdateMissionProgress(missionId, source, progress)
end)

RegisterNetEvent('missionsystem:completeMission')
AddEventHandler('missionsystem:completeMission', function(missionId, success)
    local source = source
    MissionSystem.CompleteMission(missionId, source, success)
end)

RegisterNetEvent('missionsystem:failMission')
AddEventHandler('missionsystem:failMission', function(missionId, reason)
    local source = source
    MissionSystem.FailMission(missionId, source, reason)
end)

RegisterNetEvent('missionsystem:cancelMission')
AddEventHandler('missionsystem:cancelMission', function(missionId)
    local source = source
    MissionSystem.CancelMission(missionId, source)
end)

-- Register commands
RegisterCommand("mission", function(source, args, rawCommand)
    if source == 0 then
        print("This command can only be used in-game.")
        return
    end

    if #args == 0 then
        -- Show available mission types
        local availableTypes = MissionSystem.GetAvailableMissionTypes(source)
        local message = "Available mission types: "
        for i, missionType in ipairs(availableTypes) do
            message = message .. missionType
            if i < #availableTypes then
                message = message .. ", "
            end
        end
        TriggerClientEvent('missionsystem:notification', source, "Mission", message)
        return
    end

    local action = args[1]

    if action == "start" then
        if #args < 2 then
            TriggerClientEvent('missionsystem:notification', source, "Mission", "Usage: /mission start [type]")
            return
        end
        
        local missionType = args[2]
        TriggerEvent('missionsystem:requestMission', missionType)
    elseif action == "cancel" then
        local playerMissions = MissionSystem.GetPlayerActiveMissions(source)
        for missionId, _ in pairs(playerMissions) do
            MissionSystem.CancelMission(missionId, source)
            break
        end
    elseif action == "list" then
        local playerMissions = MissionSystem.GetPlayerActiveMissions(source)
        if next(playerMissions) == nil then
            TriggerClientEvent('missionsystem:notification', source, "Mission", "You have no active missions.")
        else
            for missionId, mission in pairs(playerMissions) do
                local timeLeft = math.max(0, mission.endTime - os.time())
                local message = mission.name .. " - " .. mission.description .. " (" .. timeLeft .. "s remaining)"
                TriggerClientEvent('missionsystem:notification', source, "Mission", message)
            end
        end
    else
        TriggerClientEvent('missionsystem:notification', source, "Mission", "Unknown action. Available actions: start, cancel, list")
    end
end, false)

-- Server-side handler for getPlayerActiveMissions
RegisterNetEvent('missionsystem:getPlayerActiveMissions')
AddEventHandler('missionsystem:getPlayerActiveMissions', function()
    local source = source
    local missions = MissionSystem.GetPlayerActiveMissions(source)
    TriggerClientEvent('missionsystem:receivePlayerActiveMissions', source, missions)
end)

-- Client-side mission handling
Citizen.CreateThread(function()
    -- Register client events
    RegisterNetEvent('missionsystem:missionCreated')
    AddEventHandler('missionsystem:missionCreated', function(mission)
        -- Store mission data locally
        local activeMission = mission

        -- Show notification
        ShowNotification("New mission: " .. mission.name)
        ShowNotification(mission.description)
        
        -- Create mission blip
        local blip = AddBlipForCoord(mission.startLocation.x, mission.startLocation.y, mission.startLocation.z)
        SetBlipSprite(blip, 1)
        SetBlipColour(blip, 5)
        SetBlipRoute(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Mission: " .. mission.name)
        EndTextCommandSetBlipName(blip)
        
        -- Store blip
        activeMission.blip = blip
    end)

    RegisterNetEvent('missionsystem:missionStarted')
    AddEventHandler('missionsystem:missionStarted', function(mission)
        -- Show notification
        ShowNotification("Mission started: " .. mission.name)
        
        -- Start mission timer
        Citizen.CreateThread(function()
            local endTime = mission.endTime
            
            while true do
                Citizen.Wait(1000)
                local timeLeft = endTime - os.time()
                
                if timeLeft <= 0 then
                    -- Mission timed out
                    TriggerServerEvent('missionsystem:failMission', mission.id, "Time expired")
                    break
                end
                
                -- Display time left
                if timeLeft <= 60 then
                    -- Show warning when less than 60 seconds left
                    ShowNotification("Mission time remaining: " .. timeLeft .. " seconds")
                end
            end
        end)
    end)

    RegisterNetEvent('missionsystem:missionUpdated')
    AddEventHandler('missionsystem:missionUpdated', function(mission)
        -- Show notification
        if mission.currentCheckpoint then
            ShowNotification("Checkpoint " .. mission.currentCheckpoint .. "/" .. #mission.checkpoints .. " reached")
        end
        
        if mission.enemiesKilled then
            ShowNotification("Enemies eliminated: " .. mission.enemiesKilled .. "/" .. mission.enemies)
        end
    end)

    RegisterNetEvent('missionsystem:missionCompleted')
    AddEventHandler('missionsystem:missionCompleted', function(mission)
        -- Show notification
        if mission.success then
            ShowNotification("Mission completed: " .. mission.name)
            
            -- Show rewards
            if mission.rewards.money then
                ShowNotification("Reward: $" .. mission.rewards.money)
            end
            
            if mission.rewards.xp then
                ShowNotification("XP gained: " .. mission.rewards.xp)
            end
            
            if mission.rewards.items then
                for item, amount in pairs(mission.rewards.items) do
                    ShowNotification("Item received: " .. item .. " x" .. amount)
                end
            end
        else
            ShowNotification("Mission failed: " .. mission.name)
        end
        
        -- Remove mission blip
        if mission.blip then
            RemoveBlip(mission.blip)
        end
    end)

    RegisterNetEvent('missionsystem:missionCancelled')
    AddEventHandler('missionsystem:missionCancelled', function(mission)
        -- Show notification
        ShowNotification("Mission cancelled: " .. mission.name)
        
        -- Remove mission blip
        if mission.blip then
            RemoveBlip(mission.blip)
        end
    end)

    RegisterNetEvent('missionsystem:spawnMissionVehicle')
    AddEventHandler('missionsystem:spawnMissionVehicle', function(location)
        -- Spawn mission vehicle
        local playerPed = PlayerPedId()
        local vehicleModel = "sultan"
        
        RequestModel(vehicleModel)
        while not HasModelLoaded(vehicleModel) do
            Citizen.Wait(0)
        end
        
        local vehicle = CreateVehicle(GetHashKey(vehicleModel), location.x, location.y, location.z, 0.0, true, false)
        SetEntityAsMissionEntity(vehicle, true, true)
        SetVehicleHasBeenOwnedByPlayer(vehicle, true)
        
        -- Set vehicle as mission vehicle
        DecorSetInt(vehicle, "mission_vehicle", 1)
        
        -- Create vehicle blip
        local blip = AddBlipForEntity(vehicle)
        SetBlipSprite(blip, 225)
        SetBlipColour(blip, 5)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Mission Vehicle")
        EndTextCommandSetBlipName(blip)
        
        -- Show notification
        ShowNotification("Mission vehicle spawned. Go to the marked location.")
    end)

    RegisterNetEvent('missionsystem:spawnMissionEnemies')
    AddEventHandler('missionsystem:spawnMissionEnemies', function(locations, bodyguards)
        -- Spawn mission enemies
        local playerPed = PlayerPedId()
        local enemyModel = "g_m_y_ballasout_01"
        
        RequestModel(enemyModel)
        while not HasModelLoaded(enemyModel) do
            Citizen.Wait(0)
        end
        
        for _, location in ipairs(locations) do
            local enemy = CreatePed(4, GetHashKey(enemyModel), location.x, location.y, location.z, 0.0, true, true)
            SetEntityAsMissionEntity(enemy, true, true)
            GiveWeaponToPed(enemy, GetHashKey("WEAPON_PISTOL"), 100, false, true)
            TaskCombatPed(enemy, playerPed, 0, 16)
            
            -- Set enemy as mission enemy
            DecorSetInt(enemy, "mission_enemy", 1)
            
            -- Create enemy blip
            local blip = AddBlipForEntity(enemy)
            SetBlipSprite(blip, 270)
            SetBlipColour(blip, 1)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Mission Target")
            EndTextCommandSetBlipName(blip)
            
            -- Spawn bodyguards if needed
            if bodyguards and bodyguards > 0 then
                for i = 1, bodyguards do
                    local offsetX = math.random(-5, 5)
                    local offsetY = math.random(-5, 5)
                    local bodyguard = CreatePed(4, GetHashKey(enemyModel), location.x + offsetX, location.y + offsetY, location.z, 0.0, true, true)
                    SetEntityAsMissionEntity(bodyguard, true, true)
                    GiveWeaponToPed(bodyguard, GetHashKey("WEAPON_PISTOL"), 100, false, true)
                    TaskCombatPed(bodyguard, playerPed, 0, 16)
                    
                    -- Set bodyguard as mission enemy
                    DecorSetInt(bodyguard, "mission_enemy", 1)
                end
            end
        end
        
        -- Show notification
        ShowNotification("Mission targets located. Eliminate them.")
    end)

    RegisterNetEvent('missionsystem:createMissionElements')
    AddEventHandler('missionsystem:createMissionElements', function(mission)
        -- Create mission elements
        if mission.checkpoints and #mission.checkpoints > 0 then
            -- Create checkpoint blips
            for i, checkpoint in ipairs(mission.checkpoints) do
                local blip = AddBlipForCoord(checkpoint.x, checkpoint.y, checkpoint.z)
                SetBlipSprite(blip, 1)
                SetBlipColour(blip, 5)
                SetBlipRoute(i == 1) -- Only set route to first checkpoint
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString("Checkpoint " .. i)
                EndTextCommandSetBlipName(blip)
                
                -- Store checkpoint blip
                if not mission.checkpointBlips then
                    mission.checkpointBlips = {}
                end
                mission.checkpointBlips[i] = blip
            end
            
            -- Show notification
            ShowNotification("Go to the marked checkpoints.")
        end
    end)

     -- Register event to receive mission data
    RegisterNetEvent('missionsystem:receivePlayerActiveMissions')
    AddEventHandler('missionsystem:receivePlayerActiveMissions', function(missions)
        local playerMissions = missions
        
        -- Process missions here
        for missionId, mission in pairs(playerMissions) do
            -- Check checkpoints
            if mission.checkpoints and #mission.checkpoints > 0 and mission.currentCheckpoint < #mission.checkpoints then
                local playerPed = PlayerPedId()
                local playerCoords = GetEntityCoords(playerPed)
                local nextCheckpoint = mission.checkpoints[mission.currentCheckpoint + 1]
                local distance = #(playerCoords - vector3(nextCheckpoint.x, nextCheckpoint.y, nextCheckpoint.z))
                
                if distance < 5.0 then
                    -- Checkpoint reached
                    TriggerServerEvent('missionsystem:updateProgress', missionId, {checkpoint = mission.currentCheckpoint + 1})
                    
                    -- Update checkpoint blips
                    if mission.checkpointBlips then
                        RemoveBlip(mission.checkpointBlips[mission.currentCheckpoint + 1])
                        
                        if mission.currentCheckpoint + 2 <= #mission.checkpoints then
                            SetBlipRoute(mission.checkpointBlips[mission.currentCheckpoint + 2], true)
                        end
                    end
                end
            end
            
            -- Check enemies
            if mission.enemies > 0 then
                -- This is handled by the gameEventTriggered event below
            end
        end
    end)

    -- Helper function to show notifications
    function ShowNotification(text)
        BeginTextCommandThefeedPost("STRING")
        AddTextComponentSubstringPlayerName(text)
        EndTextCommandThefeedPostTicker(true, false)
    end

    -- Listen for enemy deaths
    AddEventHandler('gameEventTriggered', function(name, args)
        if name == "CEventNetworkEntityDamage" then
            local victim = args[1]
            local attacker = args[2]
            local fatal = args[6] == 1
            
            if fatal and attacker == PlayerPedId() and DecorExistOn(victim, "mission_enemy") then
                -- Mission enemy killed
                TriggerServerEvent('missionsystem:getPlayerActiveMissions')
            end
        end
    end)
end)

-- Export the MissionSystem
exports('GetMissionSystem', function()
    return MissionSystem
end)

