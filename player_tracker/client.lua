local playerData = {
    lastGps = vector3(0, 0, 0),
    kills = 0,
    deaths = 0,
    xp = 0,
    level = 1,
    vehicles = {},
    lastVehicle = nil
}

local updateInterval = 10000 -- Update server every 10 seconds
local trackingActive = true

-- Function to update GPS position
function UpdateGpsPosition()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    playerData.lastGps = coords
    return coords
end

-- Function to track current vehicle
function TrackCurrentVehicle()
    local playerPed = PlayerPedId()
    if IsPedInAnyVehicle(playerPed, false) then
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        if DoesEntityExist(vehicle) then
            local vehicleProps = GetVehicleProperties(vehicle)
            local vehicleModel = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
            
            -- Only update if vehicle changed
            if not playerData.lastVehicle or playerData.lastVehicle ~= vehicleProps.plate then
                playerData.lastVehicle = vehicleProps.plate
                
                -- Add to vehicles list if not already tracked
                local found = false
                for i, v in ipairs(playerData.vehicles) do
                    if v.plate == vehicleProps.plate then
                        found = true
                        break
                    end
                end
                
                if not found then
                    table.insert(playerData.vehicles, {
                        model = vehicleModel,
                        plate = vehicleProps.plate,
                        firstUsed = GetGameTimer(),
                        lastUsed = GetGameTimer()
                    })
                else
                    -- Update last used time
                    for i, v in ipairs(playerData.vehicles) do
                        if v.plate == vehicleProps.plate then
                            v.lastUsed = GetGameTimer()
                            break
                        end
                    end
                end
                
                return vehicleProps
            end
        end
    else
        playerData.lastVehicle = nil
    end
    
    return nil
end

-- Function to get vehicle properties
function GetVehicleProperties(vehicle)
    if DoesEntityExist(vehicle) then
        local colorPrimary, colorSecondary = GetVehicleColours(vehicle)
        local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
        
        return {
            model = GetEntityModel(vehicle),
            plate = GetVehicleNumberPlateText(vehicle),
            plateIndex = GetVehicleNumberPlateTextIndex(vehicle),
            health = GetEntityHealth(vehicle),
            dirtLevel = GetVehicleDirtLevel(vehicle),
            color1 = colorPrimary,
            color2 = colorSecondary,
            pearlescentColor = pearlescentColor,
            wheelColor = wheelColor,
            wheels = GetVehicleWheelType(vehicle),
            windowTint = GetVehicleWindowTint(vehicle),
            neonEnabled = {
                IsVehicleNeonLightEnabled(vehicle, 0),
                IsVehicleNeonLightEnabled(vehicle, 1),
                IsVehicleNeonLightEnabled(vehicle, 2),
                IsVehicleNeonLightEnabled(vehicle, 3)
            },
            extras = {},
            neonColor = table.pack(GetVehicleNeonLightsColour(vehicle)),
            tyreSmokeColor = table.pack(GetVehicleTyreSmokeColor(vehicle)),
            modSpoilers = GetVehicleMod(vehicle, 0),
            modFrontBumper = GetVehicleMod(vehicle, 1),
            modRearBumper = GetVehicleMod(vehicle, 2),
            modSideSkirt = GetVehicleMod(vehicle, 3),
            modExhaust = GetVehicleMod(vehicle, 4),
            modFrame = GetVehicleMod(vehicle, 5),
            modGrille = GetVehicleMod(vehicle, 6),
            modHood = GetVehicleMod(vehicle, 7),
            modFender = GetVehicleMod(vehicle, 8),
            modRightFender = GetVehicleMod(vehicle, 9),
            modRoof = GetVehicleMod(vehicle, 10),
            modEngine = GetVehicleMod(vehicle, 11),
            modBrakes = GetVehicleMod(vehicle, 12),
            modTransmission = GetVehicleMod(vehicle, 13),
            modHorns = GetVehicleMod(vehicle, 14),
            modSuspension = GetVehicleMod(vehicle, 15),
            modArmor = GetVehicleMod(vehicle, 16),
            modTurbo = IsToggleModOn(vehicle, 18),
            modSmokeEnabled = IsToggleModOn(vehicle, 20),
            modXenon = IsToggleModOn(vehicle, 22),
            modFrontWheels = GetVehicleMod(vehicle, 23),
            modBackWheels = GetVehicleMod(vehicle, 24),
            modPlateHolder = GetVehicleMod(vehicle, 25),
            modVanityPlate = GetVehicleMod(vehicle, 26),
            modTrimA = GetVehicleMod(vehicle, 27),
            modOrnaments = GetVehicleMod(vehicle, 28),
            modDashboard = GetVehicleMod(vehicle, 29),
            modDial = GetVehicleMod(vehicle, 30),
            modDoorSpeaker = GetVehicleMod(vehicle, 31),
            modSeats = GetVehicleMod(vehicle, 32),
            modSteeringWheel = GetVehicleMod(vehicle, 33),
            modShifterLeavers = GetVehicleMod(vehicle, 34),
            modAPlate = GetVehicleMod(vehicle, 35),
            modSpeakers = GetVehicleMod(vehicle, 36),
            modTrunk = GetVehicleMod(vehicle, 37),
            modHydrolic = GetVehicleMod(vehicle, 38),
            modEngineBlock = GetVehicleMod(vehicle, 39),
            modAirFilter = GetVehicleMod(vehicle, 40),
            modStruts = GetVehicleMod(vehicle, 41),
            modArchCover = GetVehicleMod(vehicle, 42),
            modAerials = GetVehicleMod(vehicle, 43),
            modTrimB = GetVehicleMod(vehicle, 44),
            modTank = GetVehicleMod(vehicle, 45),
            modWindows = GetVehicleMod(vehicle, 46),
            modLivery = GetVehicleLivery(vehicle)
        }
    else
        return nil
    end
end

-- Main tracking thread
Citizen.CreateThread(function()
    while true do
        if trackingActive then
            -- Update GPS position
            local coords = UpdateGpsPosition()
            
            -- Track current vehicle
            local vehicleProps = TrackCurrentVehicle()
            
            -- Send data to server
            TriggerServerEvent('player_tracker:updateData', {
                gps = coords,
                vehicle = vehicleProps,
                kills = playerData.kills,
                deaths = playerData.deaths,
                xp = playerData.xp,
                level = playerData.level
            })
        end
        
        Citizen.Wait(updateInterval)
    end
end)

-- Event handlers for tracking kills and deaths
RegisterNetEvent('player_tracker:incrementKill')
AddEventHandler('player_tracker:incrementKill', function()
    playerData.kills = playerData.kills + 1
    TriggerServerEvent('player_tracker:updateKills', playerData.kills)
end)

RegisterNetEvent('player_tracker:incrementDeath')
AddEventHandler('player_tracker:incrementDeath', function()
    playerData.deaths = playerData.deaths + 1
    TriggerServerEvent('player_tracker:updateDeaths', playerData.deaths)
end)

-- Event handler for XP gain
RegisterNetEvent('player_tracker:addXP')
AddEventHandler('player_tracker:addXP', function(amount)
    playerData.xp = playerData.xp + amount
    
    -- Check for level up
    local newLevel = CalculateLevel(playerData.xp)
    if newLevel > playerData.level then
        -- Level up!
        local oldLevel = playerData.level
        playerData.level = newLevel
        TriggerEvent('player_tracker:levelUp', oldLevel, newLevel)
        ShowNotification("~g~Level Up!~w~ You are now level " .. newLevel)
    end
    
    TriggerServerEvent('player_tracker:updateXP', playerData.xp, playerData.level)
end)

-- Calculate level based on XP
function CalculateLevel(xp)
    -- Simple level calculation: Each level requires 1000 * level XP
    local level = 1
    local xpRequired = 1000
    
    while xp >= xpRequired do
        xp = xp - xpRequired
        level = level + 1
        xpRequired = 1000 * level
    end
    
    return level
end

-- Notification function
function ShowNotification(message)
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandThefeedPostTicker(true, false)
end

-- Export functions
exports('GetPlayerData', function() return playerData end)
exports('GetPlayerGPS', function() return playerData.lastGps end)
exports('GetPlayerKills', function() return playerData.kills end)
exports('GetPlayerDeaths', function() return playerData.deaths end)
exports('GetPlayerXP', function() return playerData.xp end)
exports('GetPlayerLevel', function() return playerData.level end)
exports('GetPlayerVehicles', function() return playerData.vehicles end)