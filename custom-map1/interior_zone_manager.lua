-- Add to interior zone manager
local activeZones = {}

function RegisterInteriorZone(zoneName, coords, radius, priority)
    activeZones[zoneName] = {coords = coords, radius = radius, priority = priority}
end

function GetActiveZoneAtPosition(coords)
    local highestPriority = -1
    local activeZone = nil
    
    for name, zone in pairs(activeZones) do
        local distance = #(coords - zone.coords)
        if distance <= zone.radius and zone.priority > highestPriority then
            highestPriority = zone.priority
            activeZone = name
        end
    end
    
    return activeZone
end