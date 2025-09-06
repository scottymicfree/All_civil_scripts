-- =========================================================
-- [ config.lua ]
-- Configuration for the fire NPC resource.
-- =========================================================
Config = {}

-- The NPC's appearance model. You can change this to any valid ped model.
Config.NpcModel = "s_m_y_fireman_01"

-- The location where the NPC will spawn.
-- This is a vector4, including x, y, z coordinates and the heading (W).
Config.NpcCoords = vector4(1200.85, -1469.85, 34.85, 180.0)

-- The distance in meters a player must be to interact with the NPC.
Config.InteractionDistance = 2.0

-- The chat message the NPC will say.
Config.NpcChatMessage = "[Fire Chief] You're geared up and ready to respond!"
