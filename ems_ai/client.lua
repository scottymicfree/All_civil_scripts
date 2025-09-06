-- =========================================================
-- [ client.lua ]
-- Handles client-side logic for the EMS NPC.
-- =========================================================

-- Global variables
local npcPed = nil
local isNpcLoaded = false
local isNearNPC = false

-- Create the EMS NPC on a separate thread
Citizen.CreateThread(function()
    -- Wait for game to load properly
    Citizen.Wait(2000)
    
    -- Request the model with a timeout
    RequestModel(GetHashKey(Config.NpcModel))
    
    -- Wait for model to load with timeout
    local timeout = GetGameTimer() + 10000
    while not HasModelLoaded(GetHashKey(Config.NpcModel)) and GetGameTimer() < timeout do
        Citizen.Wait(100)
    end
    
    -- Check if model loaded successfully
    if not HasModelLoaded(GetHashKey(Config.NpcModel)) then
        print("ERROR: Failed to load NPC model: " .. Config.NpcModel)
        return
    end

    -- Create the ped, setting its position and heading from the config
    npcPed = CreatePed(4, GetHashKey(Config.NpcModel), Config.NpcCoords.x, Config.NpcCoords.y, Config.NpcCoords.z - 1.0, Config.NpcCoords.w, false, true)
    
    -- Make the NPC invincible and unmoveable
    SetEntityInvincible(npcPed, true)
    FreezeEntityPosition(npcPed, true)
    SetBlockingOfNonTemporaryEvents(npcPed, true)
    
    -- Set the NPC as loaded
    isNpcLoaded = true
    
    -- Clean up the model
    SetModelAsNoLongerNeeded(GetHashKey(Config.NpcModel))
    
    print("EMS NPC created successfully")
end)

-- Proximity check thread (optimized to run less frequently)
Citizen.CreateThread(function()
    while true do
        -- Only proceed if NPC is loaded
        if isNpcLoaded and DoesEntityExist(npcPed) then
            -- Get player coordinates
            local playerCoords = GetEntityCoords(PlayerPedId())
            local npcCoords = vector3(Config.NpcCoords.x, Config.NpcCoords.y, Config.NpcCoords.z)
            local distance = #(playerCoords - npcCoords)
            
            -- Update proximity state
            isNearNPC = (distance < Config.InteractionDistance * 2)
            
            -- Adjust wait time based on distance
            if distance < 50.0 then
                Citizen.Wait(1000) -- Check every second when somewhat close
            else
                Citizen.Wait(5000) -- Check less frequently when far away
            end
        else
            -- NPC not loaded yet, wait longer
            Citizen.Wait(2000)
        end
    end
end)

-- Main interaction loop (only runs when player is near the NPC)
Citizen.CreateThread(function()
    while true do
        -- Only run interaction code when near NPC
        if isNearNPC and isNpcLoaded and DoesEntityExist(npcPed) then
            -- Get precise distance
            local playerCoords = GetEntityCoords(PlayerPedId())
            local npcCoords = vector3(Config.NpcCoords.x, Config.NpcCoords.y, Config.NpcCoords.z)
            local distance = #(playerCoords - npcCoords)
            
            -- Check if within interaction distance
            if distance < Config.InteractionDistance then
                -- Draw the interaction text
                DrawText3D(Config.NpcCoords.x, Config.NpcCoords.y, Config.NpcCoords.z + 1.0, "[E / →] Talk to EMS")
                
                -- Check for key press
                if IsControlJustReleased(0, 38) or IsControlJustReleased(0, 175) then
                    -- Add a small cooldown to prevent spam
                    DisableControlAction(0, 38, true)
                    DisableControlAction(0, 175, true)
                    
                    -- Trigger the server event
                    TriggerServerEvent("ems:assist")
                    
                    -- Wait a bit before allowing interaction again
                    Citizen.Wait(1000)
                    EnableControlAction(0, 38, true)
                    EnableControlAction(0, 175, true)
                end
                
                -- Short wait when in interaction range
                Citizen.Wait(0)
            else
                -- Slightly longer wait when near but not in range
                Citizen.Wait(250)
            end
        else
            -- Much longer wait when not near NPC
            Citizen.Wait(1000)
        end
    end
end)

-- Helper function to draw 3D text in the world
function DrawText3D(x, y, z, text)
    -- Get screen coordinates
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    
    -- Only draw if on screen
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(true)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

-- Add this at the end of your client.lua file

-- Event to heal the player
RegisterNetEvent("ems:heal")
AddEventHandler("ems:heal", function()
    -- Get player ped
    local playerPed = PlayerPedId()
    
    -- Play animation (optional)
    RequestAnimDict("mini@cpr@char_a@cpr_str")
    while not HasAnimDictLoaded("mini@cpr@char_a@cpr_str") do
        Citizen.Wait(100)
    end
    
    -- Heal player
    SetEntityHealth(playerPed, GetEntityMaxHealth(playerPed))
    
    -- Notify player
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName("You have been healed.")
    EndTextCommandThefeedPostTicker(false, false)
end)