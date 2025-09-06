-- bounty_mission/client.lua
local inMission = false
local targetBlip = nil
local targetPed = nil

RegisterNetEvent('bounty:selectGender')
AddEventHandler('bounty:selectGender', function()
    local selected = 1
    local options = { "Male", "Female" }
    while true do
        Citizen.Wait(0)
        BeginTextCommandDisplayHelp("STRING")
        AddTextComponentSubstringPlayerName("Select Gender: " ..
        options[selected] .. " (~INPUT_MOVE_LEFT_ONLY~/~INPUT_MOVE_RIGHT_ONLY~) | Confirm: ~INPUT_FRONTEND_ACCEPT~")
        EndTextCommandDisplayHelp(0, false, true, -1)

        if IsControlJustPressed(0, 174) then
            PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
            selected = selected - 1
            if selected < 1 then selected = #options end
        elseif IsControlJustPressed(0, 175) then
            PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
            selected = selected + 1
            if selected > #options then selected = 1 end
        elseif IsControlJustPressed(0, 201) then
            PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
            TriggerServerEvent('bounty:setGender', string.lower(options[selected]))
            break
        end
    end
end)

RegisterNetEvent('bounty:startBountyMission')
AddEventHandler('bounty:startBountyMission', function(gender)
    Citizen.Wait(300000) -- 5 minutes
    local playerPed = PlayerPedId()
    local model = gender == "male" and GetHashKey("s_m_y_blackops_01") or GetHashKey("mp_f_freemode_01")
    RequestModel(model)
    while not HasModelLoaded(model) do Citizen.Wait(0) end
    SetPlayerModel(PlayerId(), model)
    SetModelAsNoLongerNeeded(model)

    GiveWeaponToPed(playerPed, GetHashKey("WEAPON_PISTOL"), 100, false, true)
    GiveWeaponToPed(playerPed, GetHashKey("WEAPON_MICROSMG"), 200, false, true)

    BeginTextCommandDisplayHelp("STRING")
    AddTextComponentSubstringPlayerName(
    "Bounty mission available! Press ~INPUT_CONTEXT~ to accept or ~INPUT_FRONTEND_CANCEL~ to decline.")
    EndTextCommandDisplayHelp(0, false, true, -1)

    local accepted = false
    while true do
        Citizen.Wait(0)
        if IsControlJustPressed(0, 51) then
            accepted = true
            break
        elseif IsControlJustPressed(0, 200) then
            break
        end
    end

    if accepted then
        TriggerServerEvent('bounty:acceptMission')
    else
        TriggerServerEvent('bounty:playerDied')
    end
end)

RegisterNetEvent('bounty:runMission')
AddEventHandler('bounty:runMission', function(level, target)
    if inMission then return end
    inMission = true

    RequestScriptAudioBank("SCRIPT\\BOUNTY_HUNTER", false)
    PlaySoundFrontend(-1, "Remote_Ring", "Phone_SoundSet_Default", true)

    BeginTextCommandDisplayHelp("STRING")
    AddTextComponentSubstringPlayerName("Press ~INPUT_CONTEXT~ to answer the call.")
    EndTextCommandDisplayHelp(0, false, true, -1)

    while true do
        Citizen.Wait(0)
        if IsControlJustPressed(0, 51) then
            StopSound(-1)
            break
        end
    end

    local speech = level == 1 and "BOUNTY_LEVEL1" or level == 2 and "BOUNTY_LEVEL2" or "BOUNTY_LEVEL3"
    PreloadScriptPhoneConversation(true, true)
    StartScriptPhoneConversation(true, false)

    while IsScriptedConversationOngoing() do
        Citizen.Wait(100)
    end

    RequestModel(GetHashKey(target.model))
    while not HasModelLoaded(GetHashKey(target.model)) do Citizen.Wait(0) end
    targetPed = CreatePed(4, GetHashKey(target.model), target.pos.x, target.pos.y, target.pos.z, 0.0, true, true)
    targetBlip = AddBlipForEntity(targetPed)
    SetBlipAsShortRange(targetBlip, true)
    SetBlipSprite(targetBlip, 84)
    SetBlipColour(targetBlip, 1)

    exports['standalone-framework']:ShowNotification('Hunt down the target at the blip.')

    while inMission do
        Citizen.Wait(500)
        if IsEntityDead(targetPed) then
            TriggerServerEvent('bounty:completeMission')
            RemoveBlip(targetBlip)
            DeleteEntity(targetPed)
            inMission = false
            break
        elseif IsEntityDead(PlayerPedId()) then
            TriggerServerEvent('bounty:playerDied')
            RemoveBlip(targetBlip)
            DeleteEntity(targetPed)
            inMission = false
            break
        end
    end
end)

RegisterNetEvent('bounty:notify')
AddEventHandler('bounty:notify', function(msg)
    exports['standalone-framework']:ShowNotification(msg)
end)

AddEventHandler('playerSpawned', function()
    TriggerServerEvent('bounty:getGender')
end)

RegisterCommand('startbounty', function()
    if inMission then return end
    TriggerServerEvent('bounty:getGender')
end, false)
