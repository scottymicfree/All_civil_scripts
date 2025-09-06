-- NPC Management System
-- Handles spawning and tracking of NPCs in the world

-- Table to store spawned NPCs and their roles
local npcPeds = {}

-- Spawn all configured NPCs
local function spawnNPCs()
    for _, npc in ipairs(Config.NPCs) do
        local modelHash = loadModel(npc.model)
        
        if modelHash then
            local ped = CreatePed(4, modelHash, npc.coords.x, npc.coords.y, npc.coords.z - 1.0, npc.heading, false, true)
            
            -- Configure NPC behavior
            SetBlockingOfNonTemporaryEvents(ped, true)
            SetPedFleeAttributes(ped, 0, 0)
            SetPedDropsWeaponsWhenDead(ped, false)
            FreezeEntityPosition(ped, true)
            SetEntityInvincible(ped, true)
            
            -- Store NPC data
            npcPeds[ped] = {
                role = npc.role,
                model = npc.model,
                coords = npc.coords
            }
            
            -- Set model as no longer needed
            SetModelAsNoLongerNeeded(modelHash)
            
            if Config.Debug then
                debugLog("Spawned NPC: " .. npc.model .. " as " .. npc.role)
            end
        end
    end
end

-- Clean up NPCs when resource stops
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        for ped, _ in pairs(npcPeds) do
            if DoesEntityExist(ped) then
                DeleteEntity(ped)
            end
        end
    end
end)

-- Initialize NPCs when resource starts
Citizen.CreateThread(function()
    Citizen.Wait(1000) -- Wait for resource to initialize
    spawnNPCs()
end)

-- Export function to get NPC data
exports('getNpcPeds', function()
    return npcPeds
end)
