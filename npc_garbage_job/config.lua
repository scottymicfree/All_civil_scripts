Config = {}

-- Debug mode
Config.Debug = false

-- Job settings
Config.PayPerStop = 50 -- Money earned per garbage stop
Config.XpPerStop = 5 -- XP earned per garbage stop
Config.JobCooldown = 10 -- Minutes before player can start another route

-- Locations
Config.StartLocation = vector3(-322.4, -1545.6, 31.0)
Config.GarbagePoints = {
    vector3(-348.5, -1493.2, 30.9),
    vector3(-379.6, -1470.7, 30.9),
    vector3(-428.4, -1463.5, 30.9),
    vector3(-457.8, -1450.4, 30.9)
}

-- Vehicle settings
Config.TruckModel = "trash"
Config.TruckSpawnPoint = vector4(-335.4, -1530.6, 27.6, 270.0)

-- NPC settings
Config.NPCModel = "s_m_y_garbage"
Config.NPCHeading = 270.0

-- Blip settings
Config.EnableBlips = true
Config.JobBlip = {
    sprite = 318,
    color = 2,
    scale = 0.8,
    name = "Garbage Collection"
}
