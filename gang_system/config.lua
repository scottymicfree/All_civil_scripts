-- config.lua
-- Configuration for Gang System

Config = {}

-- Gang definitions
Config.Gangs = {
    ballas = {
        name = "Ballas",
        color = 7, -- Purple
        spawnPoint = vector3(105.4, -1940.5, 20.8),
        territory = {
            center = vector3(105.4, -1940.5, 20.8),
            radius = 100.0,
            blipColor = 7
        },
        vehicles = {"manchez", "tornado", "buccaneer"},
        joinRequirements = {
            minLevel = 5,
            reputation = 10
        }
    },
    vagos = {
        name = "Los Santos Vagos",
        color = 5, -- Yellow
        spawnPoint = vector3(334.2, -2052.1, 20.8),
        territory = {
            center = vector3(334.2, -2052.1, 20.8),
            radius = 100.0,
            blipColor = 5
        },
        vehicles = {"manchez", "tornado", "buccaneer"},
        joinRequirements = {
            minLevel = 5,
            reputation = 10
        }
    },
    families = {
        name = "The Families",
        color = 2, -- Green
        spawnPoint = vector3(-173.3, -1634.5, 33.5),
        territory = {
            center = vector3(-173.3, -1634.5, 33.5),
            radius = 100.0,
            blipColor = 2
        },
        vehicles = {"manchez", "tornado", "buccaneer"},
        joinRequirements = {
            minLevel = 5,
            reputation = 10
        }
    },
    biker = {
        name = "Lost MC",
        color = 0, -- Black
        spawnPoint = vector3(977.0, -104.1, 74.8),
        territory = {
            center = vector3(977.0, -104.1, 74.8),
            radius = 100.0,
            blipColor = 0
        },
        vehicles = {"daemon", "sovereign", "hexer"},
        joinRequirements = {
            minLevel = 5,
            reputation = 10
        }
    }
}

-- Gang colors for vehicles and blips
Config.GangColors = {
    ballas = 145, -- Purple
    vagos = 88,   -- Yellow
    families = 53, -- Green
    biker = 0     -- Black
}

-- Gang mission rewards
Config.MissionRewards = {
    low = {
        money = 500,
        reputation = 5,
        items = {
            ["weapon_parts"] = 1
        }
    },
    mid = {
        money = 1000,
        reputation = 10,
        items = {
            ["weapon_parts"] = 2,
            ["drugs"] = 1
        }
    },
    high = {
        money = 2000,
        reputation = 20,
        items = {
            ["weapon_parts"] = 3,
            ["drugs"] = 2,
            ["lockpick"] = 1
        }
    }
}

-- Gang backup settings
Config.BackupSettings = {
    cooldown = 600000, -- 10 minutes
    maxNPCs = 3,
    duration = 900000  -- 15 minutes
}

-- Gang vehicle settings
Config.VehicleSettings = {
    cooldown = 1800000, -- 30 minutes
    despawnTime = 1800000 -- 30 minutes
}

-- Gang territory settings
Config.TerritorySettings = {
    captureTime = 300, -- 5 minutes
    captureRadius = 50.0,
    minPlayersToCapture = 2,
    captureRewards = {
        money = 5000,
        reputation = 50
    },
    controlBenefits = {
        incomeInterval = 3600000, -- 1 hour
        income = 1000
    }
}

-- Debug mode
Config.DebugMode = false

return Config
