-- Gang Zone Blip Drawer
-- Dependencies: zones.lua

CreateThread(function()
    Wait(1000) -- wait for player load
    for _, zone in pairs(GangZones) do
        -- Draw zone radius
        local blip = AddBlipForRadius(zone.center.x, zone.center.y, zone.center.z, zone.radius)
        SetBlipHighDetail(blip, true)
        SetBlipColour(blip, zone.color)
        SetBlipAlpha(blip, 128)

        -- Add zone label
        local labelBlip = AddBlipForCoord(zone.center.x, zone.center.y, zone.center.z)
        SetBlipSprite(labelBlip, 9)
        SetBlipColour(labelBlip, zone.color)
        SetBlipScale(labelBlip, 0.9)
        SetBlipAsShortRange(labelBlip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(zone.name .. " Turf")
        EndTextCommandSetBlipName(labelBlip)
    end
end)