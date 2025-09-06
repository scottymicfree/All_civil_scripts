-- Configuration
local npcModel = "s_m_m_autoshop_01"
local npcCoords = vector3(-30.58, -1104.45, 26.42)
local npcHeading = 155.0
local interactionDistance = 2.0
local npcCreated = false
local npcPed = nil

-- Function to load model with timeout
local function LoadModel(model)
    local hash = GetHashKey(model)
    RequestModel(hash)
    -- Add timeout to prevent infinite loading
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(hash) and GetGameTimer() < timeout do 
        Wait(100) 
    end
    if not HasModelLoaded(hash) then
        print("Failed to load model: " .. model)
        return false
    end
    return hash
end

-- Function to create the dealership NPC
function CreateDealershipNPC()
    if npcCreated then return end
    -- Load the model
    local hash = LoadModel(npcModel)
    if not hash then return end
    -- Create the NPC
    npcPed = CreatePed(4, hash, npcCoords.x, npcCoords.y, npcCoords.z - 1.0, npcHeading, false, true)
    -- Configure the NPC
    if DoesEntityExist(npcPed) then
        SetEntityInvincible(npcPed, true)
        FreezeEntityPosition(npcPed, true)
        SetBlockingOfNonTemporaryEvents(npcPed, true)
        SetModelAsNoLongerNeeded(hash)
        npcCreated = true
        -- Add a simple animation
        RequestAnimDict("mini@strip_club@idles@bouncer@base")
        while not HasAnimDictLoaded("mini@strip_club@idles@bouncer@base") do
            Wait(100)
        end
        TaskPlayAnim(npcPed, "mini@strip_club@idles@bouncer@base", "base", 8.0, -8.0, -1, 1, 0, false, false, false)
    else
        print("Failed to create dealership NPC")
    end
end

-- Initialize the NPC
CreateThread(function()
    -- Wait for game to load
    Wait(2000)
    -- Create the NPC
    CreateDealershipNPC()
end)

-- Main interaction loop with optimized performance
CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local distance = #(playerCoords - npcCoords)
        local sleep = 1000 -- Default sleep time when far away
        -- Check if player is close to the NPC
        if distance < 10.0 then
            sleep = 500 -- Medium sleep time when somewhat close
            -- Check if player is within interaction distance
            if distance < interactionDistance then
                sleep = 0 -- No sleep when in interaction range
                -- Draw interaction text
                DrawText3D(npcCoords.x, npcCoords.y, npcCoords.z + 1.0, "[E / →] Talk to Dealer")
                -- Check for interaction key press
                if IsControlJustReleased(0, 38) or IsControlJustReleased(0, 175) then
                    -- Disable controls briefly to prevent spam
                    DisableControlAction(0, 38, true)
                    DisableControlAction(0, 175, true)
                    -- Trigger server event
                    TriggerServerEvent("dealership:openMenu")
                    -- Wait before allowing interaction again
                    Wait(1000)
                    EnableControlAction(0, 38, true)
                    EnableControlAction(0, 175, true)
                end
            end
        end
        Wait(sleep)
    end
end)

-- Helper function to draw 3D text
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

-- Clean up when resource stops
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        -- Delete the NPC if it exists
        if DoesEntityExist(npcPed) then
            DeleteEntity(npcPed)
        end
    end
end)
