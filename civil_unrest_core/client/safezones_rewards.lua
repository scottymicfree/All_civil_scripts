-- SAFE ZONE NPCS & BLIPS

CreateThread(function()
    for _, zone in pairs(SafeZones) do
        local blip = AddBlipForRadius(zone.center.x, zone.center.y, zone.center.z, zone.radius)
        SetBlipHighDetail(blip, true)
        SetBlipColour(blip, zone.blip.color)
        SetBlipAlpha(blip, 120)

        local label = AddBlipForCoord(zone.center.x, zone.center.y, zone.center.z)
        SetBlipSprite(label, zone.blip.sprite)
        SetBlipColour(label, zone.blip.color)
        SetBlipScale(label, 0.9)
        SetBlipAsShortRange(label, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(zone.name)
        EndTextCommandSetBlipName(label)

        -- NPC spawn
        local pedModel = zone.type == "police" and "s_m_y_cop_01" or "s_m_m_paramedic_01"
        RequestModel(pedModel)
        while not HasModelLoaded(pedModel) do Wait(0) end
        local npc = CreatePed(4, GetHashKey(pedModel), zone.center.x, zone.center.y, zone.center.z, 90.0, false, true)
        FreezeEntityPosition(npc, true)
        SetEntityInvincible(npc, true)
        SetBlockingOfNonTemporaryEvents(npc, true)
    end
end)

-- Turf win reward logic
RegisterNetEvent("gangzones:rewardPlayer")
AddEventHandler("gangzones:rewardPlayer", function()
    TriggerEvent("chat:addMessage", {
        color = {0, 255, 0},
        args = {"Gang Rewards", "You earned 50 XP and $250 for winning the turf!"}
    })

    -- Example exports (adjust to your framework)
    if exports["xp_system"] then
        exports["xp_system"]:AddXP(50)
    end

    if exports["banking"] then
        exports["banking"]:AddMoney("cash", 250)
    end
end)
