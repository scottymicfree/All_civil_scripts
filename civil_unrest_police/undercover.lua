-- Police Undercover System
-- This script handles undercover police operations

-- Configuration
local Config = {
    UndercoverVehicles = {
        "dominator",
        "buffalo",
        "sentinel",
        "tailgater",
        "schafter2"
    },
    UndercoverOutfits = {
        male = {
            { component = 0, drawable = 1, texture = 0 },   -- Face
            { component = 1, drawable = 0, texture = 0 },   -- Mask
            { component = 2, drawable = 2, texture = 0 },   -- Hair
            { component = 3, drawable = 0, texture = 0 },   -- Torso
            { component = 4, drawable = 0, texture = 0 },   -- Legs
            { component = 5, drawable = 0, texture = 0 },   -- Bags
            { component = 6, drawable = 1, texture = 0 },   -- Shoes
            { component = 7, drawable = 0, texture = 0 },   -- Accessories
            { component = 8, drawable = 0, texture = 0 },   -- Undershirt
            { component = 9, drawable = 0, texture = 0 },   -- Body Armor
            { component = 10, drawable = 0, texture = 0 },  -- Decals
            { component = 11, drawable = 0, texture = 0 }   -- Top
        },
        female = {
            { component = 0, drawable = 1, texture = 0 },   -- Face
            { component = 1, drawable = 0, texture = 0 },   -- Mask
            { component = 2, drawable = 2, texture = 0 },   -- Hair
            { component = 3, drawable = 2, texture = 0 },   -- Torso
            { component = 4, drawable = 0, texture = 0 },   -- Legs
            { component = 5, drawable = 0, texture = 0 },   -- Bags
            { component = 6, drawable = 1, texture = 0 },   -- Shoes
            { component = 7, drawable = 0, texture = 0 },   -- Accessories
            { component = 8, drawable = 0, texture = 0 },   -- Undershirt
            { component = 9, drawable = 0, texture = 0 },   -- Body Armor
            { component = 10, drawable = 0, texture = 0 },  -- Decals
            { component = 11, drawable = 0, texture = 0 }   -- Top
        }
    },
    UndercoverLocations = {
        { coords = vector3(200.0, -800.0, 30.0), heading = 0.0 },
        { coords = vector3(-1100.0, -1400.0, 5.0), heading = 90.0 },
        { coords = vector3(1800.0, 3700.0, 34.0), heading = 180.0 }
    }
}

-- Variables
local undercoverNPCs = {}
local undercoverVehicles = {}
local isPlayerUndercover = false
local originalPlayerOutfit = {}
local debugMode = false

-- Function to spawn undercover police NPC
function SpawnUndercoverNPC(coords, heading)
    -- Select random civilian model
    local civilianModels = {
        "a_m_y_business_01",
        "a_m_y_hipster_01",
        "a_f_y_business_01",
        "a_f_y_hipster_01"
    }
    local modelName = civilianModels[math.random(1, #civilianModels)]
    local model = GetHashKey(modelName)
    
    -- Request model
    RequestModel(model)
    local timeout = 5000
    local startTime = GetGameTimer()
    while not HasModelLoaded(model) do
        if GetGameTimer() - startTime > timeout then
            if debugMode then
                print("Failed to load undercover model: " .. modelName)
            end
            return nil
        end
        Citizen.Wait(100)
    end
    
    -- Spawn NPC
    local ped = CreatePed(4, model, coords.x, coords.y, coords.z, heading or 0.0, true, false)
    
    if not ped or not DoesEntityExist(ped) then
        if debugMode then
            print("Failed to create undercover ped")
        end
        return nil
    end
    
    -- Configure NPC (looks like civilian but acts like police)
    SetPedArmour(ped, 100)
    SetPedAccuracy(ped, 70)
    SetPedCombatAttributes(ped, 46, true)
    SetPedFleeAttributes(ped, 0, false)
    SetPedCombatRange(ped, 2)
    SetPedCombatMovement(ped, 2)
    GiveWeaponToPed(ped, GetHashKey("WEAPON_PISTOL"), 100, true, true)
    SetPedCanSwitchWeapon(ped, true)
    
    -- Store NPC data
    table.insert(undercoverNPCs, {
        ped = ped,
        spawnTime = GetGameTimer(),
        model = modelName
    })
    
    -- Return the ped
    return ped
end

-- Function to spawn undercover police vehicle
function SpawnUndercoverVehicle(coords, heading)
    -- Select random undercover vehicle
    local vehicleModel = Config.UndercoverVehicles[math.random(1, #Config.UndercoverVehicles)]
    local model = GetHashKey(vehicleModel)
    
    -- Request model
    RequestModel(model)
    local timeout = 5000
    local startTime = GetGameTimer()
    while not HasModelLoaded(model) do
        if GetGameTimer() - startTime > timeout then
            if debugMode then
                print("Failed to load undercover vehicle model: " .. vehicleModel)
            end
            return nil
        end
        Citizen.Wait(100)
    end
    
    -- Spawn vehicle
    local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, heading or 0.0, true, false)
    
    if not vehicle or not DoesEntityExist(vehicle) then
        if debugMode then
            print("Failed to create undercover vehicle")
        end
        return nil
    end
    
    -- Configure vehicle
    SetVehicleOnGroundProperly(vehicle)
    SetVehicleEngineOn(vehicle, true, true, false)
    
    -- Spawn driver
    local driver = SpawnUndercoverNPC(coords, heading)
    if driver then
        SetPedIntoVehicle(driver, vehicle, -1)
        TaskVehicleDriveWander(driver, vehicle, 20.0, 786603)
    end
    
    -- Store vehicle data
    table.insert(undercoverVehicles, {
        vehicle = vehicle,
        driver = driver,
        spawnTime = GetGameTimer(),
        model = vehicleModel
    })
    
    -- Return the vehicle
    return vehicle
end

-- Function to clean up old undercover entities
function CleanupUndercoverEntities()
    local currentTime = GetGameTimer()
    local newNPCs = {}
    local newVehicles = {}
    
    -- Clean up NPCs
    for i, npc in ipairs(undercoverNPCs) do
        -- Check if NPC still exists and isn't too old (30 minutes)
        if DoesEntityExist(npc.ped) and (currentTime - npc.spawnTime) < 1800000 then
            table.insert(newNPCs, npc)
        else
            -- Delete the ped if it exists
            if DoesEntityExist(npc.ped) then
                DeleteEntity(npc.ped)
            end
            
            if debugMode then
                print("Cleaned up undercover NPC")
            end
        end
    end
    
    -- Clean up vehicles
    for i, veh in ipairs(undercoverVehicles) do
        -- Check if vehicle still exists and isn't too old (30 minutes)
        if DoesEntityExist(veh.vehicle) and (currentTime - veh.spawnTime) < 1800000 then
            table.insert(newVehicles, veh)
        else
            -- Delete the vehicle if it exists
            if DoesEntityExist(veh.vehicle) then
                DeleteEntity(veh.vehicle)
            end
            
            if debugMode then
                print("Cleaned up undercover vehicle")
            end
        end
    end
    
    undercoverNPCs = newNPCs
    undercoverVehicles = newVehicles
end

-- Function to set player as undercover
function SetPlayerUndercover(state)
    local playerPed = PlayerPedId()
    
    if state then
        -- Save original outfit
        originalPlayerOutfit = {}
        for i = 0, 11 do
            originalPlayerOutfit[i] = {
                drawable = GetPedDrawableVariation(playerPed, i),
                texture = GetPedTextureVariation(playerPed, i)
            }
        end
        
        -- Set undercover outfit
        local gender = IsPedMale(playerPed) and "male" or "female"
        local outfit = Config.UndercoverOutfits[gender]
        
        for _, item in ipairs(outfit) do
            SetPedComponentVariation(playerPed, item.component, item.drawable, item.texture, 0)
        end
        
        -- Set undercover status
        isPlayerUndercover = true
        
        -- Notify player
        ShowNotification("~b~You are now undercover")
        
        -- Trigger event for other resources
        TriggerEvent("civil_unrest_police:undercoverStatusChanged", true)
    else
        -- Restore original outfit
        for component, data in pairs(originalPlayerOutfit) do
            SetPedComponentVariation(playerPed, component, data.drawable, data.texture, 0)
        end
        
        -- Clear original outfit data
        originalPlayerOutfit = {}
        
        -- Set undercover status
        isPlayerUndercover = false
        
        -- Notify player
        ShowNotification("~b~You are no longer undercover")
        
        -- Trigger event for other resources
        TriggerEvent("civil_unrest_police:undercoverStatusChanged", false)
    end
    
    return isPlayerUndercover
end

-- Function to toggle player undercover status
function TogglePlayerUndercover()
    return SetPlayerUndercover(not isPlayerUndercover)
end

-- Main thread for undercover system
Citizen.CreateThread(function()
    -- Wait for resource to fully start
    Citizen.Wait(5000)
    
    -- Spawn initial undercover units
    for _, location in ipairs(Config.UndercoverLocations) do
        SpawnUndercoverVehicle(location.coords, location.heading)
    end
    
    while true do
        -- Spawn new undercover units periodically
        if math.random() < 0.05 then -- 5% chance each cycle
            local location = Config.UndercoverLocations[math.random(1, #Config.UndercoverLocations)]
            SpawnUndercoverVehicle(location.coords, location.heading)
        end
        
        -- Clean up old entities
        CleanupUndercoverEntities()
        
        -- Wait before next cycle
        Citizen.Wait(60000) -- Check every minute
    end
end)

-- Commands
RegisterCommand("undercover", function(source, args, rawCommand)
    -- Check if player is a police officer (replace with your job check)
    local isPoliceOfficer = true -- Placeholder, replace with actual check
    
    if isPoliceOfficer then
        TogglePlayerUndercover()
    else
        ShowNotification("~r~You are not a police officer")
    end
end, false)

-- Debug command
RegisterCommand("undercover_debug", function()
    debugMode = not debugMode
    ShowNotification("Undercover debug mode: " .. (debugMode and "Enabled" or "Disabled"))
end, false)

-- Export functions
exports('SpawnUndercoverNPC', SpawnUndercoverNPC)
exports('SpawnUndercoverVehicle', SpawnUndercoverVehicle)
exports('SetPlayerUndercover', SetPlayerUndercover)
exports('TogglePlayerUndercover', TogglePlayerUndercover)
exports('IsPlayerUndercover', function() return isPlayerUndercover end)