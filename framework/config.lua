Config = {}

-- Framework version for compatibility checks
Config.Version = '1.1.0'

-- Debug mode
Config.Debug = false

-- NPC Configuration
Config.NPCs = {
    {model = "s_m_y_cop_01", role = "police", coords = vector3(440.0, -975.0, 30.69), heading = 180.0},
    {model = "s_m_m_paramedic_01", role = "ems", coords = vector3(306.5, -595.0, 43.29), heading = 160.0},
    {model = "csb_mweather", role = "clerk", coords = vector3(24.5, -1347.5, 29.5), heading = 340.0},
    {model = "g_m_y_famca_01", role = "gang", coords = vector3(100.0, -1950.0, 20.0), heading = 90.0},
}

-- Key bindings
Config.Keys = {
    interact = 38, -- E
    controller_interact = 18 -- Controller A
}

-- Weather configuration
Config.WeatherTypes = {"CLEAR", "EXTRASUNNY", "CLOUDS", "OVERCAST", "RAIN", "THUNDER", "FOGGY", "SNOW", "BLIZZARD"}
Config.WeatherChangeInterval = 900000 -- 15 minutes in milliseconds

-- Traffic and pedestrian density
Config.TrafficDensity = {
    min = 0.3,
    max = 0.8,
    changeInterval = 300000 -- 5 minutes in milliseconds
}

-- Vehicle interaction
Config.TrunkDistance = 1.5
Config.VehicleInteractionDistance = 5.0

-- Interaction cooldowns (milliseconds)
Config.Cooldowns = {
    robbery = 600000, -- 10 minutes
    emsHeal = 60000,  -- 1 minute
    trunkAccess = 2000 -- 2 seconds
}

-- Notification settings
Config.NotificationDuration = 5000 -- 5 seconds

-- Permission levels
Config.Permissions = {
    ["admin"] = 100,
    ["moderator"] = 50,
    ["police"] = 40,
    ["ems"] = 30,
    ["mechanic"] = 20,
    ["gang_leader"] = 15,
    ["gang_member"] = 10,
    ["citizen"] = 1
}

-- Weapon access configuration
Config.WeaponAccess = {
    ["police"] = {
        ["WEAPON_PISTOL"] = 100,
        ["WEAPON_STUNGUN"] = 100,
        ["WEAPON_NIGHTSTICK"] = 100,
        ["WEAPON_CARBINERIFLE"] = 50,
        ["WEAPON_SMG"] = 50
    },
    ["ems"] = {
        ["WEAPON_FLASHLIGHT"] = 100
    },
    ["gang_member"] = {
        ["WEAPON_PISTOL"] = 50,
        ["WEAPON_KNIFE"] = 100
    }
}

-- Logging configuration
Config.EnableLogging = true
Config.LogLevel = 3 -- 1=errors only, 2=warnings, 3=info, 4=debug
