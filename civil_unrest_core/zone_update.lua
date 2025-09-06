
-- GANG ZONE MAP UPDATES + ALERTS

local blipRefs = {}

RegisterNetEvent("gangzones:updateZone")
AddEventHandler("gangzones:updateZone", function(zoneName, newOwner, color)
    for i, zone in ipairs(GangZones) do
        if zone.name == zoneName then
            zone.owner = newOwner
            zone.color = color

            if blipRefs[zoneName] then
                -- Update existing blip color + name
                SetBlipColour(blipRefs[zoneName].radius, color)
                SetBlipColour(blipRefs[zoneName].label, color)

                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString(zone.name .. " - " .. newOwner)
                EndTextCommandSetBlipName(blipRefs[zoneName].label)
            end

            TriggerEvent("chat:addMessage", {
                color = {255, 0, 0},
                multiline = true,
                args = {"Gang Wars", ("%s has taken over %s Turf!"):format(newOwner, zone.name)}
            })
            break
        end
    end
end)

-- Initial draw moved here for control
CreateThread(function()
    Wait(1000)
    for _, zone in pairs(GangZones) do
        local blip = AddBlipForRadius(zone.center.x, zone.center.y, zone.center.z, zone.radius)
        SetBlipHighDetail(blip, true)
        SetBlipColour(blip, zone.color)
        SetBlipAlpha(blip, 128)

        local label = AddBlipForCoord(zone.center.x, zone.center.y, zone.center.z)
        SetBlipSprite(label, 9)
        SetBlipColour(label, zone.color)
        SetBlipScale(label, 0.9)
        SetBlipAsShortRange(label, true)

        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(zone.name .. " Turf")
        EndTextCommandSetBlipName(label)

        blipRefs[zone.name] = {radius = blip, label = label}
    end
end)
Config = {}
Config.GangZones = {
    { name = "Vagos Turf", center = vector3(333.84, -2040.52, 21.07), radius = 100.0, owner = "vagos" },
    -- Add more zones
}
