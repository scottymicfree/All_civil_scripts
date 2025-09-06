-- =========================================================
-- [ client.lua ]
-- Handles client-side logic for the fire NPC.
-- =========================================================

-- Dependencies
local Config = {}

-- Global variables
local npcPed = nil

-- Create the fire NPC on a separate thread
CreateThread(function()
    RequestModel(Config.NpcModel)
    while not HasModelLoaded(Config.NpcModel) do
        Wait(100)
    end
    -- Create the ped, setting its position and heading from the config
    npcPed = CreatePed(4, GetHashKey(Config.NpcModel), Config.NpcCoords.x, Config.NpcCoords.y, Config.NpcCoords.z - 1.0, Config.NpcCoords.w, false, true)
    -- Make the NPC invincible and unmoveable
    SetEntityInvincible(npcPed, true)
    FreezeEntityPosition(npcPed, true)
    SetBlockingOfNonTemporaryEvents(npcPed, true)
end)

-- Main loop for interaction
CreateThread(function()
    while true do
        Wait(0)
        -- Get player coordinates and calculate distance to the NPC
        local playerCoords = GetEntityCoords(PlayerPedId())
        local distance = #(playerCoords - vector3(Config.NpcCoords.x, Config.NpcCoords.y, Config.NpcCoords.z))
        -- Check if the player is within interaction distance
        if distance < Config.InteractionDistance then
            -- Draw the interaction text
            DrawText3D(Config.NpcCoords.x, Config.NpcCoords.y, Config.NpcCoords.z + 1.0, "[E / →] Talk to Fire Chief")
            -- Check for the 'E' key or right arrow key press to trigger the server event
            if IsControlJustReleased(0, 38) or IsControlJustReleased(0, 175) then
                TriggerServerEvent("fire:assist")
            end
        end
    end
end)

-- Helper function to draw 3D text in the world
function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end
