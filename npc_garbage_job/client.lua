-- Local variables
local garbagePed = nil
local garbageTruck = nil
local currentBlip = nil
local currentIndex = 0
local isOnDuty = false
local jobBlip = nil
local createdEntities = {}
local cooldown = false

-- Debug function
local function DebugPrint(message)
    if Config.Debug then
        print("[Garbage Job] " .. message)
    end
end

-- Function to load model with timeout
local function LoadModel(model)
    if not IsModelValid(model) then
        DebugPrint("Invalid model: " .. model)
        return false
    end
    
    local hash = GetHashKey(model)
    RequestModel(hash)
    
    -- Add timeout to prevent infinite loading
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(hash) and GetGameTimer() < timeout do 
        Citizen.Wait(100) 
    end
    
    if not HasModelLoaded(hash) then
        DebugPrint("Failed to load model: " .. model)
        return false
    end
    
    return hash
end

-- Function to create a blip
local function CreateJobBlip(coords, sprite, color, scale, name)
    if not Config.EnableBlips then return nil end
    
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, sprite)
    SetBlipColour(blip, color)
    SetBlipAsShortRange(blip, true)
    SetBlipScale(blip, scale)
    
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(name)
    EndTextCommandSetBlipName(blip)
    
    return blip
end

-- Function to track entity for cleanup
local function TrackEntity(entity)
    if DoesEntityExist(entity) then
        table.insert(createdEntities, entity)
        return true
    end
    return false
end

-- Function to clean up all tracked entities
local function CleanupEntities()
    for _, entity in ipairs(createdEntities) do
        if DoesEntityExist(entity) then
            DeleteEntity(entity)
        end
    end
    
    -- Remove any active blips
    if currentBlip then RemoveBlip(currentBlip) end
    if jobBlip then RemoveBlip(jobBlip) end
    
    createdEntities = {}
    DebugPrint("All entities cleaned up")
end

-- Function to create the garbage NPC
local function CreateGarbageNPC()
    -- Load the model
    local hash = LoadModel(Config.NPCModel)
    if not hash then return false end
    
    -- Create the NPC
    garbagePed = CreatePed(4, hash, Config.StartLocation.x, Config.StartLocation.y, Config.StartLocation.z - 1.0, Config.NPCHeading, false, true)
    
    -- Configure the NPC
    if DoesEntityExist(garbagePed) then
        SetEntityInvincible(garbagePed, true)
        SetBlockingOfNonTemporaryEvents(garbagePed, true)
        FreezeEntityPosition(garbagePed, true)
        SetModelAsNoLongerNeeded(hash)
        
        -- Add to tracked entities
        TrackEntity(garbagePed)
        
        -- Add a simple animation
        RequestAnimDict("amb@world_human_clipboard@male@idle_a")
        while not HasAnimDictLoaded("amb@world_human_clipboard@male@idle_a") do
            Citizen.Wait(100)
        end
        
        TaskPlayAnim(garbagePed, "amb@world_human_clipboard@male@idle_a", "idle_a", 8.0, -8.0, -1, 1, 0, false, false, false)
        
        -- Create job blip
        jobBlip = CreateJobBlip(
            Config.StartLocation, 
            Config.JobBlip.sprite, 
            Config.JobBlip.color, 
            Config.JobBlip.scale, 
            Config.JobBlip.name
        )
        
        return true
    else
        DebugPrint("Failed to create garbage NPC")
        return false
    end
end

-- Function to spawn garbage truck
local function SpawnGarbageTruck()
    -- Load the model
    local hash = LoadModel(Config.TruckModel)
    if not hash then return nil end
    
    -- Create the vehicle
    local spawnPoint = Config.TruckSpawnPoint
    garbageTruck = CreateVehicle(hash, spawnPoint.x, spawnPoint.y, spawnPoint.z, spawnPoint.w, true, false)
    
    -- Configure the vehicle
    if DoesEntityExist(garbageTruck) then
        SetEntityAsMissionEntity(garbageTruck, true, true)
        SetVehicleOnGroundProperly(garbageTruck)
        SetVehicleNumberPlateText(garbageTruck, "GARBAGE")
        SetVehicleDirtLevel(garbageTruck, 15.0)
        SetModelAsNoLongerNeeded(hash)
        
        -- Add to tracked entities
        TrackEntity(garbageTruck)
        
        return garbageTruck
    else
        DebugPrint("Failed to create garbage truck")
        return nil
    end
end

-- Function to set next garbage point
local function SetNextGarbagePoint()
    -- Check if route is completed
    if currentIndex > #Config.GarbagePoints then
        -- Route completed
        if currentBlip then RemoveBlip(currentBlip) end
        currentIndex = 0
        isOnDuty = false
        
        -- Notify player
        TriggerEvent("garbage:notify", "Route completed! Return to the depot for payment.", "success")
        
        -- Trigger server event for payment
        TriggerServerEvent("garbage:routeCompleted")
        
        return false
    end
    
    -- Remove previous blip if exists
    if currentBlip then RemoveBlip(currentBlip) end
    
    -- Get current point coordinates
    local coords = Config.GarbagePoints[currentIndex]
    
    -- Create new blip
    currentBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(currentBlip, 318)
    SetBlipColour(currentBlip, 2)
    SetBlipRoute(currentBlip, true)
    SetBlipRouteColour(currentBlip, 2)
    
    -- Notify player
    TriggerEvent("garbage:notify", "Proceed to the next garbage collection point.", "info")
    
    return true
end

-- Function to start garbage route
local function StartGarbageRoute()
    if cooldown then
        TriggerEvent("garbage:notify", "You must wait before starting another route.", "error")
        return
    end
    
    -- Set cooldown
    cooldown = true
    
    -- Spawn truck
    local truck = SpawnGarbageTruck()
    if not truck then
        TriggerEvent("garbage:notify", "Failed to spawn garbage truck.", "error")
        cooldown = false
        return
    end
    
    -- Set on duty
    isOnDuty = true
    currentIndex = 1
    
    -- Set first garbage point
    SetNextGarbagePoint()
    
    -- Notify player
    TriggerEvent("garbage:notify", "Garbage route started. Get in the truck and follow the GPS.", "success")
    
    -- Reset cooldown after delay
    Citizen.SetTimeout(Config.JobCooldown * 60000, function()
        cooldown = false
    end)
end

-- Initialize the garbage job
Citizen.CreateThread(function()
    -- Wait for game to load
    Citizen.Wait(2000)
    
    -- Create the NPC
    if not CreateGarbageNPC() then
        DebugPrint("Failed to initialize garbage job")
        return
    end
    
    DebugPrint("Garbage job initialized")
end)

-- Main interaction loop with optimized performance
Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local sleep = 1000 -- Default sleep time when far away
        
        -- Check if player is close to the NPC
        if not isOnDuty and DoesEntityExist(garbagePed) then
            local distance = #(playerCoords - Config.StartLocation)
            
            if distance < 10.0 then
                sleep = 500 -- Medium sleep time when somewhat close
                
                -- Check if player is within interaction distance
                if distance < 2.5 then
                    sleep = 0 -- No sleep when in interaction range
                    
                    -- Draw interaction text
                    DrawText3D(Config.StartLocation.x, Config.StartLocation.y, Config.StartLocation.z + 1.0, "[E] Start Garbage Route")
                    
                    -- Check for interaction key press
                    if IsControlJustReleased(0, 38) and not cooldown then
                        -- Trigger server event
                        TriggerServerEvent("garbage:getStart")
                    end
                end
            end
        end
        
        -- Check if player is on duty and near a garbage point
        if isOnDuty and currentIndex > 0 and currentIndex <= #Config.GarbagePoints then
            local garbagePoint = Config.GarbagePoints[currentIndex]
            local distance = #(playerCoords - garbagePoint)
            
            if distance < 50.0 then
                sleep = 500
                
                if distance < 5.0 then
                    sleep = 0
                    
                    -- Draw interaction text
                    DrawText3D(garbagePoint.x, garbagePoint.y, garbagePoint.z + 1.0, "[E] Collect Garbage")
                    
                    -- Check for interaction key press
                    if IsControlJustReleased(0, 38) and not IsPedInAnyVehicle(playerPed, false) then
                        -- Play animation
                        RequestAnimDict("anim@heists@narcotics@trash")
                        while not HasAnimDictLoaded("anim@heists@narcotics@trash") do
                            Citizen.Wait(100)
                        end
                        
                        TaskPlayAnim(playerPed, "anim@heists@narcotics@trash", "pickup", 8.0, -8.0, -1, 1, 0, false, false, false)
                        Citizen.Wait(3000)
                        ClearPedTasks(playerPed)
                        
                        -- Increment to next point
                        currentIndex = currentIndex + 1
                        
                        -- Trigger server event for point completion
                        TriggerServerEvent("garbage:pointCompleted")
                        
                        -- Set next point
                        SetNextGarbagePoint()
                    end
                end
            end
        end
        
        Citizen.Wait(sleep)
    end
end)

-- Helper function to draw 3D text
function DrawText3D(x, y, z, text)
    -- Get screen coordinates
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    
    -- Only draw if on screen
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(true)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

-- Notification handler
RegisterNetEvent("garbage:notify")
AddEventHandler("garbage:notify", function(message, type)
    if type == "error" then
        -- Red notification
        BeginTextCommandThefeedPost("STRING")
        AddTextComponentSubstringPlayerName("~r~" .. message)
        EndTextCommandThefeedPostTicker(true, false)
    elseif type == "success" then
        -- Green notification
        BeginTextCommandThefeedPost("STRING")
        AddTextComponentSubstringPlayerName("~g~" .. message)
        EndTextCommandThefeedPostTicker(true, false)
    else
        -- Default notification
        BeginTextCommandThefeedPost("STRING")
        AddTextComponentSubstringPlayerName(message)
        EndTextCommandThefeedPostTicker(false, false)
    end
end)

-- Event handler for starting route
RegisterNetEvent("garbage:startRoute")
AddEventHandler("garbage:startRoute", function()
    StartGarbageRoute()
end)

-- Clean up when resource stops
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        CleanupEntities()
    end
end)
