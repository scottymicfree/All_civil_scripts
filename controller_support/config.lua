Config = {}

-- Debug settings
Config.Debug = false

-- NPC interaction settings
Config.NPCInteraction = {
    InteractionDistance = 3.0,
    CooldownTime = 1000, -- 1 second cooldown between interactions
    EnableControllerPrompts = true,
    EnableKeyboardControls = true
}

-- Menu settings
Config.Menu = {
    UseNativeUI = true,
    NotificationCooldown = 2000, -- 2 seconds between notifications
    ControllerSettings = {
        EnableControllerSupport = true,
        NavigationUpButton = "DPAD_UP",
        NavigationDownButton = "DPAD_DOWN",
        SelectButton = "DPAD_RIGHT",
        BackButton = "DPAD_LEFT"
    }
}

-- NPC types based on models
Config.NPCTypes = {
    Police = {
        "s_m_y_cop_01",
        "s_f_y_cop_01",
        "s_m_y_hwaycop_01"
    },
    EMS = {
        "s_m_m_paramedic_01",
        "s_f_y_scrubs_01"
    },
    Fire = {
        "s_m_y_fireman_01"
    },
    Gang = {
        "g_m_y_lost_03",
        "g_m_m_mexboss_01",
        "g_f_y_vagos_01",
        "g_m_y_ballasout_01",
        "g_m_y_famca_01",
        "g_m_y_mexgoon_01",
        "g_m_y_lost_01",
        "g_m_y_salvagoon_01",
        "g_m_y_strpunk_01"
    }
}
