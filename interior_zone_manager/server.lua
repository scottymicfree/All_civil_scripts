-- Interior Zone Manager Server Script
local interiorZones = {}

-- Debug function
local function DebugPrint(message)
    if Config.Debug then
        print("[Interior Zone Manager] " .. message)
    end
end

-- Function to register a new interior zone from the server
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
                data = options.data or {},
                interactions = options.interactions or {}
            }
            
            -- Sync with all clients
            TriggerClientEvent("interior_zone_manager:syncZones", -1, interiorZones)
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
        data = options.data or {},
        interactions = options.interactions or {}
    }
    
    table.insert(interiorZones, newZone)
    
    -- Sync with all clients
    TriggerClientEvent("interior_zone_manager:syncZones", -1, interiorZones)
    
    DebugPrint("Registered new zone: " .. name)
    return true
end

-- Function to remove an interior zone
function RemoveServerZone(name)
    for i, zone in ipairs(interiorZones) do
        if zone.name == name then
            table.remove(interiorZones, i)
            
            -- Sync with all clients
            TriggerClientEvent("interior_zone_manager:syncZones", -1, interiorZones)
            
            DebugPrint("Removed zone: " .. name)
            return true
        end
    end
    
    DebugPrint("Failed to remove zone: Zone not found")
    return false
end

-- Function to get all interior zones
function GetAllZones()
    return interiorZones
end

-- Function to get a specific zone by name
function GetZoneByName(name)
    for _, zone in ipairs(interiorZones) do
        if zone.name == name then
            return zone
        end
    end
    
    return nil
end

-- Initialize zones from config
Citizen.CreateThread(function()
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
                data = zone.data,
                interactions = zone.interactions
            }
        )
    end
    
    DebugPrint("Initialized " .. #interiorZones .. " interior zones")
end)

-- Event handlers
RegisterNetEvent("interior_zone_manager:enterZone")
AddEventHandler("interior_zone_manager:enterZone", function(zoneName, hasAccess)
    local source = source
    local playerName = GetPlayerName(source)
    
    DebugPrint("Player " .. playerName .. " entered zone: " .. zoneName .. ", Access: " .. tostring(hasAccess))
    
    -- Trigger event for other resources
    TriggerEvent("interior_zone_manager:playerEnteredZone", source, zoneName, hasAccess)
end)

RegisterNetEvent("interior_zone_manager:exitZone")
AddEventHandler("interior_zone_manager:exitZone", function(zoneName)
    local source = source
    local playerName = GetPlayerName(source)
    
    DebugPrint("Player " .. playerName .. " exited zone: " .. zoneName)
    
    -- Trigger event for other resources
    TriggerEvent("interior_zone_manager:playerExitedZone", source, zoneName)
end)

RegisterNetEvent("interior_zone_manager:interaction")
AddEventHandler("interior_zone_manager:interaction", function(action, zoneName)
    local source = source
    local playerName = GetPlayerName(source)
    
    DebugPrint("Player " .. playerName .. " performed action: " .. action .. " in zone: " .. zoneName)
    
    -- Trigger event for other resources
    TriggerEvent("interior_zone_manager:playerInteraction", source, action, zoneName)
    
    -- Handle specific interactions
    if action == "police_info" then
        -- Handle police info request
        TriggerClientEvent("interior_zone_manager:notification", source, "The police officer provides information about recent criminal activity.")
    elseif action == "police_report" then
        -- Handle police report
        TriggerClientEvent("interior_zone_manager:notification", source, "Your report has been filed. An officer will investigate.")
    elseif action == "hospital_treatment" then
        -- Handle hospital treatment
        TriggerClientEvent("interior_zone_manager:notification", source, "The doctor treats your injuries.")
        -- Heal the player
        TriggerClientEvent("interior_zone_manager:healPlayer", source)
    end
end)

-- Command to create a zone at player's position
RegisterCommand("createzone", function(source, args, rawCommand)
    if source == 0 then
        print("This command can only be used in-game.")
        return
    end
    
    -- Check if player has permission
    local hasPermission = IsPlayerAceAllowed(source, "command.createzone")
    if not hasPermission then
        TriggerClientEvent("interior_zone_manager:notification", source, "~r~You don't have permission to use this command.")
        return
    end
    
    if #args < 2 then
        TriggerClientEvent("interior_zone_manager:notification", source, "Usage: /createzone [name] [type] [radius]")
        return
    end
    
    local zoneName = args[1]
    local zoneType = args[2]
    local zoneRadius = tonumber(args[3]) or 25.0
    
    -- Get player position
    TriggerClientEvent("interior_zone_manager:getPlayerPosition", source)
    
    -- Wait for position callback
    RegisterNetEvent("interior_zone_manager:returnPlayerPosition")
    AddEventHandler("interior_zone_manager:returnPlayerPosition", function(position)
        -- Create zone at player position
        local success = RegisterServerZone(
            zoneName,
            position,
            {
                radius = zoneRadius,
                type = zoneType,
                showBlip = true,
                blipName = zoneName
            }
        )
        
        if success then
            TriggerClientEvent("interior_zone_manager:notification", source, "Zone created: " .. zoneName)
        else
            TriggerClientEvent("interior_zone_manager:notification", source, "~r~Failed to create zone.")
        end
    end)
end, false)

-- Command to remove a zone
RegisterCommand("removezone", function(source, args, rawCommand)
    if source == 0 then
        print("This command can only be used in-game.")
        return
    end
    
    -- Check if player has permission
    local hasPermission = IsPlayerAceAllowed(source, "command.removezone")
    if not hasPermission then
        TriggerClientEvent("interior_zone_manager:notification", source, "~r~You don't have permission to use this command.")
        return
    end
    
    if #args < 1 then
        TriggerClientEvent("interior_zone_manager:notification", source, "Usage: /removezone [name]")
        return
    end
    
    local zoneName = args[1]
    
    -- Remove zone
    local success = RemoveServerZone(zoneName)
    
    if success then
        TriggerClientEvent("interior_zone_manager:notification", source, "Zone removed: " .. zoneName)
    else
        TriggerClientEvent("interior_zone_manager:notification", source, "~r~Failed to remove zone: Zone not found.")
    end
end, false)

-- Command to list all zones
RegisterCommand("listzones", function(source, args, rawCommand)
    if source == 0 then
        -- Console output
        print("Interior Zones:")
        for i, zone in ipairs(interiorZones) do
            print(i .. ". " .. zone.name .. " (" .. zone.type .. ")")
        end
    else
        -- Check if player has permission
        local hasPermission = IsPlayerAceAllowed(source, "command.listzones")
        if not hasPermission then
            TriggerClientEvent("interior_zone_manager:notification", source, "~r~You don't have permission to use this command.")
            return
        end
        
        -- Player output
        TriggerClientEvent("interior_zone_manager:notification", source, "Interior Zones:")
        for i, zone in ipairs(interiorZones) do
            TriggerClientEvent("interior_zone_manager:notification", source, i .. ". " .. zone.name .. " (" .. zone.type .. ")")
        end
    end
end, false)

-- Command to teleport to a zone
RegisterCommand("gotozone", function(source, args, rawCommand)
    if source == 0 then
        print("This command can only be used in-game.")
        return
    end
    
    -- Check if player has permission
    local hasPermission = IsPlayerAceAllowed(source, "command.gotozone")
    if not hasPermission then
        TriggerClientEvent("interior_zone_manager:notification", source, "~r~You don't have permission to use this command.")
        return
    end
    
    if #args < 1 then
        TriggerClientEvent("interior_zone_manager:notification", source, "Usage: /gotozone [name]")
        return
    end
    
    local zoneName = args[1]
    local zone = GetZoneByName(zoneName)
    
    if zone then
        -- Teleport player to zone
        TriggerClientEvent("interior_zone_manager:teleportToZone", source, zone.center)
    else
        TriggerClientEvent("interior_zone_manager:notification", source, "~r~Zone not found: " .. zoneName)
    end
end, false)

-- Export functions
exports('RegisterServerZone', RegisterServerZone)
exports('RemoveServerZone', RemoveServerZone)
exports('GetAllZones', GetAllZones)
exports('GetZoneByName', GetZoneByName)
