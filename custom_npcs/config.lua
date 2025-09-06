Config = {}

-- NPC Definitions
Config.NPCs = {
    -- Gang Leaders
    {
        id = "ballas_leader",
        model = "g_m_y_ballasout_01",
        coords = vector3(105.4, -1940.5, 20.8),
        heading = 320.0,
        animation = {scenario = "WORLD_HUMAN_SMOKING"},
        interactionDistance = 3.0,
        interactionType = "talk",
        data = {
            dialogue = {
                "This is Ballas territory. You better have a good reason to be here.",
                "Need something? I might be able to help... for a price.",
                "Keep your eyes open around here. Not everyone is friendly."
            },
            gang = "ballas"
        }
    },
    {
        id = "vagos_leader",
        model = "g_m_y_mexgoon_01",
        coords = vector3(334.2, -2052.1, 20.8),
        heading = 140.0,
        animation = {scenario = "WORLD_HUMAN_LEANING"},
        interactionDistance = 3.0,
        interactionType = "talk",
        data = {
            dialogue = {
                "Vagos run these streets, ese. Don't forget it.",
                "Looking for work? I might have something for you.",
                "Keep your head down around here unless you're with us."
            },
            gang = "vagos"
        }
    },
    
    -- Shop Owners
    {
        id = "black_market_dealer",
        model = "s_m_y_dealer_01",
        coords = vector3(-1146.32, -1514.88, 4.18),
        heading = 30.0,
        animation = {scenario = "WORLD_HUMAN_CLIPBOARD"},
        interactionDistance = 2.5,
        interactionType = "shop",
        data = {
            shop = {
                name = "Black Market",
                items = {
                    {name = "Lockpick", price = 150},
                    {name = "Advanced Lockpick", price = 500},
                    {name = "Bulletproof Vest", price = 1000}
                }
            }
        }
    },
    
    -- Mission Givers
    {
        id = "drug_dealer",
        model = "g_m_y_salvagoon_01",
        coords = vector3(412.45, -1903.77, 25.35),
        heading = 90.0,
        animation = {scenario = "WORLD_HUMAN_DRUG_DEALER"},
        interactionDistance = 3.0,
        interactionType = "mission",
        data = {
            dialogue = "I've got a job for you if you're interested...",
            mission = "drug_delivery"
        }
    },
    
    -- Custom NPCs
    {
        id = "homeless_man",
        model = "a_m_m_tramp_01",
        coords = vector3(-1604.66, -3012.58, 13.94),
        heading = 250.0,
        animation = {scenario = "WORLD_HUMAN_BUM_FREEWAY"},
        interactionDistance = 2.0,
        interactionType = "custom",
        data = {
            dialogue = "Got any spare change?",
            event = "custom_npcs:homelessInteraction"
        }
    },
    
    -- Police Station NPC
    {
        id = "police_receptionist",
        model = "s_f_y_cop_01",
        coords = vector3(442.0, -983.0, 30.7),
        heading = 90.0,
        animation = {scenario = "WORLD_HUMAN_CLIPBOARD"},
        interactionDistance = 2.5,
        interactionType = "talk",
        data = {
            dialogue = {
                "Welcome to Mission Row Police Department. How can I help you?",
                "If you need to report a crime, please speak with an officer.",
                "The chief is not available right now."
            }
        }
    },
    
    -- Hospital NPC
    {
        id = "hospital_doctor",
        model = "s_m_m_doctor_01",
        coords = vector3(307.4, -595.3, 43.3),
        heading = 70.0,
        animation = {scenario = "WORLD_HUMAN_CLIPBOARD"},
        interactionDistance = 2.5,
        interactionType = "talk",
        data = {
            dialogue = {
                "Do you need medical attention?",
                "The emergency room is that way.",
                "We're quite busy today, please be patient."
            }
        }
    },
    
    -- Mechanic
    {
        id = "mechanic",
        model = "s_m_y_xmech_02",
        coords = vector3(-347.0, -133.0, 39.0),
        heading = 70.0,
        animation = {scenario = "WORLD_HUMAN_WELDING"},
        interactionDistance = 3.0,
        interactionType = "custom",
        data = {
            dialogue = "Need your ride fixed up?",
            event = "custom_npcs:mechanicInteraction"
        }
    }
}
