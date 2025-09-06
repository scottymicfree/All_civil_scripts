AddEventHandler("playerConnecting", function(name, setKickReason, deferrals)
    deferrals.defer()
    Wait(100)
    deferrals.update("[WEATHER EFFECTS] Syncing environment...")
    Wait(200)
    deferrals.done()

    local src = source
    TriggerClientEvent("civil_unrest_weather_effects:sync", src, currentWeather)
end)

RegisterCommand("setweather", function(source, args)
    if #args < 1 then return end
    local weather = args[1]:upper()
    currentWeather = weather
    TriggerClientEvent("civil_unrest_weather_effects:sync", -1, currentWeather)
    print("[WEATHER EFFECTS] Weather changed to:", weather)
end, true)

CreateThread(function()
    local weathers = { "CLEAR", "FOGGY", "OVERCAST", "RAIN", "THUNDER", "EXTRASUNNY" }

    while true do
        Wait(math.random(600000, 1200000)) -- 10–20 min
        currentWeather = weathers[math.random(#weathers)]
        print("[WEATHER EFFECTS] Rotating weather to:", currentWeather)
        TriggerClientEvent("civil_unrest_weather_effects:sync", -1, currentWeather)
    end
end)
