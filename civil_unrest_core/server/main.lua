-- civilunrest-core/server/main.lua
-- Server-side script for Civil Unrest Core system.

print("[CivilUnrest-Core] Server loaded.")

-- Optional: Get QBCore object if you're using QBCore
-- local QBCore = exports['qb-core']:GetCoreObject()

-- Listen for the playerReady event from the client
RegisterNetEvent("civilunrest-core:playerReady", function()
    local src = source
    print(string.format("[CivilUnrest-Core] Player %s (%s) is ready.", GetPlayerName(src), src))

    -- Send a welcome message back to the client
    TriggerClientEvent("civilunrest-core:welcome", src, {
        message = "Welcome, citizen! The city is... lively today."
    })

    -- Send initial state sync data to the client
    -- In a real scenario, this 'state' would come from your server's
    -- actual game state (e.g., current law level, active zones, etc.)
    local currentState = {
        lawLevel = math.random(1, 5),   -- Example: Random law level
        mood = "tense",       -- Example: Current city mood
        activeZones = {"downtown","south_ls"},  -- Example: Currently active zones
        weather = 'GetWeatherType()  -- Example: Current server weather'
    }
    TriggerClientEvent("civilunrest-core:syncState", src, currentState)
end)

-- You would add more server-side logic here for:
-- - Managing global civil unrest state (law level, mood, active events)
-- - Handling player actions that affect the state
-- - Saving/loading state data (e.g., to a database)
-- - Timers or loops to periodically update the state and sync with clients


-- Weapon Buying Logic
RegisterServerEvent("civilunrest:buyWeapon")
AddEventHandler("civilunrest:buyWeapon", function(weapon, price)
    local xPlayer = GetPlayerFromId(source)
    if not xPlayer then return end

    if xPlayer.getMoney() >= price then
        xPlayer.removeMoney(price)
        xPlayer.addWeapon(weapon, 42)
        TriggerClientEvent("esx:showNotification", source, "You bought a weapon!")
    else
        TriggerClientEvent("esx:showNotification", source, "~r~Not enough cash!")
    end
end)