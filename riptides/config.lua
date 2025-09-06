-- riptides/config.lua
Config = {}

-- Debug mode
Config.Debug = false

-- Surfer gang configuration
Config.SurferGang = {
    name = "The Riptides",
    -- Replace single model with array of models
    models = {
        "a_m_y_surfer_01",    -- Surfer01AMY (-356333586)
        "a_m_m_beach_01",     -- Beach01AMM (808859815)
        "a_m_y_beach_01",     -- Beach01AMY (-771835772)
        "a_f_m_beach_01",     -- Beach01AFM (-566941131)
        "a_f_y_topless_01",   -- Topless01AFY (-1661836925)
        "a_f_m_fatcult_01",   -- FatCult01AFM (-1244692252)
        "cs_tylerdix",        -- TylerDixon (1382414087)
        "cs_tracydisanto"     -- TracyDisanto (-566941131)
    },
    -- Define leader models (used for special behaviors)
    leaders = {
        "cs_tylerdix",
        "cs_tracydisanto"
    },
    blipColor = 38, -- Light blue
    enabled = true,
    
    -- Beach vehicles configuration
    vehicles = {
        {model = "blazer", hash = 2166734073, type = "atv"},     -- Blazer ATV
        {model = "blazer2", hash = 4246935337, type = "atv"},    -- Blazer Lifeguard
        {model = "bifta", hash = 3945366167, type = "buggy"},    -- Bifta (dune buggy)
        {model = "outlaw", hash = 408825843, type = "buggy"},    -- Outlaw (off-road buggy)
        {model = "surfer", hash = 699456151, type = "van"},      -- Surfer van
        {model = "surfer3", hash = 3259477733, type = "van"}     -- Surfer Custom van
    },
    
    -- Vehicle spawn weights (higher = more likely to spawn)
    vehicleSpawnWeights = {
        atv = 35,    -- ATVs are common
        buggy = 25,  -- Buggies are somewhat common
        van = 40     -- Vans are most common (for carrying surfboards)
    },
    
    -- Vehicle customization options
    vehicleCustomization = {
        colors = {38, 74, 31, 0, 111}, -- Light blue, beach blue, lime green, white, orange
        plateTexts = {"RIPTIDE", "SURF", "BEACH", "WAVES", "SANDY"},
        extras = true -- Enable vehicle extras where available
    },
    
    dog = "a_c_retriever", -- Beach dog
    offer = "weed",
    territory = {
        center = vector3(-1495.42, -1387.6, 2.13),
        radius = 100.0,
        color = 38, -- Light blue
        rivals = {"Southside Ballas"},
        allies = {"Lost MC"},
        spawnPoints = {
            vector3(-1495.42, -1387.6, 2.13),
            vector3(-1499.0, -1385.0, 2.13),
            vector3(-1502.0, -1382.0, 2.13),
            vector3(-1505.0, -1380.0, 2.13),
            vector3(-1490.0, -1390.0, 2.13)
        },
        patrolRoutes = {
            {
                vector3(-1495.42, -1387.6, 2.13),
                vector3(-1520.0, -1400.0, 2.13),
                vector3(-1540.0, -1450.0, 1.5),
                vector3(-1480.0, -1430.0, 1.5)
            }
        }
    }
}

-- Chill spots where surfers hang out
Config.ChillSpots = {
    vector4(-1495.42, -1387.6, 2.13, 180.0),
    vector4(-1499.0, -1385.0, 2.13, 90.0),
    vector4(-1502.0, -1382.0, 2.13, 270.0),
    vector4(-1505.0, -1380.0, 2.13, 180.0),
    vector4(-1490.0, -1390.0, 2.13, 90.0)
}

-- Surfboard props
Config.Surfboards = {
    "prop_surf_board_01",
    "prop_surf_board_02",
    "prop_surf_board_03",
    "prop_surf_board_ldn_01",
    "prop_surf_board_ldn_02"
}

-- Beach towel props
Config.BeachTowels = {
    "prop_beach_towel_01",
    "prop_beach_towel_02",
    "prop_beach_towel_03",
    "prop_beach_towel_04"
}

-- Beach props (additional decorative items)
Config.BeachProps = {
    "prop_beach_fire",
    "prop_beach_lg_float",
    "prop_beach_parasol_01",
    "prop_beach_parasol_03",
    "prop_beach_parasol_05",
    "prop_beach_volball01",
    "prop_beach_volball02",
    "prop_beachbag_01",
    "prop_beachbag_03",
    "prop_beachbag_04",
    "prop_beachball_02",
    "prop_beachflag_le"
}

-- Spawn timing
Config.SpawnTiming = {
    activeHoursStart = 9, -- 9 AM
    activeHoursEnd = 18, -- 6 PM
    minCooldown = 210, -- seconds
    maxCooldown = 340, -- seconds
    spawnDuration = 200, -- seconds
    vehicleCount = {min = 2, max = 4} -- How many vehicles to spawn
}

-- Surfer behavior
Config.SurferBehavior = {
    aggressionLevel = 2, -- 1-3, how aggressive surfers are
    territoryDefense = 70, -- Percentage chance to defend territory
    maxSurfersPerLocation = 3, -- Maximum surfers per spawn location
    
    -- Weapon configurations by ped type
    weaponTypes = {"WEAPON_BOTTLE", "WEAPON_BAT", "WEAPON_KNIFE"}, -- Default weapons
    
    meleeWeapons = {
        "WEAPON_BOTTLE",
        "WEAPON_BAT",
        "WEAPON_KNIFE",
        "WEAPON_POOLCUE",
        "WEAPON_KNUCKLE"
    },
    
    leaderWeapons = {
        "WEAPON_VINTAGEPISTOL",
        "WEAPON_FLAREGUN",
        "WEAPON_COMBATPISTOL",
        "WEAPON_MACHETE"
    },
    
    femaleWeapons = {
        "WEAPON_KNIFE",
        "WEAPON_SWITCHBLADE",
        "WEAPON_BOTTLE",
        "WEAPON_SNSPISTOL"
    },
    
    scenarios = {
        "WORLD_HUMAN_SUNBATHE_BACK",
        "WORLD_HUMAN_SUNBATHE",
        "WORLD_HUMAN_STAND_IMPATIENT",
        "WORLD_HUMAN_HANG_OUT_STREET"
    },
    
    -- Additional scenarios for variety
    extraScenarios = {
        "WORLD_HUMAN_DRINKING",
        "WORLD_HUMAN_PARTYING",
        "WORLD_HUMAN_SMOKING_POT",
        "WORLD_HUMAN_MUSCLE_FLEX",
        "WORLD_HUMAN_YOGA"
    },
    
    -- Vehicle behaviors
    vehicleBehaviors = {
        patrolChance = 30, -- % chance a vehicle will patrol
        driverAggressionLevel = 2, -- 1-3, how aggressively they drive
        maxSpeed = 35.0 -- Maximum speed for patrol vehicles (mph)
    },
    
    -- Male dialogue lines
    dialogLines = {
        "Dude, this is our beach!",
        "Wipe out, kook!",
        "You're in Riptide territory now, brah!",
        "Locals only, tourist!",
        "Don't harsh our mellow, man!",
        "You're about to catch the wrong kind of wave!",
        "This ain't your beach to hang ten on!",
        "Surf's up... and you're going down!",
        "You picked the wrong beach to chill at, bro!",
        "The Riptides run this sand!"
    },
    
    -- Female dialogue lines
    femaleDialogLines = {
        "This is our beach, honey!",
        "You're not welcome here, sweetheart!",
        "The Riptides don't like tourists!",
        "You better turn around and walk away!",
        "You picked the wrong beach to visit today!",
        "This sand belongs to The Riptides!",
        "You're about to get a nasty sunburn, honey!",
        "We don't take kindly to strangers here!",
        "Back off our turf or you'll regret it!",
        "The only thing you'll be catching here is trouble!"
    },
    
    -- Leader dialogue lines (for Tyler Dixon and Tracy DiSanto)
    leaderDialogLines = {
        "I'm the king/queen of this beach, and you're trespassing!",
        "The Riptides follow my orders, and I say you need to leave!",
        "Nobody steps on my beach without paying respect!",
        "You've got five seconds to turn around before my crew tears you apart!",
        "I've built this gang from nothing, and nobody's taking it from me!",
        "You think you can just walk into Riptide territory? Big mistake!",
        "My surfers will make sure you never come back here again!",
        "This is the last face you'll see before you wipe out... permanently!"
    }
}

-- Surfer services
Config.SurferServices = {
    weed = {
        price = 150,
        quality = "beach grown",
        items = {
            "weed_purple-haze",
            "weed_og-kush",
            "weed_white-widow",
            "weed_skunk",
            "weed_amnesia"
        }
    },
    surfLessons = {
        price = 300,
        duration = 10, -- minutes
        benefits = {
            swimSpeedBoost = 1.2, -- 20% faster swimming
            staminaBoost = 1.3    -- 30% more stamina
        }
    },
    beachParty = {
        price = 500,
        duration = 15, -- minutes
        partyProps = {
            "prop_beach_fire",
            "prop_beach_parasol_03",
            "prop_beach_volball01",
            "prop_beachball_02"
        }
    },
    -- New service: Surfboard rental
    surfboardRental = {
        price = 200,
        duration = 20, -- minutes
        models = {
            "prop_surf_board_01",
            "prop_surf_board_02",
            "prop_surf_board_03"
        }
    },
    -- New service: Vehicle rental
    vehicleRental = {
        price = 750,
        duration = 30, -- minutes
        available = {"blazer", "bifta"} -- Only allow renting certain vehicles
    }
}

-- Integration settings
Config.Integration = {
    civilDisorder = true, -- Enable integration with Civil Disorder framework
    interiorZoneManager = true, -- Enable integration with Interior Zone Manager
    qb_inventory = false, -- Enable integration with QB-Inventory
    ox_inventory = false  -- Enable integration with OX Inventory
}

-- Conflict zones (placeholder - will be populated from other resources)
Config.ConflictZones = {
    gangZones = {},
    safeZones = {},
    riotZones = {
        vector3(-75.0, -818.0, 326.2),
        vector3(252.0, -1000.0, 29.3),
        vector3(180.0, -1300.0, 29.2)
    }
}

-- Unrest system
Config.UnrestSystem = {
    maxUnrest = 100,
    unrestIncreasePerSpawn = 5,
    unrestDecreasePerDespawn = 10,
    unrestEffects = {
        [25] = "Minor beach disturbances",
        [50] = "Increased surfer gang activity",
        [75] = "Aggressive territorial behavior",
        [100] = "Full beach takeover"
    }
}

-- Outfit variations for different ped types
Config.PedOutfits = {
    ["a_m_y_surfer_01"] = {
        components = {
            [3] = {min = 0, max = 15}, -- Torso
            [4] = {min = 0, max = 15}, -- Legs
            [6] = {min = 0, max = 5},  -- Feet
            [11] = {min = 0, max = 5}  -- Textures
        }
    },
    ["a_f_y_topless_01"] = {
        components = {
            [3] = {min = 0, max = 3}, -- Torso
            [4] = {min = 0, max = 4}, -- Legs
            [6] = {min = 0, max = 3}  -- Feet
        }
    },
    -- Default outfit variations for other peds
    ["default"] = {
        components = {
            [0] = {min = 0, max = 1},  -- Face
            [3] = {min = 0, max = 15}, -- Torso
            [4] = {min = 0, max = 15}, -- Legs
            [6] = {min = 0, max = 5},  -- Feet
            [11] = {min = 0, max = 5}  -- Textures
        }
    }
}

-- Weather preferences (surfers spawn more during good weather)
Config.WeatherPreferences = {
    preferred = {"CLEAR", "EXTRASUNNY", "CLOUDS"},
    disliked = {"RAIN", "THUNDER", "FOGGY"},
    spawnChanceMultiplier = {
        preferred = 1.5,  -- 50% more likely to spawn in good weather
        neutral = 1.0,    -- Normal spawn chance
        disliked = 0.5    -- 50% less likely to spawn in bad weather
    }
}
