Config = {}

-- Debug mode
Config.Debug = false

-- Lighting settings
Config.Lighting = {
    enabled = true,
    timecycleModifier = "VIBRANCE", -- Options: "VIBRANCE", "tunnel", "NG_filmic01", "cinema", "CAMERA_BW"
    updateInterval = 60000, -- milliseconds (1 minute)
    blackoutEnabled = false,
    artificialLightsState = false
}

-- Weather settings
Config.Weather = {
    enabled = true,
    dynamicChanges = true,
    transitionTime = 60.0, -- seconds for weather transition
    updateInterval = 1800000, -- milliseconds (30 minutes)
    weatherTypes = {
        "EXTRASUNNY", 
        "CLEAR", 
        "CLOUDS", 
        "FOGGY", 
        "OVERCAST", 
        "RAIN", 
        "THUNDER"
    },
    -- Probability weights for each weather type (higher = more likely)
    weatherWeights = {
        EXTRASUNNY = 35,
        CLEAR = 30,
        CLOUDS = 15,
        FOGGY = 5,
        OVERCAST = 10,
        RAIN = 3,
        THUNDER = 2
    },
    -- Weather restrictions (certain weather only appears during specific hours)
    weatherRestrictions = {
        THUNDER = {minHour = 18, maxHour = 6}, -- Thunder only between 6PM and 6AM
        RAIN = {minHour = 0, maxHour = 23}, -- Rain can happen anytime
        FOGGY = {minHour = 0, maxHour = 10} -- Fog only between midnight and 10AM
    }
}

-- Traffic density settings
Config.Traffic = {
    enabled = true,
    updateInterval = 30000, -- milliseconds (30 seconds)
    
    -- Morning rush hour (7AM-9AM)
    morningRush = {
        timeStart = 7,
        timeEnd = 9,
        pedDensity = 1.0,
        vehicleDensity = 1.2,
        randomVehicleDensity = 1.1,
        parkedVehicleDensity = 0.6
    },
    
    -- Evening rush hour (5PM-7PM)
    eveningRush = {
        timeStart = 17,
        timeEnd = 19,
        pedDensity = 0.9,
        vehicleDensity = 1.2,
        randomVehicleDensity = 1.0,
        parkedVehicleDensity = 0.7
    },
    
    -- Late night (10PM-4AM)
    lateNight = {
        timeStart = 22,
        timeEnd = 4,
        pedDensity = 0.3,
        vehicleDensity = 0.4,
        randomVehicleDensity = 0.2,
        parkedVehicleDensity = 0.9
    },
    
    -- Normal daytime (default)
    normal = {
        pedDensity = 0.8,
        vehicleDensity = 0.8,
        randomVehicleDensity = 0.6,
        parkedVehicleDensity = 0.6
    }
}

-- UI settings
Config.UI = {
    autoHideRadar = true, -- Hide radar when not in vehicle
    autoHideHUD = false,  -- Hide HUD elements when not needed
    showTimeDisplay = true -- Show time in the corner of the screen
}

-- Time settings
Config.Time = {
    syncWithServerTime = false, -- Sync game time with server time
    freezeTime = false, -- Freeze time at a specific hour
    frozenHour = 14, -- Hour to freeze time at (2PM)
    frozenMinute = 0, -- Minute to freeze time at
    timeScale = 2 -- How fast time passes (2 = twice as fast as normal)
}

-- Environment settings
Config.Environment = {
    enhancedNightLighting = true, -- Enhanced lighting at night
    enhancedWaterEffects = true, -- Enhanced water visuals
    enhancedShadows = true -- Enhanced shadow quality
}
