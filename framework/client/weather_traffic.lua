-- Weather and Traffic Control System
-- Manages dynamic weather changes and traffic density

-- Weather control
Citizen.CreateThread(function()
    -- Initial weather setup
    local randomWeather = Config.WeatherTypes[math.random(#Config.WeatherTypes)]
    SetWeatherTypeOverTime(randomWeather, 5.0)
    SetWeatherTypePersist(randomWeather)
    
    debugLog("Initial weather set to: " .. randomWeather)
    
    -- Weather change loop
    while true do
        Citizen.Wait(Config.WeatherChangeInterval)
        
        -- Select new weather type
        local currentWeather = GetPrevWeatherType()
        local newWeather = currentWeather
        
        -- Make sure we don't get the same weather twice
        while newWeather == currentWeather do
            newWeather = Config.WeatherTypes[math.random(#Config.WeatherTypes)]
        end
        
        -- Gradually change weather
        debugLog("Changing weather from " .. currentWeather .. " to " .. newWeather)
        SetWeatherTypeOverTime(newWeather, 15.0)
        
        -- Wait for transition to complete
        Citizen.Wait(15000)
        
        -- Set the new weather type
        ClearOverrideWeather()
        ClearWeatherTypePersist()
        SetWeatherTypePersist(newWeather)
    end
end)

-- Traffic density control
Citizen.CreateThread(function()
    local densityThread = nil
    
    while true do
        -- Randomize traffic density within configured range
        local trafficDensity = math.random() * (Config.TrafficDensity.max - Config.TrafficDensity.min) + Config.TrafficDensity.min
        local pedDensity = math.random() * (Config.TrafficDensity.max - Config.TrafficDensity.min) + Config.TrafficDensity.min
        
        debugLog("Setting traffic density to: " .. trafficDensity)
        debugLog("Setting pedestrian density to: " .. pedDensity)
        
        -- Kill previous density thread if it exists
        if densityThread then
            Citizen.KillThread(densityThread)
        end
        
        -- Create new density thread
        densityThread = Citizen.CreateThread(function()
            while true do
                -- Vehicle density
                SetVehicleDensityMultiplierThisFrame(trafficDensity)
                SetRandomVehicleDensityMultiplierThisFrame(trafficDensity * 0.8)
                SetParkedVehicleDensityMultiplierThisFrame(trafficDensity * 0.9)
                
                -- Pedestrian density
                SetPedDensityMultiplierThisFrame(pedDensity)
                SetScenarioPedDensityMultiplierThisFrame(pedDensity, pedDensity)
                
                Citizen.Wait(0)
            end
        end)
        
        -- Wait before changing density again
        Citizen.Wait(Config.TrafficDensity.changeInterval)
    end
end)
