-- Civil Unrest Custom Features

-- Function to implement gang backup
RegisterNetEvent("gangrp:spawnBackup")
AddEventHandler("gangrp:spawnBackup", function(backupType, count)
    -- Get player gang
    local playerGang = "none"
    local success = pcall(function()
        playerGang = exports["standalone-framework"]:GetPlayerGang()
    end)
    
    if not success or playerGang == "none" then
        Notify("~r~You are not in a gang")
        return
    end
    
    -- Define gang models based on gang
    local gangModels = {
        ["ballas"] = {"g_m_y_ballasout_01", "g_f_y_ballas_01"},
        ["families"] = {"g_m_y_famca_01", "g_m_y_famdnf_01"},
        ["vagos"] = {"g_m_y_mexgoon_01", "g_m_y_mexgoon_03"},
        ["lost"] = {"g_m_y_lost_01", "g_m_y_lost_02", "g_m_y_lost_03"}
    }
    
    -- Get models for player's gang
    local models = gangModels[playerGang] or {"a_m_y_mexthug_01", "a_m_y_stbla_01"}
    
    -- Get player position
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    
    -- Spawn NPCs
    local spawnedPeds = {}
    for i = 1, count do
        -- Select random model
        local model = models[math.random(#models)]
        local hash = GetHashKey(model)
        
        -- Request model
        RequestModel(hash)
        local timeout = GetGameTimer() + 5000
        while not HasModelLoaded(hash) and GetGameTimer() < timeout do
            Citizen.Wait(100)
        end
        
        if HasModelLoaded(hash) then
            -- Calculate spawn position
            local angle = (i * 360 / count) * math.pi / 180
            local x = coords.x + math.cos(angle) * 5
            local y = coords.y + math.sin(angle) * 5
            
            -- Spawn NPC
            local ped = CreatePed(4, hash, x, y, coords.z, 0.0, true, true)
            
            -- Configure NPC
            SetPedArmour(ped, 100)
            GiveWeaponToPed(ped, GetHashKey("WEAPON_PISTOL"), 500, false, true)
            
            if backupType == "defensive" then
                -- Defensive behavior
                TaskGuardCurrentPosition(ped, 10.0, 10.0, true)
            elseif backupType == "offensive" then
                -- Offensive behavior - attack nearest enemies
                TaskCombatHatedTargetsAroundPed(ped, 50.0, 0)
            elseif backupType == "follow" then
                -- Follow player
                TaskFollowToOffsetOfEntity(ped, playerPed, 0.0, -2.0, 0.0, 5.0, -1, 1.0, true)
            end
            
            -- Add to spawned peds
            table.insert(spawnedPeds, ped)
            
            -- Clean up model
            SetModelAsNoLongerNeeded(hash)
        end
    end
    
    -- Notify player
    Notify("Spawned " .. count .. " " .. backupType .. " gang members")
    
    -- Clean up after 5 minutes
    Citizen.SetTimeout(300000, function()
        for _, ped in ipairs(spawnedPeds) do
            if DoesEntityExist(ped) then
                DeleteEntity(ped)
            end
        end
        Notify("Gang backup has left the area")
    end)
end)

-- Register command for gang backup
RegisterCommand("gangbackup", function(source, args, rawCommand)
    local backupType = args[1] or "defensive"
    local count = tonumber(args[2]) or 2
    
    -- Limit count to reasonable number
    count = math.min(count, 5)
    
    -- Trigger backup event
    TriggerEvent("gangrp:spawnBackup", backupType, count)
end, false)

-- Notification function
function Notify(message)
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandThefeedPostTicker(true, false)
end

-- Initialize
Citizen.CreateThread(function()
    print("Civil Unrest Features initialized")
end)
