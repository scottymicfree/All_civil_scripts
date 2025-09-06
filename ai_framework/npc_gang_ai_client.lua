-- Local variables
local activeEntities = {}
local spawnedServices = {
    ems = false,
    fire = false,
    tow = false,
    taxi = false,
    bus = false
}

-- Debug function
local function DebugPrint(message)
    if Config.Debug then
        print("[Civil Disorder] " .. message)
    end
end

-- Function to load model with timeout
local function LoadModel(model)
    if not IsModelValid(model) then
        DebugPrint("Invalid model: " .. model)
        return false
    end
    
local hash = GetHashKey(model)
    RequestModel(hash)
    
-- Add timeout to prevent infinite loading
local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(hash) and GetGameTimer() < timeout do
    Wait(100)
end
    
if not HasModelLoaded(hash) then
    DebugPrint("Failed to load model: " .. model)
    return false
    end
return hash
end

-- Function to create a blip
local function CreateNPCBlip(coords, sprite, color, name)
    if not Config.EnableBlips then return nil end
    
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, sprite)
    SetBlipColour(blip, color)
    SetBlipAsShortRange(blip, true)
    SetBlipScale(blip, 0.8)
    
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(name)
    EndTextCommandSetBlipName(blip)
    
    return blip
end

-- Function to clean up entities
local function CleanupEntity(entity)
    if DoesEntityExist(entity) then
        DeleteEntity(entity)
        return true
    end
    return false
end


-- Function to spawn EMS service
function NpcEMSMoniton() if spawnedServices.ems then return end
    
CreateThread(function()
local ems = Config.Services.ems
        
-- Load models
local pedHash = LoadModel(ems.model)
local vehHash = LoadModel(ems.vehicle)
        
if not pedHash or not vehHash then
    DebugPrint("Failed to load EMS models")
    return
end
        
-- Create vehicle and ped
local vehicle = CreateVehicle(vehHash, ems.coords.x, ems.coords.y, ems.coords.z, 0.0, true, false)
    if not DoesEntityExist(vehicle) then
    DebugPrint("Failed to create EMS vehicle")
    SetModelAsNoLongerNeeded(vehHash)
    SetModelAsNoLongerNeeded(pedHash)
    return
end
        
local driver = CreatePedInsideVehicle(vehicle, 4, pedHash, -1, true, false)
    if not DoesEntityExist(driver) then
        DebugPrint("Failed to create EMS driver")
        DeleteEntity(vehicle)
        SetModelAsNoLongerNeeded(vehHash)
        SetModelAsNoLongerNeeded(pedHash)
    return
end 
-- FIXED: Removed extra closing brace
        
-- Configure entities
SetEntityAsMissionEntity(vehicle, true, true)
SetEntityAsMissionEntity(driver, true, true)
        
-- Create blip
local blip = CreateNPCBlip(ems.coords, ems.blip, 1, "EMS")
     
-- Set task
TaskVehicleDriveWander(driver, vehicle, 20.0, 786603)
        
 -- Add to active entities
table.insert(activeEntities, {
    type = "ems",
    driver = driver,
    vehicle = vehicle,
    blip = blip
    })
    spawnedServices.ems = true
    DebugPrint("EMS service spawned")
        
-- Clean up models
    SetModelAsNoLongerNeeded(pedHash)
    SetModelAsNoLongerNeeded(vehHash)
    end)
end

-- Function to spawn Fire service
function NpcFireMonitor()
    if spawnedServices.fire then return end
    CreateThread(function()
    local fire = Config.Services.fire
        
-- Load models
local pedHash = LoadModel(fire.model)
        local vehHash = LoadModel(fire.vehicle)
        
if not pedHash or not vehHash then
    DebugPrint("Failed to load Fire models")
    return
end
        
-- Create vehicle and ped
local vehicle = CreateVehicle(vehHash, fire.coords.x, fire.coords.y, fire.coords.z, 0.0, true, false)
    if not DoesEntityExist(vehicle) then
        DebugPrint("Failed to create Fire vehicle")
        SetModelAsNoLongerNeeded(vehHash)
        SetModelAsNoLongerNeeded(pedHash)
        return
    end
    local driver = CreatePedInsideVehicle(vehicle, 4, pedHash, -1, true, false)
        if not DoesEntityExist(driver) then
            DebugPrint("Failed to create Fire driver")
            DeleteEntity(vehicle)
            SetModelAsNoLongerNeeded(vehHash)
            SetModelAsNoLongerNeeded(pedHash)
        return
    end 
-- FIXED: Removed extra closing brace
        
-- Configure entities
SetEntityAsMissionEntity(vehicle, true, true)
    SetEntityAsMissionEntity(driver, true, true)
        
-- Create blip
local blip = CreateNPCBlip(fire.coords, fire.blip, 1, "Fire Department")
        
-- Set task
        TaskVehicleDriveWander(driver, vehicle, 20.0, 786603)
        
-- Add to active entities
table.insert(activeEntities, {
    type = "fire",
        driver = driver,
            vehicle = vehicle,
        blip = blip
    })
        
spawnedServices.fire = true
    DebugPrint("Fire service spawned")
        
-- Clean up models
        SetModelAsNoLongerNeeded(pedHash)
        SetModelAsNoLongerNeeded(vehHash)
    end)
end

-- Function to spawn Tow service
function NpcTowMonitor()
    if spawnedServices.tow then return end
       CreateThread(function()
    local tow = Config.Services.tow
        
-- Load models
local pedHash = LoadModel(tow.model)
        local vehHash = LoadModel(tow.vehicle)
        
        if not pedHash or not vehHash then
            DebugPrint("Failed to load Tow models")
            return
        end
        
        -- Create vehicle and ped
        local vehicle = CreateVehicle(vehHash, tow.coords.x, tow.coords.y, tow.coords.z, 0.0, true, false)
        if not DoesEntityExist(vehicle) then
            DebugPrint("Failed to create Tow vehicle")
            SetModelAsNoLongerNeeded(vehHash)
            SetModelAsNoLongerNeeded(pedHash)
            return
        end
        
        local driver = CreatePedInsideVehicle(vehicle, 4, pedHash, -1, true, false)
        if not DoesEntityExist(driver) then
            DebugPrint("Failed to create Tow driver")
            DeleteEntity(vehicle)
            SetModelAsNoLongerNeeded(vehHash)
            SetModelAsNoLongerNeeded(pedHash)
            return
        end -- FIXED: Removed extra closing brace
        
        -- Configure entities
        SetEntityAsMissionEntity(vehicle, true, true)
        SetEntityAsMissionEntity(driver, true, true)
        
        -- Create blip
        local blip = CreateNPCBlip(tow.coords, tow.blip, 5, "Tow Service")
        
        -- Set task
        TaskVehicleDriveWander(driver, vehicle, 15.0, 786603)
        
        -- Add to active entities
        table.insert(activeEntities, {
            type = "tow",
            driver = driver,
            vehicle = vehicle,
            blip = blip
        })
        
        spawnedServices.tow = true
        DebugPrint("Tow service spawned")
        
        -- Clean up models
        SetModelAsNoLongerNeeded(pedHash)
        SetModelAsNoLongerNeeded(vehHash)
    end)
end

-- Function to spawn Taxi service
function NpcTaxiMonitor()
    if spawnedServices.taxi then return end
    
    CreateThread(function()
        local taxi = Config.Services.taxi
        
        -- Load models
        local pedHash = LoadModel(taxi.model)
        local vehHash = LoadModel(taxi.vehicle)
        
        if not pedHash or not vehHash then
            DebugPrint("Failed to load Taxi models")
            return
        end
        
        -- Create vehicle and ped
        local vehicle = CreateVehicle(vehHash, taxi.coords.x, taxi.coords.y, taxi.coords.z, 0.0, true, false)
        if not DoesEntityExist(vehicle) then
            DebugPrint("Failed to create Taxi vehicle")
            SetModelAsNoLongerNeeded(vehHash)
            SetModelAsNoLongerNeeded(pedHash)
            return
        end
        
        local driver = CreatePedInsideVehicle(vehicle, 4, pedHash, -1, true, false)
        if not DoesEntityExist(driver) then
            DebugPrint("Failed to create Taxi driver")
            DeleteEntity(vehicle)
            SetModelAsNoLongerNeeded(vehHash)
            SetModelAsNoLongerNeeded(pedHash)
            return
        end -- FIXED: Removed extra closing brace
        
        -- Configure entities
        SetEntityAsMissionEntity(vehicle, true, true)
        SetEntityAsMissionEntity(driver, true, true)
        
        -- Create blip
        local blip = CreateNPCBlip(taxi.coords, taxi.blip, 5, "Taxi Service")
        
        -- Set task
        TaskVehicleDriveWander(driver, vehicle, 15.0, 786603)
        
        -- Add to active entities
        table.insert(activeEntities, {
            type = "taxi",
            driver = driver,
            vehicle = vehicle,
            blip = blip
        })
        
        spawnedServices.taxi = true
        DebugPrint("Taxi service spawned")
        
        -- Clean up models
        SetModelAsNoLongerNeeded(pedHash)
        SetModelAsNoLongerNeeded(vehHash)
    end)
end

-- Function to spawn Bus service
function NpcBusMonitor()
    if spawnedServices.bus then return end
    
CreateThread(function()
    local bus = Config.Services.bus
        
-- Load models
    local pedHash = LoadModel(bus.model)
    local vehHash = LoadModel(bus.vehicle)
        if not pedHash or not vehHash then
        DebugPrint("Failed to load Bus models")
    return
 end
        
        -- Create vehicle and ped
        local vehicle = CreateVehicle(vehHash, bus.coords.x, bus.coords.y, bus.coords.z, 0.0, true, false)
        if not DoesEntityExist(vehicle) then
            DebugPrint("Failed to create Bus vehicle")
            SetModelAsNoLongerNeeded(vehHash)
            SetModelAsNoLongerNeeded(pedHash)
            return
        end
        
        local driver = CreatePedInsideVehicle(vehicle, 4, pedHash, -1, true, false)
        if not DoesEntityExist(driver) then
            DebugPrint("Failed to create Bus driver")
            DeleteEntity(vehicle)
            SetModelAsNoLongerNeeded(vehHash)
            SetModelAsNoLongerNeeded(pedHash)
            return
        end -- FIXED: Removed extra closing brace
        
        -- Configure entities
        SetEntityAsMissionEntity(vehicle, true, true)
        SetEntityAsMissionEntity(driver, true, true)
        
        -- Create blip
        local blip = CreateNPCBlip(bus.coords, bus.blip, 3, "Bus Service")
        
        -- Add to active entities
        table.insert(activeEntities, {
            type = "bus",
            driver = driver,
            vehicle = vehicle,
            blip = blip,
            currentStop = 1
        })
        
        spawnedServices.bus = true
        DebugPrint("Bus service spawned")
        
        -- Clean up models
        SetModelAsNoLongerNeeded(pedHash)
        SetModelAsNoLongerNeeded(vehHash)
        
        -- Bus route logic
        CreateThread(function()
            local busData = activeEntities[#activeEntities]
            local routeIndex = 1
            
            while DoesEntityExist(busData.vehicle) and DoesEntityExist(busData.driver) do
                local stop = bus.route[routeIndex]
                
-- Wait until close to stop
local arrived = false
                while not arrived and DoesEntityExist(busData.vehicle) 
                do local busCoords = GetEntityCoords(busData.vehicle)
                    local distance = #(busCoords - stop)
           if distance < 10.0 then
    arrived = true
    end
                    
    Wait(1000)
end
                
-- Wait at stop
Wait(5000)
                
-- Move to next stop
routeIndex = routeIndex % #bus.route + 1
            end
        end)
    end)
end

-- Function to spawn gang members
function SpawnGangMembers(gangData)
    CreateThread(function()
        -- Load models
        local pedHash = LoadModel(gangData.model)
        local vehHash = LoadModel(gangData.vehicle)
        local dogHash = Config.EnableDogs and LoadModel(gangData.dog)
        
        if not pedHash or not vehHash then
            DebugPrint("Failed to load gang models for " .. gangData.name)
            return
        end
        
-- Create vehicle
local vehicle = CreateVehicle(vehHash, gangData.coords.x, gangData.coords.y, gangData.coords.z, 0.0, true, false)
    if not DoesEntityExist(vehicle) then
        DebugPrint("Failed to create gang vehicle for " .. gangData.name)
        SetModelAsNoLongerNeeded(vehHash)
        SetModelAsNoLongerNeeded(pedHash)
        if dogHash then SetModelAsNoLongerNeeded(dogHash)
         end
    return
end
-- Create gang members
local members = {}
    for i = 1, 3 do
        local seat = i - 2 -- -1 = driver, 0 = passenger, 1 = rear left
        local ped
            if i == 1 then
                ped = CreatePedInsideVehicle(vehicle, 4, pedHash, seat, true, false)
            else
                ped = CreatePedInsideVehicle(vehicle, 4, pedHash, seat, true, false)
            end
            
            if DoesEntityExist(ped) then
                -- Configure gang member
                SetEntityAsMissionEntity(ped, true, true)
                SetPedArmour(ped, 100)
                SetPedAccuracy(ped, 60)
                SetPedCombatAttributes(ped, 46, true)
                SetPedFleeAttributes(ped, 0, false)
                GiveWeaponToPed(ped, GetHashKey("WEAPON_PISTOL"), 100, false, true)
                
                table.insert(members, ped)
            end
        end
        
        -- Create dog if enabled
        local dog = nil
        if dogHash and Config.EnableDogs then
            dog = CreatePed(28, dogHash, 
                gangData.coords.x + 2.0, 
                gangData.coords.y + 2.0, 
                gangData.coords.z, 
                0.0, true, false)
                
            if DoesEntityExist(dog) then
                SetEntityAsMissionEntity(dog, true, true)
                TaskFollowToOffsetOfEntity(dog, members[1], 1.0, -1.0, 0.0, 5.0, -1, 1.0, true)
            end
        end
        
        -- Create blip
        local blip = CreateNPCBlip(gangData.coords, 429, gangData.blipColor, gangData.name)
        
        -- Set task
        TaskVehicleDriveWander(members[1], vehicle, 15.0, 786603)
        
        -- Add to active entities
        table.insert(activeEntities, {
            type = "gang",
            name = gangData.name,
            members = members,
            vehicle = vehicle,
            dog = dog,
            blip = blip,
            offer = gangData.offer
        })
        
        DebugPrint("Gang spawned: " .. gangData.name)
        
        -- Clean up models
        SetModelAsNoLongerNeeded(pedHash)
        SetModelAsNoLongerNeeded(vehHash)
        if dogHash then SetModelAsNoLongerNeeded(dogHash) end
    end)
end

-- Function to clean up all entities
function CleanupAllEntities()
    for _, entity in ipairs(activeEntities) do
        if entity.type == "gang" then
            -- Clean up gang members
            for _, member in ipairs(entity.members) do
                CleanupEntity(member)
            end
            
            -- Clean up dog
            if entity.dog then
                CleanupEntity(entity.dog)
            end
        else
            -- Clean up driver
            if entity.driver then
                CleanupEntity(entity.driver)
            end
        end
        
        -- Clean up vehicle
        if entity.vehicle then
            CleanupEntity(entity.vehicle)
        end
        
        -- Clean up blip
        if entity.blip then
            RemoveBlip(entity.blip)
        end
    end
    
    -- Reset active entities
    activeEntities = {}
    
    -- Reset spawned services
    for service in pairs(spawnedServices) do
        spawnedServices[service] = false
    end
    
    DebugPrint("All entities cleaned up")
end

-- Main thread to manage entities
CreateThread(function()
    -- Wait for game to load
    Wait(5000)
    
    -- Initialize services
    NpcFireMonitor()
    NpcTowMonitor()
    NpcTaxiMonitor()
    NpcBusMonitor()
    
    -- Spawn initial gangs
    for _, gang in ipairs(Config.Gangs) do
        if gang.enabled then
            SpawnGangMembers(gang)
            Wait(500) -- Stagger spawns to prevent resource spikes
        end
    end
    
    DebugPrint("Civil Disorder initialized")
end)

-- Event handler for resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        CleanupAllEntities()
    end
end)

-- Command to toggle debug mode
RegisterCommand("cd_debug", function()
    Config.Debug = not Config.Debug
    TriggerEvent("chat:addMessage", {
        color = {255, 255, 0},
        multiline = false,
        args = {"Civil Disorder", "Debug mode: " .. (Config.Debug and "Enabled" or "Disabled")}
    })
end, false)

-- Command to respawn all entities
RegisterCommand("cd_respawn", function()
     CleanupAllEntities()
    Wait(1000)
    
-- Reinitialize services
     NpcFireMonitor()
     NpcTowMonitor()
     NpcTaxiMonitor()
     NpcBusMonitor()
-- Respawn gangs
     for _, gang in ipairs(Config.Gangs) do
        if gang.enabled then
            SpawnGangMembers(gang)
            Wait(500)
        end
    end
 TriggerEvent("chat:addMessage", {
        color = {255, 255, 0},
        multiline = false,
        args = {"Civil Disorder", "All entities respawned"}
    })
end, false)
