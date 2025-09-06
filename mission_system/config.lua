-- =============================================================
-- [ config.lua ]
-- Configuration file for the Mission System
-- =============================================================


Config = {}


-- Mission types
Config.MissionTypes = {
    gang = {
        name = "Gang Mission",
        description = "Complete tasks for your gang",
        difficulties = {
            low = {
                name = "Low Risk",
                reward = 500,
                xp = 100
            },
            mid = {
                name = "Medium Risk",
                reward = 1000,
                xp = 200
            },
            high = {
                name = "High Risk",
                reward = 2000,
                xp = 400
            }
        }
    },
    drug = {
        name = "Drug Mission",
        description = "Complete drug-related tasks",
        difficulties = {
            low = {
                name = "Low Risk",
                reward = 600,
                xp = 120
            },
            mid = {
                name = "Medium Risk",
                reward = 1200,
                xp = 240
            },
            high = {
                name = "High Risk",
                reward = 2400,
                xp = 480
            }
        }
    },
    police = {
        name = "Police Mission",
        description = "Complete tasks for the police department",
        difficulties = {
            low = {
                name = "Low Risk",
                reward = 400,
                xp = 80
            },
            mid = {
                name = "Medium Risk",
                reward = 800,
                xp = 160
            },
            high = {
                name = "High Risk",
                reward = 1600,
                xp = 320
            }
        }
    },
    ems = {
        name = "EMS Mission",
        description = "Complete tasks for the EMS department",
        difficulties = {
            low = {
                name = "Low Risk",
                reward = 300,
                xp = 60
            },
            mid = {
                name = "Medium Risk",
                reward = 600,
                xp = 120
            },
            high = {
                name = "High Risk",
                reward = 1200,
                xp = 240
            }
        }
    },
    fire = {
        name = "Fire Mission",
        description = "Complete tasks for the fire department",
        difficulties = {
            low = {
                name = "Low Risk",
                reward = 300,
                xp = 60
            },
            mid = {
                name = "Medium Risk",
                reward = 600,
                xp = 120
            },
            high = {
                name = "High Risk",
                reward = 1200,
                xp = 240
            }
        }
    }
}


-- Mission locations
Config.MissionLocations = {
    gang = {
        { coords = vector3(970.0, -130.0, 74.35), radius = 100.0, name = "Biker Gang Territory" },
        { coords = vector3(-1160.0, -2030.0, 13.18), radius = 100.0, name = "Cartel Territory" },
        { coords = vector3(350.0, -880.0, 28.29), radius = 100.0, name = "Divine Gang Territory" },
        { coords = vector3(-580.0, -1060.0, 22.35), radius = 100.0, name = "Queens Gang Territory" }
    },
    drug = {
        { coords = vector3(412.45, -1903.77, 25.35), radius = 30.0, name = "Weed Dealer Area" },
        { coords = vector3(-1146.32, -1514.88, 4.18), radius = 30.0, name = "Meth Dealer Area" },
        { coords = vector3(233.12, -1761.53, 28.29), radius = 30.0, name = "Cocaine Dealer Area" }
    },
    police = {
        { coords = vector3(426.1, -979.5, 30.7), radius = 100.0, name = "Mission Row PD" },
        { coords = vector3(-1095.02, -836.14, 19.0), radius = 100.0, name = "Vespucci PD" }
    },
    ems = {
        { coords = vector3(307.4, -595.3, 43.3), radius = 90.0, name = "Pillbox Hill Medical" },
        { coords = vector3(1839.6, 3672.93, 34.28), radius = 40.0, name = "Sandy Shores Medical" }
    },
    fire = {
        { coords = vector3(-701.37, -148.97, 37.49), radius = 80.0, name = "Davis Fire Station" },
        { coords = vector3(277.62, -1632.74, 29.29), radius = 80.0, name = "South LS Fire Station" }
    }
}


-- Mission objectives
Config.MissionObjectives = {
    gang = {
        low = {
            { type = "goto", description = "Go to the specified location" },
            { type = "collect", description = "Collect the package" },
            { type = "deliver", description = "Deliver the package" }
        },
        mid = {
            { type = "goto", description = "Go to the specified location" },
            { type = "kill", description = "Eliminate the target" },
            { type = "collect", description = "Collect the evidence" },
            { type = "deliver", description = "Return to the starting point" }
        },
        high = {
            { type = "goto", description = "Go to the specified location" },
            { type = "kill", description = "Eliminate all targets" },
            { type = "collect", description = "Collect the valuable item" },
            { type = "escape", description = "Escape the area" },
            { type = "deliver", description = "Deliver the item" }
        }
    },
    drug = {
        low = {
            { type = "goto", description = "Go to the specified location" },
            { type = "collect", description = "Collect the drugs" },
            { type = "deliver", description = "Deliver the drugs" }
        },
        mid = {
            { type = "goto", description = "Go to the specified location" },
            { type = "kill", description = "Eliminate the rival dealer" },
            { type = "collect", description = "Collect the drugs" },
            { type = "deliver", description = "Deliver the drugs" }
        },
        high = {
            { type = "goto", description = "Go to the specified location" },
            { type = "kill", description = "Eliminate all rival dealers" },
            { type = "collect", description = "Collect the drug shipment" },
            { type = "escape", description = "Escape the area" },
            { type = "deliver", description = "Deliver the shipment" }
        }
    },
    police = {
        low = {
            { type = "goto", description = "Go to the crime scene" },
            { type = "collect", description = "Collect evidence" },
            { type = "deliver", description = "Return to the police station" }
        },
        mid = {
            { type = "goto", description = "Go to the suspect's location" },
            { type = "arrest", description = "Arrest the suspect" },
            { type = "deliver", description = "Bring the suspect to the police station" }
        },
        high = {
            { type = "goto", description = "Go to the hostage situation" },
            { type = "kill", description = "Neutralize the threats" },
            { type = "rescue", description = "Rescue the hostages" },
            { type = "deliver", description = "Escort the hostages to safety" }
        }
    },
    ems = {
        low = {
            { type = "goto", description = "Go to the patient's location" },
            { type = "heal", description = "Provide medical assistance" },
            { type = "deliver", description = "Return to the hospital" }
        },
        mid = {
            { type = "goto", description = "Go to the accident scene" },
            { type = "heal", description = "Treat multiple patients" },
            { type = "deliver", description = "Transport patients to the hospital" }
        },
        high = {
            { type = "goto", description = "Go to the mass casualty incident" },
            { type = "heal", description = "Triage and treat patients" },
            { type = "rescue", description = "Extract patients from danger" },
            { type = "deliver", description = "Transport critical patients to the hospital" }
        }
    },
    fire = {
        low = {
            { type = "goto", description = "Go to the fire location" },
            { type = "extinguish", description = "Extinguish the fire" },
            { type = "deliver", description = "Return to the fire station" }
        },
        mid = {
            { type = "goto", description = "Go to the building fire" },
            { type = "rescue", description = "Rescue trapped civilians" },
            { type = "extinguish", description = "Extinguish the fire" },
            { type = "deliver", description = "Return to the fire station" }
        },
        high = {
            { type = "goto", description = "Go to the major fire" },
            { type = "rescue", description = "Rescue multiple trapped civilians" },
            { type = "extinguish", description = "Contain the fire" },
            { type = "deliver", description = "Escort civilians to safety" }
        }
    }
}


-- Server-side configuration
Config.Server = {
    -- XP multipliers by difficulty
    XPMultipliers = {
        low = 1.0,
        mid = 1.5,
        high = 2.0
    },


-- Money multipliers by difficulty
MoneyMultipliers = {
    low = 1.0,
    mid = 1.5,
    high = 2.0
},

-- Time bonuses (seconds)
TimeBonuses = {
    low = 300,  -- 5 minutes
    mid = 600,  -- 10 minutes
    high = 900  -- 15 minutes
},

-- Bonus multipliers
BonusMultipliers = {
    xp = 0.2,   -- 20% bonus XP for completing within time limit
    money = 0.2 -- 20% bonus money for completing within time limit
},

-- Cooldown between missions (in milliseconds)
Cooldown = 300000, -- 5 minutes

-- Debug mode
DebugMode = false

}


-- Controller support configuration
Config.Controller = {
    -- Button mappings
    Buttons = {
        Interact = 46,    -- E key / Xbox A button
        Cancel = 177,     -- Backspace / Xbox B button
        Menu = 244,       -- M key / Xbox Y button
        Context = 51      -- E key / Xbox A button
    }
}


-- NPC models
Config.NPCModels = {
    Enemies = {
        "g_m_y_lost_03",
        "g_m_m_mexboss_01",
        "g_f_y_vagos_01",
        "a_m_y_mexthug_01"
    },
    Civilians = {
        "a_m_y_business_01",
        "a_f_y_business_01",
        "a_m_y_tourist_01",
        "a_f_y_tourist_01"
    }
}


-- Mission objects
Config.Objects = {
    Package = "prop_drug_package",
    Evidence = "prop_cs_documents_01",
    Valuable = "prop_cash_case_02"
}


-- Debug settings
Config.Debug = {
    Enabled = false,
    ShowBlips = true,
    ShowMarkers = true
}