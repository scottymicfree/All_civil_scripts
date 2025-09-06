-- Enhanced Player Tracking System - Server Side
-- This script stores and manages player data on the server side

local playerData = {}
local DATA_FILE_PATH = "data/player_tracker.json"

-- Load player data from file
function LoadPlayerData()
    local dataFile = LoadResourceFile(GetCurrentResourceName(), DATA_FILE_PATH)
    if dataFile then
        playerData = json.decode(dataFile)
        print("^2[PLAYER_TRACKER]^0 Loaded player data from file.")
    else
        playerData = {}
        print("^1[PLAYER_TRACKER]^0 No player data file found. Creating a new one.")
    end
end

-- Save player data to file
function SavePlayerData()
    local encodedData = json.encode(playerData)
    SaveResourceFile(GetCurrentResourceName(), DATA_FILE_PATH, encodedData, -1)
    print("^2[PLAYER_TRACKER]^0 Saved player data to file.")
end

-- Initialize player data for a new player
function InitPlayerData(source)
    local identifier = GetPlayerIdentifier(source, 0)
    if identifier then
        if not playerData[identifier] then
            playerData[identifier] = {
                lastGps = {x = 0, y = 0, z = 0},
                kills = 0,
                deaths = 0,
                xp = 0,
                level = 1,
                vehicles = {},
                lastSeen = os.time()
            }
            print("^2[PLAYER_TRACKER]^0 Initialized data for new player: " .. identifier)
        else
            -- Update last seen time
            playerData[identifier].lastSeen = os.time()
            print("^2[PLAYER_TRACKER]^0 Loaded existing data for player: " .. identifier)
        end
        
        -- Send data to client
        TriggerClientEvent('player_tracker:loadData', source, playerData[identifier])
    else
        print("^1[PLAYER_TRACKER]^0 Failed to get identifier for player: " .. source)
    end
end

-- Update player data
function UpdatePlayerData(source, data)
    local identifier = GetPlayerIdentifier(source, 0)
    if identifier and playerData[identifier] then
        if data.gps then
            playerData[identifier].lastGps = data.gps
        end
        
        if data.vehicle then
            -- Track vehicle
            local found = false
            for i, v in ipairs(playerData[identifier].vehicles or {}) do
                if v.plate == data.vehicle.plate then
                    found = true
                    v.lastUsed = os.time()
                    break
                end
            end
            
            if not found and data.vehicle.plate then
                table.insert(playerData[identifier].vehicles or {}, {
                    model = GetDisplayNameFromVehicleModel(data.vehicle.model),
                    plate = data.vehicle.plate,
                    firstUsed = os.time(),
                    lastUsed = os.time()
                })
            end
        end
        
        if data.kills then
            playerData[identifier].kills = data.kills
        end
        
        if data.deaths then
            playerData[identifier].deaths = data.deaths
        end
        
        if data.xp then
            playerData[identifier].xp = data.xp
        end
        
        if data.level then
            playerData[identifier].level = data.level
        end
        
        playerData[identifier].lastSeen = os.time()
    end
end

-- Get player data
function GetPlayerDataBySource(source)
    local identifier = GetPlayerIdentifier(source, 0)
    if identifier and playerData[identifier] then
        return playerData[identifier]
    end
    return nil
end

-- Get player data by identifier
function GetPlayerDataByIdentifier(identifier)
    if playerData[identifier] then
        return playerData[identifier]
    end
    return nil
end

-- Event handlers
RegisterNetEvent('player_tracker:updateData')
AddEventHandler('player_tracker:updateData', function(data)
    UpdatePlayerData(source, data)
end)

RegisterNetEvent('player_tracker:updateKills')
AddEventHandler('player_tracker:updateKills', function(kills)
    local identifier = GetPlayerIdentifier(source, 0)
    if identifier and playerData[identifier] then
        playerData[identifier].kills = kills
    end
end)

RegisterNetEvent('player_tracker:updateDeaths')
AddEventHandler('player_tracker:updateDeaths', function(deaths)
    local identifier = GetPlayerIdentifier(source, 0)
    if identifier and playerData[identifier] then
        playerData[identifier].deaths = deaths
    end
end)

RegisterNetEvent('player_tracker:updateXP')
AddEventHandler('player_tracker:updateXP', function(xp, level)
    local identifier = GetPlayerIdentifier(source, 0)
    if identifier and playerData[identifier] then
        playerData[identifier].xp = xp
        playerData[identifier].level = level
    end
end)

-- Player connecting
AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local source = source
    deferrals.defer()
    deferrals.update("Loading player data...")
    
    -- Short delay to ensure everything is ready
    Citizen.Wait(1000)
    
    deferrals.done()
end)

-- Player joined
AddEventHandler('playerJoining', function(source, oldID)
    InitPlayerData(source)
end)

-- Resource start/stop
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        LoadPlayerData()
        
        -- Initialize data for all connected players
        for _, playerId in ipairs(GetPlayers()) do
            InitPlayerData(tonumber(playerId))
        end
        
        print("^2[PLAYER_TRACKER]^0 Resource started.")
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        SavePlayerData()
        print("^2[PLAYER_TRACKER]^0 Resource stopped.")
    end
end)

-- Save data periodically
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(300000) -- Save every 5 minutes
        SavePlayerData()
    end
end)

-- Export functions
exports('GetPlayerDataBySource', GetPlayerDataBySource)
exports('GetPlayerDataByIdentifier', GetPlayerDataByIdentifier)