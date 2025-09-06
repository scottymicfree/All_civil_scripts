-- Police Patrol System
-- This script handles police patrol routes and behaviors

-- Patrol routes
local patrolRoutes = {
    downtown = {
        { coords = vector3(235.12, -800.53, 30.10), duration = 30 },
        { coords = vector3(300.45, -900.77, 29.29), duration = 30 },
        { coords = vector3(400.21, -950.33, 29.42), duration = 30 },
        { coords = vector3(350.67, -850.12, 29.29), duration = 30 }
    },
    vespucci = {
        { coords = vector3(-1200.33, -1450.21, 4.37), duration = 30 },
        { coords = vector3(-1300.45, -1400.67, 4.10), duration = 30 },
        { coords = vector3(-1350.21, -1300.33, 4.42), duration = 30 },
        { coords = vector3(-1250.67, -1350.12, 4.29), duration = 30 }
    },
    sandy = {
        { coords = vector3(1800.33, 3650.21, 34.37), duration = 30 },
        { coords = vector3(1900.45, 3700.67, 32.10), duration = 30 },
        { coords = vector3(1950.21, 3800.33, 32.42), duration = 30 },
        { coords = vector3(1850.67, 3750.12, 33.29), duration = 30 }
    }
}

-- Patrol data
local activePatrols = {}
local patrolVehicles = {}
local patrolPeds = {}
local debugMode = false

-- Function to start a new patrol
function StartPatrol(routeName, vehicleModel, pedModel)
    -- Check if route exists
    if not patrolRoutes[routeName] then
        if debugMode then
            print("Patrol route not found: " .. routeName)
        end
        return nil
    end
    
    -- Get route
    local route = patrolRoutes[routeName]
    
    -- Select spawn point (first point in route)
    local spawnPoint = route[1].coords
    
    -- Load vehicle model
    vehicleModel = vehicleModel or "police"
    local vehHash = GetHashKey(vehicleModel)
    RequestModel(vehHash)
    local timeout = 5000
    local startTime = GetGameTimer()
    while not HasModelLoaded(vehHash) do
        if GetGameTimer() - startTime > timeout then
            if debugMode then
                print("Failed to load vehicle model: " .. vehicleModel)
            end
            return nil
        end
        Citizen.Wait(100)
    end
    
    -- Load ped model
    pedModel = pedModel or "s_m_y_cop_01"
    local pedHash = GetHashKey(pedModel)
    RequestModel(pedHash)
    startTime = GetGameTimer()
    while not HasModelLoaded(pedHash) do
        if GetGameTimer() - startTime > timeout then
            if debugMode then
                print("Failed to load ped model: " .. pedModel)
            end
            return nil
        end
        Citizen.Wait(100)
    end
    
    -- Spawn vehicle
    local vehicle = CreateVehicle(vehHash, spawnPoint.x, spawnPoint.y, spawnPoint.z, 0.0, true, false)
    if not vehicle or not DoesEntityExist(vehicle) then
        if debugMode then
            print("Failed to create patrol vehicle")
        end
        return nil
    end
    
    -- Configure vehicle
    SetVehicleOnGroundProperly(vehicle)
    SetVehicleEngineOn(vehicle, true, true, false)
    SetVehicleSiren(vehicle, false)
    
    -- Spawn driver
    local driver = CreatePed(4, pedHash, spawnPoint.x, spawnPoint.y, spawnPoint.z, 0.0, true, false)
    if not driver or not DoesEntityExist(driver) then
        if debugMode then
            print("Failed to create patrol driver")
        end
        DeleteEntity(vehicle)
        return nil
    end
    
    -- Configure driver
    SetPedIntoVehicle(driver, vehicle, -1)
    SetPedArmour(driver, 100)
    SetPedAccuracy(driver, 60)
    SetPedCombatAttributes(driver, 46, true)
    SetPedFleeAttributes(driver, 0, false)
    SetPedCombatRange(driver, 2)
    SetPedCombatMovement(driver, 2)
    GiveWeaponToPed(driver, GetHashKey("WEAPON_PISTOL"), 100, false, true)
    
    -- Spawn passenger
    local passenger = CreatePed(4, pedHash, spawnPoint.x, spawnPoint.y, spawnPoint.z, 0.0, true, false)
    if passenger and DoesEntityExist(passenger) then
        -- Configure passenger
        SetPedIntoVehicle(passenger, vehicle, 0)
        SetPedArmour(passenger, 100)
        SetPedAccuracy(passenger, 60)
        SetPedCombatAttributes(passenger, 46, true)
        SetPedFleeAttributes(passenger, 0, false)
        SetPedCombatRange(passenger, 2)
        SetPedCombatMovement(passenger, 2)
        GiveWeaponToPed(passenger, GetHashKey("WEAPON_PISTOL"), 100, false, true)
    end
    
    -- Create patrol data
    local patrolId = #activePatrols + 1
    local patrolData = {
        id = patrolId,
        route = routeName,
        vehicle = vehicle,
        driver = driver,
        passenger = passenger,
        currentPoint = 1,
        startTime = GetGameTimer()
    }
    
    -- Add to active patrols
    activePatrols[patrolId] = patrolData
    
    -- Start patrol
    DriveToNextPatrolPoint(patrolId)
    
    if debugMode then
        print("Started patrol #" .. patrolId .. " on route: " .. routeName)
    end
    
    return patrolId
end

-- Function to drive to next patrol point
function DriveToNextPatrolPoint(patrolId)
    -- Check if patrol exists
    if not activePatrols[patrolId] then
        if debugMode then
            print("Patrol not found: " .. patrolId)
        end
        return false
    end
    
    -- Get patrol data
    local patrol = activePatrols[patrolId]
    
    -- Check if vehicle and driver exist
    if not DoesEntityExist(patrol.vehicle) or not DoesEntityExist(patrol.driver) then
        if debugMode then
            print("Patrol vehicle or driver no longer exists")
        end
        CleanupPatrol(patrolId)
        return false
    end
    
    -- Get route
    local route = patrolRoutes[patrol.route]
    if not route then
        if debugMode then
            print("Patrol route not found: " .. patrol.route)
        end
        CleanupPatrol(patrolId)
        return false
    end
    
    -- Get next point
    local nextPoint = route[patrol.currentPoint]
    
    -- Drive to next point
    TaskVehicleDriveToCoord(patrol.driver, patrol.vehicle, nextPoint.coords.x, nextPoint.coords.y, nextPoint.coords.z, 20.0, 0, GetEntityModel(patrol.vehicle), 786603, 5.0, true)
    
    -- Update patrol data
    patrol.currentPoint = patrol.currentPoint % #route + 1
    
    if debugMode then
        print("Patrol #" .. patrolId .. " driving to point #" .. patrol.currentPoint)
    end
    
    return true
end

-- Function to cleanup patrol
function CleanupPatrol(patrolId)
    -- Check if patrol exists
    if not activePatrols[patrolId] then
        return false
    end
    
    -- Get patrol data
    local patrol = activePatrols[patrolId]
    
    -- Delete entities
    if DoesEntityExist(patrol.vehicle) then
        DeleteEntity(patrol.vehicle)
    end
    
    if DoesEntityExist(patrol.driver) then
        DeleteEntity(patrol.driver)
    end
    
    if DoesEntityExist(patrol.passenger) then
        DeleteEntity(patrol.passenger)
    end
    
    -- Remove from active patrols
    activePatrols[patrolId] = nil
    
    if debugMode then
        print("Cleaned up patrol #" .. patrolId)
    end
    
    return true
end

-- Function to check patrol status
function CheckPatrolStatus(patrolId)
    -- Check if patrol exists
    if not activePatrols[patrolId] then
        return false
    end
    
    -- Get patrol data
    local patrol = activePatrols[patrolId]
    
    -- Check if vehicle and driver exist
    if not DoesEntityExist(patrol.vehicle) or not DoesEntityExist(patrol.driver) then
        if debugMode then
            print("Patrol vehicle or driver no longer exists")
        end
        CleanupPatrol(patrolId)
        return false
    end
    
    -- Check if vehicle is stuck
    if IsEntityUpsidedown(patrol.vehicle) or IsEntityInWater(patrol.vehicle) then
        if debugMode then
            print("Patrol vehicle is stuck")
        end
        CleanupPatrol(patrolId)
        return false
    end
    
    -- Check if vehicle has reached destination
    local vehicleCoords = GetEntityCoords(patrol.vehicle)
    local route = patrolRoutes[patrol.route]
    local currentPoint = route[patrol.currentPoint]
    local distance = #(vehicleCoords - currentPoint.coords)
    
    if distance < 10.0 then
        -- Wait at point
        Citizen.SetTimeout(currentPoint.duration * 1000, function()
            if activePatrols[patrolId] then
                DriveToNextPatrolPoint(patrolId)
            end
        end)
    end
    
    return true
end

-- Main thread for patrol management
Citizen.CreateThread(function()
    -- Wait for resource to fully start
    Citizen.Wait(5000)
    
    -- Start initial patrols
    StartPatrol("downtown", "police", "s_m_y_cop_01")
    StartPatrol("vespucci", "police2", "s_f_y_cop_01")
    StartPatrol("sandy", "police3", "s_m_y_hwaycop_01")
    
    while true do
        -- Check patrol status
        for patrolId, _ in pairs(activePatrols) do
            CheckPatrolStatus(patrolId)
        end
        
        -- Start new patrols periodically
        if math.random() < 0.1 then -- 10% chance each cycle
            local routes = {"downtown", "vespucci", "sandy"}
            local vehicles = {"police", "police2", "police3", "police4"}
            local peds = {"s_m_y_cop_01", "s_f_y_cop_01", "s_m_y_hwaycop_01"}
            
            local route = routes[math.random(1, #routes)]
            local vehicle = vehicles[math.random(1, #vehicles)]
            local ped = peds[math.random(1, #peds)]
            
            StartPatrol(route, vehicle, ped)
        end
        
        -- Wait before next cycle
        Citizen.Wait(30000) -- Check every 30 seconds
    end
end)

-- Debug command
RegisterCommand("patrol_debug", function()
    debugMode = not debugMode
    ShowNotification("Patrol debug mode: " .. (debugMode and "Enabled" or "Disabled"))
end, false)

-- Export functions
exports('StartPatrol', StartPatrol)
exports('CleanupPatrol', CleanupPatrol)