Config = {}

-- NPC Service Locations
Config.ServiceLocations = {
    -- Mechanic Services
    {
        type = "mechanic",
        name = "LS Customs",
        coords = vector3(-337.0, -136.0, 39.0),
        heading = 70.0,
        model = "s_m_y_xmech_02",
        animation = "WORLD_HUMAN_CLIPBOARD",
        blip = {
            sprite = 446,
            color = 5,
            scale = 0.8,
            name = "Mechanic Service"
        }
    },
    -- Taxi Services
    {
        type = "taxi",
        name = "Downtown Cab Co",
        coords = vector3(895.0, -179.0, 74.7),
        heading = 240.0,
        model = "a_m_y_stlat_01",
        animation = "WORLD_HUMAN_STAND_MOBILE",
        blip = {
            sprite = 198,
            color = 5,
            scale = 0.8,
            name = "Taxi Service"
        }
    },
    -- Medical Services
    {
        type = "medic",
        name = "Street Doctor",
        coords = vector3(307.0, -595.0, 43.3),
        heading = 70.0,
        model = "s_m_m_doctor_01",
        animation = "WORLD_HUMAN_CLIPBOARD",
        blip = {
            sprite = 61,
            color = 1,
            scale = 0.8,
            name = "Medical Service"
        }
    }
}

-- Service Prices
Config.ServicePrices = {
    mechanic = {
        repair = 350,
        wash = 50,
        tow = 200
    },
    taxi = {
        short = 50,
        medium = 100,
        long = 200
    },
    medic = {
        heal = 150,
        revive = 500
    }
}

-- Service Cooldowns (in milliseconds)
Config.Cooldowns = {
    mechanic = 60000,  -- 1 minute
    taxi = 30000,      -- 30 seconds
    medic = 120000     -- 2 minutes
}
