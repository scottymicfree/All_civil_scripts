-- Fix Interior Zones Script
-- This script resolves conflicts between interior zones

-- List of interior zones that might conflict
local interiorZones = {
    -- FIB Building
    {
        name = "FIB Building",
        coords = vector3(136.0, -761.0, 45.0),
        radius = 50.0,
        priority = 10,
        interiorId = 136802
    },
    
    -- Biker Clubhouses
    {
        name = "Biker Clubhouse 1",
        coords = vector3(1107.04, -3157.399, -37.51),
        radius = 30.0,
        priority = 10,
        interiorId = 246273
    },
    {
        name = "Biker Clubhouse 2",
        coords = vector3(998.4809, -3164.711, -38.90),
        radius = 30.0,
        priority = 10,
        interiorId = 246529
    },
    {
        name = "Biker Clubhouse 3",
        coords = vector3(1121.897, -3195.338, -40.40),
        radius = 30.0,
        priority = 10,
        interiorId = 246785
    },
    
    -- Bunker
    {
        name = "Bunker Interior",
        coords = vector3(899.5518, -3246.038, -98.04907),
        radius = 50.0,
        priority = 10,
        interiorId = 258561
    },
    
    -- Nightclub
    {
        name = "Nightclub Interior",
        coords = vector3(-1604.664, -3012.583, -78.00),
        radius = 50.0,
        priority = 10,
        interiorId = 271617
    },
    
    -- CEO Offices
    {
        name = "CEO Office 1",
        coords = vector3(-141.1987, -620.913, 167.8205),
        radius = 30.0,
        priority = 10,
        interiorId = 236801
    },
    {
        name = "CEO Office 2",
        coords = vector3(-75.8466, -826.9893, 242.3859),
        radius = 30.0,
        priority = 10,
        interiorId = 237057
    },
    {
        name = "CEO Office 3",
        coords = vector3(-1579.756, -565.0661, 107.6229),
        radius = 30.0,
        priority = 10,
        interiorId = 237313
    },
    
    -- Apartments
    {
        name = "Mid-End Apartment",
        coords = vector3(-786.8663, 315.7642, 216.6385),
        radius = 30.0,
        priority = 10,
        interiorId = 146689
    },
    {
        name = "High-End Apartment",
        coords = vector3(-786.9563, 315.6229, 186.9136),
        radius = 30.0,
        priority = 10,
        interiorId = 147201
    },
    
    -- Casino
    {
        name = "Diamond Casino",
        coords = vector3(1100.000, 220.000, -50.000),
        radius = 100.0,
        priority = 10,
        interiorId = 275201
    },
    {
        name = "Diamond Casino Penthouse",
        coords = vector3(976.6364, 70.29476, 115.1641),
        radius = 50.0,
        priority = 10,
        interiorId = 274689
    }
}

-- Variables
local activeInteriorZone = nil
local debugMode = false

-- Function to get the highest priority interior zone at a position
function GetInteriorZoneAtPosition(coords)
    local highestPriority = -1
    local activeZone = nil
    
    for _, zone in ipairs(interiorZones) do
        local distance = #(coords - zone.coords)
        if distance <= zone.radius and zone.priority > highestPriority then
            highestPriority = zone.priority
            activeZone = zone
        end
    end
    
    return activeZone
end

-- Function to apply interior settings
function ApplyInteriorSettings(zone)
    if not zone or not zone.interiorId then return end
    
    -- Get interior ID
    local interiorId = zone.interiorId
    
    -- Refresh interior
    RefreshInterior(interiorId)
    
    if debugMode then
        print("Applied settings for interior: " .. zone.name .. " (ID: " .. interiorId .. ")")
    end
end

-- Main thread to check player position
Citizen.CreateThread(function()
    -- Wait for resource to fully start
    Citizen.Wait(1000)
    
    while true do
        -- Get player position
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        
        -- Get interior zone at player position
        local zone = GetInteriorZoneAtPosition(playerCoords)
        
        -- If zone changed
        if zone ~= activeInteriorZone then
            -- Exit previous zone
            if activeInteriorZone then
                if debugMode then
                    print("Exited interior zone: " .. activeInteriorZone.name)
                end
                
                -- Trigger exit event
                TriggerEvent("fix_interior_zones:exitedZone", activeInteriorZone.name, activeInteriorZone)
            end
            
            -- Enter new zone
            if zone then
                if debugMode then
                    print("Entered interior zone: " .. zone.name)
                end
                
                -- Apply interior settings
                ApplyInteriorSettings(zone)
                
                -- Trigger enter event
                TriggerEvent("fix_interior_zones:enteredZone", zone.name, zone)
            end
            
            -- Update active zone
            activeInteriorZone = zone
        end
        
        -- Wait before next check
        Citizen.Wait(1000) -- Check every second
    end
end)

-- Debug command
RegisterCommand("interiorzone_debug", function()
    debugMode = not debugMode
    
    if debugMode then
        -- Show current zone
        local playerCoords = GetEntityCoords(PlayerPedId())
        local zone = GetInteriorZoneAtPosition(playerCoords)
        
        if zone then
            print("Current interior zone: " .. zone.name)
        else
            print("Not in any interior zone")
        end
    end
    
    TriggerEvent('fxcode:utils:notify', "Interior zone debug mode: " .. (debugMode and "Enabled" or "Disabled"), "info")
end, false)

-- Register interior zones with zone manager if available
Citizen.CreateThread(function()
    -- Wait for zone manager to be ready
    Citizen.Wait(2000)
    
    -- Check if zone manager is available
    if exports['zone_manager'] then
        for _, zone in ipairs(interiorZones) do
            -- Register zone with zone manager
            exports['zone_manager']:RegisterInteriorZone(
                zone.name,
                zone.coords,
                zone.radius,
                zone.priority,
                "interior",
                {
                    interiorId = zone.interiorId
                }
            )
            
            if debugMode then
                print("Registered interior zone with zone manager: " .. zone.name)
            end
        end
    end
end)