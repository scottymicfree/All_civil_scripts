-- Initialize variables
local lastWeather = nil
local currentWeather = "CLEAR"
local weatherChangeCooldown = 0
-- Register event handler for weather sync
RegisterNetEvent("civil_unrest_weather_effects:sync")
AddEventHandler("civil_unrest_weather_effects:sync", function(weather)
    if weather and type(weather) == "string" then
        print("[WEATHER EFFECTS] Received weather sync: " .. weather)
        SetWeatherTypeOverTime(weather, 15.0)
        currentWeather = weather
        lastWeather = GetHashKey(weather)
        -- Trigger behavior for the new weather
        handleWeatherChange(GetHashKey(weather))
    end
end)

-- Main weather monitoring thread
CreateThread(function()
    -- Initialize lastWeather
    lastWeather = GetPrevWeatherTypeHashName()
    while true do
        Wait(5000)
        local weatherType = GetPrevWeatherTypeHashName()
        if weatherType ~= lastWeather and weatherChangeCooldown < GetGameTimer() then
            lastWeather = weatherType
            handleWeatherChange(weatherType)
            weatherChangeCooldown = GetGameTimer() + 10000 -- 10 second cooldown
        end
    end
end)

-- Handle weather changes and trigger appropriate behaviors
function handleWeatherChange(weatherType)
    local name = GetWeatherNameFromHash(weatherType)
    print("[WEATHER EFFECTS] Weather changed to: " .. name)
    if name == "RAIN" or name == "THUNDER" then
        TriggerRainBehavior()
    elseif name == "CLEAR" or name == "EXTRASUNNY" then
        TriggerClearWeatherBehavior()
    elseif name == "FOGGY" then
        TriggerFoggyBehavior()
    end
end

-- Convert weather hash to name
function GetWeatherNameFromHash(hash)
    local weatherNames = {
        [GetHashKey("CLEAR")] = "CLEAR",
        [GetHashKey("EXTRASUNNY")] = "EXTRASUNNY",
        [GetHashKey("CLOUDS")] = "CLOUDS",
        [GetHashKey("FOGGY")] = "FOGGY",
        [GetHashKey("RAIN")] = "RAIN",
        [GetHashKey("THUNDER")] = "THUNDER",
        [GetHashKey("SMOG")] = "SMOG",
        [GetHashKey("OVERCAST")] = "OVERCAST"
    }
    return weatherNames[hash] or "UNKNOWN"
end

-- Behavior for rainy weather
function TriggerRainBehavior()
    print("[WEATHER EFFECTS] Rain detected: NPCs running, umbrellas, traffic slows.")
    -- Reduce traffic density
    SetParkedVehicleDensityMultiplierThisFrame(Config.Traffic.Rain.parked)
    SetVehicleDensityMultiplierThisFrame(Config.Traffic.Rain.moving)
    -- Randomly trigger NPCs sprinting with umbrella
    if Config.EnableNPCFleeing or Config.EnableNPCRun then
        for ped in EnumeratePeds() do
            if not IsPedAPlayer(ped) and not IsPedInAnyVehicle(ped, false) and not IsPedDeadOrDying(ped, true) then
                if Config.EnableNPCFleeing and math.random() < 0.1 then
                    TaskReactAndFleePed(ped, PlayerPedId())
                elseif Config.EnableNPCRun and math.random() < 0.2 then
                    TaskGoStraightToCoord(ped, GetOffsetFromEntityInWorldCoords (ped, 0.0, 15.0, 0.0), 2.0, -1, 0.0, 0.0)
                end
            end
        end
    end
end

-- Behavior for clear weather
function TriggerClearWeatherBehavior()
    print("[WEATHER EFFECTS] Clear skies: NPCs relax, traffic normal.")
    -- Restore normal traffic density
    SetParkedVehicleDensityMultiplierThisFrame(Config.Traffic.Clear.parked)
    SetVehicleDensityMultiplierThisFrame(Config.Traffic.Clear.moving)
end

-- Behavior for foggy weather
function TriggerFoggyBehavior()
    print("[WEATHER EFFECTS] Foggy conditions: NPCs slow down, act cautious.")
    -- Reduce traffic density
    SetVehicleDensityMultiplierThisFrame(Config.Traffic.Foggy.moving)
    -- Make NPCs occasionally stop and look around
    if Config.EnableNPCFreezeFog then
        for ped in EnumeratePeds() do
            if not IsPedAPlayer(ped) and not IsPedInAnyVehicle(ped, false) and not IsPedDeadOrDying(ped, true) then
                if math.random() < 0.05 then
                    TaskStandStill(ped, 5000)
                end
            end
        end
    end
end

-- Helper function to enumerate all peds
function EnumeratePeds()
    return coroutine.wrap(function()
        local handle, ped = FindFirstPed()
        if not handle or handle == -1 then return end
        local success
        repeat
            coroutine.yield(ped)
            success, ped = FindNextPed(handle)
        until not success
        EndFindPed(handle)
    end)
end

-- Thread to continuously apply traffic density changes
CreateThread(function()
    while true do
        Wait(0)
        -- Get current weather
        local weatherType = GetPrevWeatherTypeHashName()
        local name = GetWeatherNameFromHash(weatherType)
        -- Apply traffic density based on weather
        if name == "RAIN" or name == "THUNDER" then
            SetParkedVehicleDensityMultiplierThisFrame(Config.Traffic.Rain.parked)
            SetVehicleDensityMultiplierThisFrame(Config.Traffic.Rain.moving)
        elseif name == "FOGGY" then
            SetVehicleDensityMultiplierThisFrame(Config.Traffic.Foggy.moving)
        else
            SetParkedVehicleDensityMultiplierThisFrame(Config.Traffic.Clear.parked)
            SetVehicleDensityMultiplierThisFrame(Config.Traffic.Clear.moving)
        end
    end
end)
