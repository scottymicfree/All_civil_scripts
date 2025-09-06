Config = {}

-- NPC behavior settings
Config.EnableNPCFleeing = true
Config.EnableNPCRun = true
Config.EnableNPCFreezeFog = true

-- Traffic density settings
Config.Traffic = {
    Rain = {
        parked = 0.3,
        moving = 0.5
    },
    Foggy = {
        parked = 0.7, -- Added missing value
        moving = 0.6
    },
    Clear = {
        parked = 1.0,
        moving = 1.0
    }
}

-- Weather change settings
Config.WeatherChangeTimes = {
    min = 600000,  -- 10 minutes
    max = 1200000  -- 20 minutes
}

-- Debug mode
Config.Debug = false
