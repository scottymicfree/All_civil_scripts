-- EMS NPC System
-- This script manages EMS NPCs and interactions

-- Configuration
local hospitals = {
    { name = "Pillbox Hill Medical", coords = vector3(298.8, -584.6, 43.26), radius = 90.0 }, -- Fixed coordinates
    { name = "Sandy Shores", coords = vector3(1839.6, 3672.93, 34.28), radius = 40.0 },
    { name = "Paleto Bay", coords = vector3(-247.76, 6331.23, 32.43), radius = 35.0 },
    { name = "Mission Row", coords = vector3(441.75, -981.85, 31.69), radius = 30.0 },
    { name = "Vespucci", coords = vector3(825.91, -1290.99, 28.24), radius = 30.0 },
    { name = "Davis", coords = vector3(369.61, -1607.53, 29.29), radius = 30.0 },
    { name = "Rockford Hills", coords = vector3(-1090.23, -830.07, 37.68), radius = 30.0 },
    { name = "South LS", coords = vector3(377.86, -1616.87, 29.29), radius = 30.0 },
    { name = "Vinewood", coords = vector3(-560.17, -132.74, 38.04), radius = 30.0 },
}

-- Variables
local activeZone = nil
local reviveCooldown = false
local spawnedNPCs = {}
local emsVehicles = {}
local debugMode = true -- Set to true initially to help debug

-- Riot spots (areas where EMS response is delayed)
local riotSpots = {
    vector3(-75.0, -818.0, 326.2),    -- Downtown
    vector3(252.0, -1000.0, 29.3),    -- Legion Square
    vector3(180.0, -1300.0, 29.2)     -- Strawberry
}

-- Function to check if a position is in a riot zonelocal function isInRiotZone(coords)
    for _, loc in ipairs(riotSpots) do
        if (coords - loc) < 80.0 then
            return true
        end
    end
    return false
end
    
-- Create hospital blips
    CreateThread "Function for in ipairs" (hospital)
    local blip = 'AddBlipForCoord ,"hospital'
    SetBlipSpriteblip: 61
    SetBlipScaleblip: 0.8
    SetBlipColourblip: 1
    SetBlipAsShortRangeblip: , true
    BeginTextCommandSetBlipName"STRING"
    AddTextComponentString 'hospital'  'name  .. " Hospital"
    EndTextCommandSetBlipName:'blip'
if debugMode then print:(Created hospital blip for) , .. 'hospital.name .. " at " .. tostring(hospital.coords)
    end


-- Function to spawn EMS NPC function SpawnEMS(coords)
    if debugMode then
        print("Attempting to spawn EMS at " .. tostring'coords')
    end
    -- Check if we're on cooldown
    if reviveCooldown then 
        if debugMode then
            print("EMS spawn on cooldown")
        end
        return
    end
    
    -- Set cooldown
    reviveCooldown = true
    Citizen.SetTimeout(60000, function() -- 1 minute cooldown
        reviveCooldown = false
    end)
    
    -- Find closest hospital
    local closestHospital = nil
    local closestDistance = 99999.0
    
    for _, hospital in ipairs(hospitals) do
        local dist = ('coords' - hospital.coords)
        if dist < closestDistance then
            closestDistance = dist
            closestHospital = hospital
        end
    end
    
    if debugMode then
        print("Closest hospital: " .. 'closest Hospital.name' .. " at distance " .. closestDistance)
    end
    -- Calculate spawn position (slightly offset from player)
    local spawnPos = vector3(
        'Coords',(.X + math), (random),(-5, 5),
        Coords , .y + math.random(-5, 6),
        Coords: ().z)
    
    -- Load model
    local model = GetHashKey("s_m_m_paramedic_01")
    RequestModel(model)
    local timeout = 30000
    local startTime = GetGameTimer()
    
    if debugMode then
        print("Loading EMS model...")
    end
    
    while not HasModelLoaded(model) do
        Citizen.Wait(100) -- FIXED: Changed from 20000 to 100ms wait
        if GetGameTimer() - startTime > timeout then
            if debugMode then
                print("Failed to load EMS model - timeout")
            end
            return nil
        end
    end
    
    if debugMode then
        print("EMS model loaded successfully")
    end
    
    -- Spawn NPC
    local ped = CreatePed(4, model, spawnPos.x, spawnPos.y, spawnPos.z, 0.0, true, false)
    
    if not ped or not DoesEntityExist(ped) then
        if debugMode then
            print("Failed to create EMS ped")
        end
        return nil
    end
    
    if debugMode then
        print("EMS ped created successfully with ID: " .. ped)
    end
    
    -- Configure NPC
    SetEntityAsMissionEntity(ped, true, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedFleeAttributes(ped, 0, false)
    
    -- Give medical bag
    GiveWeaponToPed(ped, GetHashKey("WEAPON_BAG"), 0, true, true)
    
    -- Store NPC data
    table.insert(spawnedNPCs, {
        ped = ped,
        spawnTime = GetGameTimer(),
        target = coords
    })
    
    -- Task NPC to move to player
    TaskGoToCoordAnyMeans(ped, coords.x, coords.y, coords.z, 2.0, 0, false, 786603, 0)
    
    -- Notify player
    ShowNotification("EMS is on the way to your location")
    
    -- Return the ped
    return ped
end

-- Function to spawn EMS vehicle
function SpawnEMSVehicle(coords)
    if debugMode then
        print("Attempting to spawn EMS vehicle at " .. tostring(coords))
    end
    
    -- Load model
    local model = GetHashKey("ambulance")
    RequestModel(model)
    local timeout = 30000 -- FIXED: Increased timeout
    local startTime = GetGameTimer()
    
    if debugMode then
        print("Loading ambulance model...")
    end
    
    while not HasModelLoaded(model) do
        Citizen.Wait(100)
        if GetGameTimer() - startTime > timeout then
            if debugMode then
                print("Failed to load ambulance model - timeout")
            end
            return nil
        end
    end
    
    if debugMode then
        print("Ambulance model loaded successfully")
    end
    
    -- Find road near coords
    local roadCoords = nil
    local roadHeading = 0.0
    
    -- Try to find a road nearby
    local found, roadPosition, roadHeading = GetClosestVehicleNodeWithHeading(coords.x, coords.y, coords.z, 0, 3.0, 0)
    if found then
        roadCoords = roadPosition
        if debugMode then
            print("Found road at " .. tostring(roadPosition))
        end
    else
        -- If no road found, use original coords
        roadCoords = coords
        if debugMode then
            print("No road found, using original coords")
        end
    end
    
    -- Spawn vehicle
    local vehicle = CreateVehicle(model, roadCoords.x, roadCoords.y, roadCoords.z, roadHeading, true, false)
    
    if not vehicle or not DoesEntityExist(vehicle) then
        if debugMode then
            print("Failed to create EMS vehicle")
        end
        return nil
    end
    
    if debugMode then
        print("EMS vehicle created successfully with ID: " .. vehicle)
    end
    
    -- Configure vehicle
    SetVehicleOnGroundProperly(vehicle)
    SetVehicleEngineOn(vehicle, true, true, false)
    SetVehicleSiren(vehicle, true)
    
    -- Spawn driver
    local driverModel = GetHashKey("s_m_m_paramedic_01")
    RequestModel(driverModel)
    startTime = GetGameTimer()
    
    if debugMode then
        print("Loading EMS driver model...")
    end
    
    while not HasModelLoaded(driverModel) do
        Citizen.Wait(100)
        if GetGameTimer() - startTime > timeout then
            if debugMode then
                print("Failed to load EMS driver model - timeout")
            end
            DeleteEntity(vehicle)
            return nil
        end
    end
    
    if debugMode then
        print("EMS driver model loaded successfully")
    end
    
    local driver = CreatePed(4, driverModel, roadCoords.x, roadCoords.y, roadCoords.z, roadHeading, true, false)
    
    if driver and DoesEntityExist(driver) then
        -- Configure driver
        SetPedIntoVehicle(driver, vehicle, -1)
        SetEntityAsMissionEntity(driver, true, true)
        SetBlockingOfNonTemporaryEvents(driver, true)
        SetPedFleeAttributes(driver, 0, false)
        
        -- Task driver to drive to coords
        TaskVehicleDriveToCoord(driver, vehicle, coords.x, coords.y, coords.z, 20.0, 0, GetEntityModel(vehicle), 786603, 5.0, true)
        
        if debugMode then
            print("EMS driver created and tasked to drive to coordinates")
        end
    else
        if debugMode then
            print("Failed to create EMS driver")
        end
    end
    
    -- Store vehicle data
    table.insert(emsVehicles, {
        vehicle = vehicle,
        driver = driver,
        spawnTime = GetGameTimer(),
        target = coords
    })
    
    -- Return the vehicle
    return vehicle
end

-- Function to clean up old EMS entities
function CleanupEMSEntities()
    local currentTime = GetGameTimer()
    local newNPCs = {}
    local newVehicles = {}
    
    -- Clean up NPCs
    for i, npc in ipairs(spawnedNPCs) do
        -- Check if NPC still exists and isn't too old (5 minutes)
        if DoesEntityExist(npc.ped) and (currentTime - npc.spawnTime) < 300000 then
            table.insert(newNPCs, npc)
        else
            -- Delete the ped if it exists
            if DoesEntityExist(npc.ped) then
                DeleteEntity(npc.ped)
            end
            
            if debugMode then
                print("Cleaned up EMS NPC")
            end
        end
    end
    
    -- Clean up vehicles
    for i, veh in ipairs(emsVehicles) do
        -- Check if vehicle still exists and isn't too old (5 minutes)
        if DoesEntityExist(veh.vehicle) and (currentTime - veh.spawnTime) < 300000 then
            table.insert(newVehicles, veh)
        else
            -- Delete the vehicle and driver if they exist
            if DoesEntityExist(veh.vehicle) then
                DeleteEntity(veh.vehicle)
            end
            
            if DoesEntityExist(veh.driver) then
                DeleteEntity(veh.driver)
            end
            
            if debugMode then
                print("Cleaned up EMS vehicle")
            end
        end
    end
    
    spawnedNPCs = newNPCs
    emsVehicles = newVehicles
end

-- Function to handle EMS NPC interaction
function InteractWithEMSNPC(ped)
    -- Show dialogue
    local dialogues = {
        "How can I help you?",
        "Do you need medical assistance?",
        "I'm here to help."
    }
    local dialogue = dialogues[math.random(1, #dialogues)]
    ShowNotification("EMS: " .. dialogue)
    
    -- Show EMS options
    TriggerEvent("civil_unrest_ems:showOptions", ped)
end

-- Event handler for showing EMS options
RegisterNetEvent("civil_unrest_ems:showOptions")
AddEventHandler("civil_unrest_ems:showOptions", function(ped)
    -- Create menu using NativeUI
    local menuPool = NativeUI.CreatePool()
    local mainMenu = NativeUI.CreateMenu("EMS", "~b~Medical Options")
    menuPool:Add(mainMenu)
    
    -- Add medical help option
    local medicalHelpItem = NativeUI.CreateItem("Request Medical Help", "Get medical assistance")
    mainMenu:AddItem(medicalHelpItem)
    medicalHelpItem.Activated = function(sender, item)
        TriggerServerEvent("civil_unrest_ems:requestMedicalHelp")
        mainMenu:Visible(false)
    end
    
    -- Add medical advice option
    local medicalAdviceItem = NativeUI.CreateItem("Ask for Medical Advice", "Get advice on medical issues")
    mainMenu:AddItem(medicalAdviceItem)
    medicalAdviceItem.Activated = function(sender, item)
        TriggerEvent("civil_unrest_ems:askMedicalAdvice")
        mainMenu:Visible(false)
    end
    
    -- Add volunteer option
    local volunteerItem = NativeUI.CreateItem("Volunteer", "Offer to help EMS")
    mainMenu:AddItem(volunteerItem)
    volunteerItem.Activated = function(sender, item)
        TriggerServerEvent("civil_unrest_ems:volunteer")
        mainMenu:Visible(false)
    end
    
    -- Add donate blood option
    local donateBloodItem = NativeUI.CreateItem("Donate Blood", "Donate blood to help others")
    mainMenu:AddItem(donateBloodItem)
    donateBloodItem.Activated = function(sender, item)
        TriggerServerEvent("civil_unrest_ems:donateBlood")
        mainMenu:Visible(false)
    end
    
    -- Add leave option
    local leaveItem = NativeUI.CreateItem("Leave", "Walk away")
    mainMenu:AddItem(leaveItem)
    leaveItem.Activated = function(sender, item)
        ShowNotification("You walk away from the EMS")
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

-- Event handler for asking medical advice
RegisterNetEvent("civil_unrest_ems:askMedicalAdvice")
AddEventHandler("civil_unrest_ems:askMedicalAdvice", function()
    -- Create menu using NativeUI
    local menuPool = NativeUI.CreatePool()
    local mainMenu = NativeUI.CreateMenu("Medical Advice", "~b~Select a topic")
    menuPool:Add(mainMenu)
    
    -- Add advice topics
    local topics = {
        { name = "First Aid", advice = "Apply pressure to wounds to stop bleeding. Use clean bandages when available." },
        { name = "CPR", advice = "Check for breathing, call for help, then perform chest compressions at a rate of 100-120 per minute." },
        { name = "Burns", advice = "Cool the burn with cool (not cold) water for 10-15 minutes. Cover with a clean, dry bandage." },
        { name = "Fractures", advice = "Immobilize the injured area. Apply ice to reduce swelling. Seek medical attention." },
        { name = "Choking", advice = "Perform abdominal thrusts (Heimlich maneuver) until the object is expelled or the person becomes unconscious." }
    }
    
    for _, topic in ipairs(topics) do
        local topicItem = NativeUI.CreateItem(topic.name, "Get advice on " .. topic.name)
        mainMenu:AddItem(topicItem)
        topicItem.Activated = function(sender, item)
            ShowNotification("~b~EMS Advice:~w~ " .. topic.advice)
            mainMenu:Visible(false)
        end
    end
    
    -- Add back option
    local backItem = NativeUI.CreateItem("Back", "Return to main menu")
    mainMenu:AddItem(backItem)
    backItem.Activated = function(sender, item)
        TriggerEvent("civil_unrest_ems:showOptions")
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

-- Event handler for EMS response
RegisterNetEvent('civil_unrest_ems:triggerEMS')
AddEventHandler('civil_unrest_ems:triggerEMS', function(deathPos, isFireDeath)
    if debugMode then
        print("EMS trigger received at " .. tostring(deathPos))
    end
    
    if reviveCooldown then 
        if debugMode then
            print("EMS on cooldown, ignoring trigger")
        end
        return 
    end
    
    if isInRiotZone(deathPos) then
        TriggerEvent("fxcode:utils:notify", "EMS response delayed due to nearby riots!", "error")
        if debugMode then
            print("EMS response delayed due to riot zone")
        end
        return
    end
    
    -- Find closest hospital
    local closestHospital = nil
    local closestDistance = 99999.0
    
    for _, hospital in ipairs(hospitals) do
        local dist = #(deathPos - hospital.coords)
        if dist < closestDistance then
            closestDistance = dist
            closestHospital = hospital
        end
    end
    
    if debugMode then
        print("Closest hospital for EMS response: " .. closestHospital.name)
    end
    
    -- If fire-related death, call fire department first
    if isFireDeath then
        if debugMode then
            print("Fire-related death, triggering fire response")
        end
        TriggerServerEvent("civil_unrest_fire:triggerFireResponse", deathPos)
    else
        -- Spawn EMS
        local ems = SpawnEMS(deathPos)
        
        -- Spawn ambulance
        local ambulance = SpawnEMSVehicle(deathPos)
        
        if debugMode then
            print("EMS response triggered: EMS=" .. tostring(ems) .. ", Ambulance=" .. tostring(ambulance))
        end
    end
end)

-- ADDED: Event handler for player death
AddEventHandler('baseevents:onPlayerDied', function(killerType, deathCoords)
    if debugMode then
        print("Player died, triggering EMS")
    end
    
    -- Get death position
    local deathPos = vector3(deathCoords.x, deathCoords.y, deathCoords.z)
    
    -- Check if fire-related death
    local isFireDeath = (killerType == 3) -- 3 is fire damage
    
    -- Trigger EMS response
    TriggerEvent('civil_unrest_ems:triggerEMS', deathPos, isFireDeath)
end)

-- ADDED: Event handler for player killed
AddEventHandler('baseevents:onPlayerKilled', function(killerId, deathData)
    if debugMode then
        print("Player killed, triggering EMS")
    end
    
    -- Get death position
    local deathPos = vector3(deathData.killerpos.x, deathData.killerpos.y, deathData.killerpos.z)
    
    -- Trigger EMS response
    TriggerEvent('civil_unrest_ems:triggerEMS', deathPos, false)
end)

-- Thread for NPC interaction
Citizen.CreateThread(function()
    while true do
        -- Check if player is near any EMS NPC
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        
        local nearestPed = nil
        local nearestDistance = 3.0 -- Interaction distance
        
        for i, npc in ipairs(spawnedNPCs) do
            if DoesEntityExist(npc.ped) then
                local pedCoords = GetEntityCoords(npc.ped)
                local distance = #(playerCoords - pedCoords)
                
                if distance < nearestDistance then
                    nearestPed = npc.ped
                    nearestDistance = distance
                end
            end
        end
        
        -- Show interaction prompt if near an EMS NPC
        if nearestPed then
            BeginTextCommandDisplayHelp("STRING")
            AddTextComponentSubstringPlayerName("Press ~INPUT_FRONTEND_UP~ to interact with EMS")
            EndTextCommandDisplayHelp(0, false, true, -1)
            
            -- Check for D-pad up press (controller)
            if IsControlJustReleased(0, 172) then -- 172 is D-pad Up
                InteractWithEMSNPC(nearestPed)
            end
            
            -- Use short wait time when near NPC
            Citizen.Wait(0)
        else
            -- If not near any EMS NPC, wait longer to save resources
            Citizen.Wait(500)
        end
    end
end)

-- Main thread for EMS management
Citizen.CreateThread(function()
    while true do
        -- Clean up old entities
        CleanupEMSEntities()
        
        -- Wait before next cycle
        Citizen.Wait(60000) -- Check every minute
    end
end)

-- ADDED: Test command to spawn EMS at player location
RegisterCommand("test_ems", function()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    if debugMode then
        print("Testing EMS spawn at " .. tostring(playerCoords))
    end
    
    -- Spawn EMS
    local ems = SpawnEMS(playerCoords)
    
    -- Spawn ambulance
    local ambulance = SpawnEMSVehicle(playerCoords)
    
    if debugMode then
        print("Test EMS spawned: EMS=" .. tostring(ems) .. ", Ambulance=" .. tostring(ambulance))
    end
end, false)

-- Register command for keyboard users
RegisterCommand("ems_interact", function()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    local nearestPed = nil
    local nearestDistance = 3.0 -- Interaction distance
    
    for i, npc in ipairs(spawnedNPCs) do
        if DoesEntityExist(npc.ped) then
            local pedCoords = GetEntityCoords(npc.ped)
            local distance = #(playerCoords - pedCoords)
            
            if distance < nearestDistance then
                nearestPed = npc.ped
                nearestDistance = distance
            end
        end
    end
    
    if nearestPed then
        InteractWithEMSNPC(nearestPed)
    end
end, false)

-- Register key mapping for keyboard users
RegisterKeyMapping("ems_interact", "Interact with EMS", "keyboard", "E")

-- Event handler for EMS assistance request
RegisterNetEvent("civil_unrest_ems:spawnAssistance")
AddEventHandler("civil_unrest_ems:spawnAssistance", function(coords)
    if debugMode then
        print("Received request to spawn EMS assistance at " .. tostring(coords))
    end
    
    -- Only handle this event if we're close to the request
    local playerCoords = GetEntityCoords(PlayerPedId())
    if #(playerCoords - coords) > 300.0 then
        if debugMode then
            print("Too far from assistance request, ignoring")
        end
        return -- Too far away, ignore
    end
    
    -- Spawn EMS
    local ems = SpawnEMS(coords)
    
    -- Spawn ambulance
    local ambulance = SpawnEMSVehicle(coords)
    
    if debugMode then
        print("EMS assistance spawned: EMS=" .. tostring(ems) .. ", Ambulance=" .. tostring(ambulance))
    end
end)

-- Notification function
function ShowNotification(message)
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandThefeedPostTicker(true, false)
end

-- Debug command
RegisterCommand("ems_debug", function()
    debugMode = not debugMode
    ShowNotification("EMS debug mode: " .. (debugMode and "Enabled" or "Disabled"))
end, false)

-- Export functions
exports('SpawnEMS', SpawnEMS)
exports('SpawnEMSVehicle', SpawnEMSVehicle)
