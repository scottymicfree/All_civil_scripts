
print("[CivilUnrest-Core] Server initialized.")

local currentWeather = "CLEAR"

-- Welcome player and forward weather
RegisterNetEvent("civilunrest-core:playerReady", function()
    local src = source
    print(("[CivilUnrest-Core] Player %d connected and is ready."):format(src))
    TriggerClientEvent("civilunrest-core:welcome", src, {
        message = "Welcome to Civil Unrest RP, powered by Randy Webb!"
    })
    -- Sync current weather
    TriggerClientEvent("civil_unrest_weather_effects:sync", src, currentWeather)
end)

-- Log kill event
RegisterNetEvent("civilunrest-core:onPlayerKilled", function(killerID, data)
    local victim = source
    print(("[CivilUnrest-Core] Player %d was killed by %s (weapon: %s)"):format(victim, killerID or "unknown", data.weapon or "unknown"))
end)

-- Log weather changes from command
RegisterCommand("setweather", function(source, args)
    if #args < 1 then return end
    currentWeather = args[1]:upper()
    TriggerClientEvent("civil_unrest_weather_effects:sync", -1, currentWeather)
    print("[Core] Weather changed to:", currentWeather)
end, true)

-- Player disconnect/connect logging
AddEventHandler('playerDropped', function(reason)
    print(('[CivilUnrest-Core] Player %s left the server: %s'):format(source, reason))
end)

AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    print(('[CivilUnrest-Core] Player %s is connecting...'):format(name))
end)
