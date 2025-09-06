local hideoutCoords = vector3(1391.92, 3606.39, 34.98) -- Example criminal base
local isCriminal = false

-- Command to become a criminal
RegisterCommand("criminaljob", function()
    TriggerServerEvent("criminal:assignJob")
end, false)

-- Notification handler
RegisterNetEvent("criminal:notify")
AddEventHandler("criminal:notify", function(msg)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(msg)
    DrawNotification(false, true)
end)

-- Improved spawn handler with proper teleportation
RegisterNetEvent("criminal:spawn")
AddEventHandler("criminal:spawn", function()
    -- Set flag
    isCriminal = true
    
    -- Prepare player for teleport
    DoScreenFadeOut(800)
    Wait(1000)
    
    -- Teleport player
    local playerPed = PlayerPedId()
    RequestCollisionAtCoord(hideoutCoords.x, hideoutCoords.y, hideoutCoords.z)
    SetEntityCoords(playerPed, hideoutCoords.x, hideoutCoords.y, hideoutCoords.z, false, false, false, true)
    
    -- Wait for collision to load
    while not HasCollisionLoadedAroundEntity(playerPed) do
        Wait(100)
    end
    
    -- Ensure player is on ground
    SetEntityHeading(playerPed, 0.0)
    PlaceObjectOnGroundProperly(playerPed)
    
    -- Fade back in
    Wait(500)
    DoScreenFadeIn(800)
    
    -- Notify player
    Wait(1000)
    TriggerEvent("criminal:notify", "Welcome to your hideout")
end)

-- Optional: Add criminal-specific functionality
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        
        if isCriminal then
            -- Add criminal-specific logic here
            -- For example, show nearby robbery opportunities
        else
            Citizen.Wait(5000) -- Wait longer if not a criminal
        end
    end
end)
