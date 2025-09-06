-- NPC Services Client Script
local npcPeds = {}
local activeService = nil
local cooldowns = {}

-- Load model with timeout
local function loadModel(model)
    local modelHash = GetHashKey(model)
    RequestModel(modelHash)
    
    local timeout = 5000
    local startTime = GetGameTimer()
    
    while not HasModelLoaded(modelHash) do
        Citizen.Wait(10)
        if GetGameTimer() - startTime > timeout then
            print("^1[ERROR] Model load timeout: " .. model)
            return false
        end
    end
    
    return modelHash
end

-- Create blips for service locations
local function createBlips()
    for _, location in ipairs(Config.ServiceLocations) do
        local blip = AddBlipForCoord(location.coords.x, location.coords.y, location.coords.z)
        SetBlipSprite(blip, location.blip.sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, location.blip.scale)
        SetBlipColour(blip, location.blip.color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(location.blip.name)
        EndTextCommandSetBlipName(blip)
    end
end

-- Spawn service NPCs
local function spawnServiceNPCs()
    for _, location in ipairs(Config.ServiceLocations) do
        local modelHash = loadModel(location.model)
        
        if modelHash then
            local ped = CreatePed(4, modelHash, location.coords.x, location.coords.y, location.coords.z - 1.0, location.heading, false, true)
            
            -- Configure NPC behavior
            SetBlockingOfNonTemporaryEvents(ped, true)
            SetPedFleeAttributes(ped, 0, 0)
            SetPedDropsWeaponsWhenDead(ped, false)
            FreezeEntityPosition(ped, true)
            SetEntityInvincible(ped, true)
            
            -- Set animation if provided
            if location.animation then
                TaskStartScenarioInPlace(ped, location.animation, 0, true)
            end
            
            -- Store NPC data
            npcPeds[ped] = {
                type = location.type,
                name = location.name,
                coords = location.coords
            }
            
            -- Set model as no longer needed
            SetModelAsNoLongerNeeded(modelHash)
        end
    end
end

-- Draw 3D text in the world
local function draw3DText(coords, text)
    local onScreen, _x, _y = World3dToScreen2d(coords.x, coords.y, coords.z)
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(true)
        AddTextComponentString(text)
        DrawText(_x, _y)
        local factor = (string.len(text)) / 370
        DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 0, 0, 0, 120)
    end
end

-- Show notification
local function showNotification(message)
    SetNotificationTextEntry('STRING')
    AddTextComponentString(message)
    DrawNotification(false, false)
end

-- Check cooldown
local function checkCooldown(serviceType)
    if not cooldowns[serviceType] then
        cooldowns[serviceType] = 0
    end
    
    local currentTime = GetGameTimer()
    if currentTime < cooldowns[serviceType] then
        return false, math.ceil((cooldowns[serviceType] - currentTime) / 1000)
    end
    
    return true
end

-- Set cooldown
local function setCooldown(serviceType)
    cooldowns[serviceType] = GetGameTimer() + Config.Cooldowns[serviceType]
end

-- Handle mechanic service
local function handleMechanicService()
    local playerPed = PlayerPedId()
    
    if not DoesEntityExist(vehicle) then
    showNotification("~r~Vehicle not found.")
    return
end 
    
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    
    -- Create menu options
    local options = {
        {label = "Repair Vehicle ($" .. Config.ServicePrices.mechanic.repair .. ")", value = "repair"},
        {label = "Wash Vehicle ($" .. Config.ServicePrices.mechanic.wash .. ")", value = "wash"},
        {label = "Cancel", value = "cancel"}
    }
    
    -- Display menu (this would use your menu system)
    -- For now, we'll simulate a menu selection
    showNotification("~b~Mechanic: ~w~What service do you need?")
    
    -- Simulate repair selection
    Citizen.Wait(1000)
    
    -- Check if player can afford the service
    TriggerServerEvent('npc_services:requestService', 'mechanic', 'repair', Config.ServicePrices.mechanic.repair)
end

-- Handle taxi service
local function handleTaxiService()
    -- Create menu options
    local options = {
        {label = "Short Ride ($" .. Config.ServicePrices.taxi.short .. ")", value = "short"},
        {label = "Medium Ride ($" .. Config.ServicePrices.taxi.medium .. ")", value = "medium"},
        {label = "Long Ride ($" .. Config.ServicePrices.taxi.long .. ")", value = "long"},
        {label = "Cancel", value = "cancel"}
    }
    
    -- Display menu (this would use your menu system)
    -- For now, we'll simulate a menu selection
    showNotification("~b~Taxi Driver: ~w~Where do you want to go?")
    
    -- Simulate short ride selection
    Citizen.Wait(1000)
    
    -- Check if player can afford the service
    TriggerServerEvent('npc_services:requestService', 'taxi', 'short', Config.ServicePrices.taxi.short)
end

-- Handle medic service
local function handleMedicService()
    -- Create menu options
    local options = {
        {label = "Heal ($" .. Config.ServicePrices.medic.heal .. ")", value = "heal"},
        {label = "Revive ($" .. Config.ServicePrices.medic.revive .. ")", value = "revive"},
        {label = "Cancel", value = "cancel"}
    }
    
    -- Display menu (this would use your menu system)
    -- For now, we'll simulate a menu selection
    showNotification("~b~Doctor: ~w~What medical service do you need?")
    
    -- Simulate heal selection
    Citizen.Wait(1000)
    
    -- Check if player can afford the service
    TriggerServerEvent('npc_services:requestService', 'medic', 'heal', Config.ServicePrices.medic.heal)
end

-- Perform mechanic service
local function performMechanicService(serviceType)
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    
    if not DoesEntityExist(vehicle) then
        showNotification("~r~Vehicle not found.")
        return
    }
    
    if serviceType == "repair" then
        -- Repair animation and sound
        showNotification("~b~Mechanic: ~w~Working on your vehicle...")
        FreezeEntityPosition(vehicle, true)
        
        -- Play repair sound
        PlaySoundFromEntity(-1, "Drill_Pin_Break", vehicle, "DLC_HEIST_FLEECA_SOUNDSET", 1, 0)
        
        -- Wait for repair
        Citizen.Wait(5000)
        
        -- Fix vehicle
        SetVehicleFixed(vehicle)
        SetVehicleDeformationFixed(vehicle)
        SetVehicleUndriveable(vehicle, false)
        SetVehicleEngineOn(vehicle, true, true, false)
        
        FreezeEntityPosition(vehicle, false)
        showNotification("~b~Mechanic: ~w~All fixed up!")
        
    elseif serviceType == "wash" then
        -- Wash animation and sound
        showNotification("~b~Mechanic: ~w~Washing your vehicle...")
        FreezeEntityPosition(vehicle, true)
        
        -- Play wash sound
        PlaySoundFromEntity(-1, "Splash_Water", vehicle, "DLC_Apt_Yacht_Ambient_Soundset", 1, 0)
        
        -- Wait for wash
        Citizen.Wait(3000)
        
        -- Clean vehicle
        SetVehicleDirtLevel(vehicle, 0.0)
        
        FreezeEntityPosition(vehicle, false)
        showNotification("~b~Mechanic: ~w~Your vehicle is clean now!")
    end
    
    -- Set cooldown
    setCooldown("mechanic")
end

-- Perform taxi service
local function performTaxiService(serviceType)
    local playerPed = PlayerPedId()
    
    -- Get destination based on service type
    local destination = vector3(0, 0, 0)
    local destinationName = ""
    
    if serviceType == "short" then
        destination = vector3(253.4, -375.9, 44.1) -- Legion Square
        destinationName = "Legion Square"
    elseif serviceType == "medium" then
        destination = vector3(-1037.6, -2737.7, 20.2) -- Airport
        destinationName = "Los Santos International Airport"
    elseif serviceType == "long" then
        destination = vector3(1852.0, 3685.0, 34.3) -- Sandy Shores
        destinationName = "Sandy Shores"
    end
    
    -- Spawn taxi
    showNotification("~b~Taxi Driver: ~w~Your taxi is on the way...")
    
    -- This would spawn a taxi and drive the player to the destination
    -- For now, we'll just teleport the player
    Citizen.Wait(3000)
    
    -- Teleport player
    SetEntityCoords(playerPed, destination.x, destination.y, destination.z, false, false, false, false)
    
    showNotification("~b~Taxi Driver: ~w~We've arrived at " .. destinationName .. "!")
    
    -- Set cooldown
    setCooldown("taxi")
end

-- Perform medic service
local function performMedicService(serviceType)
    local playerPed = PlayerPedId()
    
    if serviceType == "heal" then
        -- Healing animation
        showNotification("~b~Doctor: ~w~Treating your injuries...")
        
        -- Play heal animation
        RequestAnimDict("mini@cpr@char_a@cpr_str")
        while not HasAnimDictLoaded("mini@cpr@char_a@cpr_str") do
            Citizen.Wait(10)
        end
        
        TaskPlayAnim(playerPed, "mini@cpr@char_a@cpr_str", "cpr_pumpchest", 8.0, -8.0, 5000, 0, 0, false, false, false)
        
        -- Wait for healing
        Citizen.Wait(5000)
        
        -- Heal player
        SetEntityHealth(playerPed, GetEntityMaxHealth(playerPed))
        
        showNotification("~b~Doctor: ~w~You're all patched up!")
        
    elseif serviceType == "revive" then
        -- This would revive a dead player
        -- For now, we'll just heal them
        showNotification("~b~Doctor: ~w~Reviving you...")
        
        -- Wait for revive
        Citizen.Wait(8000)
        
        -- Heal player
        SetEntityHealth(playerPed, GetEntityMaxHealth(playerPed))
        
        showNotification("~b~Doctor: ~w~You've been revived!")
    end
    
    -- Set cooldown
    setCooldown("medic")
end

-- Check for NPC interactions
Citizen.CreateThread(function()
    -- Wait for resource to initialize
    Citizen.Wait(1000)
    
    -- Create blips and spawn NPCs
    createBlips()
    spawnServiceNPCs()
    
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local nearbyNPC = false
        
        -- Check for nearby service NPCs
        for ped, data in pairs(npcPeds) do
            if DoesEntityExist(ped) then
                local pedCoords = GetEntityCoords(ped)
                local dist = #(playerCoords - pedCoords)
                
                if dist < 3.0 then
                    nearbyNPC = true
                    
                    -- Draw interaction text
                    draw3DText(pedCoords + vector3(0, 0, 1.0), "[E] Use " .. data.name .. " Services")
                    
                    -- Check for interaction
                    if IsControlJustReleased(0, 38) then -- E key
                        -- Check cooldown
                        local canUse, timeLeft = checkCooldown(data.type)
                        
                        if canUse then
                            -- Handle service based on type
                            if data.type == "mechanic" then
                                handleMechanicService()
                            elseif data.type == "taxi" then
                                handleTaxiService()
                            elseif data.type == "medic" then
                                handleMedicService()
                            end
                        else
                            showNotification("~r~Please wait " .. timeLeft .. " seconds before using this service again.")
                        end
                    end
                end
            end
        end
        
        -- Optimize wait time
        if nearbyNPC then
            Citizen.Wait(0)
        else
            Citizen.Wait(500)
        end
    end
end)

-- Event handlers
RegisterNetEvent('npc_services:serviceApproved')
AddEventHandler('npc_services:serviceApproved', function(serviceType, service)
    if serviceType == "mechanic" then
        performMechanicService(service)
    elseif serviceType == "taxi" then
        performTaxiService(service)
    elseif serviceType == "medic" then
        performMedicService(service)
    end
end)

RegisterNetEvent('npc_services:serviceDenied')
AddEventHandler('npc_services:serviceDenied', function(reason)
    showNotification("~r~" .. reason)
end)

-- Clean up NPCs when resource stops
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        for ped, _ in pairs(npcPeds) do
            if DoesEntityExist(ped) then
                DeleteEntity(ped)
            end
        end
    end
end)
