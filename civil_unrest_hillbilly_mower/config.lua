Config = {}

-- Spawn settings
Config.HillbillyModels = { "a_m_m_hillbilly_01", "a_m_m_hillbilly_02" }
Config.MowerModel = "mower"  -- Changed from "lawnmower" to "mower" which is the actual model name
Config.SpawnLocations = {
    {
        center = vector3(2032.5, 4980.1, 41.1),
        radius = 70.0,
        despawnRadius = 120.0,
        minSpawn = 2,
        maxSpawn = 4
    }
}

-- Behavior settings
Config.MowerSpeed = 8.0
Config.AggressionChance = 30 -- Percentage chance hillbilly becomes aggressive
Config.AggressionDistance = 10.0

-- Debug mode
Config.Debug = false


-- Behavior settings
Config.MowerSpeed = 8.0
Config.AggressionChance = 30 -- Percentage chance hillbilly becomes aggressive when player gets too close
Config.AggressionDistance = 10.0
Config.ChaseDistance = 40.0
Config.AttackCooldown = 15000 -- 15 seconds between attacks
Config.DamageAmount = 5 -- Damage per hit

-- Integration settings
Config.UseFramework = true -- Set to false if not using standalone-framework
Config.XPReward = 10 -- XP reward for defeating a hillbilly
Config.MoneyReward = {min = 5, max = 25} -- Random money reward range

-- Debug mode
Config.Debug = false
