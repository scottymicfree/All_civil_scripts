-- =========================================================
-- [ config.lua ]
-- Configuration for the EMS NPC resource.
-- =========================================================
Config = {}

-- The NPC's appearance model. You can change this to any valid ped model.
Config.NpcModel = "s_m_m_paramedic_01"

-- The location where the NPC will spawn.
-- This is a vector4, including x, y, z coordinates and the heading (w).
Config.NpcCoords = vector4(300.5, -1449.7, 29.8, 50.0)

-- The distance in meters a player must be to interact with the NPC.
Config.InteractionDistance = 2.0

-- The chat message the NPC will say.
Config.NpcChatMessage = "[EMS] You've been patched up. Take care out there!"
