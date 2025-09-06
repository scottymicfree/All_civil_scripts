-- NPC Job Prompt System
-- This script adds controller-friendly job prompts for NPCs

local activePrompts = {}
local promptDistance = 3.0
local promptCooldown = false
local cooldownTime = 1000 -- 1 second cooldown between prompts

-- NPC job types and their configurations
local npcJobTypes = {
    police = {
        models = {
            "s_m_y_cop_01",
            "s_f_y_cop_01",
            "s_m_y_hwaycop_01"
        },
        prompt = "Press ~INPUT_FRONTEND_UP~ to interact with Police Officer",
        actions = {
            "Request Backup",
            "Report Crime",
            "Pay Ticket",
            "Ask for Directions"
        }
    },
    ems = {
        models = {
            "s_m_m_paramedic_01",
            "s_f_y_scrubs_01"
        },
        prompt = "Press ~INPUT_FRONTEND_UP~ to interact with EMS",
        actions = {
            "Request Medical Help",
            "Ask for Medical Advice",
            "Volunteer",
            "Donate Blood"
        }
    },
    fire = {
        models = {
            "s_m_y_fireman_01"
        },
        prompt = "Press ~INPUT_FRONTEND_UP~ to interact with Firefighter",
        actions = {
            "Report Fire",
            "Request Fire Safety Check",
            "Volunteer",
            "Ask for Directions"
        }
    },
    gang = {
        models = {
            "g_m_y_lost_03",
            "g_m_m_mexboss_01",
            "g_f_y_vagos_01"
        },
        prompt = "Press ~INPUT_FRONTEND_UP~ to interact with Gang Member",
        actions = {
            "Request Job",
            "Buy Contraband",
            "Join Gang",
            "Pay Protection"
        }
    },
    drugdealer = {
        models = {
            "a_m_y_hipster_01",
            "a_m_m_skater_01",
            "a_m_y_stwhi_01"
        },
        prompt = "Press ~INPUT_FRONTEND_UP~ to interact with Dealer",
        actions = {
            "Buy Drugs",
            "Sell Information",
            "Request Job",
            "Leave"
        }
    }
}

-- Function to get NPC type based on model
function GetNPCJobType(ped)
    local pedModel = GetEntityModel(ped)
    
    for jobType, config in pairs(npcJobTypes) do
        for _, model in ipairs(config.models) do
            if pedModel == GetHashKey(model) then
                return jobType
            end
        end
    end
    
    return "civilian"
end

-- Function to show interaction prompt
function ShowInteractionPrompt(npcType)
    if npcJobTypes[npcType] then
        BeginTextCommandDisplayHelp("STRING")
        AddTextComponentSubstringPlayerName(npcJobTypes[npcType].prompt)
        EndTextCommandDisplayHelp(0, false, true, -1)
    else
        BeginTextCommandDisplayHelp("STRING")
        AddTextComponentSubstringPlayerName("Press ~INPUT_FRONTEND_UP~ to interact with NPC")
        EndTextCommandDisplayHelp(0, false, true, -1)
    end
end

-- Function to handle NPC interaction
function HandleNPCJobInteraction(npcType, npc)
    if promptCooldown then return end
    
    promptCooldown = true
    
    if npcJobTypes[npcType] then
        -- Create menu with job-specific actions
        local actions = npcJobTypes[npcType].actions
        
        -- Show menu
        TriggerEvent("npc_job_prompts:showActionMenu", npcType, actions, npc)
    else
        -- Default civilian interaction
        TriggerEvent("npc:interact", npc)
    end
    
    -- Reset cooldown
    Citizen.SetTimeout(cooldownTime, function()
        promptCooldown = false
    end)
end

-- Main thread for showing prompts
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        
        -- Get all peds in the area
        local peds = GetGamePool('CPed')
        local foundNPC = false
        
        for _, ped in ipairs(peds) do
            -- Skip if it's the player or not a valid NPC
            if ped ~= playerPed and not IsPedAPlayer(ped) and DoesEntityExist(ped) then
                local pedCoords = GetEntityCoords(ped)
                local distance = #(playerCoords - pedCoords)
                
                if distance < promptDistance then
                    local npcType = GetNPCJobType(ped)
                    
                    -- Only show prompt for job NPCs
                    if npcType ~= "civilian" then
                        ShowInteractionPrompt(npcType)
                        foundNPC = true
                        
                        -- Check for D-pad up press (controller)
                        if IsControlJustReleased(0, 172) then -- 172 is D-pad Up
                            HandleNPCJobInteraction(npcType, ped)
                        end
                        
                        -- Only show prompt for closest NPC
                        break
                    end
                end
            end
        end
        
        -- If no NPC found, wait longer to save resources
        if not foundNPC then
            Citizen.Wait(500)
        end
    end
end)

-- Register command for keyboard users
RegisterCommand("npc_job_interact", function()
    if promptCooldown then return end
    
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    -- Get all peds in the area
    local peds = GetGamePool('CPed')
    local closestNPC = nil
    local closestDistance = promptDistance
    local closestType = nil
    
    for _, ped in ipairs(peds) do
        -- Skip if it's the player or not a valid NPC
        if ped ~= playerPed and not IsPedAPlayer(ped) and DoesEntityExist(ped) then
            local pedCoords = GetEntityCoords(ped)
            local distance = #(playerCoords - pedCoords)
            
            if distance < closestDistance then
                local npcType = GetNPCJobType(ped)
                
                -- Only interact with job NPCs
                if npcType ~= "civilian" then
                    closestNPC = ped
                    closestDistance = distance
                    closestType = npcType
                end
            end
        end
    end
    
    if closestNPC then
        HandleNPCJobInteraction(closestType, closestNPC)
    end
end, false)

-- Register key mapping for keyboard users
RegisterKeyMapping("npc_job_interact", "Interact with Job NPC", "keyboard", "E")

-- Event handler for showing action menu
RegisterNetEvent("npc_job_prompts:showActionMenu")
AddEventHandler("npc_job_prompts:showActionMenu", function(npcType, actions, npc)
    -- Create a menu using NativeUI
    local menuPool = NativeUI.CreatePool()
    local mainMenu = NativeUI.CreateMenu("NPC Interaction", "~b~Select an action")
    menuPool:Add(mainMenu)
    
    -- Add actions to menu
    for _, action in ipairs(actions) do
        local item = NativeUI.CreateItem(action, "")
        mainMenu:AddItem(item)
    end
    
    -- Handle menu selection
    mainMenu.OnItemSelect = function(sender, item, index)
        local selectedAction = actions[index]
        
        -- Handle different actions based on NPC type
        if npcType == "police" then
            if selectedAction == "Request Backup" then
                TriggerEvent("civil_unrest_police:requestBackup")
            elseif selectedAction == "Report Crime" then
                TriggerEvent("civil_unrest_police:reportCrime")
            elseif selectedAction == "Pay Ticket" then
                TriggerEvent("civil_unrest_police:payTicket")
            elseif selectedAction == "Ask for Directions" then
                TriggerEvent("civil_unrest_police:askDirections")
            end
        elseif npcType == "ems" then
            if selectedAction == "Request Medical Help" then
                TriggerEvent("civil_unrest_ems:requestMedicalHelp")
            elseif selectedAction == "Ask for Medical Advice" then
                TriggerEvent("civil_unrest_ems:askMedicalAdvice")
            elseif selectedAction == "Volunteer" then
                TriggerEvent("civil_unrest_ems:volunteer")
            elseif selectedAction == "Donate Blood" then
                TriggerEvent("civil_unrest_ems:donateBlood")
            end
        elseif npcType == "fire" then
            if selectedAction == "Report Fire" then
                TriggerEvent("civil_unrest_fire:reportFire")
            elseif selectedAction == "Request Fire Safety Check" then
                TriggerEvent("civil_unrest_fire:requestSafetyCheck")
            elseif selectedAction == "Volunteer" then
                TriggerEvent("civil_unrest_fire:volunteer")
            elseif selectedAction == "Ask for Directions" then
                TriggerEvent("civil_unrest_fire:askDirections")
            end
        elseif npcType == "gang" then
            if selectedAction == "Request Job" then
                TriggerEvent("gangrp:requestJob")
            elseif selectedAction == "Buy Contraband" then
                TriggerEvent("gangrp:buyContraband")
            elseif selectedAction == "Join Gang" then
                TriggerEvent("gangrp:joinGang")
            elseif selectedAction == "Pay Protection" then
                TriggerEvent("gangrp:payProtection")
            end
        elseif npcType == "drugdealer" then
            if selectedAction == "Buy Drugs" then
                TriggerEvent("gangrp:buyDrugs")
            elseif selectedAction == "Sell Information" then
                TriggerEvent("gangrp:sellInformation")
            elseif selectedAction == "Request Job" then
                TriggerEvent("gangrp:requestDrugJob")
            end
        end
        
        -- Close menu after selection
        mainMenu:Visible(false)
    end
    
    -- Show menu
    menuPool:RefreshIndex()
    mainMenu:Visible(true)
    
    -- Process menu in a separate thread
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            menuPool:ProcessMenus()
            
            -- Break loop when menu is closed
            if not mainMenu:Visible() then
                break
            end
        end
    end)
end)

-- Notification function
function ShowNotification(message)
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandThefeedPostTicker(true, false)
end