-- Local variables
local activeEntities = {}
local playerInZone = false

-- Debug function
local function DebugPrint(message)
    if Config.Debug then
        print("[HILLBILLY] " .. message)
    end
end

-- Load model with timeout
local function LoadModel(model)
    local hash = GetHashKey(model)
    RequestModel(hash)
    
    -- Add timeout to prevent infinite loading
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(hash) and GetGameTimer() < timeout do 
        Wait(50) 
    end
    
    if not HasModelLoaded(hash) then
        DebugPrint("Failed to load model: " .. model)
        return nil
    end
    
    return hash
end

-- Spawn hillbilly on mower
local function SpawnHillbillyMower(location, offset)
    -- Select random model
    local modelIndex = math.random(#Config.HillbillyModels)
    local pedHash = LoadModel(Config.HillbillyModels[modelIndex])
    local mowerHash = LoadModel(Config.MowerModel)
    
    if not pedHash or not mowerHash then
        DebugPrint("Failed to load models for hillbilly spawn")
        return nil
    end
    
    -- Calculate spawn position
    local pos = location.center + offset
    
    -- Create vehicle and ped
    local mower = CreateVehicle(mowerHash, pos.x, pos.y, pos.z, math.random(0, 360), true, false)
    if not DoesEntityExist(mower) then
        DebugPrint("Failed to create mower vehicle")
        SetModelAsNoLongerNeeded(mowerHash)
        SetModelAsNoLongerNeeded(pedHash)
        return nil
    end
    
    local ped = CreatePedInsideVehicle(mower, 4, pedHash, -1, true, false)
    if not DoesEntityExist(ped) then
        DebugPrint("Failed to create hillbilly ped")
        DeleteEntity(mower)
        SetModelAsNoLongerNeeded(mowerHash)
        SetModelAsNoLongerNeeded(pedHash)
        return nil
    end
    
    -- Configure entities
    SetEntityAsMissionEntity(ped, true, true)
    SetEntityAsMissionEntity(mower, true, true)
    SetBlockingOfNonTemporaryEvents(ped, false)
    
    -- Set initial task
    TaskVehicleDriveWander(ped, mower, Config.MowerSpeed, 786603)
    
    -- Add to active entities
    table.insert(activeEntities, {
        ped = ped,
        vehicle = mower,
        location = location
    })
    
    DebugPrint("Spawned hillbilly at " .. pos.x .. ", " .. pos.y .. ", " .. pos.z)
    
    -- Clean up models
    SetModelAsNoLongerNeeded(pedHash)
    SetModelAsNoLongerNeeded(mowerHash)
    
    return true
end

-- Despawn all hillbillies
local function DespawnAll()
    for _, entity in ipairs(activeEntities) do
        if DoesEntityExist(entity.ped) then DeleteEntity(entity.ped) end
        if DoesEntityExist(entity.vehicle) then DeleteEntity(entity.vehicle) end
    end
    activeEntities = {}
    DebugPrint("All hillbillies despawned")
end

-- Main thread for zone checking
Citizen.CreateThread(function()
    -- Wait for game to load
    Citizen.Wait(2000)
    
    -- Main loop
    while true do
        local playerCoords = GetEntityCoords(PlayerPedId())
        local inAnyZone = false
        local sleep = 5000
        
        for _, location in ipairs(Config.SpawnLocations) do
            local dist = #(playerCoords - location.center)
            
            -- Check if player entered zone
            if dist < location.radius and not playerInZone then
                playerInZone = true
                inAnyZone = true
                sleep = 3000
                
                -- Spawn hillbillies for this location
                local spawnCount = math.random(location.minSpawn, location.maxSpawn)
                for i = 1, spawnCount do
                    local offset = vector3(
                        math.random(-location.radius/2, location.radius/2),
                        math.random(-location.radius/2, location.radius/2),
                        0.0
                    )
                    SpawnHillbillyMower(location, offset)
                end
                
                -- Notify server
                TriggerServerEvent("hillbilly_mower:playerEnteredZone")
                
            -- Check if player left zone
            elseif dist > location.despawnRadius and playerInZone then
                playerInZone = false
                
                -- Despawn hillbillies
                DespawnAll()
                
                -- Notify server
                TriggerServerEvent("hillbilly_mower:playerLeftZone")
            end
            
            if dist < location.radius then
                inAnyZone = true
                sleep = 3000
            end
        end
        
        -- Update global zone status
        if inAnyZone ~= playerInZone then
            playerInZone = inAnyZone
            if playerInZone then
                DebugPrint("Player entered hillbilly territory")
            else
                DebugPrint("Player left hillbilly territory")
            end
        end
        
        Citizen.Wait(sleep)
    end
end)

-- Event handler for server-triggered spawn
RegisterNetEvent("hillbilly_mower:spawn")
AddEventHandler("hillbilly_mower:spawn", function()
    -- Check if player is in any spawn zone
    local playerCoords = GetEntityCoords(PlayerPedId())
    
    for _, location in ipairs(Config.SpawnLocations) do
        local dist = #(playerCoords - location.center)
        
        if dist < location.radius then
            -- Spawn hillbillies for this location
            local spawnCount = math.random(location.minSpawn, location.maxSpawn)
            for i = 1, spawnCount do
                local offset = vector3(
                    math.random(-location.radius/2, location.radius/2),
                    math.random(-location.radius/2, location.radius/2),
                    0.0
                )
                SpawnHillbillyMower(location, offset)
            end
            
            playerInZone = true
            break
        end
    end
end)

-- Event handler for resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        DespawnAll()
    end
end)

-- Notify server when resource starts
AddEventHandler('onClientResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        Citizen.Wait(2000) -- Wait for everything to initialize
        TriggerServerEvent("hillbilly_mower:clientReady")
        DebugPrint("Client initialized")
    end
end)
