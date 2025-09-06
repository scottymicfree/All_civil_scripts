-- job_wheel/client.lua
local characterPeds = {}
local jobBlips = {}
local isWheelOpen = false

local characters = {
    male = {
        { name = "Police Officer", model = "g_m_y_rampmex",      job = "police",      pos = vector3(50.0, 50.0, 30.0) },
        { name = "Gang Member",    model = "g_m_y_afriamer_01",  job = "drugdealer",  pos = vector3(55.0, 50.0, 30.0) },
        { name = "Firefighter",    model = "s_m_y_fireman_01",   job = "firefighter", pos = vector3(60.0, 50.0, 30.0) },
        { name = "Paramedic",      model = "s_m_m_paramedic_01", job = "ems",         pos = vector3(65.0, 50.0, 30.0) }
    },
    female = {
        { name = "Police Officer", model = "ig_karendanie",      job = "police",      pos = vector3(50.0, 50.0, 30.0) },
        { name = "Gang Member",    model = "a_f_y_juggalo_01",   job = "drugdealer",  pos = vector3(55.0, 50.0, 30.0) },
        { name = "Firefighter",    model = "s_f_y_fireman_01",   job = "firefighter", pos = vector3(60.0, 50.0, 30.0) },
        { name = "Paramedic",      model = "s_f_y_paramedic_01", job = "ems",         pos = vector3(65.0, 50.0, 30.0) }
    }
}

-- Function to show the job wheel
function ShowJobWheel(gender)
    if isWheelOpen then return end
    isWheelOpen = true
    
    SetPlayerControl(PlayerId(), false, 0)
    DisplayHud(false)

    local charList = characters[gender]
    for i, char in ipairs(charList) do
        RequestModel(GetHashKey(char.model))
        while not HasModelLoaded(GetHashKey(char.model)) do Citizen.Wait(0) end
        local ped = CreatePed(4, GetHashKey(char.model), char.pos.x, char.pos.y, char.pos.z, 0.0, false, false)
        SetEntityVisible(ped, false, false)
        characterPeds[i] = ped
    end

    local playerPed = PlayerPedId()
    local camPos = GetEntityCoords(playerPed) + vector3(0.0, 5.0, 2.0)
    
    -- Try to use the switch player camera system
    if _SET_PLAYER_SWITCH_OUTRO then
        _SET_PLAYER_SWITCH_OUTRO(camPos.x, camPos.y, camPos.z, 0.0, 0.0, 0.0, 45.0, 2, 0, 0)
        _SWITCH_OUT_PLAYER(playerPed, 0, 1)
    end

    local selectedCharacter = 1
    local wheelActive = true
    while wheelActive do
        Citizen.Wait(0)
        BeginTextCommandDisplayHelp("STRING")
        AddTextComponentSubstringPlayerName("Select Job: " ..
        charList[selectedCharacter].name ..
        " (~INPUT_MOVE_LEFT_ONLY~/~INPUT_MOVE_RIGHT_ONLY~) | Confirm: ~INPUT_FRONTEND_ACCEPT~")
        EndTextCommandDisplayHelp(0, false, true, -1)

        if IsControlJustPressed(0, 174) then
            PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
            selectedCharacter = selectedCharacter - 1
            if selectedCharacter < 1 then selectedCharacter = #charList end
        elseif IsControlJustPressed(0, 175) then
            PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
            selectedCharacter = selectedCharacter + 1
            if selectedCharacter > #charList then selectedCharacter = 1 end
        elseif IsControlJustPressed(0, 201) then
            PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
            wheelActive = false
        end
    end

    local newPed = characterPeds[selectedCharacter]
    SetEntityVisible(newPed, true, false)
    
    -- Try to use the switch player camera system for transition
    if _SWITCH_IN_PLAYER then
        _SWITCH_IN_PLAYER(newPed)
    end
    
    SetPlayerModel(PlayerId(), GetHashKey(charList[selectedCharacter].model))
    SetPlayerControl(PlayerId(), true, 0)
    DisplayHud(true)

    for i, ped in ipairs(characterPeds) do
        if i ~= selectedCharacter then
            DeleteEntity(ped)
        end
    end
    characterPeds = {}

    TriggerServerEvent('jobwheel:setJob', charList[selectedCharacter].job)
    isWheelOpen = false
end

-- Function to trigger the job wheel
function TriggerJobWheel()
    -- Default to male if we can't determine
    local gender = "male"
    
    -- Try to get gender from player model
    local playerModel = GetEntityModel(PlayerPedId())
    if playerModel == GetHashKey("mp_f_freemode_01") then
        gender = "female"
    end
    
    ShowJobWheel(gender)
end

RegisterNetEvent('jobwheel:showJobWheel')
AddEventHandler('jobwheel:showJobWheel', function(gender)
    if not gender or (gender ~= "male" and gender ~= "female") then
        gender = "male" -- Default to male if invalid
    end
    ShowJobWheel(gender)
end)

RegisterNetEvent('jobwheel:setupJob')
AddEventHandler('jobwheel:setupJob', function(job)
    for _, blip in ipairs(jobBlips) do
        RemoveBlip(blip)
    end
    jobBlips = {}

    if job == "drugdealer" then
        local blip = AddBlipForCoord(333.84, -2040.52, 21.07) -- Vagos Turf
        SetBlipSprite(blip, 51)
        SetBlipColour(blip, 5)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName("Dealing Spot")
        EndTextCommandSetBlipName(blip)
        table.insert(jobBlips, blip)
        exports['standalone-framework']:ShowNotification('Head to the Vagos Turf to sell drugs.')
        
        -- Give drug dealer equipment
        local playerPed = PlayerPedId()
        GiveWeaponToPed(playerPed, GetHashKey("WEAPON_PISTOL"), 100, false, true)
        
    elseif job == "police" then
        local blip = AddBlipForCoord(1142.54, -1522.71, 34.84) -- Eastside Ballas
        SetBlipSprite(blip, 60)
        SetBlipColour(blip, 7)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName("Wanted Criminal")
        EndTextCommandSetBlipName(blip)
        table.insert(jobBlips, blip)
        exports['standalone-framework']:ShowNotification('Dispatch: Suspect at Eastside Ballas turf. Proceed to arrest.')
        
        -- Give police weapons
        local playerPed = PlayerPedId()
        GiveWeaponToPed(playerPed, GetHashKey("WEAPON_STUNGUN"), 100, false, true)
        GiveWeaponToPed(playerPed, GetHashKey("WEAPON_NIGHTSTICK"), 0, false, true)
        GiveWeaponToPed(playerPed, GetHashKey("WEAPON_PISTOL"), 100, false, true)
        
    elseif job == "ems" then
        local blip = AddBlipForCoord(-1604.66, -3012.58, 13.94) -- Red Hood
        SetBlipSprite(blip, 153)
        SetBlipColour(blip, 1)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName("Injured Person")
        EndTextCommandSetBlipName(blip)
        table.insert(jobBlips, blip)
        exports['standalone-framework']:ShowNotification('Dispatch: Injured person at Red Hood turf. Proceed to revive.')
        
        -- Give EMS equipment
        local playerPed = PlayerPedId()
        GiveWeaponToPed(playerPed, GetHashKey("WEAPON_FLASHLIGHT"), 0, false, true)
        
    elseif job == "firefighter" then
        local blip = AddBlipForCoord(400.0, 400.0, 30.0) -- Placeholder
        SetBlipSprite(blip, 436)
        SetBlipColour(blip, 1)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName("Fire Incident")
        EndTextCommandSetBlipName(blip)
        table.insert(jobBlips, blip)
        exports['standalone-framework']:ShowNotification(
        'Dispatch: Fire reported at marked location. Proceed to extinguish.')
        
        -- Give firefighter equipment
        local playerPed = PlayerPedId()
        GiveWeaponToPed(playerPed, GetHashKey("WEAPON_FIREEXTINGUISHER"), 1000, false, true)
    end
end)

RegisterNetEvent('jobwheel:clearJobBlips')
AddEventHandler('jobwheel:clearJobBlips', function()
    for _, blip in ipairs(jobBlips) do
        RemoveBlip(blip)
    end
    jobBlips = {}
    exports['standalone-framework']:ShowNotification('Job activity timed out.')
end)

RegisterNetEvent('jobwheel:notify')
AddEventHandler('jobwheel:notify', function(msg)
    exports['standalone-framework']:ShowNotification(msg)
end)

-- Controller input thread
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        -- D-pad Right: Open job wheel
        if IsControlJustPressed(0, 307) and not isWheelOpen then -- D-pad right
            TriggerJobWheel()
        end
    end
end)

-- Export the function
exports('TriggerJobWheel', TriggerJobWheel)
