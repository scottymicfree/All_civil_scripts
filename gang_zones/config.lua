-- Gang Zone Config
GangZones = {
    {
        name = "Red Hood",
        center = vector3(-1604.66, -3012.58, 13.94),
        radius = 150.0,
        owner = "redgang",
        color = 1, -- Red
        jobs = {"ems"}, -- Jobs that use this zone
        spawnPriority = 3
    },
    {
        name = "Eastside Ballas",
        center = vector3(1142.54, -1522.71, 34.84),
        radius = 125.0,
        owner = "ballas",
        color = 7, -- Purple
        jobs = {"police"},
        spawnPriority = 3
    },
    {
        name = "Vagos Turf",
        center = vector3(333.84, -2040.52, 21.07),
        radius = 100.0,
        owner = "vagos",
        color = 5, -- Yellow
        jobs = {"drugdealer"},
        spawnPriority = 5
    }
}

-- Export: Get all gang zones
function GetGangZones()
    return GangZones
end

-- Export: Get zone by name
function GetZoneByName(name)
    for _, zone in ipairs(GangZones) do
        if zone.name == name then
            return zone
        end
    end
    return nil
end

-- Export: Get the zone a player is in
function GetPlayerZone(coords)
    for _, zone in ipairs(GangZones) do
        local distance = #(coords - zone.center)
        if distance <= zone.radius then
            return zone
        end
    end
    return nil
end