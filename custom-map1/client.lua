-- Interior Zone Manager Client Script  
-- Dependencies: config.lua

local Config = {}
local interiorZones = {}
local activeZone = nil
local previousZone = nil
local playerInZone = false
local blips = {}

-- Debug function
local function DebugPrint(message)
    if Config.Debug then      
        print("[Interior Zone Manager] " .. message)
    end
end

-- Function to create a zone blip
local function CreateZoneBlip(zone)   
    if not zone.showBlip then return end   
    local zoneType = Config.ZoneTypes[zone.type] or {}
    local blip = AddBlipForCoord(zone.center.x, zone.center.y, zone.center.z)
    SetBlipSprite(blip, zone.blipSprite or zoneType.blipSprite or Config.DefaultZoneSettings.blipSprite)
    SetBlipColour(blip, zone.blipColor or zoneType.blipColor or Config.DefaultZoneSettings.blipColor)
    SetBlipScale(blip, zone.blipScale or zoneType.blipScale or Config.DefaultZoneSettings.blipScale)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(zone.blipName or zoneType.blipName or zone.name or Config.DefaultZoneSettings.blipName)
    EndTextCommandSetBlipName(blip)
    return blip
end

-- Function to check if player is in a zone
local function IsPlayerInZone(zone)
    local playerCoords = GetEntityCoords(PlayerPedId())
    -- Box zone check (width, length, height)
    if zone.width and zone.length then
        local halfWidth = zone.width / 2
        local halfLength = zone.length / 2
        local minZ = zone.minZ or (zone.center.z - (zone.height or 10.0) / 2)
        local maxZ = zone.maxZ or (zone.center.z + (zone.height or 10.0) / 2)
        -- Check if player is within the box boundaries
        return (
            playerCoords.x >= zone.center.x - halfWidth and
            playerCoords.x <= zone.center.x + halfWidth and
            playerCoords.y >= zone.center.y - halfLength and
            playerCoords.y <= zone.center.y + halfLength and
            playerCoords.z >= minZ and
            playerCoords.z <= maxZ
        )
    end
    -- Circle zone check (radius)
    if zone.radius then
        local distance = #(playerCoords - zone.center)
        local minZ = zone.minZ or (zone.center.z - (zone.height or 10.0) / 2)
        local maxZ = zone.maxZ or (zone.center.z + (zone.height or 10.0) / 2)
        -- Check if player is within the circle boundaries
        return (
            distance <= zone.radius and
            playerCoords.z >= minZ and
            playerCoords.z <= maxZ
        )
    end
    return false
end

-- Function to check if player has access to a zone
local function HasZoneAccess(zone)
    if not zone.allowedJobs and not (Config.ZoneTypes[zone.type] and Config.ZoneTypes[zone.type].allowedJobs) then
        return true -- No job restrictions
    end
    local allowedJobs = zone.allowedJobs or (Config.ZoneTypes[zone.type] and Config.ZoneTypes[zone.type].allowedJobs)
    if not allowedJobs then return true end
    -- Get player job (replace with your framework's job getter)
    local playerJob = exports["standalone-framework"]:GetPlayerJob()
    for _, job in ipairs(allowedJobs) do
        if playerJob == job then
            return true
        end
    end
    return false
end

-- Function to show notification
local function ShowNotification(message)
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandThefeedPostTicker(true, false)
end

-- Function to register a new interior zone
function RegisterInteriorZone(name, center, options)
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
            -- Update blip if it exists
            if blips[name] then
                RemoveBlip(blips[name])
                blips[name] = CreateZoneBlip(interiorZones[i])
            end
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
    -- Create blip if needed
    if newZone.showBlip then
        blips[name] = CreateZoneBlip(newZone)
    end
    DebugPrint("Registered new zone: " .. name)
    return true
end

-- Function to get active zone at position
function GetActiveZoneAtPosition(position)
    position = position or GetEntityCoords(PlayerPedId())
    for _, zone in ipairs(interiorZones) do
        -- Box zone check
        if zone.width and zone.length then
            local halfWidth = zone.width / 2
            local halfLength = zone.length / 2
            local minZ = zone.minZ or (zone.center.z - (zone.height or 10.0) / 2)
            local maxZ = zone.maxZ or (zone.center.z + (zone.height or 10.0) / 2)
            if (
                position.x >= zone.center.x - halfWidth and
                position.x <= zone.center.x + halfWidth and
                position.y >= zone.center.y - halfLength and
                position.y <= zone.center.y + halfLength and
                position.z >= minZ and
                position.z <= maxZ
            ) then
                return zone
            end
        end
        -- Circle zone check
        if zone.radius then
            local distance = #(position - zone.center)
            local minZ = zone.minZ or (zone.center.z - (zone.height or 10.0) / 2)
            local maxZ = zone.maxZ or (zone.center.z + (zone.height or 10.0) / 2)      
            if (
                distance <= zone.radius and
                position.z >= minZ and
                position.z <= maxZ
            ) then
                return zone
            end
        end
    end
    return nil
end

-- Initialize zones from config
CreateThread(function()
    -- Register pre-defined zones from config
    for _, zone in ipairs(Config.InteriorZones) do
        RegisterInteriorZone(
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

-- Main thread for zone checking
CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local isInAnyZone = false
        local closestZone = nil
        local closestDistance = 9999.0
        -- Check all zones
        for _, zone in ipairs(interiorZones) do
            if IsPlayerInZone(zone) then
                isInAnyZone = true     
                -- Calculate distance to zone center
                local distance = #(playerCoords - zone.center) 
                -- Track closest zone
                if distance < closestDistance then
                    closestDistance = distance
                    closestZone = zone
                end
            end
        end
        -- Handle zone changes
        if closestZone ~= activeZone then
            previousZone = activeZone
            activeZone = closestZone
            -- Exiting previous zone
            if previousZone and Config.Notifications.showEnterExit then
                ShowNotification("Exiting: " .. previousZone.name)
                TriggerEvent("interior_zone_manager:exitZone", previousZone)
                TriggerServerEvent("interior_zone_manager:exitZone", previousZone.name)
            end
            -- Entering new zone
            if activeZone then
                local hasAccess = HasZoneAccess(activeZone)
                if Config.Notifications.showEnterExit then
                    ShowNotification("Entering: " .. activeZone.name)
                end
                if not hasAccess and Config.Notifications.showJobRestricted then
                    ShowNotification("~r~This area is restricted")
                end
                TriggerEvent("interior_zone_manager:enterZone", activeZone, hasAccess)
                TriggerServerEvent("interior_zone_manager:enterZone", activeZone.name, hasAccess)
            end
        end
        -- Update player in zone status
        if isInAnyZone ~= playerInZone then
            playerInZone = isInAnyZone
            TriggerEvent("interior_zone_manager:playerZoneStatusChanged", playerInZone, activeZone)
        end
        -- Adjust wait time based on whether player is in a zone
        if isInAnyZone then
            Wait(500) -- Check more frequently when in a zone
        else
            Wait(1000) -- Check less frequently when not in a zone
        end
    end
end)

-- Debug command to show current zone
RegisterCommand("checkzone", function()
    local zone = GetActiveZoneAtPosition()
    if zone then
        ShowNotification("Current zone: " .. zone.name .. " (" .. zone.type .. ")")
    else
        ShowNotification("Not in any interior zone")
    end
end, false)

-- Event handlers
AddEventHandler("interior_zone_manager:enterZone", function(zone, hasAccess)
    DebugPrint("Entered zone: " .. zone.name .. ", Access: " .. tostring(hasAccess))
end)

AddEventHandler("interior_zone_manager:exitZone", function(zone)
    DebugPrint("Exited zone: " .. zone.name)
end)

-- Register net events
RegisterNetEvent("interior_zone_manager:syncZones")
AddEventHandler("interior_zone_manager:syncZones", function(zones)
    -- Clear existing zones
    for name, blip in pairs(blips) do
        RemoveBlip(blip)
    end
    blips = {}
    -- Update with synced zones
    interiorZones = zones
    -- Recreate blips
    for _, zone in ipairs(interiorZones) do
        if zone.showBlip then
            blips[zone.name] = CreateZoneBlip(zone)
        end
    end
    DebugPrint("Synced " .. #interiorZones .. " zones from server")
end)
