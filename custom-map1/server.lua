-- Interior Zone Manager Server Script
-- Dependencies: config.lua

local Config = {}
local interiorZones = {}
local playerZones = {}

-- Debug function
local function DebugPrint(message)
    if Config.Debug then
        print("[Interior Zone Manager] " .. message)
    end
end

-- Function to register a server-side zone
function RegisterServerZone(name, center, options)
    if not name or not center then
        DebugPrint("Failed to register zone: Missing required parameters")
        return false
    end

    -- Check if zone already exists
    for i, zone in ipairs(interiorZones) do
        if zone.name == name then
            DebugPrint("Zone '" .. name .. "' already exists, updating it")
            interiorZones[i] = {
                name = name,
                center = center,
                width = options.width,
                length = options.length,
                height = options.height or 10.0,
                radius = options.radius,
                minZ = options.minZ,
                maxZ = options.maxZ,
                type = options.type or "generic",
                subType = options.subType,
                showBlip = options.showBlip,
                blipSprite = options.blipSprite,
                blipColor = options.blipColor,
                blipScale = options.blipScale,
                blipName = options.blipName or name,
                allowedJobs = options.allowedJobs,
                data = options.data or {}
            }
            return true
        end
    end

    -- Create new zone
    local newZone = {
        name = name,
        center = center,
        width = options.width,
        length = options.length,
        height = options.height or 10.0,
        radius = options.radius,
        minZ = options.minZ,
        maxZ = options.maxZ,
        type = options.type or "generic",
        subType = options.subType,
        showBlip = options.showBlip,
        blipSprite = options.blipSprite,
        blipColor = options.blipColor,
        blipScale = options.blipScale,
        blipName = options.blipName or name,
        allowedJobs = options.allowedJobs,
        data = options.data or {}
    }

    table.insert(interiorZones, newZone)
    DebugPrint("Registered new zone: " .. name)

    -- Sync to all clients
    TriggerClientEvent("interior_zone_manager:syncZones", -1, interiorZones)

    return true
end

-- Function to get all players in a zone
function GetPlayersInZone(zoneName)
    local players = {}

    for playerId, zoneName in pairs(playerZones) do
        if zoneName == zoneName then
            table.insert(players, playerId)
        end
    end

    return players
end

-- Function to get a player's current zone
function GetPlayerZone(playerId)
    return playerZones[playerId]
end

-- Initialize zones from config
CreateThread(function()
    -- Register pre-defined zones from config
    for _, zone in ipairs(Config.InteriorZones) do
        RegisterServerZone(
            zone.name,
            zone.center,
            {
                width = zone.width,
                length = zone.length,
                height = zone.height,
                radius = zone.radius,
                minZ = zone.minZ,
                maxZ = zone.maxZ,
                type = zone.type,
                subType = zone.subType,
                showBlip = zone.showBlip,
                blipSprite = zone.blipSprite,
                blipColor = zone.blipColor,
                blipScale = zone.blipScale,
                blipName = zone.blipName,
                allowedJobs = zone.allowedJobs,
                data = zone.data
            }
        )
    end

    DebugPrint("Initialized " .. #interiorZones .. " interior zones")
end)

-- Event handlers
RegisterNetEvent("interior_zone_manager:enterZone")
AddEventHandler("interior_zone_manager:enterZone", function(zoneName, hasAccess)
    local playerId = source
    playerZones[playerId] = zoneName

    DebugPrint("Player " .. playerId .. " entered zone: " .. zoneName)

    -- Trigger event for other resources
    TriggerEvent("interior_zone_manager:playerEnteredZone", playerId, zoneName, hasAccess)
end)

RegisterNetEvent("interior_zone_manager:exitZone")
AddEventHandler("interior_zone_manager:exitZone", function(zoneName)
    local playerId = source

    if playerZones[playerId] == zoneName then
        playerZones[playerId] = nil
    end

    DebugPrint("Player " .. playerId .. " exited zone: " .. zoneName)

    -- Trigger event for other resources
    TriggerEvent("interior_zone_manager:playerExitedZone", playerId, zoneName)
end)

-- Player disconnect handler
AddEventHandler("playerDropped", function()
    local playerId = source

    if playerZones[playerId] then
        local zoneName = playerZones[playerId]
        playerZones[playerId] = nil

        -- Trigger event for other resources
        TriggerEvent("interior_zone_manager:playerExitedZone", playerId, zoneName)
    end
end)

-- Command to list all zones
RegisterCommand("listzones", function(source, args, rawCommand)
    if source == 0 or IsPlayerAceAllowed(source, "command.listzones") then
        local zoneList = "Interior Zones:\n"

        for i, zone in ipairs(interiorZones) do
            local playersInZone = GetPlayersInZone(zone.name)
            zoneList = zoneList .. i .. ". " .. zone.name .. " (" .. zone.type .. ") - Players: " .. #playersInZone .. "\n"
        end

        if source == 0 then
            print(zoneList)
        else
            TriggerClientEvent("chat:addMessage", source, {
                color = {255, 255, 128},
                multiline = true,
                args = {"Interior Zone Manager", zoneList}
            })
        end
    else
        TriggerClientEvent("chat:addMessage", source, {
            color = {255, 0, 0},
            args = {"Interior Zone Manager", "You don't have permission to use this command"}
        })
    end
end, false)

-- Command to add a new zone
RegisterCommand("addzone", function(source, args, rawCommand)
    if source == 0 or IsPlayerAceAllowed(source, "command.addzone") then
        if #args < 4 then
            local usage = "Usage: /addzone [name] [type] [width] [length] [height]"
            if source == 0 then
                print(usage)
            else
                TriggerClientEvent("chat:addMessage", source, {
                    color = {255, 0, 0},
                    args = {"Interior Zone Manager", usage}
                })
            end
            return
        end

        local name = args[1]
        local type = args[2]
        local width = tonumber(args[3])
        local length = tonumber(args[4])
        local height = tonumber(args[5]) or 10.0

        if source > 0 then
            -- Get player position for center
            TriggerClientEvent("interior_zone_manager:getPlayerPosition", source, function(position)
                RegisterServerZone(name, position, {
                    width = width,
                    length = length,
                    height = height,
                    type = type,
                    showBlip = true
                })

                TriggerClientEvent("chat:addMessage", source, {
                    color = {0, 255, 0},
                    args = {"Interior Zone Manager", "Zone '" .. name .. "' added successfully"}
                })
            end)
        else
            print("This command cannot be executed from the console without specifying coordinates")
        end
    else
        TriggerClientEvent("chat:addMessage", source, {
            color = {255, 0, 0},
            args = {"Interior Zone Manager", "You don't have permission to use this command"}
        })
    end
end, false)

-- Export functions
exports('RegisterServerZone', RegisterServerZone)
exports('GetPlayersInZone', GetPlayersInZone)
exports('GetPlayerZone', GetPlayerZone)
