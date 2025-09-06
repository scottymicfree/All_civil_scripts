-- =========================================================
-- [ config.lua ]
-- Configuration for the police NPC resource.
-- =========================================================
Config = {}

-- The NPC's appearance model. You can change this to any valid ped model.
Config.NpcModel = "s_m_y_cop_01"

-- The location where the NPC will spawn.
-- This is a vector4, including x, y, z coordinates and the heading (W).
Config.NpcCoords = vector4(441.2, -981.97, 30.69, 90.0)

-- Additional police NPCs that will spawn
Config.AdditionalNPCs = {
    {
        model = "s_f_y_cop_01", -- Female officer
        coords = vector4(442.5, -978.8, 30.69, 180.0),
        scenario = "WORLD_HUMAN_CLIPBOARD"
    },
    {
        model = "s_m_y_hwaycop_01", -- Highway patrol
        coords = vector4(440.0, -978.8, 30.69, 180.0),
        scenario = "WORLD_HUMAN_COP_IDLES"
    },
    {
        model = "s_m_m_snowcop_01", -- Another officer
        coords = vector4(438.5, -981.97, 30.69, 90.0),
        scenario = "WORLD_HUMAN_STAND_IMPATIENT"
    }
}

-- The distance in meters a player must be to interact with the NPC.
Config.InteractionDistance = 2.0

-- The chat message the NPC will say.
Config.NpcChatMessage = "[Officer] Stay sharp out there. Let us know if you need backup."

-- Police services configuration
Config.PoliceServices = {
    -- Whether to enable various police services
    enableReporting = true,
    enableWantedCheck = true,
    enableFinePayment = true,
    enableLicenseCheck = true,
    enableVehicleCheck = true,
    
    -- Fines configuration
    fines = {
        {
            id = 1,
            name = "Speeding Ticket",
            amount = 150,
            description = "Fine for exceeding speed limits"
        },
        {
            id = 2,
            name = "Illegal Parking",
            amount = 100,
            description = "Fine for parking in restricted areas"
        },
        {
            id = 3,
            name = "Public Disturbance",
            amount = 200,
            description = "Fine for causing public disturbance"
        },
        {
            id = 4,
            name = "Weapon License Violation",
            amount = 500,
            description = "Fine for carrying weapons without proper license"
        },
        {
            id = 5,
            name = "Property Damage",
            amount = 350,
            description = "Fine for damaging public or private property"
        }
    },
    
    -- Crime reporting options
    crimeReports = {
        "Theft",
        "Assault",
        "Vandalism",
        "Drug Activity",
        "Suspicious Person",
        "Gang Activity",
        "Illegal Racing",
        "Weapons Discharge"
    }
}

-- Police station blip configuration
Config.StationBlip = {
    enable = true,
    sprite = 60, -- Police station icon
    color = 38, -- Blue
    scale = 0.8,
    name = "Police Station"
}

-- Integration settings
Config.Integration = {
    interiorZoneManager = true,
    civilDisorder = true,
    useESX = false,
    useQBCore = false
}

-- Debug mode
Config.Debug = false
