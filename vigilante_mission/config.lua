Config = {}

-- Debug mode
Config.Debug = true

-- NPC Configuration
Config.Jimmy = {
    model = "ig_jimmydisanto",
    coords = vector4(-1218.72, 526.8, 96.04, 148.37),
    scenario = "WORLD_HUMAN_SMOKING",
    blip = {
        sprite = 280,
        color = 1,
        scale = 0.8,
        name = "Jimmy's Job"
    }
}

-- Vigilante Vehicle
Config.VigilanteVehicle = {
    model = "vigilante",
    coords = vector4(871.37, -1350.22, 26.31, 85.98),
    blip = {
        sprite = 225,
        color = 1,
        scale = 0.8,
        name = "Target Vehicle"
    }
}

-- Delivery Location
Config.DeliveryLocation = vector4(-363.71, -116.58, 38.7, 0.0)

-- Reward
Config.Reward = 100000

-- Time-based difficulty settings
Config.TimeDifficulty = {
    -- Early morning (5AM-8AM) - Moderate difficulty
    earlyMorning = {
        timeStart = 5,
        timeEnd = 8,
        policeResponseTime = 60, -- seconds
        policeCount = 2,
        policeVehicles = {"police", "police2"},
        message = "Early morning is a good time for the job. Police patrols are changing shifts."
    },
    
    -- Day time (9AM-5PM) - Hardest
    dayTime = {
        timeStart = 9,
        timeEnd = 17,
        policeResponseTime = 30, -- seconds
        policeCount = 4,
        policeVehicles = {"police", "police2", "police3", "police4"},
        message = "Broad daylight is risky. Police response will be heavy."
    },
    
    -- Evening (6PM-9PM) - Moderate difficulty
    evening = {
        timeStart = 18,
        timeEnd = 21,
        policeResponseTime = 45, -- seconds
        policeCount = 3,
        policeVehicles = {"police", "police2", "police3"},
        message = "Evening hours provide some cover, but police are still active."
    },
    
    -- Night (10PM-4AM) - Easiest
    night = {
        timeStart = 22,
        timeEnd = 4,
        policeResponseTime = 90, -- seconds
        policeCount = 1,
        policeVehicles = {"police"},
        message = "Night time is perfect for this job. Minimal police presence."
    }
}

-- Cooldown between missions (in minutes)
Config.Cooldown = 60
