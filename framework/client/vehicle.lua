-- Vehicle Interaction System
-- Handles player interactions with vehicles

local interactKey = Config.Keys.interact
local controllerInteractKey = Config.Keys.controller_interact
local lastTrunkAccess = 0

-- Check for vehicle trunk interactions
Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local vehicle = getClosestVehicle(playerCoords, Config.VehicleInteractionDistance)
        local sleep = 500
        
        if vehicle then
            local trunkCoords = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, -2.5, 0.0)
            local dist = #(playerCoords - trunkCoords)
            
            if dist < Config.TrunkDistance then
                sleep = 0
                draw3DText(trunkCoords + vector3(0, 0, 0.5), "[E / A] Open Trunk")
                
                if (IsControlJustReleased(0, interactKey) or IsControlJustReleased(0, controllerInteractKey)) then
                    -- Prevent trunk spam
                    local currentTime = GetGameTimer()
                    if currentTime - lastTrunkAccess > Config.Cooldowns.trunkAccess then
                        lastTrunkAccess = currentTime
                        openVehicleTrunk(vehicle)
                    end
                end
            end
        end
        
        Citizen.Wait(sleep)
    end
end)

-- Open vehicle trunk
function openVehicleTrunk(vehicle)
    -- Check if vehicle is locked
    if GetVehicleDoorLockStatus(vehicle) ~= 1 then -- 1 = unlocked
        showNotification("Vehicle is locked.", "error")
        return
    end
    
    -- Open trunk animation
    SetVehicleDoorOpen(vehicle, 5, false, false) -- 5 = trunk
    
    -- Request trunk inventory
    TriggerServerEvent("cfw:requestVehicleWeapons", NetworkGetNetworkIdFromEntity(vehicle))
end

-- Handle weapon storage menu
RegisterNetEvent("cfw:openWeaponStorageMenu")
AddEventHandler("cfw:openWeaponStorageMenu", function(weapons)
    -- This would typically open a UI menu
    -- For now, we'll just show a notification with available weapons
    local weaponList = ""
    for _, weapon in ipairs(weapons) do
        weaponList = weaponList .. "- " .. weapon.name .. " (" .. weapon.ammo .. " rounds)\n"
    end
    
    showNotification("Available weapons:\n" .. weaponList)
end)

-- Close trunk when player moves away
Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local openTrunks = {}
        
        -- Find all vehicles with open trunks
        local vehicles = GetGamePool('CVehicle')
        for _, vehicle in ipairs(vehicles) do
            if DoesEntityExist(vehicle) and GetVehicleDoorAngleRatio(vehicle, 5) > 0.1 then
                local trunkCoords = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, -2.5, 0.0)
                local dist = #(playerCoords - trunkCoords)
                
                if dist > Config.TrunkDistance * 2 then
                    SetVehicleDoorShut(vehicle, 5, false)
                end
            end
        end
        
        Citizen.Wait(1000)
    end
end)

-- Request vehicle trunk access
RegisterNetEvent("cfw:openWeaponStorage")
AddEventHandler("cfw:openWeaponStorage", function(vehicle)
    TriggerServerEvent("cfw:requestVehicleWeapons", NetworkGetNetworkIdFromEntity(vehicle))
end)
