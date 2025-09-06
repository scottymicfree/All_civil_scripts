-- NPC Interactions for Controller (Optimized)
-- Provides controller-friendly NPC interaction integrated with job wheel and gang zones
-- Variables
local interactionDistance = 3.0
local isNearNPC = false
local closestNPC = nil
local playerPed = PlayerPedId()
local debugMode = false
local function debugLog(msg)
    if debugMode then
        print('[NPCController] ' .. msg)
    end
end

-- NPC type mapping (based on models from [npc_spawner])
local npcTypeMap = {
    ['g_m_y_ballaorig_01'] = 'criminal',
    ['g_m_y_mexgoon_02'] = 'criminal',
    ['g_m_y_strpunk_01'] = 'criminal',
    ['g_m_y_mexgoon_03'] = 'rival_gang',
    ['g_m_y_famfor_01'] = 'rival_gang',
    ['g_m_y_famca_01'] = 'rival_gang',
    ['a_m_y_hiker_01'] = 'injured',
    ['a_f_y_business_01'] = 'injured',
    ['a_m_y_business_02'] = 'injured',
    ['a_m_y_business_03'] = 'civilian',
    ['a_f_y_vinewood_01'] = 'civilian'
}

-- Main thread for detection and UI
CreateThread(function()
    while true do
        local waitTime = 500
        playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local playerJob = exports['standalone-framework']:GetPlayerJob() or "none"
        local currentZone = exports['gang_zones']:GetPlayerZone(playerCoords)
        local currentClosestNPC = nil
        local closestDist = interactionDistance
        -- OPTIMIZATION: Use GetClosestPed for efficiency
        local peds = {}
        local found, closestPed = GetClosestPed(playerCoords.x, playerCoords.y, playerCoords.z, interactionDistance, 1, 0, 0, 0, -1)
        if found and closestPed ~= playerPed and not IsPedAPlayer(closestPed) and DoesEntityExist(closestPed) and not IsEntityDead(closestPed) then
            local pedCoords = GetEntityCoords(closestPed)
            closestDist = #(playerCoords - pedCoords)
            currentClosestNPC = closestPed
        end
        -- LOGIC FIX: Process the result
        if currentClosestNPC and not isNearNPC then
            isNearNPC = true
            closestNPC = currentClosestNPC
            TriggerEvent('npc_controller:nearNPC', closestNPC)
            debugLog("Near NPC: " .. closestNPC)
        elseif currentClosestNPC and isNearNPC and currentClosestNPC ~= closestNPC then
            closestNPC = currentClosestNPC
            TriggerEvent('npc_controller:nearNPC', closestNPC)
            debugLog("Switched to new NPC: " .. closestNPC)
        elseif not currentClosestNPC and isNearNPC then
            isNearNPC = false
            closestNPC = nil
            TriggerEvent('npc_controller:leftNPC')
            debugLog("Left NPC range")
        end
        -- Handle UI prompt and interaction
        if isNearNPC and closestNPC and currentZone then
            waitTime = 0
            local npcModel = GetEntityModel(closestNPC)
            local npcType = npcTypeMap[GetEntityModelName(npcModel)] or "civilian"
            local isValidInteraction = false
            -- Validate interaction based on job and zone
            if playerJob == "police" and npcType == "criminal" and currentZone.name == "Eastside Ballas" then
                isValidInteraction = true
            elseif playerJob == "drugdealer" and npcType == "rival_gang" and currentZone.name == "Vagos Turf" then
                isValidInteraction = true
            elseif playerJob == "ems" and npcType == "injured" and currentZone.name == "Red Hood" then
                isValidInteraction = true
            elseif playerJob == "firefighter" and npcType == "civilian" then -- Update with real fire zone
                isValidInteraction = true
            end
            if isValidInteraction then
                BeginTextCommandDisplayHelp("STRING")
                AddTextComponentSubstringPlayerName("Press ~INPUT_CONTEXT~ to " .. 
                    (playerJob == "police" and "arrest" or playerJob == "ems" and "revive" or playerJob == "firefighter" and "rescue" or "interact"))
                EndTextCommandDisplayHelp(0, false, true, -1)
                if IsControlJustReleased(0, 51) then -- E key / Xbox A button
                    TriggerEvent('npc_controller:interactWithNPC', closestNPC, npcType)
                end
            end
        end
        Wait(waitTime)
    end
end)

-- Event handler for NPC interaction
AddEventHandler('npc_controller:interactWithNPC', function(npc, npcType)
    if not DoesEntityExist(npc) then
        debugLog("Error: Invalid NPC for interaction")
        return
    end
    local playerJob = exports['standalone-framework']:GetPlayerJob() or "none"
    local interactionEvent = nil
    if playerJob == "police" and npcType == "criminal" then
        interactionEvent = "npc_controller:arrestCriminal"
        TaskPlayAnim(npc, "random@arrests", "generic_arrest", 8.0, -8.0, -1, 49, 0, false, false, false)
        exports['standalone-framework']:ShowNotification("Criminal arrested!")
    elseif playerJob == "ems" and npcType == "injured" then
        interactionEvent = "npc_controller:reviveInjured"
        TaskPlayAnim(npc, "amb@medic@standing@kneel@base", "base", 8.0, -8.0, -1, 1, 0, false, false, false)
        exports['standalone-framework']:ShowNotification("Injured person revived!")
    elseif playerJob == "firefighter" and npcType == "civilian" then
        interactionEvent = "npc_controller:rescueCivilian"
        TaskFollowToOffsetOfEntity(npc, PlayerPedId(), 0.0, -2.0, 0.0, 5.0, -1, 0.5, true)
        exports['standalone-framework']:ShowNotification("Civilian rescued!")
    elseif playerJob == "drugdealer" and npcType == "rival_gang" then
        interactionEvent = "npc_controller:dealWithRival"
        TaskReactAndFleePed(npc, PlayerPedId())
        exports['standalone-framework']:ShowNotification("Rival gang member intimidated!")
    else
        exports['standalone-framework']:ShowNotification("No valid interaction available.")
        debugLog("Invalid interaction: job=" .. playerJob .. ", npcType=" .. npcType)
        return
    end
    TriggerEvent("npc:interaction", npc, npcType, playerJob)
    TriggerServerEvent("npc_controller:interaction", npcType, playerJob)
    debugLog("Interacted with NPC of type: " .. npcType .. " as " .. playerJob)
end)

-- Clean up on player death or mission end
AddEventHandler('bounty:playerDied', function()
    isNearNPC = false
    closestNPC = nil
    debugLog("Player died, reset NPC interaction")
end)

AddEventHandler('bounty:completeMission', function()
    isNearNPC = false
    closestNPC = nil
    debugLog("Mission completed, reset NPC interaction")
end)

AddEventHandler('playerDropped', function()
    isNearNPC = false
    closestNPC = nil
    debugLog("Player dropped, reset NPC interaction")
end)

-- Debug command
RegisterCommand("npccontroller_debug", function()
    debugMode = not debugMode
    print("[NPCController] Debug mode " .. (debugMode and "enabled" or "disabled"))
end, false)

-- Utility function to get model name from hash
function GetEntityModelName(modelHash)
    for model, npcType in pairs(npcTypeMap) do
        if GetHashKey(model) == modelHash then
            return model
        end
    end
    return "unknown"
end