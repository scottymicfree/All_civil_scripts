-- Client-side bounty hunter system for Civil Unrest RP
local inMission = false
local targetBlip = nil
local targetPed = nil
local missionLevel = 0
local missionTimer = nil
local targetAlive = true

-- Start a bounty mission
RegisterNetEvent('civil_unrest_bounties:startMission')
AddEventHandler('civil_unrest_bounties:startMission', function(level, target)
    if inMission then 
        exports['standalone-framework']:ShowNotification("You're already on a bounty mission.")
        return 
    end
    
    inMission = true
    missionLevel = level
    targetAlive = true
    
    -- Load audio bank
    RequestScriptAudioBank(Config.Audio.bank, false)
    
    -- Play ringtone
    PlaySoundFrontend(-1, Config.Audio.ringtone, Config.Audio.soundSet, true)
    
    -- Show phone notification
    exports['standalone-framework']:ShowNotification("Incoming call from Bounty Dispatcher...")
    
    -- Prompt to answer
    BeginTextCommandDisplayHelp("STRING")
    AddTextComponentSubstringPlayerName("Press ~INPUT_CONTEXT~ to answer the call.")
    EndTextCommandDisplayHelp(0, false, true, -1)
    
    -- Wait for input
    local answered = false
    CreateThread(function()
        local startTime = GetGameTimer()
        while GetGameTimer() - startTime < 10000 do -- 10 second timeout
            Wait(0)
            if IsControlJustPressed(0, 51) then -- E key
                StopSound(-1) -- Stop ringtone
                answered = true
                break
            end
        end
        
        if not answered then
            StopSound(-1)
            inMission = false
            exports['standalone-framework']:ShowNotification("You missed the call.")
        end
    end)
    
    -- Wait for answer
    while not answered and inMission do
        Wait(100)
    end
    
    if not inMission then return end
    
    -- Start phone conversation
    PreloadScriptPhoneConversation(true, true)
    StartScriptPhoneConversation(true, false)
    
    -- Mission briefing based on level
    local messages = {
        [1] = "I've got an easy one for you. This target shouldn't give you much trouble.",
        [2] = "This target has some experience. Be careful, they might be armed.",
        [3] = "High-value target. Extremely dangerous. Bring them in alive for a bonus."
    }
    
    exports['standalone-framework']:ShowNotification("Bounty Dispatcher: " .. messages[level])
    Wait(2000)
    exports['standalone-framework']:ShowNotification("Check your map for the target location.")
    
    -- Wait for conversation to end
    while IsScriptedConversationOngoing() do
        Wait(100)
    end
    
    -- Create target ped
    RequestModel(GetHashKey(target.model))
    while not HasModelLoaded(GetHashKey(target.model)) do Wait(0) end
    
    targetPed = CreatePed(4, GetHashKey(target.model), target.pos.x, target.pos.y, target.pos.z, 0.0, true, true)
    
    -- Set up target based on difficulty
    if level == 1 then
        -- Easy target - unarmed, low health
        SetEntityHealth(targetPed, 120)
        SetPedFleeAttributes(targetPed, 0, false)
        SetPedCombatAttributes(targetPed, 46, true)
    elseif level == 2 then
        -- Medium target - pistol, medium health
        SetEntityHealth(targetPed, 150)
        GiveWeaponToPed(targetPed, GetHashKey("WEAPON_PISTOL"), 36, false, false)
        SetPedAccuracy(targetPed, 30)
        SetPedCombatAttributes(targetPed, 46, true)
        SetPedCombatAttributes(targetPed, 5, true)
    else
        -- Hard target - SMG, high health, good accuracy
        SetEntityHealth(targetPed, 200)
        GiveWeaponToPed(targetPed, GetHashKey("WEAPON_MICROSMG"), 150, false, false)
        SetPedAccuracy(targetPed, 60)
        SetPedCombatAttributes(targetPed, 46, true)
        SetPedCombatAttributes(targetPed, 5, true)
        SetPedCombatRange(targetPed, 2)
    end
    
    -- Add blip
    targetBlip = AddBlipForEntity(targetPed)
    SetBlipSprite(targetBlip, Config.Blip.sprite)
    SetBlipColour(targetBlip, Config.Blip.color)
    SetBlipScale(targetBlip, Config.Blip.scale)
    SetBlipAsShortRange(targetBlip, false)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Bounty Target")
    EndTextCommandSetBlipName(targetBlip)
    
    -- Set mission timer
    missionTimer = GetGameTimer() + Config.MissionTimeout
    
    -- Mission loop
    CreateThread(function()
        while inMission do
            Wait(500)
            
            -- Check if target is dead
            if IsEntityDead(targetPed) then
                targetAlive = false
                exports['standalone-framework']:ShowNotification("Target eliminated. Return to the dispatcher for payment.")
                
                -- Complete mission after a delay
                Wait(5000)
                TriggerServerEvent('civil_unrest_bounties:completeMission', missionLevel, false)
                cleanupMission()
                break
            end
            
            -- Check if player has captured target (close to player and subdued)
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local targetCoords = GetEntityCoords(targetPed)
            local distance = #(playerCoords - targetCoords)
            
            if distance < 3.0 and IsPedCuffed(targetPed) then
                exports['standalone-framework']:ShowNotification("Target captured alive! Return to the dispatcher for payment.")
                
                -- Complete mission
                TriggerServerEvent('civil_unrest_bounties:completeMission', missionLevel, true)
                cleanupMission()
                break
            end
            
            -- Check mission timeout
            if GetGameTimer() > missionTimer then
                exports['standalone-framework']:ShowNotification("Mission failed: Time expired.")
                cleanupMission()
                break
            end
        end
    end)
end)

-- Clean up mission resources
function cleanupMission()
    inMission = false
    
    if DoesBlipExist(targetBlip) then
        RemoveBlip(targetBlip)
    end
    
    if DoesEntityExist(targetPed) then
        DeleteEntity(targetPed)
    end
    
    targetBlip = nil
    targetPed = nil
    missionLevel = 0
    missionTimer = nil
end

-- Notification handler
RegisterNetEvent('civil_unrest_bounties:notify')
AddEventHandler('civil_unrest_bounties:notify', function(message)
    exports['standalone-framework']:ShowNotification(message)
end)

-- Command to start a bounty mission
RegisterCommand('bounty', function()
    if inMission then
        exports['standalone-framework']:ShowNotification("You're already on a bounty mission.")
        return
    end
    
    TriggerServerEvent('civil_unrest_bounties:requestMission')
end, false)

-- Add cuffing ability (simplified)
RegisterCommand('cuff', function()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    
    -- Find closest ped
    local closestPed = nil
    local closestDistance = 3.0
    
    local handle, ped = FindFirstPed()
    local success = true
    
    repeat
        local distance = #(coords - GetEntityCoords(ped))
        if distance < closestDistance and ped ~= playerPed then
            closestPed = ped
            closestDistance = distance
        end
        success, ped = FindNextPed(handle)
    until not success
    
    EndFindPed(handle)
    
    -- Cuff the ped if it's our target
    if closestPed and closestPed == targetPed then
        TaskPlayAnim(playerPed, "mp_arresting", "a_uncuff", 8.0, -8, 3000, 49, 0, false, false, false)
        Wait(3000)
        SetEnableHandcuffs(closestPed, true)
        TaskPlayAnim(closestPed, "mp_arresting", "idle", 8.0, -8, -1, 49, 0, false, false, false)
        exports['standalone-framework']:ShowNotification("Target cuffed.")
    elseif closestPed then
        exports['standalone-framework']:ShowNotification("This person is not your bounty target.")
    else
        exports['standalone-framework']:ShowNotification("No one nearby to cuff.")
    end
end, false)
