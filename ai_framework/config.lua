Config = {}

-- Gang configurations
Config.Gangs = {
    {name = "Southside Ballas", coords = vector3(-150, -1600, 35), blipColor = 1, enabled = true, model = "g_m_y_ballaeast_01", vehicle = "faction", dog = "a_c_rottweiler", offer = "guns"},
    {name = "East Families", coords = vector3(100, -2000, 20), blipColor = 2, enabled = true, model = "g_m_y_famca_01", vehicle = "peyote3", dog = "a_c_shepherd", offer = "drugs"},
    {name = "Polo Cartel", coords = vector3(2000, 3000, 45), blipColor = 3, enabled = true, model = "g_m_y_pologoon_02", vehicle = "chino2", dog = "a_c_rottweiler", offer = "cars"},
    {name = "Lost MC", coords = vector3(-400, 1200, 325), blipColor = 5, enabled = true, model = "g_m_y_lost_03", vehicle = "gauntlet4", dog = "a_c_rottweiler", offer = "drugs"},
    {name = "Mex Cartel", coords = vector3(1020, -2500, 28), blipColor = 1, enabled = true, model = "g_m_m_mexboss_01", vehicle = "club", dog = "a_c_shepherd", offer = "guns"},
    {name = "Korean Mob", coords = vector3(-1200, -500, 35), blipColor = 4, enabled = true, model = "g_m_m_korboss_01", vehicle = "brioso2", dog = "a_c_pug", offer = "mini_mission"},
    {name = "Russian Mafia", coords = vector3(2500, 1400, 30), blipColor = 6, enabled = true, model = "g_m_y_armgoon_02", vehicle = "blista", dog = "a_c_rottweiler", offer = "guns"}
}

-- Service NPC configurations
Config.Services = {
    ems = {model = "s_m_m_paramedic_01", vehicle = "ambulance", blip = 61, coords = vector3(295.0, -1446.0, 29.0)},
    fire = {model = "s_m_y_fireman_01", vehicle = "firetruk", blip = 60, coords = vector3(1200.0, -1460.0, 34.0)},
    tow = {model = "s_m_m_dockwork_01", vehicle = "towtruck2", blip = 68, coords = vector3(400.0, -1600.0, 29.0)},
    taxi = {model = "s_m_m_gentransport", vehicle = "taxi", blip = 56, coords = vector3(900.0, -170.0, 74.0)},
    bus = {model = "s_m_m_busdriver_01", vehicle = "bus", blip = 513, coords = vector3(451.0, -656.0, 28.0), route = {
        vector3(451.0, -656.0, 28.0),
        vector3(350.0, -1200.0, 30.0),
        vector3(-100.0, -1100.0, 25.0),
        vector3(-450.0, -600.0, 35.0),
        vector3(-1200.0, -300.0, 40.0)
    }}
}

-- General settings
Config.Debug = false
Config.SpawnDistance = 300.0
Config.DespawnDistance = 500.0
Config.EnableBlips = true
Config.EnableDogs = true
