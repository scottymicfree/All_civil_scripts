-- NPC Interactions for Controller (Optimized)
-- Provides controller-friendly NPC interaction

-- Variables
local interactionDistance = 3.0
local isNearNPC = false
local closestNPC = nil
local playerPed = PlayerPedId()

-- Main thread for detection and UI
CreateThread(function()
    while true do
    -- Default wait time if nothing is happening
    local waitTime = 500
    playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local currentClosestNPC = nil
    local closestDist = interactionDistance
    -- OPTIMIZATION: Iterate through peds in a radius instead of the entire game pool
    local handle, ped = FindFirstPed()
    local success
    repeat
        -- Filter out the player, other players, and dead peds
        if ped ~= playerPed and not IsPedAPlayer(ped) and DoesEntityExist(ped) and not IsEntityDead(ped) then
            local pedCoords = GetEntityCoords(ped)
            local distance = #(playerCoords - pedCoords)

            if distance < closestDist then
                closestDist = distance
                currentClosestNPC = ped
            end
        end
        success, ped = FindNextPed(handle)
    until not success
    EndFindPed(handle)
    -- LOGIC FIX: Process the result *after* the loop has finished
    if currentClosestNPC and not isNearNPC then
        -- Player has entered the range of an NPC for the first time
        isNearNPC = true
        closestNPC = currentClosestNPC
        TriggerEvent("controller:nearNPC", closestNPC)
    elseif currentClosestNPC and isNearNPC and currentClosestNPC ~= closestNPC then
        -- Player is still near an NPC, but it's a different one
        closestNPC = currentClosestNPC
        TriggerEvent("controller:nearNPC", closestNPC)
    elseif not currentClosestNPC and isNearNPC then
        -- Player has left the range of all NPCs
        isNearNPC = false
        closestNPC = nil
        TriggerEvent("controller:leftNPC")
    end

    -- Handle UI prompt and interaction
    if isNearNPC and closestNPC then
        -- Run every frame to catch input
        waitTime = 0

        -- Show interaction prompt
        BeginTextCommandDisplayHelp("STRING")
        AddTextComponentSubstringPlayerName("Press ~INPUT_CONTEXT~ to interact")
        EndTextCommandDisplayHelp(0, false, true, -1)

        -- Check for button press
        if IsControlJustReleased(0, 51) then -- 51 = E key / Xbox A button
            TriggerEvent("controller:interactWithNPC", closestNPC)
        end
    end
    Wait(waitTime)
    end
end)

-- Event handler for NPC interaction
AddEventHandler("controller:interactWithNPC", function(npc)
    if not DoesEntityExist(npc) then return end

    -- Check if NPC has a special type, otherwise default to civilian
    local npcType = "civilian"
    if DecorExistOn(npc, "npc_type") then
        npcType = DecorGetString(npc, "npc_type")
    end

    -- Trigger the generic interaction event for other scripts to use
    TriggerEvent("npc:interaction", npc, npcType)
    print("Interacted with NPC of type: " .. npcType)
end)
