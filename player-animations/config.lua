Config = {}

-- Animation definitions
Config.Animations = {
    point = {
        dict = "anim@mp_point",
        anim = "idle_a",
        flag = 49, -- Upper body only
        money = 10 -- Reward for peaceful gesture
    },
    surrender = {
        dict = "random@mugging3",
        anim = "handsup_standing_base",
        flag = 1, -- Loop
        money = -50 -- Penalty for surrendering
    },
    handshake = {
        dict = "mp_ped_interaction",
        anim = "handshake_guy_a",
        flag = 0,
        money = 25 -- Reward for social interaction
    },
    repair = {
        dict = "mini@repair",
        anim = "fixing_a_ped",
        flag = 1,
        cost = 200, -- Cost to repair
        reward = 50 -- Bonus after repair
    }
}

-- Controls
Config.Controls = {
    point = {keyboard = 73, controller = {73, 15}}, -- X or X+A
    surrender = {keyboard = 29, controller = {15, 18}}, -- B or A+B
    handshake = {keyboard = 74, controller = 74} -- H key
}

-- Repair settings
Config.RepairSettings = {
    searchRadius = 10.0,
    repairTime = 8000,
    mechanicModels = {
        `s_m_y_construct_01`,
        `s_m_m_autoshop_01`,
        `s_m_y_construct_02`
    }
}
