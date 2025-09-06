-- Interior Zone Manager Configuration
Config = {}

-- Debug mode (set to false in production)
Config.Debug = false

-- Default zone settings
Config.DefaultZoneSettings = {
    showBlip = false,
    blipSprite = 374,  -- Building icon
    blipColor = 3,     -- Blue
    blipScale = 0.6,
    blipName = "Interior Zone"
}

-- Pre-defined interior zones
Config.InteriorZones = {
    -- Police stations
    {
        name = "Mission Row Police Station",
        center = vector3(441.8, -983.0, 30.7),
        width = 80.0,
        length = 80.0,
        height = 30.0,
        minZ = 25.0,
        maxZ = 55.0,
        type = "police",
        showBlip = true,
        blipName = "Mission Row Police Department"
    },
    {
        name = "Sandy Shores Sheriff",
        center = vector3(1853.0, 3686.0, 34.2),
        width = 40.0,
        length = 40.0,
        height = 15.0,
        minZ = 30.0,
        maxZ = 45.0,
        type = "police",
        showBlip = true,
        blipName = "Sandy Shores Sheriff"
    },
    
    -- Hospitals
    {
        name = "Pillbox Hospital",
        center = vector3(311.2, -592.9, 43.3),
        width = 100.0,
        length = 100.0,
        height = 40.0,
        minZ = 30.0,
        maxZ = 70.0,
        type = "hospital",
        showBlip = true,
        blipSprite = 61,  -- Hospital icon
        blipColor = 2,    -- Red
        blipName = "Pillbox Hospital"
    },
    
    -- Shops
    {
        name = "Ammunation - Downtown",
        center = vector3(22.0, -1107.2, 29.8),
        width = 20.0,
        length = 20.0,
        height = 10.0,
        minZ = 25.0,
        maxZ = 35.0,
        type = "shop",
        subType = "weapons",
        showBlip = false
    },
    
    -- Apartments
    {
        name = "Alta Street Apartments",
        center = vector3(-269.9, -957.9, 31.2),
        width = 40.0,
        length = 40.0,
        height = 80.0,
        minZ = 25.0,
        maxZ = 105.0,
        type = "residential",
        showBlip = true,
        blipSprite = 475,  -- Apartment icon
        blipColor = 0,     -- White
        blipName = "Alta Street Apartments"
    }
}

-- Zone types and their default settings
Config.ZoneTypes = {
    ["police"] = {
        blipSprite = 60,  -- Police station icon
        blipColor = 38,   -- Blue
        blipScale = 0.7,
        blipName = "Police Station",
        allowedJobs = {"police", "sheriff"}
    },
    ["hospital"] = {
        blipSprite = 61,  -- Hospital icon
        blipColor = 2,    -- Red
        blipScale = 0.7,
        blipName = "Hospital",
        allowedJobs = {"ambulance", "doctor"}
    },
    ["shop"] = {
        blipSprite = 52,  -- Shopping cart icon
        blipColor = 0,    -- White
        blipScale = 0.6,
        blipName = "Shop"
    },
    ["residential"] = {
        blipSprite = 40,  -- Home icon
        blipColor = 0,    -- White
        blipScale = 0.6,
        blipName = "Residential"
    },
    ["office"] = {
        blipSprite = 475, -- Office icon
        blipColor = 5,    -- Yellow
        blipScale = 0.6,
        blipName = "Office"
    },
    ["entertainment"] = {
        blipSprite = 93,  -- Star icon
        blipColor = 48,   -- Purple
        blipScale = 0.6,
        blipName = "Entertainment"
    }
}

-- Notification settings
Config.Notifications = {
    showEnterExit = true,
    showJobRestricted = true
}
