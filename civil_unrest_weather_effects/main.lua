-- Initialize variables
local currentWeather = "CLEAR"
local weatherChangeTimer = 0
local weatherChangeCooldown = 600000 -- 10 minutes

-- Event handler for player connecting
AddEventHandler("playerConnecting", function(name, setKickReason, deferrals)
    deferrals.defer()
    Wait(100)
    deferrals.update("[WEATHER EFFECTS] Syncing environment...")
    Wait(200)
    deferrals.done()

    local src = source
    TriggerClientEvent("civil_unrest_weather_effects:sync", src, currentWeather)
end)

-- Command to manually set weather
RegisterCommand("setweather", function(source, args)
    -- Check if player has permission
    if source > 0 and not IsPlayerAceAllowed(source, "command.setweather") then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            multiline = false,
            args = {"[WEATHER]", "You don't have permission to use this command."}
        })
        return
    end
    
    if #args < 1 then 
        if source > 0 then
            TriggerClientEvent('chat:addMessage', source, {
                color = {255, 255, 0},
                multiline = false,
                args = {"[WEATHER]", "Usage: /setweather [CLEAR/FOGGY/OVERCAST/RAIN/THUNDER/EXTRASUNNY]"}
            })
        else
            print("[WEATHER EFFECTS] Usage: setweather [CLEAR/FOGGY/OVERCAST/RAIN/THUNDER/EXTRASUNNY]")
        end
        return 
    end
    
    local weather = args[1]:upper()
    
    -- Validate weather type
    local validWeathers = { "CLEAR", "FOGGY", "OVERCAST", "RAIN", "THUNDER", "EXTRASUNNY", "CLOUDS", "SMOG" }
    local isValid = false
    
    for _, validWeather in ipairs(validWeathers) do
        if weather == validWeather then
            isValid = true
            break
        end
    end
    
    if not isValid then
        if source > 0 then
            TriggerClientEvent('chat:addMessage', source, {
                color = {255, 0, 0},
                multiline = false,
                args = {"[WEATHER]", "Invalid weather type. Valid types: CLEAR, FOGGY, OVERCAST, RAIN, THUNDER, EXTRASUNNY, CLOUDS, SMOG"}
            })
        else
            print("[WEATHER EFFECTS] Invalid weather type. Valid types: CLEAR, FOGGY, OVERCAST, RAIN, THUNDER, EXTRASUNNY, CLOUDS, SMOG")
        end
        return
    end
    
    -- Set the weather
    currentWeather = weather
    weatherChangeTimer = GetGameTimer() + weatherChangeCooldown
    TriggerClientEvent("civil_unrest_weather_effects:sync", -1, currentWeather)
    
    -- Notify
    if source > 0 then
        TriggerClientEvent('chat:addMessage', source, {
            color = {0, 255, 0},
            multiline = false,
            args = {"[WEATHER]", "Weather changed to: " .. weather}
        })
    end
    print("[WEATHER EFFECTS] Weather manually changed to:", weather)
end, true)

-- Thread for automatic weather changes
CreateThread(function()
    local weathers = { "CLEAR", "FOGGY", "OVERCAST", "RAIN", "THUNDER", "EXTRASUNNY", "CLOUDS" }
    
    -- Initial weather
    currentWeather = weathers[math.random(#weathers)]
    print("[WEATHER EFFECTS] Initial weather set to:", currentWeather)
    
    while true do
        Wait(60000) -- Check every minute
        
        -- Only change weather if timer has expired
        if GetGameTimer() > weatherChangeTimer then
            -- Pick a new weather that's different from current
            local newWeather = currentWeather
            while newWeather == currentWeather do
                newWeather = weathers[math.random(#weathers)]
            end
            
            currentWeather = newWeather
            print("[WEATHER EFFECTS] Rotating weather to:", currentWeather)
            TriggerClientEvent("civil_unrest_weather_effects:sync", -1, currentWeather)
            
            -- Set next change time (10-20 minutes)
            weatherChangeTimer = GetGameTimer() + math.random(600000, 1200000)
        end
    end
end)

-- Command to check current weather
RegisterCommand("checkweather", function(source, args)
    if source > 0 then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 255, 0},
            multiline = false,
            args = {"[WEATHER]", "Current server weather: " .. currentWeather}
        })
    else
        print("[WEATHER EFFECTS] Current server weather:", currentWeather)
    end
end, false)
