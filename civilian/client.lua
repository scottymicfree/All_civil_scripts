-- Configuration
local civilianCoords = vector3(-1042.49, -2745.91, 20.36) -- Example civilian spawn
local isTeleporting = false

-- Initialize
Citizen.CreateThread(function()
    -- Wait for player to fully load
    while not NetworkIsPlayerActive(PlayerId()) do
        Citizen.Wait(100)
    end
    
    print("Civilian job script initialized")
end)

-- Command to become a civilian
RegisterCommand("civilianjob", function()
    if isTeleporting then
        TriggerEvent("civilian:notify", "~r~Already processing a request")
        return
    end
    
    TriggerServerEvent("civilian:assignJob")
end, false)

-- Notification handler
RegisterNetEvent("civilian:notify")
AddEventHandler("civilian:notify", function(msg)
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandThefeedPostTicker(false, false)
end)

-- Safe teleport function
function SafeTeleport(x, y, z)
    local playerPed = PlayerPedId()
    isTeleporting = true
    
    -- Freeze player to prevent issues
    FreezeEntityPosition(playerPed, true)
    
    -- Start a loading screen
    DoScreenFadeOut(500)
    Citizen.Wait(600)
    
    -- Request collision at the target location
    RequestCollisionAtCoord(x, y, z)
    
    -- Set the new coordinates
    SetEntityCoords(playerPed, x, y, z, false, false, false, false)
    
    -- Wait for the world to load around the player
    while not HasCollisionLoadedAroundEntity(playerPed) do
        Citizen.Wait(100)
    end
    
    -- Unfreeze player and fade back in
    FreezeEntityPosition(playerPed, false)
    DoScreenFadeIn(750)
    
    -- Reset teleport flag
    isTeleporting = false
end

-- Spawn event handler with improved teleportation
RegisterNetEvent("civilian:spawn")
AddEventHandler("civilian:spawn", function()
    -- Use the safe teleport function
    SafeTeleport(civilianCoords.x, civilianCoords.y, civilianCoords.z)
    
    -- Give the player some feedback
    Citizen.Wait(1000)
    TriggerEvent("civilian:notify", "Welcome to your civilian job")
end)

-- Add a help text to show available commands
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10000)
        BeginTextCommandDisplayHelp("STRING")
        AddTextComponentSubstringPlayerName("Type /civilianjob to become a civilian")
        EndTextCommandDisplayHelp(0, false, true, 5000)
    end
end)
