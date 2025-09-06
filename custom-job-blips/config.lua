Config = {}

-- Job blip configurations
Config.JobBlips = {
    police = {
        {
            coords = vector3(442.0, -983.0, 30.7),
            sprite = 60,
            color = 29,
            scale = 1.0,
            label = "Police Station"
        },
        {
            coords = vector3(-1095.0, -836.0, 19.0),
            sprite = 60,
            color = 29,
            scale = 1.0,
            label = "Police Station"
        },
        {
            coords = vector3(1142.54, -1522.71, 34.84), -- Eastside Ballas
            sprite = 60,
            color = 7,
            scale = 0.8,
            label = "Wanted Criminal"
        }
    },
    ems = {
        {
            coords = vector3(307.0, -1433.0, 29.9),
            sprite = 61,
            color = 1,
            scale = 1.0,
            label = "Hospital"
        },
        {
            coords = vector3(1839.0, 3672.0, 34.3),
            sprite = 61,
            color = 1,
            scale = 1.0,
            label = "Hospital"
        },
        {
            coords = vector3(-1604.66, -3012.58, 13.94), -- Red Hood
            sprite = 153,
            color = 1,
            scale = 0.8,
            label = "Injured Person"
        }
    },
    mechanic = {
        {
            coords = vector3(-347.0, -133.0, 39.0),
            sprite = 446,
            color = 5,
            scale = 1.0,
            label = "Mechanic Shop"
        },
        {
            coords = vector3(1178.0, 2640.0, 37.8),
            sprite = 446,
            color = 5,
            scale = 1.0,
            label = "Mechanic Shop"
        }
    },
    firefighter = {
        {
            coords = vector3(215.0, -1642.0, 29.7),
            sprite = 436,
            color = 1,
            scale = 1.0,
            label = "Fire Station"
        },
        {
            coords = vector3(400.0, 400.0, 30.0), -- Placeholder
            sprite = 436,
            color = 1,
            scale = 0.8,
            label = "Fire Incident"
        }
    },
    drugdealer = {
        {
            coords = vector3(333.84, -2040.52, 21.07), -- Vagos Turf
            sprite = 51,
            color = 5,
            scale = 0.8,
            label = "Dealing Spot"
        }
    }
}

-- Debug settings
Config.Debug = false
