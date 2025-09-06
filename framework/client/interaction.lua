-- NPC Interaction System
-- Handles player interactions with NPCs

local interacting = false
local interactKey = Config.Keys.interact
local controllerInteractKey = Config.Keys.controller_interact

-- Check for NPC interactions
Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local npcPeds = exports[GetCurrentResourceName()]:getNpcPeds()
        local foundNearbyNPC = false
        
        for ped, data in pairs(npcPeds) do
            if DoesEntityExist(ped) then
                local pedCoords = GetEntityCoords(ped)
                local dist = #(playerCoords - pedCoords)
                
                if dist < 2.0 then
                    foundNearbyNPC = true
                    draw3DText(pedCoords + vector3(0, 0, 1.0), "[E / A] Interact (" .. data.role .. ")")
                    
                    if (IsControlJustReleased(0, interactKey) or IsControlJustReleased(0, controllerInteractKey)) and not interacting then
                        interacting = true
                        TriggerEvent("cfw:npcInteract", data.role, ped)
                        Citizen.Wait(1000) -- Cooldown to prevent spam
                        interacting = false
                    end
                end
            end
        end
        
        -- Only use Wait(0) when near an NPC, otherwise use a longer wait time
        if foundNearbyNPC then
            Citizen.Wait(0)
        else
            Citizen.Wait(500)
        end
    end
end)

-- Handle NPC interactions
RegisterNetEvent("cfw:npcInteract")
AddEventHandler("cfw:npcInteract", function(role, ped)
    if role == "police" then
        TriggerEvent("vMenu:openPoliceMenu")
    elseif role == "ems" then
        TriggerEvent("vMenu:openEMSMenu")
    elseif role == "clerk" then
        TriggerEvent("cfw:attemptRobbery", ped)
    elseif role == "gang" then
        TriggerEvent("vMenu:openGangMenu")
    else
        showNotification("You interacted with " .. role)
    end
end)

-- Handle aiming at NPCs (for robberies)
Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local npcPeds = exports[GetCurrentResourceName()]:getNpcPeds()
        local isAiming = false
        
        -- Check if player is aiming
        if IsPlayerFreeAiming(PlayerId()) then
            isAiming = true
            local aiming, targetPed = GetEntityPlayerIsFreeAimingAt(PlayerId())
            
            if aiming and DoesEntityExist(targetPed) and npcPeds[targetPed] and npcPeds[targetPed].role == "clerk" then
                local dist = #(playerCoords - GetEntityCoords(targetPed))
                
                if dist < 3.0 then
                    draw3DText(GetEntityCoords(targetPed) + vector3(0, 0, 1.0), "~r~Press E / A to Rob")
                    
                    if IsControlJustReleased(0, interactKey) or IsControlJustReleased(0, controllerInteractKey) then
                        -- Check robbery cooldown
                        local canRob, timeLeft = checkCooldown("robbery")
                        
                        if canRob then
                            TriggerEvent("cfw:startRobbery", targetPed)
                            setCooldown("robbery", Config.Cooldowns.robbery)
                        else
                            showNotification("You can't rob this store yet. Try again in " .. timeLeft .. " seconds.", "error")
                        end
                    end
                end
            end
        end
        
        -- Optimize wait time based on player activity
        if isAiming then
            Citizen.Wait(0)
        else
            Citizen.Wait(500)
        end
    end
end)

-- Handle robbery start
RegisterNetEvent("cfw:startRobbery")
AddEventHandler("cfw:startRobbery", function(targetPed)
    TriggerServerEvent("cfw:robberyStarted", NetworkGetNetworkIdFromEntity(targetPed))
    showNotification('Robbery started! Stay alert!', 'inform')
end)

-- Handle player death and EMS requests
local isDead = false

AddEventHandler('baseevents:onPlayerDied', function()
    isDead = true
    
    Citizen.CreateThread(function()
        while isDead do
            local playerCoords = GetEntityCoords(PlayerPedId())
            draw3DText(playerCoords + vector3(0, 0, 0.5), "~g~Press E / A to request EMS heal")
            
            if IsControlJustReleased(0, interactKey) or IsControlJustReleased(0, controllerInteractKey) then
                -- Check EMS heal cooldown
                local canHeal, timeLeft = checkCooldown("emsHeal")
                
                if canHeal then
                    TriggerServerEvent("cfw:requestEMSHeal")
                    setCooldown("emsHeal", Config.Cooldowns.emsHeal)
                    isDead = false
                else
                    showNotification("You must wait " .. timeLeft .. " seconds before requesting EMS again.", "error")
                end
            end
            
            Citizen.Wait(0)
        end
    end)
end)

AddEventHandler('baseevents:onPlayerRespawned', function()
    isDead = false
end)

-- Handle robbery attempt
RegisterNetEvent("cfw:attemptRobbery")
AddEventHandler("cfw:attemptRobbery", function(ped)
    -- Check if player has a weapon
    local playerPed = PlayerPedId()
    local hasWeapon = IsPedArmed(playerPed, 4) -- 4 = armed with gun
    
    if hasWeapon then
        showNotification("Point your weapon at the clerk to rob them.")
    else
        showNotification("You need a weapon to rob this store.", "error")
    end
end)
