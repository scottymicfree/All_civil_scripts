local isAnimating = false
local currentVehicle = nil

-- Load animation dictionary
local function LoadAnimDict(dict)
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            Wait(1)
        end
    end
end

-- Check if player is unarmed [citation:4](#)
local function IsPlayerUnarmed()
    local playerPed = PlayerPedId()
    local weaponHash = GetSelectedPedWeapon(playerPed)
    return weaponHash == GetHashKey("WEAPON_UNARMED")
end

-- Check if player is at gunpoint or cops nearby
local function IsInDangerSituation()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    -- Check if being aimed at
    if IsPedBeingJacked(playerPed) then
        return true
    end
    
    -- Check for nearby cops/hostile peds
    local nearbyPeds = GetGamePool('CPed')
    for _, ped in pairs(nearbyPeds) do
        if DoesEntityExist(ped) and ped ~= playerPed then
            local pedCoords = GetEntityCoords(ped)
            local distance = #(playerCoords - pedCoords)
            
            if distance < 10.0 then
                -- Check if ped is aiming at player
                if IsPedAimingFromCover(ped) or GetPedConfigFlag(ped, 78, true) then
                    local target = GetPedTargetFromPed(ped)
                    if target == playerPed then
                        return true
                    end
                end
                
                -- Check if it's a cop
                if IsPedAModel(ped, GetHashKey("s_m_y_cop_01")) or 
                   IsPedAModel(ped, GetHashKey("s_f_y_cop_01")) then
                    return true
                end
            end
        end
    end
    
    return false
end

-- Find nearest mechanic ped
local function FindNearestMechanic(coords)
    local nearbyPeds = GetGamePool('CPed')
    local closestMechanic = nil
    local closestDistance = Config.RepairSettings.searchRadius
    
    for _, ped in pairs(nearbyPeds) do
        if DoesEntityExist(ped) and ped ~= PlayerPedId() then
            local pedCoords = GetEntityCoords(ped)
            local distance = #(coords - pedCoords)
            
            if distance < closestDistance then
                -- Check if it's a mechanic model
                for _, model in pairs(Config.RepairSettings.mechanicModels) do
                    if IsPedAModel(ped, model) then
                        closestMechanic = ped
                        closestDistance = distance
                        break
                    end
                end
            end
        end
    end
    
    return closestMechanic
end

-- Play animation with money transaction
local function PlayAnimationWithMoney(animData, condition)
    if isAnimating then return end
    
    local playerPed = PlayerPedId()
    
    -- Check condition
    if condition and not condition() then
        return false
    end
    
    isAnimating = true
    LoadAnimDict(animData.dict)
    
    -- Play animation
    TaskPlayAnim(playerPed, animData.dict, animData.anim, 8.0, -8.0, -1, animData.flag, 0, false, false, false)
    
    -- Handle money transaction
    if animData.money then
        if animData.money > 0 then
            TriggerEvent('esx:showNotification', '~g~+$' .. animData.money)
            -- Add your money system here: TriggerServerEvent('esx:addMoney', animData.money)
        else
            TriggerEvent('esx:showNotification', '~r~-$' .. math.abs(animData.money))
            -- Remove money here: TriggerServerEvent('esx:removeMoney', math.abs(animData.money))
        end
    end
    
    Wait(3000) -- Animation duration
    isAnimating = false
    return true
end

-- Vehicle repair sequence [citation:1](#)
local function StartVehicleRepair(vehicle)
    if not DoesEntityExist(vehicle) then return end
    
    local playerPed = PlayerPedId()
    local vehicleCoords = GetEntityCoords(vehicle)
    local repairAnim = Config.Animations.repair
    
    -- Check if player has enough money
    -- Add your money check here: if GetPlayerMoney() < repairAnim.cost then return end
    
    -- Charge for repair
    TriggerEvent('esx:showNotification', '~r~-$' .. repairAnim.cost .. ' (Repair Cost)')
    -- TriggerServerEvent('esx:removeMoney', repairAnim.cost)
    
    -- Open hood [citation:1](#)
    SetVehicleDoorOpen(vehicle, 4, false, false)
    
    -- Find mechanic or use player
    local mechanic = FindNearestMechanic(vehicleCoords)
    if not mechanic then
        mechanic = playerPed
    end
    
    -- Move to front of vehicle
    local frontCoords = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, 2.5, 0.0)
    
    if mechanic ~= playerPed then
        TaskGoToCoordAnyMeans(mechanic, frontCoords.x, frontCoords.y, frontCoords.z, 1.0,
