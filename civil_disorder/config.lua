-- Civil Disorder AI Framework - Configuration
Config = {}

-- Debug mode (set to false in production)
Config.Debug = false

-- Integration settings
Config.Integration = {
    useESX = false,           -- Set to true if using ESX framework
    useQBCore = false,        -- Set to true if using QBCore framework
    useCustomFramework = false, -- Set to true if using a custom framework
    frameworkExport = "custom_framework", -- Name of your custom framework export
    useCustomInventory = false, -- Set to true if using a custom inventory system
    inventoryExport = "custom_inventory", -- Name of your custom inventory export
    interiorZoneManager = true -- Enable integration with Interior Zone Manager
}

-- Gang definitions
Config.Gangs = {
    {
        name = "Ballas",
        enabled = true,
        offer = "drugs",
        territory = {
            center = vector3(105.8, -1940.2, 20.8),
            radius = 150.0,
            color = 27, -- Purple
            rivals = {"Families", "Vagos"},
            allies = {},
            spawnPoints = {
                vector3(105.8, -1940.2, 20.8),
                vector3(117.9, -1948.3, 20.7),
                vector3(85.5, -1958.6, 20.7)
            }
        }
    },
    {
        name = "Families",
        enabled = true,
        offer = "weapons",
        territory = {
            center = vector3(-173.3, -1634.5, 33.5),
            radius = 150.0,
            color = 25, -- Green
            rivals = {"Ballas", "Vagos"},
            allies = {},
            spawnPoints = {
                vector3(-173.3, -1634.5, 33.5),
                vector3(-161.2, -1638.9, 34.0),
                vector3(-185.8, -1632.4, 33.3)
            }
        }
    },
    {
        name = "Vagos",
        enabled = true,
        offer = "vehicles",
        territory = {
            center = vector3(334.2, -2039.5, 21.1),
            radius = 150.0,
            color = 46, -- Yellow
            rivals = {"Ballas", "Families"},
            allies = {},
            spawnPoints = {
                vector3(334.2, -2039.5, 21.1),
                vector3(344.7, -2028.1, 22.4),
                vector3(325.1, -2050.7, 20.9)
            }
        }
    },
    {
        name = "Lost MC",
        enabled = true,
        offer = "weapons",
        territory = {
            center = vector3(977.2, -95.8, 74.8),
            radius = 150.0,
            color = 40, -- Dark blue
            rivals = {"Vagos"},
            allies = {"Riptides"},
            spawnPoints = {
                vector3(977.2, -95.8, 74.8),
                vector3(987.5, -93.2, 74.8),
                vector3(968.3, -98.4, 74.3)
            }
        }
    },
    {
        name = "Marabunta Grande",
        enabled = true,
        offer = "drugs",
        territory = {
            center = vector3(1251.5, -1601.2, 53.3),
            radius = 150.0,
            color = 38, -- Blue
            rivals = {"Ballas", "Vagos"},
            allies = {},
            spawnPoints = {
                vector3(1251.5, -1601.2, 53.3),
                vector3(1260.8, -1616.4, 54.7),
                vector3(1240.3, -1590.1, 52.8)
            }
        }
    },
    {
        name = "Riptides",
        enabled = true,
        offer = "weed",
        territory = {
            center = vector3(-1495.42, -1387.6, 2.13),
            radius = 100.0,
            color = 15, -- Light blue
            rivals = {"Ballas"},
            allies = {"Lost MC"},
            spawnPoints = {
                vector3(-1495.42, -1387.6, 2.13),
                vector3(-1499.0, -1385.0, 2.13),
                vector3(-1502.0, -1382.0, 2.13)
            }
        }
    }
}

-- Player interaction settings
Config.PlayerInteraction = {
    neutralGangReputation = 0,  -- Starting reputation with gangs
    maxGangReputation = 100,    -- Maximum reputation possible
    minGangReputation = -100,   -- Minimum reputation possible
    reputationDecayTime = 7,    -- Days before reputation starts to decay
    reputationDecayAmount = 1,  -- Amount of reputation lost per day after decay starts
    
    -- Reputation thresholds and their effects
    reputationThresholds = {
        hostile = -50,          -- Below this value, gang members will attack on sight
        unfriendly = -10,       -- Below this value, gang members will be hostile but not attack
        neutral = 0,            -- Default starting value
        friendly = 10,          -- Above this value, gang members will be friendly
        respected = 50,         -- Above this value, gang members will offer special missions/items
        allied = 75            -- Above this value, gang members will help in combat
    }
}

-- Gang mission settings
Config.GangMissions = {
    missionCooldown = 30,       -- Minutes before a player can take another mission from the same gang
    missionTimeMultiplier = 1.0, -- Multiplier for mission time limits
    missionRewardMultiplier = 1.0, -- Multiplier for mission rewards
    
    -- Difficulty settings
    difficulty = {
        easy = {
            enemyAccuracy = 0.5,
            enemyHealth = 100,
            timeLimit = 15,     -- Minutes
            rewardMultiplier = 0.8
        },
        medium = {
            enemyAccuracy = 0.7,
            enemyHealth = 150,
            timeLimit = 10,     -- Minutes
            rewardMultiplier = 1.0
        },
        hard = {
            enemyAccuracy = 0.9,
            enemyHealth = 200,
            timeLimit = 8,      -- Minutes
            rewardMultiplier = 1.5
        }
    }
}

-- Gang shop settings
Config.GangShops = {
    markupPercentage = 20,      -- Percentage markup on items sold by gangs
    discountPerReputation = 0.5, -- Percentage discount per reputation point above friendly
    maxDiscount = 25,           -- Maximum percentage discount possible
    
-- Shop inventory refresh
    inventoryRefreshTime = 24,  -- Hours between inventory refreshes
    chanceForRareItems = 10     -- Percentage chance for rare items to appear
}

-- Gang territory settings
Config.TerritorySettings = {
    captureTime = 300,          -- Seconds needed to capture a territory
    captureRadius = 50.0,       -- Radius in which players must stay to capture
    captureReward = 5000,       -- Money reward for capturing territory
    captureReputationGain = 20, -- Reputation gained with the capturing gang
    captureReputationLoss = 30, -- Reputation lost with the defending gang
    
-- Territory control benefits
    controlBenefits = {
        incomePerHour = 500,    -- Money generated per hour of control
        itemDiscounts = 15,     -- Percentage discount on items in controlled territory
        extraInventory = true   -- Whether controlled territories have expanded inventory
    }
}

-- Safe zones where gang activity is restricted
Config.SafeZones = {
    {
        name = "Police Station",
        center = vector3(441.2, -981.97, 30.69),
        radius = 50.0
    },
    {
        name = "Hospital",
        center = vector3(298.8, -584.2, 43.3),
        radius = 50.0
    },
    {
        name = "City Hall",
        center = vector3(-544.7, -204.4, 38.2),
        radius = 50.0
    }
}

-- Gang zone settings
Config.GangZones = {}  -- This will be populated from Config.Gangs during initialization

-- Riot zones where civil unrest can occur
Config.RiotZones = {
    vector3(-75.0, -818.0, 326.2),
    vector3(252.0, -1000.0, 29.3),
    vector3(180.0, -1300.0, 29.2)
}

-- Initialize gang zones from gang territories
for _, gang in pairs(Config.Gangs) do
    if gang.enabled and gang.territory then
        table.insert(Config.GangZones, {
            name = gang.name,
            center = gang.territory.center,
            radius = gang.territory.radius
        })
    end
end

-- Conflict zones for compatibility with other scripts
Config.ConflictZones = {
    gangZones = Config.GangZones,
    safeZones = Config.SafeZones,
    riotZones = Config.RiotZones
}
