-- Local variables
local currentWeather = Config.Weather.weatherTypes[1]
local nextWeather = currentWeather
local weatherTimer = 0

-- Debug function
local function DebugPrint(message)
    if Config.Debug then
        print("[Realism] " .. message)
    end
end

-- Function to get weighted random weather
local function GetRandomWeather()
    -- Get current hour
    local hour = GetClockHours()
    
    -- Build table of valid weather types for current hour
    local validWeather = {}
    local totalWeight = 0
    
    for weather, weight in pairs(Config.Weather.weatherWeights) do
        local restriction = Config.Weather.weatherRestrictions[weather]
        local isValid = true
        
        -- Check if weather has time restrictions
        if restriction then
            if restriction.minHour <= restriction.maxHour then
                -- Simple range check
                isValid = hour >= restriction.minHour and hour <= restriction.maxHour
            else
                -- Wrapped range (e.g., 22-4)
                isValid = hour >= restriction.minHour or hour <= restriction.maxHour
            end
        end
        
        -- Add to valid weather if passes restrictions
        if isValid then
            validWeather[weather] = weight
            totalWeight = totalWeight + weight
        end
    end
    
    -- Select random weather based on weights
    local randomValue = math.random(1, totalWeight)
    local cumulativeWeight = 0
    
    for weather, weight in pairs(validWeather) do
        cumulativeWeight = cumulativeWeight + weight
        if randomValue <= cumulativeWeight then
            return weather
        end
    end
    
    -- Fallback to clear weather
    return "CLEAR"
end

-- Function to update weather
local function UpdateWeather()
    -- Check if dynamic weather is enabled
    if not Config.Weather.dynamicChanges then
        return
    end
    
    -- Get new random weather
    nextWeather = GetRandomWeather()
    
    -- Skip if same as current
    if nextWeather == currentWeather then
        return
    end
    
    -- Transition to new weather
    DebugPrint("Weather changing from " .. currentWeather .. " to " .. nextWeather)
    
    -- Start weather transition
    SetWeatherTypeOverTime(nextWeather, Config.Weather.transitionTime)
    
    -- Wait for transition to complete
    Citizen.SetTimeout(Config.Weather.transitionTime * 1000, function()
        -- Update current weather
        currentWeather = nextWeather
        
        -- Apply new weather
        ClearOverrideWeather()
        SetWeatherTypePersist(currentWeather)
        SetWeatherTypeNow(currentWeather)
        
        DebugPrint("Weather changed to " .. currentWeather)
    end)
end

-- Function to force weather
function ForceWeather(weather)
    if not weather then return false end
    
    -- Check if valid weather type
    local isValid = false
    for _, validWeather in ipairs(Config.Weather.weatherTypes) do
        if validWeather == weather then
            isValid = true
            break
        end
    end
    
    if not isValid then
        DebugPrint("Invalid weather type: " .. weather)
        return false
    end
    
    -- Update weather
    currentWeather = weather
    nextWeather = weather
    
    -- Apply weather immediately
    ClearOverrideWeather()
    SetWeatherTypePersist(weather)
    SetWeatherTypeNow(weather)
    
    DebugPrint("Weather forced to " .. weather)
    return true
end

-- Main thread for weather
Citizen.CreateThread(function()
    -- Wait for game to load
    Citizen.Wait(3000)
    
    -- Initial weather
    ForceWeather(currentWeather)
    DebugPrint("Weather system initialized with " .. currentWeather)
    
    -- Main loop
    while Config.Weather.enabled do
        -- Update weather
        UpdateWeather()
        
        -- Wait for next update
        Citizen.Wait(Config.Weather.updateInterval)
    end
end)

-- Register command
RegisterCommand("weather", function(source, args, rawCommand)
    if not args[1] then
        TriggerEvent("chat:addMessage", {
            color = {255, 255, 0},
            multiline = false,
            args = {"System", "Current weather: " .. currentWeather}
        })
        return
    end
    
    local result = ForceWeather(args[1])
    
    -- Notify player
    if result then
        TriggerEvent("chat:addMessage", {
            color = {255, 255, 0},
            multiline = false,
            args = {"System", "Weather changed to: " .. args[1]}
        })
    else
        TriggerEvent("chat:addMessage", {
            color = {255, 0, 0},
            multiline = false,
            args = {"System", "Invalid weather type. Valid types: " .. table.concat(Config.Weather.weatherTypes, ", ")}
        })
    end
end, false)
