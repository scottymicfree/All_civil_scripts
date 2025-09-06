print("[MAIN] Server script loaded.")

RegisterNetEvent("civil_unrest_radial:setGang")
AddEventHandler("civil_unrest_radial:setGang", function(gang)
    local src = source
    TriggerEvent("myframework:setjob", src, gang)
    TriggerClientEvent("fxcode:utils:notify", src, "You joined the " .. gang .. " gang!", "success")
end)

RegisterNetEvent("turf:entered")
AddEventHandler("turf:entered", function(turfName)
    local src = source
    print("[MAIN] Player " .. src .. " entered turf: " .. turfName)
end)

RegisterNetEvent("turf:left")
AddEventHandler("turf:left", function(turfName)
    local src = source
    print("[MAIN] Player " .. src .. " left turf: " .. turfName)
end)

RegisterNetEvent("safezone:entered")
AddEventHandler("safezone:entered", function(zoneName)
    local src = source
    print("[MAIN] Player " .. src .. " entered safe zone: " .. zoneName)
end)

RegisterNetEvent("safezone:left")
AddEventHandler("safezone:left", function(zoneName)
    local src = source
    print("[MAIN] Player " .. src .. " left safe zone: " .. zoneName)
end)

RegisterNetEvent("gangzones:takeover")
AddEventHandler("gangzones:takeover", function(turfName, gang, reward)
    local src = source
    TriggerEvent("myframework:addMoney", src, 250)
    print("[MAIN] Player " .. src .. " took over turf: " .. turfName .. " for gang: " .. gang)
end)