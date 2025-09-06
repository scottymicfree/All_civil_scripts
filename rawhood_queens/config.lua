-- CIVIL UNREST SCRIPT
-- System: Rawhood Queens - Configuration

Config = {}

-- Queen gang configuration
Config.QueenGang = {
    name = "Rawhood Queens",
    model = "g_f_y_vagos_01",
    blipColor = 7, -- Pink
    enabled = true,
    vehicle = "manana",
    dog = "a_c_poodle",
    offer = "protection",
    territory = {
        center = vector3(-116.0, -1433.0, 29.3),
        radius = 150.0,
        color = 7, -- Pink
        rivals = {"Southside Ballas", "East Families"},
        allies = {"Korean Mob"},
        spawnPoints = {
            vector3(-116.0, -1433.0, 29.3), -- Southside Alley
            vector3(215.0, -1700.0, 28.7),  -- Grove Park
            vector3(-280.0, -1340.0, 31.3)  -- Strawberry
        },
        patrolRoutes = {
            {
                vector3(-116.0, -1433.0, 29.3),
                vector3(-150.0, -1450.0, 29.3),
                vector3(-180.0, -1430.0, 30.0),
                vector3(-140.0, -1400.0, 29.5)
            }
        }
    }
}

-- Sass lines for interactions
Config.SassyLines = {
    "You better werk it!",
    "Don't mess with the Queens, honey.",
    "This our block, sugar.",
    "Mmmhmm, you lost?",
    "Gurl, your outfit is a hate crime.",
    "Step off my corner, sweetie.",
    "You ain't ready for this jelly.",
    "I'm serving looks and pain today.",
    "This ain't a fashion show you winning.",
    "Queens run this block, remember that."
}

-- Queen behavior settings
Config.QueenBehavior = {
    sassFrequency = 15, -- Seconds between sass comments
    aggressionLevel = 2, -- 1-3, how aggressive queens are
    territoryDefense = 80, -- Percentage chance to defend territory
    maxQueensPerLocation = 3, -- Maximum queens per spawn location
    weaponTypes = {"WEAPON_KNIFE", "WEAPON_SWITCHBLADE", "WEAPON_BOTTLE"},
    specialAbilities = {
        canDisarm = true, -- Queens can disarm players
        canTaunt = true, -- Queens can taunt players
        canCallBackup = true -- Queens can call for backup
    }
}

-- Queen services
Config.QueenServices = {
    protection = {
        price = 1000,
        duration = 10 -- minutes
    },
    information = {
        price = 500
    },
    contraband = {
        items = {
            {name = "lockpick", label = "Lockpick", price = 200},
            {name = "makeup", label = "Makeup Kit", price = 150},
            {name = "perfume", label = "Perfume Spray", price = 100},
            {name = "highheels", label = "High Heels", price = 300}
        }
    }
}

-- Integration settings
Config.Integration = {
    civilDisorder = true, -- Enable integration with Civil Disorder framework
    interiorZoneManager = true -- Enable integration with Interior Zone Manager
}
