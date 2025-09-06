-- Controller Support for NPC Interactions
-- This script adds controller-friendly NPC interactions using D-pad controls

local interactionDistance = 3.0
local interactionCooldown = false
local cooldownTime = 1000 -- 1 second cooldown between interactions
local debugMode = false

-- Function to find the closest NPC to the player
function GetClosestNPC(maxDistance)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local closestNPC = nil
    local closestDistance = maxDistance or 3.0
    
    -- Get all peds in the area
    local peds = GetGamePool('CPed')
    
    for _, ped in ipairs(peds) do
        -- Skip if it's the player or not a valid NPC
        if ped ~= playerPed and not IsPedAPlayer(ped) and DoesEntityExist(ped) and not IsPedDeadOrDying(ped, true) then
            local pedCoords = GetEntityCoords(ped)
            local distance = #(playerCoords - pedCoords)
            
            if distance < closestDistance then
                closestDistance = distance
                closestNPC = ped
            end
        end
    end
    
    return closestNPC, closestDistance
end

-- Function to determine NPC type
function GetNPCType(ped)
    -- Check if the NPC is registered in the NPC interaction system
    if GetResourceState('standalone-framework') == 'started' then
        local success, result = pcall(function()
            return exports['standalone-framework']:GetNPCType(ped)
        end)
        
        if success and result then
            return result
        end
    end
    
    -- Fallback to model-based detection
    local pedModel = GetEntityModel(ped)
    local pedType = "civilian"
    
    -- Police models
    local policeModels = {
        GetHashKey("s_m_y_cop_01"),
        GetHashKey("s_f_y_cop_01"),
        GetHashKey("s_m_y_hwaycop_01")
    }
    
    -- EMS models
    local emsModels = {
        GetHashKey("s_m_m_paramedic_01"),
        GetHashKey("s_f_y_scrubs_01")
    }
    
    -- Fire models
    local fireModels = {
        GetHashKey("s_m_y_fireman_01")
    }
    
    -- Gang models
    local gangModels = {
        GetHashKey("g_m_y_lost_03"),
        GetHashKey("g_m_m_mexboss_01"),
        GetHashKey("g_f_y_vagos_01")
    }
    
    -- Check model against known types
    for _, model in ipairs(policeModels) do
        if pedModel == model then return "police" end
    end
    
    for _, model in ipairs(emsModels) do
        if pedModel == model then return "ems" end
    end
    
    for _, model in ipairs(fireModels) do
        if pedModel == model then return "fire" end
    end
    
    for _, model in ipairs(gangModels) do
        if pedModel == model then return "gang" end
    end
    
    return pedType
end

-- Function to show interaction prompt
function ShowInteractionPrompt(npcType)
    BeginTextCommandDisplayHelp("STRING")
    if npcType == "police" then
        AddTextComponentSubstringPlayerName("Press ~INPUT_FRONTEND_UP~ to interact with Police Officer")
    elseif npcType == "ems" then
        AddTextComponentSubstringPlayerName("Press ~INPUT_FRONTEND_UP~ to interact with EMS")
    elseif npcType == "fire" then
        AddTextComponentSubstringPlayerName("Press ~INPUT_FRONTEND_UP~ to interact with Firefighter")
    elseif npcType == "gang" then
        AddTextComponentSubstringPlayerName("Press ~INPUT_FRONTEND_UP~ to interact with Gang Member")
    else
        AddTextComponentSubstringPlayerName("Press ~INPUT_FRONTEND_UP~ to interact with NPC")
    end
    EndTextCommandDisplayHelp(0, false, true, -1)
end

-- Function to handle NPC interaction
function HandleNPCInteraction(npcType, npc)
    -- Check if the NPC is registered in the NPC interaction system
    if GetResourceState('standalone-framework') == 'started' then
        local success, result = pcall(function()
            return exports['standalone-framework']:InteractWithNPCEntity(npc)
        end)
        
        if success and result then
            if debugMode then
                print("[Controller Support] Interaction handled by standalone-framework")
            end
            return true
        end
    end
    
    -- Fallback to event-based interaction
    if npcType == "police" then
        TriggerEvent("civil_unrest_police:interact", npc)
    elseif npcType == "ems" then
        TriggerEvent("civil_unrest_ems:interact", npc)
    elseif npcType == "fire" then
        TriggerEvent("civil_unrest_fire:interact", npc)
    elseif npcType == "gang" then
        TriggerEvent("gangrp:interact", npc)
    else
        -- Default civilian interaction
        TriggerEvent("npc:interact", npc)
    end
    
    return true
end

-- Main thread for showing prompts
Citizen.CreateThread(function()
    local checkTimer = 0
    local nearNPC = false
    local currentNPC = nil
    local currentNPCType = nil
    
    while true do
        -- Only check every 250ms to save resources when not near an NPC
        local waitTime = nearNPC and 0 or 250
        Citizen.Wait(waitTime)
        
        -- Check for nearby NPCs periodically
        checkTimer = checkTimer - waitTime
        if checkTimer <= 0 then
            currentNPC, distance = GetClosestNPC(interactionDistance)
            
            if currentNPC then
                currentNPCType = GetNPCType(currentNPC)
                nearNPC = true
                checkTimer = 1000 -- Check again in 1 second
            else
                nearNPC = false
                currentNPC = nil
                currentNPCType = nil
                checkTimer = 250 -- Check again in 250ms
            end
        end
        
        -- Show prompt if near an NPC
        if nearNPC and currentNPC and not interactionCooldown then
            ShowInteractionPrompt(currentNPCType)
            
            -- Check for D-pad up press (controller)
            if IsControlJustReleased(0, 172) then -- 172 is D-pad Up
                interactionCooldown = true
                HandleNPCInteraction(currentNPCType, currentNPC)
                
                -- Reset cooldown
                Citizen.SetTimeout(cooldownTime, function()
                    interactionCooldown = false
                end)
            end
        end
    end
end)

-- Register command for keyboard users
RegisterCommand("npc_interact", function()
    if not interactionCooldown then
        local npc, distance = GetClosestNPC(interactionDistance)
        
        if npc then
            local npcType = GetNPCType(npc)
            interactionCooldown = true
            HandleNPCInteraction(npcType, npc)
            
            -- Reset cooldown
            Citizen.SetTimeout(cooldownTime, function()
                interactionCooldown = false
            end)
        end
    end
end, false)

-- Register key mapping for keyboard users
RegisterKeyMapping("npc_interact", "Interact with NPC", "keyboard", "E")

-- Notification function
function ShowNotification(message)
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandThefeedPostTicker(true, false)
end

-- Debug command
RegisterCommand("controller_debug", function()
    debugMode = not debugMode
    ShowNotification("Controller debug mode: " .. (debugMode and "Enabled" or "Disabled"))
end, false)
