-- Server-side turf update broadcaster

RegisterNetEvent("gangzones:takeover", function(zoneName, newOwner, newColor)
    TriggerClientEvent("gangzones:updateZone", -1, zoneName, newOwner, newColor)
    print(("[GangZones] %s has taken over %s (color ID %s)"):format(newOwner, zoneName, newColor))
end)

AddEventHandler("gangzones:takeover", function(zoneName, newOwner, newColor)
    local src = source
    TriggerClientEvent("gangzones:updateZone", -1, zoneName, newOwner, newColor)
    TriggerClientEvent("gangzones:rewardPlayer", src)
end)

local zoneCooldowns = {}
local turfWins = {}

RegisterNetEvent("gangzones:takeover", function(zoneName, newOwner, newColor)
    local src = source
    if zoneCooldowns[zoneName] and zoneCooldowns[zoneName] > os.time() then
        TriggerClientEvent("chat:addMessage", src, {
            color = {255, 100, 0},
            args = {"Gang Wars", "This turf is under cooldown. Come back later!"}
        })
        return
    end

    -- Broadcast map update + reward
    TriggerClientEvent("gangzones:updateZone", -1, zoneName, newOwner, newColor)
    TriggerClientEvent("gangzones:rewardPlayer", src)

    -- Notification to all
    TriggerClientEvent("chat:addMessage", -1, {
        color = {255, 0, 0},
        args = {"Gang Wars", ("%s has captured %s Turf!"):format(newOwner, zoneName)}
    })

    -- Cooldown: 10 minutes
    zoneCooldowns[zoneName] = os.time() + 600

    -- Turf win stats
    if not turfWins[src] then turfWins[src] = 0 end
    turfWins[src] = turfWins[src] + 1
end)

RegisterCommand("gangstats", function(source)
    local wins = turfWins[source] or 0
    TriggerClientEvent("chat:addMessage", source, {
        color = {255, 255, 0},
        args = {"Gang Wars", ("You have %s turf wins."):format(wins)}
    })
end, false)

RegisterNetEvent("gang:warcry", function()
    local src = source
    local players = GetPlayers()
    local coords = GetEntityCoords(GetPlayerPed(src))
    local gang = GetPlayerRoutingBucket(src)

    for _, id in pairs(players) do
        local ped = GetPlayerPed(id)
        local dist = #(coords - GetEntityCoords(ped))
        if dist < 20.0 and id ~= src then
            TriggerClientEvent("gang:playwarcry", id)
        end
    end
end)
