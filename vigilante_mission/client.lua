-- Local variables
local jimmyPed = nil
local jimmyBlip = nil
local targetBlip = nil
local deliveryBlip = nil
local missionActive = true
local missionVehicle = nil
local policePeds = {}
local policeVehicles = {}
local missionStartTime = 0
local currentDifficulty = nil
local cooldownActive = false

-- Debug function
local function DebugPrint(message)
    if Config.Debug then
        print("[Vigilante Mission] " .. message)
    end
end

-- Function to load model with timeout
function LoadModel(model)
    local hash = GetHashKey(model)
    RequestModel(hash)

    -- Add timeout to prevent infinite loading
    local timeout = GetGameTimer() + 10000
    while not HasModelLoaded(hash) and GetGameTimer() < timeout do
        Wait(100)
    end

    if not HasModelLoaded(hash) then
        DebugPrint("Failed to load model: " .. tostring(model))
        return false
    end

    return true
end

-- Function to load model with timeout
function LoadModel(model)
    local hash = GetHashKey(model)
    RequestModel(hash)

    -- Add timeout to prevent infinite loading
    local timeout = GetGameTimer() + 10000
    while not HasModelLoaded(hash) and GetGameTimer() < timeout do
        Wait(100)
    end

    if not HasModelLoaded(hash) then
        DebugPrint("Failed to load model: " .. tostring(model))
        return false
    end

    return true
end

-- Function to load model with timeout
function LoadModel(model)
    local hash = GetHashKey(model)
    RequestModel(hash)

    -- Add timeout to prevent infinite loading
    local timeout = GetGameTimer() + 10000
    while not HasModelLoaded(hash) and GetGameTimer() < timeout do
        Wait(100)
    end

    if not HasModelLoaded(hash) then
        DebugPrint("Failed to load model: " .. tostring(model))
        return false
    end

    return true
end

-- Function to load model with timeout
function LoadModel(model)
    local hash = GetHashKey(model)
    RequestModel(hash)

    -- Add timeout to prevent infinite loading
    local timeout = GetGameTimer() + 10000
    while not HasModelLoaded(hash) and GetGameTimer() < timeout do
        Wait(100)
    end

    if not HasModelLoaded(hash) then
        DebugPrint("Failed to load model: " .. tostring(model))
        return false
    end

    return true
end

-- Function to load model with timeout
function LoadModel(model)
    local hash = GetHashKey(model)
    RequestModel(hash)

    -- Add timeout to prevent infinite loading
    local timeout = GetGameTimer() + 10000
    while not HasModelLoaded(hash) and GetGameTimer() < timeout do
        Wait(100)
    end

    if not HasModelLoaded(hash) then
        DebugPrint("Failed to load model: " .. tostring(model))
        return false
    end

    return true
end

-- Function to load model with timeout
function LoadModel(model)
    local hash = GetHashKey(model)
    RequestModel(hash)

    -- Add timeout to prevent infinite loading
    local timeout = GetGameTimer() + 10000
    while not HasModelLoaded(hash) and GetGameTimer() < timeout do
        Wait(100)
    end

    if not HasModelLoaded(hash) then
        DebugPrint("Failed to load model: " .. tostring(model))
        return false
    end

    return true
end

-- Function to load model with timeout
function LoadModel(model)
    local hash = GetHashKey(model)
    RequestModel(hash)

    -- Add timeout to prevent infinite loading
    local timeout = GetGameTimer() + 10000
    while not HasModelLoaded(hash) and GetGameTimer() < timeout do
        Wait(100)
    end

    if not HasModelLoaded(hash) then
        DebugPrint("Failed to load model: " .. tostring(model))
        return false
    end

    return true
end
-- Function to load model with timeout
function LoadModel(model)
    local hash = GetHashKey(model)
    RequestModel(hash)

    -- Add timeout to prevent infinite loading
    local timeout = GetGameTimer() + 10000
    while not HasModelLoaded(hash) and GetGameTimer() < timeout do
        Wait(100)
    end

    if not HasModelLoaded(hash) then
        DebugPrint("Failed to load model: " .. tostring(model))
        return false
    end

    return true
end

-- Function to load model with timeout
function LoadModel(model)
    local hash = GetHashKey(model)
    RequestModel(hash)

    -- Add timeout to prevent infinite loading
    local timeout = GetGameTimer() + 10000
    while not HasModelLoaded(hash) and GetGameTimer() < timeout do
        Wait(100)
    end

    if not HasModelLoaded(hash) then
        DebugPrint("Failed to load model: " .. tostring(model))
        return false
    end

    return true
end

-- Function to load model with timeout
function LoadModel(model)
    local hash = GetHashKey(model)
    RequestModel(hash)

    -- Add timeout to prevent infinite loading
    local timeout = GetGameTimer() + 10000
    while not HasModelLoaded(hash) and GetGameTimer() < timeout do
        Wait(100)
    end

    if not HasModelLoaded(hash) then
        DebugPrint("Failed to load model: " .. tostring(model))
        return false
    end

    return true
end

-- Function to load model with timeout
function LoadModel(model)
    local hash = GetHashKey(model)
    RequestModel(hash)

    -- Add timeout to prevent infinite loading
    local timeout = GetGameTimer() + 10000
    while not HasModelLoaded(hash) and GetGameTimer() < timeout do
        Wait(100)
    end

    if not HasModelLoaded(hash) then
        DebugPrint("Failed to load model: " .. tostring(model))
        return false
    end

    return true
end

-- Function to load model with timeout
function LoadModel(model)
    local hash = GetHashKey(model)
    RequestModel(hash)

    -- Add timeout to prevent infinite loading
    local timeout = GetGameTimer() + 10000
    while not HasModelLoaded(hash) and GetGameTimer() < timeout do
        Wait(100)
    end

    if not HasModelLoaded(hash) then
        DebugPrint("Failed to load model: " .. tostring(model))
        return false
    end

    return true
end

-- Function to load model with timeout
function LoadModel(model)
    local hash = GetHashKey(model)
    RequestModel(hash)

    -- Add timeout to prevent infinite loading
    local timeout = GetGameTimer() + 10000
    while not HasModelLoaded(hash) and GetGameTimer() < timeout do
        Wait(100)
    end

    if not HasModelLoaded(hash) then
        DebugPrint("Failed to load model: " .. tostring(model))
        return false
    end

    return true
end

-- Function to load model with timeout
function LoadModel(model)
    local hash = GetHashKey(model)
    RequestModel(hash)

    -- Add timeout to prevent infinite loading
    local timeout = GetGameTimer() + 10000
    while not HasModelLoaded(hash) and GetGameTimer() < timeout do
        Wait(100)
    end

    if not HasModelLoaded(hash) then
        DebugPrint("Failed to load model: " .. tostring(model))
        return false
    end

    return true
end

-- Function to load model with timeout
function LoadModel(model)
    local hash = GetHashKey(model)
    RequestModel(hash)

    -- Add timeout to prevent infinite loading
    local timeout = GetGameTimer() + 10000
    while not HasModelLoaded(hash) and GetGameTimer() < timeout do
        Wait(100)
    end

    if not HasModelLoaded(hash) then
        DebugPrint("Failed to load model: " .. tostring(model))
        return false
    end

    return true
end

-- Function to load model with timeout
function LoadModel(model)
    local hash = GetHashKey(model)
    RequestModel(hash)

    -- Add timeout to prevent infinite loading
    local timeout = GetGameTimer() + 10000
    while not HasModelLoaded(hash) and GetGameTimer() < timeout do
        Wait(100)
    end

    if not HasModelLoaded(hash) then
        DebugPrint("Failed to load model: " .. tostring(model))
        return false
    end

    return true
end

-- Function to load model with timeout
function LoadModel(model)
    local hash = GetHashKey(model)
    RequestModel(hash)

    -- Add timeout to prevent infinite loading
    local timeout = GetGameTimer() + 10000
    while not HasModelLoaded(hash) and GetGameTimer() < timeout do
        Wait(100)
    end

    if not HasModelLoaded(hash) then
        DebugPrint("Failed to load model: " .. tostring(model))
        return false
    end

    return true
end


-- Function to create Jimmy NPC
function CreateJimmyNPC()
print("Starting Jimmy NPC creation...")

-- Load the model
    local modelName = Config.Jimmy.model
    local modelHash = GetHashKey(modelName)

    print("Requesting model: " .. modelName .. " (Hash: " .. modelHash .. ")")

-- Request model
    RequestModel(modelHash)

-- Add timeout to prevent infinite loading
    local timeout = GetGameTimer() + 10000
    local loaded = false

    while not loaded and GetGameTimer() < timeout do
        Wait(100)
         loaded = HasModelLoaded(modelHash)
    end

    if not loaded then
        print("Failed to load Jimmy model: " .. modelName)
         return false
    end

    print("Model loaded successfully")

     -- Create the NPC
    local x, y, z, h = Config.Jimmy.coords.x, Config.Jimmy.coords.y, Config.Jimmy.coords.z, Config.Jimmy.coords.w

     -- Get ground Z coordinate
    local groundZ = z
    local ground, foundZ = GetGroundZFor_3dCoord(x, y, z, true)
    if ground then
        groundZ = foundZ
        print("Found ground at Z: " .. groundZ)
    end

    print("Creating Jimmy at: " .. x .. ", " .. y .. ", " .. groundZ)
    jimmyPed = CreatePed(4, modelHash, x, y, groundZ, h, false, true)

    -- Check if Jimmy was created
    if not DoesEntityExist(jimmyPed) then
        print("Failed to create Jimmy NPC")
         SetModelAsNoLongerNeeded(modelHash)
          return false
    end

        print("Jimmy created with ID: " .. jimmyPed)

    -- Configure the NPC
    SetEntityInvincible(jimmyPed, true)
    SetBlockingOfNonTemporaryEvents(jimmyPed, true)
    FreezeEntityPosition(jimmyPed, true)
    SetPedDefaultComponentVariation(jimmyPed)

    -- Set NPC scenario
    if Config.Jimmy.scenario then
        print("Setting Jimmy scenario: " .. Config.Jimmy.scenario)
        TaskStartScenarioInPlace(jimmyPed, Config.Jimmy.scenario, 0, true)
    end

-- Create blip
if Config.Jimmy.blip then
    print("Creating Jimmy blip")
    jimmyBlip = AddBlipForCoord(x, y, z)
    SetBlipSprite(jimmyBlip, Config.Jimmy.blip.sprite)
    SetBlipColour(jimmyBlip, Config.Jimmy.blip.color)
    SetBlipScale(jimmyBlip, Config.Jimmy.blip.scale)
    SetBlipAsShortRange(jimmyBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.Jimmy.blip.name)
    EndTextCommandSetBlipName(jimmyBlip)
end

-- Set as no longer needed
SetModelAsNoLongerNeeded(modelHash)
print("Jimmy De Santa NPC created successfully")
return true
end

-- Function to clean up NPC
function CleanupJimmyNPC()
    if jimmyPed ~= nil and DoesEntityExist(jimmyPed) then
        DeleteEntity(jimmyPed)
        jimmyPed = nil
    end

    if jimmyBlip then
        RemoveBlip(jimmyBlip)
        jimmyBlip = nil
    end
end

-- Function to clean up NPC
function CleanupJimmyNPC()
    if jimmyPed ~= nil and DoesEntityExist(jimmyPed) then
        DeleteEntity(jimmyPed)
        jimmyPed = nil
    end

    if jimmyBlip then
        RemoveBlip(jimmyBlip)
        jimmyBlip = nil
    end
end

-- Function to draw 3D text
function DrawText3D(x, y, z, text)
    -- Get screen coordinates
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)

    -- Only draw if on screen
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(true)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(true)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

-- Function to get current difficulty based on time
function GetCurrentDifficulty()
    local hour = GetClockHours()

    -- Check early morning
    if hour >= Config.TimeDifficulty.earlyMorning.timeStart and hour < Config.TimeDifficulty.earlyMorning.timeEnd then
        return Config.TimeDifficulty.earlyMorning
    end

    -- Check day time
    if hour >= Config.TimeDifficulty.dayTime.timeStart and hour < Config.TimeDifficulty.dayTime.timeEnd then
        return Config.TimeDifficulty.dayTime
    end

-- Check evening
    if hour >= Config.TimeDifficulty.evening.timeStart and hour < Config.TimeDifficulty.evening.timeEnd then
        return Config.TimeDifficulty.evening
    end

-- Default to night time
    return Config.TimeDifficulty.night
end

-- Function to start the mission
function StartMission()
    -- Check cooldown
    if cooldownActive then
        TriggerEvent("chat:addMessage", {
            color = { 255, 0, 0 },
            multiline = false,
            args = { "Jimmy De Santa", "I don't have any jobs for you right now. Come back later." }
        })
        return
    end

    -- Check if mission is already active
    if missionActive then
        TriggerEvent("chat:addMessage", {
            color = { 255, 255, 0 },
            multiline = false,
            args = { "Jimmy De Santa", "You're already on a job! Finish it first." }
        })
        return
    end

    -- Set mission as active
    missionActive = true
    missionStartTime = GetGameTimer()

    -- Get current difficulty
    currentDifficulty = GetCurrentDifficulty()

    -- Notify player about time-based difficulty
    TriggerEvent("chat:addMessage", {
        color = { 255, 255, 0 },
        multiline = false,
        args = { "Jimmy De Santa", currentDifficulty.message }
    })

    -- Create target vehicle blip
    targetBlip = AddBlipForCoord(Config.VigilanteVehicle.coords.x, Config.VigilanteVehicle.coords.y,
        Config.VigilanteVehicle.coords.z)
    SetBlipSprite(targetBlip, Config.VigilanteVehicle.blip.sprite)
    SetBlipColour(targetBlip, Config.VigilanteVehicle.blip.color)
    SetBlipScale(targetBlip, Config.VigilanteVehicle.blip.scale)
    SetBlipRoute(targetBlip, true)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.VigilanteVehicle.blip.name)
    EndTextCommandSetBlipName(targetBlip)

    -- Notify player
    TriggerEvent("chat:addMessage", {
        color = { 255, 255, 0 },
        multiline = false,
        args = { "Jimmy De Santa", "I've marked the location of the Vigilante on your GPS. Steal it and deliver it to the marked location. You'll get $" .. Config.Reward .. " for this job." }
    })

    -- Start mission thread
    CreateThread(function()
        -- Wait until player is close to vehicle
        while true do
            Wait(1000)

            -- Check if mission is still active
            if not missionActive then
                return
            end

            -- Check player position
            local playerCoords = GetEntityCoords(PlayerPedId())
            local vehicleCoords = vector3(Config.VigilanteVehicle.coords.x, Config.VigilanteVehicle.coords.y,
                Config.VigilanteVehicle.coords.z)
            local distance = #(playerCoords - vehicleCoords)

            if distance < 100.0 then
                -- Player is close, spawn vehicle
                SpawnMissionVehicle()

                -- Break out of wait loop
                break
            end
        end

        -- Wait for player to enter vehicle
        while true do
            Wait(1000)

            -- Check if mission is still active
            if not missionActive then
                return
            end

            -- Check if vehicle exists
            if missionVehicle == nil or not DoesEntityExist(missionVehicle) then
                FailMission("The target vehicle was destroyed!")
                return
            end

            -- Check if player is in vehicle
            if GetPedInVehicleSeat(missionVehicle, -1) == PlayerPedId() then
                -- Player entered vehicle

                -- Remove target blip
                if targetBlip then
                    RemoveBlip(targetBlip)
                    targetBlip = nil
                end

                -- Create delivery blip
                deliveryBlip = AddBlipForCoord(Config.DeliveryLocation.x, Config.DeliveryLocation.y,
                    Config.DeliveryLocation.z)
                SetBlipSprite(deliveryBlip, 38)
                SetBlipColour(deliveryBlip, 2)
                SetBlipScale(deliveryBlip, 0.8)
                SetBlipRoute(deliveryBlip, true)

                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString("Delivery Location")
                EndTextCommandSetBlipName(deliveryBlip)

                -- Notify player
                TriggerEvent("chat:addMessage", {
                    color = { 0, 255, 0 },
                    multiline = false,
                    args = { "Jimmy De Santa", "You got the Vigilante! Now deliver it to the marked location." }
                })

                -- Trigger police response after delay
                Citizen.SetTimeout(currentDifficulty.policeResponseTime * 1000, function()
                    if missionActive then
                        SpawnPoliceResponse()
                    end
                end)

                -- Break out of wait loop
                break
            end
        end

        -- Wait for delivery
        while true do
            Wait(1000)

            -- Check if mission is still active
            if not missionActive then
                return
            end

            -- Check if vehicle exists
            if missionVehicle == nil or not DoesEntityExist(missionVehicle) then
                FailMission("The target vehicle was destroyed!")
                return
            end

            -- Check if player is still in vehicle
            if GetPedInVehicleSeat(missionVehicle, -1) ~= PlayerPedId() then
                -- Notify player to get back in vehicle
                TriggerEvent("chat:addMessage", {
                    color = { 255, 255, 0 },
                    multiline = false,
                    args = { "Jimmy De Santa", "Get back in the Vigilante! You need to deliver it!" }
                })

                     -- Wait for player to get back in
                Wait(5000)
                goto continue
            end

            -- Check if vehicle is at delivery location
            local vehicleCoords = GetEntityCoords(missionVehicle)
            local deliveryCoords = vector3(Config.DeliveryLocation.x, Config.DeliveryLocation.y,
                Config.DeliveryLocation.z)
            local distance = #(vehicleCoords - deliveryCoords)

            if distance < 5.0 then
                -- Vehicle delivered
                CompleteMission()
                return
            end

            ::continue::
        end
    end)
end

-- Function to spawn mission vehicle
function SpawnMissionVehicle()
    -- Check if vehicle already exists
    if missionVehicle ~= nil and DoesEntityExist(missionVehicle) then
        return
    end

    -- Load the model
    local hash = GetHashKey(Config.VigilanteVehicle.model)
    RequestModel(hash)

    -- Wait for model to load with timeout
    local timeout = GetGameTimer() + 10000
    while not HasModelLoaded(hash) and GetGameTimer() < timeout do
        Wait(100)
    end

    if not HasModelLoaded(hash) then
        DebugPrint("Failed to load vehicle model")
        FailMission("Failed to load vehicle model")
        return
    end

    -- Spawn vehicle
    local coords = Config.VigilanteVehicle.coords
    missionVehicle = CreateVehicle(hash, coords.x, coords.y, coords.z, coords.w, true, false)

    -- Configure vehicle
    SetVehicleOnGroundProperly(missionVehicle)
    SetVehicleDoorsLocked(missionVehicle, 1) -- Unlocked
    SetVehicleEngineOn(missionVehicle, false, false, true)

    -- Set as no longer needed
    SetModelAsNoLongerNeeded(hash)
    DebugPrint("Mission vehicle spawned")
end

-- Function to spawn police response
function SpawnPoliceResponse()
      -- Get difficulty settings
      if not currentDifficulty then
          DebugPrint("Error: currentDifficulty is nil in SpawnPoliceResponse")
          return
      end
      local policeCount = currentDifficulty.policeCount
      local policeVehicleModels = currentDifficulty.policeVehicles

    -- Notify player
    TriggerEvent("chat:addMessage", {
        color = { 255, 0, 0 },
        multiline = false,
        args = { "Dispatch", "All units, we have a grand theft auto in progress. Suspect is driving a Vigilante." }
    })
    
     -- Play police report sound
      PlaySoundFrontend(-1, "TIMER_STOP", "HUD_MINI_GAME_SOUNDSET", true)

     -- Set wanted level
    SetPlayerWantedLevel(PlayerId(), 3, false)
    SetPlayerWantedLevelNow(PlayerId(), false)

    -- Spawn police vehicles
    for i = 1, policeCount do
        -- Get player position
        local playerCoords = GetEntityCoords(PlayerPedId())

        -- Calculate spawn position (behind player)
        local heading = GetEntityHeading(PlayerPedId())
        local spawnDistance = 80.0
        local spawnHeading = heading - 180.0
        if spawnHeading < 0 then spawnHeading = spawnHeading + 360.0 end

        local spawnX = playerCoords.x + math.sin(math.rad(spawnHeading)) * spawnDistance
        local spawnY = playerCoords.y + math.cos(math.rad(spawnHeading)) * spawnDistance
        local spawnZ = playerCoords.z

        -- Select random police vehicle model
        local vehicleModel = policeVehicleModels[math.random(#policeVehicleModels)]
        local vehicleHash = GetHashKey(vehicleModel)

        -- Request model
        RequestModel(vehicleHash)

        -- Wait for model to load with timeout
        local timeout = GetGameTimer() + 5000
        while not HasModelLoaded(vehicleHash) and GetGameTimer() < timeout do
            Wait(100)
        end

        if HasModelLoaded(vehicleHash) then
            -- Spawn police vehicle
            local policeVehicle = CreateVehicle(vehicleHash, spawnX, spawnY, spawnZ, spawnHeading, true, false)

            -- Configure vehicle
            SetVehicleOnGroundProperly(policeVehicle)
            SetVehicleSiren(policeVehicle, true)

            -- Add to list
            table.insert(policeVehicles, policeVehicle)

            -- Spawn police officers
            local officerHash = GetHashKey("s_m_y_cop_01")
            RequestModel(officerHash)

            -- Wait for model to load with timeout
            timeout = GetGameTimer() + 5000
            while not HasModelLoaded(officerHash) and GetGameTimer() < timeout do
            Wait(100)
            end

            if HasModelLoaded(officerHash) then
            -- Create driver
                local driver = CreatePedInsideVehicle(policeVehicle, 4, officerHash, -1, true, false)

            -- Configure driver
                SetPedAsCop(driver, true)
                SetPedCombatAttributes(driver, 46, true)
                SetPedFleeAttributes(driver, 0, false)

            -- Add to list
                table.insert(policePeds, driver)

                -- Create passenger if it's not the last vehicle (to vary the difficulty)
                if i < policeCount then
                    local passenger = CreatePedInsideVehicle(policeVehicle, 4, officerHash, 0, true, false)

                      -- Configure passenger
                    SetPedAsCop(passenger, true)
                    SetPedCombatAttributes(passenger, 46, true)
                    SetPedFleeAttributes(passenger, 0, false)

                     -- Add to list
                    table.insert(policePeds, passenger)
                end

                -- Make police chase player
                TaskVehicleChase(driver, PlayerPedId())
                SetTaskVehicleChaseBehaviorFlag(driver, 1, true) -- TASK_VEHICLE_CHASE_BEHAVIOR_FLAG_ALLOW_OVERTAKING

                -- Set as no longer needed
                SetModelAsNoLongerNeeded(officerHash)
            end

            -- Set as no longer needed
            SetModelAsNoLongerNeeded(vehicleHash)
        end
    end

    DebugPrint("Police response spawned: " .. policeCount .. " vehicles")
end

-- Function to complete mission
function CompleteMission()
    if not missionActive then return end

    -- Stop mission
    missionActive = false

    -- Clean up
    CleanupMission()

    -- Give reward
    TriggerServerEvent("vigilante_mission:giveReward", Config.Reward)

    -- Notify player
    TriggerEvent("chat:addMessage", {
        color = { 0, 255, 0 },
        multiline = false,
        args = { "Jimmy De Santa", "Great job! The Vigilante has been delivered. Here's your payment: $" .. Config.Reward }
    })

    -- Set cooldown
    cooldownActive = true
    Citizen.SetTimeout(Config.Cooldown * 60000, function()
        cooldownActive = false
        DebugPrint("Mission cooldown ended")
    end)
end

-- Function to fail mission
function FailMission(reason)
    if not missionActive then return end

    -- Stop mission
    missionActive = false

    -- Clean up
    CleanupMission()

    -- Notify player
    TriggerEvent("chat:addMessage", {
        color = { 255, 0, 0 },
        multiline = false,
        args = { "Jimmy De Santa", "Mission failed! " .. reason }
    })

    -- Set shorter cooldown for failed mission
    cooldownActive = true
    Citizen.SetTimeout((Config.Cooldown / 2) * 60000, function()
        cooldownActive = false
        DebugPrint("Mission cooldown ended")
    end)
end

-- Function to clean up mission
function CleanupMission()
-- Remove blips
    if targetBlip then
        RemoveBlip(targetBlip)
        targetBlip = nil
    end

    if deliveryBlip then
        RemoveBlip(deliveryBlip)
        deliveryBlip = nil
    end

-- Remove mission vehicle
    if missionVehicle ~= nil and DoesEntityExist(missionVehicle) then
        DeleteEntity(missionVehicle)
        missionVehicle = nil
    end

-- Remove police vehicles
    for _, vehicle in ipairs(policeVehicles) do
        if DoesEntityExist(vehicle) then
            DeleteEntity(vehicle)
        end
    end
    policeVehicles = {}

-- Remove police peds
    for _, ped in ipairs(policePeds) do
        if DoesEntityExist(ped) then
            DeleteEntity(ped)
        end
    end
    policePeds = {}

-- Clear wanted level
    SetPlayerWantedLevel(PlayerId(), 0, false)
    SetPlayerWantedLevelNow(PlayerId(), false)

    DebugPrint("Mission cleaned up")
end

-- Initialize
  CreateThread(function()
-- Wait for game to fully load
     Wait(5000)
    print("Vigilante mission initializing...")

-- Check if coordinates are valid
       local coords = Config.Jimmy.coords
        if coords.x == 0 and coords.y == 0 and coords.z == 0 then
     print("ERROR: Invalid Jimmy coordinates!")
   return
end
-- Create Jimmy NPC
    local success = CreateJimmyNPC()
    print("Jimmy NPC creation " .. (success and "successful" or "failed"))
    print("Jimmy NPC creation " .. (success and "successful" or "failed"))

    print("Vigilante mission initialized")
end)

-- Main thread for interaction
CreateThread(function()
-- Wait for game to load
    Wait(2000)

        'whiletrue' do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local jimmyCoords = vector3(Config.Jimmy.coords.x, Config.Jimmy.coords.y, Config.Jimmy.coords.z)
        local distance = #(playerCoords - jimmyCoords)
        local sleep = 1000

-- Check if player is near Jimmy
        if distance < 10.0 then
            sleep = 0

-- Draw interaction text
    if distance < 3.0 then
         DrawText3D(jimmyCoords.x, jimmyCoords.y, jimmyCoords.z + 1.0, "[E] Talk to Jimmy")
-- Check for interaction key press
                if IsControlJustReleased(0, 38) then
-- Start mission
                 StartMission()
               end
            end
        end

    Wait(sleep)
    end
end)

-- Clean up when resource stops
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        CleanupJimmyNPC()
        CleanupMission()
    end
end)

-- Command to cancel mission
RegisterCommand("cancelmission", function()
    if missionActive then
        FailMission("Mission cancelled by player.")
    else
        TriggerEvent("chat:addMessage", {
            color = { 255, 255, 0 },
            multiline = false,
            args = { "System", "You don't have an active mission to cancel." }
        })
    end
end, false)

-- Command to spawn Jimmy manually
RegisterCommand("spawnjimmy", function()
    print("Attempting to spawn Jimmy...")

-- Delete existing Jimmy if present
    if jimmyPed ~= nil and DoesEntityExist(jimmyPed) then
        print("Deleting existing Jimmy...")
        DeleteEntity(jimmyPed)
        jimmyPed = nil
    end
-- Try to create Jimmy
    print("Creating Jimmy...")
    local success = CreateJimmyNPC()
-- Notify player
    TriggerEvent("chat:addMessage", {
        color = { 255, 255, 0 },
        multiline = false,
        args = { "System", "Jimmy spawn " .. (success and "successful" or "failed" ) }
    })
end, false)

-- Command to check Jimmy model
RegisterCommand("checkjimmy", function()
    local modelName = Config.Jimmy.model
    local modelHash = GetHashKey(modelName)

    local isValid = IsModelInCdimage(modelHash)
    local canLoad = IsModelValid(modelHash)

    TriggerEvent("chat:addMessage", {
        color = { 255, 255, 0 },
        multiline = true,
        args = { "System", "Model: " .. modelName .. "\nHash: " .. modelHash ..
        "\nIn CD Image: " .. (isValid and "Yes" or "No") ..
        "\nValid: " .. (canLoad and "Yes" or "No") }
    })
end, false)
