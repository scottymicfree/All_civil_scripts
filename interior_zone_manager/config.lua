-- Interior Zone Manager Configuration
Config = {}

-- Debug mode (set to false in production)
Config.Debug = false

-- Notification settings
Config.Notifications = {
    showEnterExit = true,     -- Show notifications when entering/exiting zones
    showJobRestricted = true, -- Show notifications when entering job-restricted zones
}

-- Default zone settings
Config.DefaultZoneSettings = {
    blipSprite = 1,    -- Default blip sprite
    blipColor = 0,     -- Default blip color (white)
    blipScale = 0.8,   -- Default blip scale
    blipName = "Zone", -- Default blip name
}

-- Zone type definitions
Config.ZoneTypes = {
    -- Police zones
    police = {
        blipSprite = 60,   -- Police station blip
        blipColor = 38,    -- Blue
        blipScale = 0.8,
        blipName = "Police Station",
        allowedJobs = {"police", "sheriff"},
    },
    
    -- Hospital zones
    hospital = {
        blipSprite = 61,   -- Hospital blip
        blipColor = 1,     -- Red
        blipScale = 0.8,
        blipName = "Hospital",
        allowedJobs = {"ambulance", "doctor"},
    },
    
    -- Shop zones
    shop = {
        blipSprite = 52,   -- Shop blip
        blipColor = 2,     -- Green
        blipScale = 0.7,
        blipName = "Shop",
    },
    
    -- Residential zones
    residential = {
        blipSprite = 40,   -- Home blip
        blipColor = 0,     -- White
        blipScale = 0.6,
        blipName = "Residential",
    },
    
    -- Office zones
    office = {
        blipSprite = 475,  -- Office blip
        blipColor = 5,     -- Yellow
        blipScale = 0.7,
        blipName = "Office",
    },
    
    -- Entertainment zones
    entertainment = {
        blipSprite = 135,  -- Movie theater blip
        blipColor = 7,     -- Pink
        blipScale = 0.7,
        blipName = "Entertainment",
    },
    
    -- Gang territory zones
    gang_territory = {
        blipSprite = 310,  -- Gang blip
        blipColor = 1,     -- Red
        blipScale = 0.6,
        blipName = "Gang Territory",
    },
    
    -- Generic zones
    generic = {
        blipSprite = 1,    -- Generic blip
        blipColor = 0,     -- White
        blipScale = 0.6,
        blipName = "Location",
    },
}

-- Pre-defined interior zones
Config.InteriorZones = {
    -- Police stations
    {
        name = "Mission Row Police Station",
        center = vector3(441.2, -981.97, 30.69),
        width = 80.0,
        length = 80.0,
        height = 20.0,
        type = "police",
        showBlip = true,
        interactions = {
            {label = "Request Police Badge", value = "police_badge", description = "Get your police badge"},
            {label = "Access Armory", value = "police_armory", description = "Access the police armory"},
            {label = "Check Wanted List", value = "police_wanted", description = "View the most wanted criminals"}
        }
    },
    {
        name = "Sandy Shores Sheriff's Office",
        center = vector3(1853.82, 3686.43, 34.27),
        width = 50.0,
        length = 50.0,
        height = 15.0,
        type = "police",
        showBlip = true
    },
    {
        name = "Paleto Bay Sheriff's Office",
        center = vector3(-448.4, 6012.8, 31.72),
        width = 50.0,
        length = 50.0,
        height = 15.0,
        type = "police",
        showBlip = true
    },
    
    -- Hospitals
    {
        name = "Pillbox Hospital",
        center = vector3(298.8, -584.2, 43.3),
        width = 100.0,
        length = 100.0,
        height = 30.0,
        type = "hospital",
        showBlip = true,
        interactions = {
            {label = "Request Medical Attention", value = "hospital_heal", description = "Get medical treatment"},
            {label = "Purchase Health Insurance", value = "hospital_insurance", description = "Buy health insurance"},
            {label = "Request Medical Report", value = "hospital_report", description = "Get your medical report"}
        }
    },
    {
        name = "Sandy Shores Medical Center",
        center = vector3(1839.52, 3672.52, 34.28),
        width = 50.0,
        length = 50.0,
        height = 15.0,
        type = "hospital",
        showBlip = true
    },
    {
        name = "Paleto Bay Medical Center",
        center = vector3(-247.4, 6331.7, 32.43),
        width = 50.0,
        length = 50.0,
        height = 15.0,
        type = "hospital",
        showBlip = true
    },
    
    -- Shops
    {
        name = "24/7 Supermarket",
        center = vector3(25.82, -1347.22, 29.5),
        radius = 15.0,
        type = "shop",
        showBlip = true
    },
    {
        name = "LTD Gasoline",
        center = vector3(-48.34, -1757.94, 29.42),
        radius = 15.0,
        type = "shop",
        showBlip = true
    },
    {
        name = "Rob's Liquor",
        center = vector3(-1222.78, -907.22, 12.33),
        radius = 15.0,
        type = "shop",
        showBlip = true
    },
    
    -- Residential areas
    {
        name = "Eclipse Towers",
        center = vector3(-773.89, 311.99, 85.7),
        width = 60.0,
        length = 60.0,
        height = 100.0,
        type = "residential",
        showBlip = true,
        interactions = {
            {label = "Enter Apartment", value = "residential_enter", description = "Go to your apartment"},
            {label = "Check Mailbox", value = "residential_mail", description = "Check your mail"},
            {label = "Pay Rent", value = "residential_rent", description = "Pay your monthly rent"}
        }
    },
    {
        name = "Integrity Apartments",
        center = vector3(-18.07, -583.57, 79.46),
        width = 60.0,
        length = 60.0,
        height = 100.0,
        type = "residential",
        showBlip = true
    },
    
    -- Office buildings
    {
        name = "Maze Bank Tower",
        center = vector3(-75.0, -818.0, 326.2),
        width = 80.0,
        length = 80.0,
        height = 200.0,
        type = "office",
        showBlip = true,
        interactions = {
            {label = "Enter Office", value = "office_enter", description = "Go to your office"},
            {label = "Banking Services", value = "office_banking", description = "Access banking services"},
            {label = "Schedule Meeting", value = "office_meeting", description = "Schedule a business meeting"}
        }
    },
    {
        name = "Arcadius Business Center",
        center = vector3(-141.29, -621.0, 168.82),
        width = 80.0,
        length = 80.0,
        height = 150.0,
        type = "office",
        showBlip = true
    },
    
    -- Entertainment venues
    {
        name = "Tequi-la-la",
        center = vector3(-564.64, 275.33, 83.02),
        radius = 20.0,
        type = "entertainment",
        showBlip = true,
        interactions = {
            {label = "Order Drink", value = "entertainment_drink", description = "Buy a drink"},
            {label = "Dance", value = "entertainment_dance", description = "Dance to the music"},
            {label = "Request Song", value = "entertainment_song", description = "Request a song from the DJ"}
        }
    },
    {
        name = "Vanilla Unicorn",
        center = vector3(132.38, -1304.42, 29.2),
        radius = 25.0,
        type = "entertainment",
        showBlip = true
    },
    {
        name = "Movie Theater",
        center = vector3(300.85, 200.97, 104.38),
        radius = 30.0,
        type = "entertainment",
        showBlip = true
    },
    
    -- Gang territories (these will be supplemented by the civil_disorder resource)
    {
        name = "Gang Territory - Davis",
        center = vector3(105.8, -1940.2, 20.8),
        radius = 150.0,
        type = "gang_territory",
        subType = "ballas",
        showBlip = true,
        blipColor = 27, -- Purple
        blipName = "Ballas Territory"
    },
    {
        name = "Gang Territory - Chamberlain Hills",
        center = vector3(-173.3, -1634.5, 33.5),
        radius = 150.0,
        type = "gang_territory",
        subType = "families",
        showBlip = true,
        blipColor = 25, -- Green
        blipName = "Families Territory"
    },
    {
        name = "Gang Territory - Rancho",
        center = vector3(334.2, -2039.5, 21.1),
        radius = 150.0,
        type = "gang_territory",
        subType = "vagos",
        showBlip = true,
        blipColor = 46, -- Yellow
        blipName = "Vagos Territory"
    }
}
