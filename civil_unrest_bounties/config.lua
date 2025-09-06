Config = {}

-- Mission difficulty levels
Config.Levels = {
    [1] = { -- Beginner (0-49 XP)
        reward = 25,
        targets = {
            {model = 'a_m_y_hiker_01', pos = vector3(-1032.0, -2729.0, 13.8)},
            {model = 'a_m_y_hipster_01', pos = vector3(1137.0, -644.0, 56.8)},
            {model = 'a_m_y_skater_01', pos = vector3(-1389.0, -585.0, 30.2)}
        }
    },
    [2] = { -- Intermediate (50-99 XP)
        reward = 35,
        targets = {
            {model = 'a_m_y_business_02', pos = vector3(1274.0, -1720.0, 54.7)},
            {model = 'a_m_m_business_01', pos = vector3(307.0, -1003.0, 29.3)},
            {model = 'a_m_y_business_03', pos = vector3(-1579.0, -569.0, 108.5)}
        }
    },
    [3] = { -- Advanced (100+ XP)
        reward = 50,
        targets = {
            {model = 'g_m_y_mexgoon_01', pos = vector3(1391.0, 3608.0, 38.9)},
            {model = 'g_m_y_mexgoon_02', pos = vector3(-2166.0, 5197.0, 16.9)},
            {model = 'g_m_y_mexgoon_03', pos = vector3(2340.0, 3126.0, 48.2)}
        }
    }
}

-- Audio settings
Config.Audio = {
    bank = "SCRIPT\\BOUNTY_HUNTER",
    ringtone = "Remote_Ring",
    soundSet = "Phone_SoundSet_Default"
}

-- Blip settings
Config.Blip = {
    sprite = 84,  -- Bounty icon
    color = 1,    -- Red
    scale = 0.8
}

-- Mission settings
Config.MissionTimeout = 1200000  -- 20 minutes in ms
