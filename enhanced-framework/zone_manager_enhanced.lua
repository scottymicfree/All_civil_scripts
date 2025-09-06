-- =============================================================
-- [ zone_manager_enhanced.lua ]
-- Enhanced Interior Zone Management System for resolving zone conflicts
-- Make sure 'ox_lib' is started before this resource in your server.cfg!
-- =============================================================

-- Wait for ox_lib to be ready
while not lib do
    Wait(100)
end

local ZoneManager = {}
ZoneManager.ActiveZones = {}
ZoneManager.RegisteredZones = {}
ZoneManager.CurrentInterior = nil
ZoneManager.CurrentZone = nil
ZoneManager.ZoneTypes = {
    INTERIOR = "interior",
    TURF = "turf",
    SAFE = "safe",
    RESTRICTED = "restricted",
    CUSTOM = "custom"
}

-- Zone priority levels (higher number = higher priority)
ZoneManager.PriorityLevels = {
    LOW = 1,
    MEDIUM = 5,
    HIGH = 10,
    CRITICAL = 100
}

-- Function to register a new zone
function ZoneManager.RegisterZone(name, center, radius, type, priority, data)
    if ZoneManager.RegisteredZones[name] then
        print("Warning: Zone '" .. name .. "' already registered. Updating properties.")
    end

    ZoneManager.RegisteredZones[name] = {
        name = name,
        center = center,
        radius = radius,
        type = type or ZoneManager.ZoneTypes.CUSTOM,
        priority = priority or ZoneManager.PriorityLevels.MEDIUM,
        data = data or {},
        active = false
    }

    print("Zone registered: " .. name)
    return ZoneManager.RegisteredZones[name]
end

-- (The rest of your ZoneManager code is well-structured and should work once ox_lib is loaded)
-- ... (all your other ZoneManager functions) ...

-- Main thread to update zones
CreateThread(function()
    -- Register default zones
    ZoneManager.RegisterDefaultZones()

    -- Create blips for zones
    ZoneManager.CreateZoneBlips()

    -- Main loop
    while true do
        local changed = ZoneManager.UpdateActiveZones()

        -- If zones changed, wait a short time, otherwise wait longer
        if changed then
            Wait(100)
        else
            Wait(1000)
        end
    end
end)

-- Debug command to show current zone info
RegisterCommand("zonedebug", function()
    local playerPed = PlayerPedId()
    if not playerPed then return end
    local playerCoords = GetEntityCoords(playerPed)
    local zones = ZoneManager.GetZonesAtPoint(playerCoords)

    print("Player position: " .. tostring(playerCoords))
    print("Active zones: " .. #zones)

    for i, zone in ipairs(zones) do
        print(i .. ". " .. zone.name .. " (Type: " .. zone.type .. ", Priority: " .. zone.priority .. ")")
    end

    if ZoneManager.CurrentZone then
        print("Current highest priority zone: " .. ZoneManager.CurrentZone.name)
    else
        print("Not in any zone")
    end

    if ZoneManager.CurrentInterior then
        print("Current interior: " ..
        ZoneManager.CurrentInterior.zone .. " (ID: " .. ZoneManager.CurrentInterior.id .. ")")
    else
        print("Not in any interior")
    end
end, false)

-- Export the ZoneManager
exports('GetZoneManager', function()
    return ZoneManager
end)
