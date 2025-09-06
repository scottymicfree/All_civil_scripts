Config = {}

-- General settings
Config.Debug = true  -- Set to true initially to help debug issues
Config.UseBlips = true
Config.UseMarkers = true
Config.UseNativeUI = true -- Set to false if you want to use vMenu's built-in menus

-- Payment settings
Config.EnablePayment = true
Config.RepairCost = 350 -- Base cost for repairs
Config.CustomizationMultiplier = 1.5 -- Multiplier for customization costs

-- Mechanic job settings
Config.MechanicJobName = "mechanic"
Config.MechanicDiscount = 0.5 -- 50% discount for mechanics

-- Garage locations
Config.Garages = {
    {
        name = "LS Customs",
        position = vector3(-337.0, -136.0, 39.0),
        blip = {
            sprite = 446,
            color = 5,
            scale = 0.8,
            name = "LS Customs Auto Repair"
        },
        marker = {
            type = 1,
            size = {x = 3.0, y = 3.0, z = 1.0},
            color = {r = 255, g = 165, b = 0, a = 100}
        },
        repairPoint = vector3(-339.0, -139.0, 38.5),
        repairHeading = 251.0,
        menuPosition = vector3(-337.0, -136.0, 39.0),
        mechanicRequired = false -- Set to true if you want only mechanics to use this garage
    },
    {
        name = "Benny's Original Motorworks",
        position = vector3(-211.55, -1324.55, 30.90),
        blip = {
            sprite = 446,
            color = 47,
            scale = 0.8,
            name = "Benny's Original Motorworks"
        },
        marker = {
            type = 1,
            size = {x = 3.0, y = 3.0, z = 1.0},
            color = {r = 0, g = 0, b = 255, a = 100}
        },
        repairPoint = vector3(-211.55, -1324.55, 30.90),
        repairHeading = 320.0,
        menuPosition = vector3(-211.55, -1324.55, 30.90),
        mechanicRequired = false
    },
    {
        name = "Sandy Shores Repair",
        position = vector3(1174.8, 2640.19, 37.75),
        blip = {
            sprite = 446,
            color = 5,
            scale = 0.8,
            name = "Sandy Shores Auto Repair"
        },
        marker = {
            type = 1,
            size = {x = 3.0, y = 3.0, z = 1.0},
            color = {r = 255, g = 165, b = 0, a = 100}
        },
        repairPoint = vector3(1174.8, 2640.19, 37.75),
        repairHeading = 0.0,
        menuPosition = vector3(1174.8, 2640.19, 37.75),
        mechanicRequired = false
    },
    {
        name = "Paleto Bay Repairs",
        position = vector3(110.93, 6626.51, 31.89),
        blip = {
            sprite = 446,
            color = 5,
            scale = 0.8,
            name = "Paleto Bay Auto Repair"
        },
        marker = {
            type = 1,
            size = {x = 3.0, y = 3.0, z = 1.0},
            color = {r = 255, g = 165, b = 0, a = 100}
        },
        repairPoint = vector3(110.93, 6626.51, 31.89),
        repairHeading = 225.0,
        menuPosition = vector3(110.93, 6626.51, 31.89),
        mechanicRequired = false
    }
}

-- Repair options
Config.RepairOptions = {
    {
        name = "Basic Repair",
        description = "Fix engine and body damage",
        price = Config.RepairCost,
        action = "basic_repair"
    },
    {
        name = "Full Service",
        description = "Complete vehicle restoration",
        price = Config.RepairCost * 1.5,
        action = "full_repair"
    },
    {
        name = "Wash Vehicle",
        description = "Clean your vehicle",
        price = Config.RepairCost * 0.2,
        action = "wash"
    }
}

-- Customization options
Config.CustomizationOptions = {
    {
        name = "Performance Upgrades",
        description = "Upgrade engine, brakes, transmission, etc.",
        price = Config.RepairCost * 2,
        action = "performance"
    },
    {
        name = "Cosmetic Upgrades",
        description = "Change appearance, paint, wheels, etc.",
        price = Config.RepairCost * 1.5,
        action = "cosmetic"
    },
    {
        name = "Full Customization",
        description = "Access all vehicle modifications",
        price = Config.RepairCost * 3,
        action = "full_customize"
    }
}
