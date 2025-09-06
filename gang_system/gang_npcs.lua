-- gang_npcs.lua
-- Handles gang NPC spawning, behavior, and interactions

-- NPC behavior states
local NPC_STATE = {
    IDLE = 1,
    PATROL = 2,
    COMBAT = 3,
    FLEE = 4
}

-- NPC scenarios for idle behavior
local idleScenarios = {
    "WORLD_HUMAN_SMOKING",
    "WORLD_HUMAN_STAND_IMPATIENT",
    "WORLD_HUMAN_HANG_OUT_STREET",
    "WORLD_HUMAN_DRINKING",
    "WORLD_HUMAN_LEANING"
}

-- Active NPCs
local activeNPCs = {}
local spawnedVehicles = {}
local playerGang = nil
local inCombat = false
local lastSpawnTime = 0
local spawnCooldown = 300000 -- 5 minutes
local debugMode = Config.DebugMode or false

-- Function to get player's gang
function GetPlayerGang()
    if not playerGang then
        local success, result = pcall(function()
            return exports['standalone-framework']:GetPlayerGang()
        end)
        
        if success then
            playerGang = result
        else
            print("[Gang System] Error getting player gang: " .. tostring(result))
        end
    end
    return playerGang
end

-- Function to spawn gang NPCs in territory
function SpawnGangNPCs(gangId, count)
    if not gangId or not Config.Gangs[gangId] then return end
    
    -- Check cooldown
    local currentTime = GetGameTimer()
    if currentTime - lastSpawnTime < spawnCooldown then
        return
    end
    
    -- Set spawn count
    count = count or math.random(2, 4)
    
    -- Get models for this gang
    local models = {
        ballas = {"g_m_y_ballasout_01", "g_m_y_ballaeast_01", "g_f_y_ballas_01"},
        vagos = {"g_m_y_mexgoon_01", "g_m_y_mexgoon_02", "g_f_y_vagos_01"},
        families = {"g_m_y_famca_01", "g_m_y_famdnf_01", "g_f_y_families_01"},
        biker = {"g_m_y_lost_01", "g_m_y_lost_02", "g_m_y_lost_03"}
    }
    
    if not models[gangId] then return end
    
    -- Get weapons for this gang
    local weapons = {
        ballas = {"WEAPON_PISTOL", "WEAPON_MICROSMG", "WEAPON_BAT"},
        vagos = {"WEAPON_PISTOL", "WEAPON_MACHINEPISTOL", "WEAPON_KNIFE"},
        families = {"WEAPON_PISTOL", "WEAPON_MICROSMG", "WEAPON_CROWBAR"},
        biker = {"WEAPON_PISTOL", "WEAPON_SAWNOFFSHOTGUN", "WEAPON_WRENCH"}
    }
    
    if not weapons[gangId] then return end
    
    -- Get spawn points
    local spawnPoint = Config.Gangs[gangId].spawnPoint
    if not spawnPoint then return end
    
    -- Spawn NPCs
    local spawnedCount = 0
    for i = 1, count do
        -- Calculate offset position
        local offset = vector3(
            math.random(-10, 10) * 1.0,
            math.random(-10, 10) * 1.0,
            0.0
        )
        
        local finalPos = vector3(
            spawnPoint.x + offset.x,
            spawnPoint.y + offset.y,
            spawnPoint.z
        )
        
        -- Get random model
        local model = models[gangId][math.random(#models[gangId])]
        
        -- Request model
        RequestModel(GetHashKey(model))
        local timeout = 5000
        local startTime = GetGameTimer()
        while not HasModelLoaded(GetHashKey(model)) do
            if GetGameTimer() - startTime > timeout then
                if debugMode then
                    print("[Gang System] Failed to load model: " .. model)
                end
                break
            end
            Citizen.Wait(100)
        end
        
        -- Spawn NPC
        local ped = CreatePed(4, GetHashKey(model), finalPos.x, finalPos.y, finalPos.z, math.random(0, 359) * 1.0, true, false)
        
        if DoesEntityExist(ped) then
            -- Set NPC properties
            SetPedArmour(ped, math.random(0, 50))
            SetPedAccuracy(ped, math.random(30, 70))
            SetPedCombatAttributes(ped, 46, true) -- BF_CanFightArmedPedsWhenNotArmed
            SetPedCombatAttributes(ped, 5, true) -- BF_AlwaysFight
            SetPedCombatRange(ped, 2) -- Medium range
            SetPedCombatMovement(ped, 2) -- Defensive
            SetPedRelationshipGroupHash(ped, GetHashKey("GANG_" .. string.upper(gangId)))
            
            -- Give weapon
            local weapon = weapons[gangId][math.random(#weapons[gangId])]
            GiveWeaponToPed(ped, GetHashKey(weapon), 100, false, true)
            
            -- Set idle behavior
            local scenario = idleScenarios[math.random(#idleScenarios)]
            TaskStartScenarioInPlace(ped, scenario, 0, true)
            
            -- Store NPC data
            table.insert(activeNPCs, {
                ped = ped,
                gang = gangId,
                state = NPC_STATE.IDLE,
                spawnTime = GetGameTimer()
            })
            
            spawnedCount = spawnedCount + 1
        else
            if debugMode then
                print("[Gang System] Failed to spawn NPC for gang: " .. gangId)
            end
        end
    end
    
    -- Update spawn time
    if spawnedCount > 0 then
        lastSpawnTime = GetGameTimer()
        if debugMode then
            print("[Gang System] Spawned " .. spawnedCount .. " NPCs for gang: " .. gangId)
        end
    end
    
    return spawnedCount
end

-- Function to spawn gang vehicle
function SpawnGangVehicle(gangId, model)
    if not gangId or not model then return nil end
    
    -- Get player position
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local heading = GetEntityHeading(playerPed)
    
    -- Calculate spawn position (in front of player)
    local spawnX = playerCoords.x + math.sin(-math.rad(heading)) * 5.0
    local spawnY = playerCoords.y + math.cos(-math.rad(heading)) * 5.0
    local spawnZ = playerCoords.z
    
    -- Get ground Z
    local ground, groundZ = GetGroundZFor_3dCoord(spawnX, spawnY, spawnZ + 10.0, 0)
    if ground then
        spawnZ = groundZ
    end
    
    -- Request model
    RequestModel(GetHashKey(model))
    local timeout = 5000
    local startTime = GetGameTimer()
    while not HasModelLoaded(GetHashKey(model)) do
        if GetGameTimer() - startTime > timeout then
            if debugMode then
                print("[Gang System] Failed to load vehicle model: " .. model)
            end
            return nil
        end
        Citizen.Wait(100)
    end
    
    -- Spawn vehicle
    local vehicle = CreateVehicle(GetHashKey(model), spawnX, spawnY, spawnZ, heading, true, true)
    
    if DoesEntityExist(vehicle) then
        -- Set vehicle properties
        local gangColor = Config.GangColors[gangId] or 0
        SetVehicleColours(vehicle, gangColor, gangColor)
        SetVehicleNumberPlateText(vehicle, string.upper(string.sub(gangId, 1, 3)) .. math.random(100, 999))
        SetVehicleEngineOn(vehicle, true, true, true)
        SetVehicleDirtLevel(vehicle, math.random() * 10.0)
        
        -- Store vehicle data
        table.insert(spawnedVehicles, {
            vehicle = vehicle,
            gang = gangId,
            spawnTime = GetGameTimer()
        })
        
        if debugMode then
            print("[Gang System] Spawned vehicle for gang: " .. gangId)
        end
        return vehicle
    else
        if debugMode then
            print("[Gang System] Failed to spawn vehicle for gang: " .. gangId)
        end
        return nil
    end
end

-- Function to clean up old NPCs
function CleanupGangNPCs()
    local currentTime = GetGameTimer()
    local newActiveNPCs = {}
    
    for i, npcData in ipairs(activeNPCs) do
        -- Check if NPC still exists and isn't too old (15 minutes)
        if DoesEntityExist(npcData.ped) and (currentTime - npcData.spawnTime) < 900000 then
            table.insert(newActiveNPCs, npcData)
        else
            -- Delete the ped if it exists
            if DoesEntityExist(npcData.ped) then
                DeleteEntity(npcData.ped)
            end
        end
    end
    
    activeNPCs = newActiveNPCs
    
    -- Clean up vehicles
    local newSpawnedVehicles = {}
    
    for i, vehicleData in ipairs(spawnedVehicles) do
        -- Check if vehicle still exists and isn't too old (30 minutes)
        if DoesEntityExist(vehicleData.vehicle) and (currentTime - vehicleData.spawnTime) < 1800000 then
            table.insert(newSpawnedVehicles, vehicleData)
        else
            -- Delete the vehicle if it exists
            if DoesEntityExist(vehicleData.vehicle) then
                DeleteEntity(vehicleData.vehicle)
            end
        end
    end
    
    spawnedVehicles = newSpawnedVehicles
end

-- Function to handle NPC behavior
function UpdateGangNPCBehavior()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local playerGang = GetPlayerGang()
    
    for i, npcData in ipairs(activeNPCs) do
        if DoesEntityExist(npcData.ped) then
            local pedCoords = GetEntityCoords(npcData.ped)
            local distance = #(playerCoords - pedCoords)
            
            -- Only process NPCs within range
            if distance < 100.0 then
                -- Check if player is in rival gang
                if playerGang and playerGang ~= npcData.gang then
                    -- Chance to become hostile based on distance
                    local hostileChance = 0
                    
                    if distance < 5.0 then
                        hostileChance = 0.8 -- 80% chance when very close
                    elseif distance < 15.0 then
                        hostileChance = 0.4 -- 40% chance when close
                    elseif distance < 30.0 then
                        hostileChance = 0.1 -- 10% chance when in medium range
                    end
                    
                    -- Roll for hostility
                    if math.random() < hostileChance and npcData.state ~= NPC_STATE.COMBAT then
                        -- Become hostile
                        TaskCombatPed(npcData.ped, playerPed, 0, 16)
                        npcData.state = NPC_STATE.COMBAT
                        inCombat = true
                    end
                end
                
                -- Update behavior based on state
                if npcData.state == NPC_STATE.IDLE then
                    -- Occasionally change idle behavior
                    if math.random() < 0.01 then -- 1% chance per update
                        local scenario = idleScenarios[math.random(#idleScenarios)]
                        ClearPedTasks(npcData.ped)
                        TaskStartScenarioInPlace(npcData.ped, scenario, 0, true)
                    end
                elseif npcData.state == NPC_STATE.PATROL then
                    -- Check if patrol is complete
                    if not GetIsTaskActive(npcData.ped, 221) then -- SCRIPT_TASK_WANDER
                        -- Return to idle
                        local scenario = idleScenarios[math.random(#idleScenarios)]
                        TaskStartScenarioInPlace(npcData.ped, scenario, 0, true)
                        npcData.state = NPC_STATE.IDLE
                    end
                elseif npcData.state == NPC_STATE.COMBAT then
                    -- Check if combat is over
                    if not IsPedInCombat(npcData.ped, playerPed) then
                        -- Return to idle
                        local scenario = idleScenarios[math.random(#idleScenarios)]
                        TaskStartScenarioInPlace(npcData.ped, scenario, 0, true)
                        npcData.state = NPC_STATE.IDLE
                    end
                end
            end
        end
    end
end

-- Function to spawn backup for player
function SpawnBackupForPlayer(gangId, count)
    if not gangId then return 0 end
    
    -- Set spawn count
    count = count

_Note: `safezones.lua`, `gangzones.lua`, `zones.lua`, and 15 more were excluded from the analysis due to size limit. Please upload again or start a new conversation if your question is related to them._
