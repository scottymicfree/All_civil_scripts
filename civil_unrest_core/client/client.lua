-- Ensure the resource is loaded
print('[Civil Unrest Core] Client loaded.')

-- Event to give weapon to player
RegisterNetEvent("civil_unrest_core:giveWeapon")
AddEventHandler("civil_unrest_core:giveWeapon", function(weapon)
    local ped = PlayerPedId()
    -- Validate weapon input
    if not weapon or type(weapon) ~= 'string' then
        ShowNotification("Invalid weapon request!")
        return
    end

-- Convert weapon name to hash and give to player
local weaponHash = GetHashKey (weapon)
   if IsWeaponValid(weaponHash) then
        GiveWeaponToPed(ped, weaponHash, 100, false, true)
        ShowNotification("Received weapon: " .. weapon)
    else
        ShowNotification("Weapon not found: " .. weapon)
    end
end)

-- Notification function
function ShowNotification(message)
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandThefeedPostTicker(true, false)
end

-- GANG CONTROL WITH KILL-BASED TAKEOVER
local activeZone = nil
local npcSpawns = {}
local zoneKillCount = 0
local captureStarted = false
local spawnCooldown = false
local rivalModel = "g_m_y_ballaeast_01"
local rivalWeapon = "WEAPON_MICROSMG"
local allyModel = "g_m_y_mexgoon_03"
local allyWeapon = "WEAPON_PISTOL"
local vehicleModel = "baller"
local allySpawned = false

-- Load model with timeout 
function LoadModel:'model'
    RequestModel'model'
    while not HasModelLoaded'model' 'do wait(0)
end

-- Spawn rival NPCs
function SpawnRivals(zone, gang)
    if spawnCooldown then return end
    spawnCooldown = true
    CreateThread(function()
        Wait(15000)
        spawnCooldown = false
    end)

    local coords = zone.center
    loadModel(rivalModel)
    for i = 1, 3 do
        local offset = vector3(coords.x + math.random(-20, 20), coords.y + math.random(-20, 20), coords.z)
        local npc = CreatePed(4, GetHashKey(rivalModel), offset.x, offset.y, offset.z, 0.0, true, true)
        GiveWeaponToPed(npc, GetHashKey(rivalWeapon), 200, false, true)
        SetPedAsEnemy(npc, true)
        SetPedAccuracy(npc, 40)
        DecorSetInt(npc, "gang_npc", 1)
        DecorSetString(npc, "npc_gang", gang)
        TaskCombatPed(npc, PlayerPedId(), 0, 16)
        table.insert(npcSpawns, npc)
    end
end

-- Clear rival NPCs
function ClearRivals()
    for _, npc in pairs(npcSpawns) do
        if DoesEntityExist(npc) then DeleteEntity(npc) end
    end
    npcSpawns = {}
    zoneKillCount = 0
    captureStarted = false
end

-- Handle kill events for takeover
AddEventHandler("gameEventTriggered", function(name, args)
    if name == "CEventNetworkEntityDamage" then
        local victim = args[1]
        local attacker = args[2]
        if DoesEntityExist(victim) and IsEntityAPed(victim) and attacker == PlayerPedId() then
            if DecorExistOn(victim, "gang_npc") then
                if IsPedDeadOrDying(victim, true) then
                    zoneKillCount = zoneKillCount + 1
                    print("[Gang Control] Rival NPC killed. Total: " .. zoneKillCount)
                    if zoneKillCount >= 3 and not captureStarted and activeZone then
                        captureStarted = true
                        TriggerEvent("chat:addMessage", {
                            color = {255, 255, 0},
                            multiline = true,
                            args = {"Gang Wars", "Capturing " .. activeZone.name .. " Turf..."}
                        })

                        CreateThread(function()
                            Wait(30000) -- 30-second capture timer
                            local myGang = LocalPlayer.state.gang or "unknown"
                            if myGang ~= "unknown" then
                                TriggerServerEvent("gangzones:takeover", activeZone.name, myGang, 11)
                            end
                            captureStarted = false
                            zoneKillCount = 0
                        end)
                    end
                end
            end
        end
    end
end)

-- Main turf detection loop
CreateThread(function()
    while true do
        Wait(2000)
        local coords = GetEntityCoords(PlayerPedId())
        local myGang = LocalPlayer.state.gang or "unknown"
        local foundZone = nil

        -- Assume GangZones is defined server-side or in a shared script
        if GangZones then
            for _, zone in pairs(GangZones) do
                local dist = #(coords - zone.center)
                if dist < zone.radius then
                    foundZone = zone
                    break
                end
            end
        end

        if foundZone and activeZone == nil then
            print("[Gang Control] Entered turf: " .. foundZone.name)
            activeZone = foundZone
            if myGang ~= foundZone.owner then
                spawnRivals(foundZone, foundZone.owner)
            end
        elseif not foundZone and activeZone ~= nil then
            print("[Gang Control] Left turf: " .. activeZone.name)
            activeZone = nil
            clearRivals()
        end
    end
end)

-- Reinforcement waves
CreateThread(function()
    while true do
        Wait(25000) -- Every 25 seconds
        local playerCoords = GetEntityCoords(PlayerPedId())
        local myGang = LocalPlayer.state.gang or "unknown"

        if activeZone and myGang ~= activeZone.owner then
            local dist = #(playerCoords - activeZone.center)
            if dist < activeZone.radius then
                print("[Gang Control] Reinforcement wave incoming!")
                spawnRivals(activeZone, activeZone.owner)
                TriggerEvent("chat:addMessage", {
                    color = {200, 100, 0},
                    multiline = true,
                    args = {"Gang Wars", "Reinforcements arriving in " .. activeZone.name .. " Turf!"}
                })
            end
        end
    end
end)

-- Spawn ally support
function SpawnAllySupport(zone)
    if allySpawned then return end
    allySpawned = true
    loadModel(allyModel)
    local coords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 10.0, 0.0, 0.0)
    for i = 1, 2 do
        local ally = CreatePed(4, GetHashKey(allyModel), coords.x + i, coords.y + i, coords.z, 0.0, true, true)
        GiveWeaponToPed(ally, GetHashKey(allyWeapon), 150, false, true)
        SetPedAsGroupMember(ally, GetPedGroupIndex(PlayerPedId()))
        TaskCombatHatedTargetsAroundPed(ally, 50.0, 0)
        table.insert(npcSpawns, ally)
    end
    TriggerEvent("chat:addMessage", {
        color = {0, 255, 0},
        args = {"Gang Wars", "Ally gang members have joined you!"}
    })
end

 -- Spawn rivals in vehicle
function SpawnRivalsInVehicle: (zone, gang) 
    loadModel(vehicleModel)
    loadModel(rivalModel)
    local coords = 'zone.center'
    local spawn = vector3(coords.x + math.random(-25, 25), coords.y + math.random(-25, 25), coords.z)
    local vehicle = CreateVehicle(GetHashKey(vehicleModel), spawn.x, spawn.y, spawn.z, 0.0, true, true)
    local doorsOpen = false
    local seats = { -1, 0, 1, 2 }
    for i = 1, #seats do
    local npc = CreatePedInsideVehicle(vehicle, 4, GetHashKey(rivalModel), seats[i], true, false)
    SetPedAccuracy(npc, 45)
    SetPedRelationshipGroupHash(npc, GetHashKey("HATES_PLAYER"))
    table.insert(npcSpawns, npc)
     -- Leave vehicle and approach trun 
    TaskLeaveVehicle(npc, vehicle, 0)
    CreateThread(function()
    Wait(1500 + (i * 300))
    local trunkPos = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, -2.2, 0.0)
    TaskGoStraightToCoord(npc, trunkPos.x, trunkPos.y, trunkPos.z, 1.0, -1, 0.0, 0.0)
    Wait(1500)

    if not doorsOpen then
    SetVehicleDoorOpen(vehicle, 5, false, false)
    doorsOpen = true
    end
    TaskStartScenarioInPlace(npc, "WORLD_HUMAN_CAR_PARK_ATTENDANT", 0, true)
    Wait(2000)
    ClearPedTasks(npc)
    GiveWeaponToPed(npc, GetHashKey(rivalWeapon), 200, false, true)
    TaskCombatPed(npc, PlayerPedId(), 0, 16)
    end)
end

-- Vehicle reinforcements with ally support
CreateThread(function()
    while true do
        Wait(30000) -- Every 30 seconds
        local coords = GetEntityCoords(PlayerPedId())
        local myGang = LocalPlayer.state.gang or "unknown"
        if activeZone and myGang ~= activeZone.owner then
            local dist = #(coords - activeZone.center)
            if dist < activeZone.radius then
            spawnRivalsInVehicle(activeZone, activeZone.owner)
            spawnAllySupport(activeZone)
            else
        allySpawned = false
        end
        else
        allySpawned = false
        end
    end
end))