-- Initialize variables at the top of the script
local ESX = nil
local QBCore = nil
local activeCrimeReports = {}

-- Detect which framework is running on the server
CreateThread(function()
    if GetResourceState('es_extended') == 'started' then
        ESX = exports['es_extended']:getSharedObject()
        print("[Police NPC] ESX framework detected.")
    elseif GetResourceState('qb-core') == 'started' then
        QBCore = exports['qb-core']:GetCoreObject()
        print("[Police NPC] QBCore framework detected.")
    else
        print("[Police NPC] No compatible framework (ESX/QBCore) detected.")
    end
end)

-- Function to handle crime reports
local function ProcessCrimeReport(source, crimeType)
    -- Use GetPlayerIdentifier with the correct index for server-side
    local identifier = GetPlayerIdentifier(source, 0)
    local playerName = GetPlayerName(source)
    local timestamp = os.time()

    -- Store the crime report
    if not activeCrimeReports[identifier] then
        activeCrimeReports[identifier] = {}
    end

    table.insert(activeCrimeReports[identifier], {
        type = crimeType,
        timestamp = timestamp,
        location = "Unknown", -- This could be enhanced with actual player location
        status = "Filed"
    })

    -- Log the crime report
    print(string.format("[Police NPC] Player %s (%s) reported crime: %s", playerName, identifier, crimeType))

    -- Notify player
    TriggerClientEvent("chat:addMessage", source, {
        args = { "[Officer]", "Thank you for reporting this incident. We'll investigate " .. crimeType .. " in the area." }
    })

    -- Notify other police players if using a framework
    if ESX then
        local xPlayers = ESX.GetPlayers()
        for i = 1, #xPlayers do
            local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
            if xPlayer and xPlayer.job.name == 'police' then
                TriggerClientEvent("chat:addMessage", xPlayers[i], {
                    args = { "[Police Dispatch]", "New crime report: " .. crimeType .. " reported by a citizen." }
                })
            end
        end
    elseif QBCore then
        local players = QBCore.Functions.GetPlayers() -- Corrected function for QBCore
        for _, playerId in pairs(players) do
            local player = QBCore.Functions.GetPlayer(playerId)
            if player and player.PlayerData.job.name == "police" then
                TriggerClientEvent("chat:addMessage", player.PlayerData.source, {
                    args = { "[Police Dispatch]", "New crime report: " .. crimeType .. " reported by a citizen." }
                })
            end
        end
    end

    -- Integration with Civil Disorder if available
    if GetResourceState('civil_disorder') == 'started' then
        -- This would trigger a response from the Civil Disorder system
        -- For example, sending police NPCs to investigate
        TriggerEvent("civil_disorder:crimeReported", crimeType, source)
    end
end

-- This is the missing piece that caused your "missing-parameter" error.
-- You need to register the network event that calls the function.
-- Replace 'your_event_name_here' with the actual event name triggered from your client script.
RegisterNetEvent('your_event_name_here', ProcessCrimeReport)
