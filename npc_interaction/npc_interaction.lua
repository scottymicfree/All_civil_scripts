-- Controller Support for NPC Interactions
-- This script adds controller-friendly NPC interactions using D-pad controls
local interactionCooldown = false
local nearNPC = false
local currentNPC = nil
local currentNPCType = nil

-- Function to find the closest NPC to the player
function GetClosestNPC(maxDistance)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local closestNPC = nil
    local closestDistance = maxDistance or Config.NPCInteraction.InteractionDistance
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
    -- Convert hash keys to model names for easier comparison
    local pedModelName = nil
    for i = 0, 256 do
        if GetHashKey(i) == pedModel then
            pedModelName = i
            break
        end
    end
    -- Check model against known types from config
    for npcType, models in pairs(Config.NPCTypes) do
        for _, model in ipairs(models) do
            if pedModelName == model or pedModel == GetHashKey(model) then
                return string.lower(npcType)
            end
        end
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
            if Config.Debug then
                print("[Controller Support] Interaction handled by standalone-framework")
            end
            return true
        end
    end
    -- Handle gang member interactions with our menu system
    if npcType == "gang" then
        -- Get gang name from the model or other properties
        local gangName = DetermineGangFromPed(npc)
        if gangName then
            -- Use our menu system for gang interactions
            TriggerEvent("controller_menu:openGangMenu", gangName, NetworkGetNetworkIdFromEntity(npc))
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

-- Function to determine gang from ped model
function DetermineGangFromPed(ped)
    local pedModel = GetEntityModel(ped)
    -- Map models to gangs
    local gangModels = {
        [GetHashKey("g_m_y_ballasout_01")] = "Ballas",
        [GetHashKey("g_m_y_famca_01")] = "Families",
        [GetHashKey("g_m_y_mexgoon_01")] = "Vagos",
        [GetHashKey("g_m_y_lost_01")] = "Lost MC",
        [GetHashKey("g_m_y_lost_03")] = "Lost MC",
        [GetHashKey("g_m_m_mexboss_01")] = "Cartel",
        [GetHashKey("g_f_y_vagos_01")] = "Vagos",
        [GetHashKey("g_m_y_salvagoon_01")] = "Marabunta Grande",
        [GetHashKey("g_m_y_strpunk_01")] = "Riptides"
    }
    return gangModels[pedModel] or "Unknown Gang"
end

-- Initialize NPC interaction system
function InitializeNPCInteractions()
-- Main thread for showing prompts
CreateThread(function()
local checkTimer = 0
    while true do
        -- Only check every 250ms to save resources when not near an NPC
        local waitTime = nearNPC and 0 or 250
        Wait(waitTime)
        -- Check for nearby NPCs periodically
        checkTimer = checkTimer - waitTime
        if checkTimer <= 0 then
            currentNPC, distance = GetClosestNPC(Config.NPCInteraction.InteractionDistance)
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
        if nearNPC and currentNPC and not interactionCooldown and Config.NPCInteraction.EnableControllerPrompts then
            ShowInteractionPrompt(currentNPCType)
            -- Check for D-pad up press (controller)
            if IsControlJustReleased(0, 172) then -- 172 is D-pad Up
                interactionCooldown = true
                HandleNPCInteraction(currentNPCType, currentNPC) 
                -- Reset cooldown
                Citizen.SetTimeout(Config.NPCInteraction.CooldownTime, function()
                interactionCooldown = false
                end)
            end
        end
    end
end)

-- Register command for keyboard users
if Config.NPCInteraction.EnableKeyboardControls then
    RegisterCommand("npc_interact", function()
        if not interactionCooldown then
            local npc, distance = GetClosestNPC(Config.NPCInteraction.InteractionDistance)
            if npc then
                local npcType = GetNPCType(npc)
                interactionCooldown = true
                HandleNPCInteraction(npcType, npc)
                -- Reset cooldown
                Citizen.SetTimeout(Config.NPCInteraction.CooldownTime, function()
                    interactionCooldown = false
                end)
            end
        end
    end, false)
    -- Register key mapping for keyboard users
    RegisterKeyMapping("npc_interact", "Interact with NPC", "keyboard", "E")
end
-- Debug command
RegisterCommand("controller_debug", function()
    Config.Debug = not Config.Debug
    ShowNotification("Controller debug mode: " .. (Config.Debug and "Enabled" or "Disabled"))
end, false)


-- Export functions
exports('GetClosestNPC', GetClosestNPC)
exports('GetNPCType', GetNPCType)
exports('HandleNPCInteraction', HandleNPCInteraction)