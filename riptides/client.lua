-- riptides/client.lua
print("[RIPTIDES] Client script loaded.")

local spawnedSurfers = {}
local spawnedProps = {}
local spawnedVehicles = {}
local spawnedDogs = {}
local chillCooldown = 0
local isInSurferTerritory = false
local playerPed = nil
local playerCoords = nil
local surferBlips = {}
local territoryBlip = nil
local activeMission = nil
local playerHasProtection = false
local protectionEndTime = 0
local activeRentedSurfboard = nil
local surfLessonsActive = false

-- Beach vehicles configuration
local beachVehicles = {
    {model = "blazer", hash = 2166734073, type = "atv"},     -- Blazer ATV
    {model = "blazer2", hash = 4246935337, type = "atv"},    -- Blazer Lifeguard
    {model = "bifta", hash = 3945366167, type = "buggy"},    -- Bifta (dune buggy)
    {model = "outlaw", hash = 408825843, type = "buggy"},    -- Outlaw (off-road buggy)
    {model = "surfer", hash = 699456151, type = "van"},      -- Surfer van
    {model = "surfer3", hash = 3259477733, type = "van"}     -- Surfer Custom van
}

-- Debug function
local function DebugPrint(message)
    if Config.Debug then
        print("[RIPTIDES] " .. message)
    end
end

-- Helper: Show notification
function ShowNotification(msg, type)
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandThefeedPostTicker(type == "error" and 1 or type == "success" and 2 or 0, false)
end

-- Function to check if player is in surfer territory
local function IsPlayerInSurferTerritory()
    playerPed = PlayerPedId()
    playerCoords = GetEntityCoords(playerPed)
    
    local distance = #(playerCoords - Config.SurferGang.territory.center)
    return distance <= Config.SurferGang.territory.radius
end

-- Function to create surfer blips
local function CreateSurferBlips()
    -- Create gang HQ blip
    local blip = AddBlipForCoord(Config.SurferGang.territory.center)
    SetBlipSprite(blip, 304) -- Beach icon
    SetBlipColour(blip, Config.SurferGang.blipColor)
    SetBlipScale(blip, 0.8)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.SurferGang.name)
    EndTextCommandSetBlipName(blip)
    table.insert(surferBlips, blip)
    
    -- Create territory blip
    territoryBlip = AddBlipForRadius(Config.SurferGang.territory.center, Config.SurferGang.territory.radius)
    SetBlipColour(territoryBlip, Config.SurferGang.territory.color)
    SetBlipAlpha(territoryBlip, 128)
end

-- Function to check if a model is a leader
local function IsLeaderModel(modelName)
    if not Config.SurferGang.leaders then return false end
    
    for _, leader in ipairs(Config.SurferGang.leaders) do
        if modelName == leader then
            return true
        end
    end
    return false
end

-- Function to check if a model is female
local function IsFemaleModel(modelName)
    return modelName:find("_f_") or modelName == "cs_tracydisanto" or modelName == "a_f_y_topless_01"
end

-- Function to apply outfit variations to a ped
local function ApplyOutfitVariations(ped, modelName)
    local outfitConfig = Config.PedOutfits[modelName] or Config.PedOutfits["default"]
    
    if outfitConfig and outfitConfig.components then
        for componentId, range in pairs(outfitConfig.components) do
            local variation = math.random(range.min, range.max)
            SetPedComponentVariation(ped, componentId, variation, 0, 0)
        end
    end
end

-- Function to spawn a surfer
function SpawnSurfer(location)
    -- Select a random model from the array
    local modelName = Config.SurferGang.models[math.random(#Config.SurferGang.models)]
    local model = GetHashKey(modelName)
    RequestModel(model)
    
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(model) and GetGameTimer() < timeout do 
        Wait(50) 
    end
    
    if HasModelLoaded(model) then
        local surfer = CreatePed(4, model, location.x, location.y, location.z, location.w, true, false)
        
        if surfer and DoesEntityExist(surfer) then
            -- Configure ped
            SetPedFleeAttributes(surfer, 0, 0)
            SetPedAsEnemy(surfer, true)
            SetPedCombatAttributes(surfer, 46, true)
            
            -- Apply random outfit variations
            ApplyOutfitVariations(surfer, modelName)
            
            -- Select appropriate weapon based on ped type
            local weaponType
            if IsLeaderModel(modelName) then
                weaponType = Config.SurferBehavior.leaderWeapons[math.random(#Config.SurferBehavior.leaderWeapons)]
            elseif IsFemaleModel(modelName) then
                weaponType = Config.SurferBehavior.femaleWeapons[math.random(#Config.SurferBehavior.femaleWeapons)]
            else
                weaponType = Config.SurferBehavior.meleeWeapons[math.random(#Config.SurferBehavior.meleeWeapons)]
            end
            
            GiveWeaponToPed(surfer, GetHashKey(weaponType), 1, false, true)
            
            -- Set initial task - use extended scenarios if available
            local scenarioPool = Config.SurferBehavior.scenarios
            if Config.SurferBehavior.extraScenarios and math.random(100) <= 30 then
                scenarioPool = Config.SurferBehavior.extraScenarios
            end
            
            local scenario = scenarioPool[math.random(#scenarioPool)]
            TaskStartScenarioInPlace(surfer, scenario, 0, true)
            
            -- Add to spawned surfers
            table.insert(spawnedSurfers, {
                ped = surfer,
                spawnPoint = vector3(location.x, location.y, location.z),
                lastAction = GetGameTimer(),
                state = "idle",
                model = modelName, -- Store the model name for reference
                isLeader = IsLeaderModel(modelName),
                isFemale = IsFemaleModel(modelName)
            })
            
            SetModelAsNoLongerNeeded(model)
            return surfer
        else
            ShowNotification("Error: Failed to spawn surfer", "error")
        end
    end
    
    return nil
end

-- Function to spawn surfboard prop
function SpawnSurfboard(location)
    local surfboardType = Config.Surfboards[math.random(#Config.Surfboards)]
    local model = GetHashKey(surfboardType)
    RequestModel(model)
    
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(model) and GetGameTimer() < timeout do 
        Wait(50) 
    end
    
    if HasModelLoaded(model) then
        local offset = vector3(math.random(-3, 3) * 0.1, math.random(-3, 3) * 0.1, 0)
        local prop = CreateObject(model, location.x + offset.x, location.y + offset.y, location.z, true, false, true)
        
        if prop and DoesEntityExist(prop) then
            PlaceObjectOnGroundProperly(prop)
            SetEntityHeading(prop, math.random(0, 359) + 0.0)
            FreezeEntityPosition(prop, true)
            
            table.insert(spawnedProps, prop)
            SetModelAsNoLongerNeeded(model)
            return prop
        end
    end
    
    return nil
end

-- Function to spawn beach towel prop
function SpawnBeachTowel(location)
    local towelType = Config.BeachTowels[math.random(#Config.BeachTowels)]
    local model = GetHashKey(towelType)
    RequestModel(model)
    
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(model) and GetGameTimer() < timeout do 
        Wait(50) 
    end
    
    if HasModelLoaded(model) then
        local offset = vector3(math.random(-5, 5) * 0.1, math.random(-5, 5) * 0.1, 0)
        local prop = CreateObject(model, location.x + offset.x, location.y + offset.y, location.z, true, false, true)
        
        if prop and DoesEntityExist(prop) then
            PlaceObjectOnGroundProperly(prop)
            SetEntityHeading(prop, math.random(0, 359) + 0.0)
            FreezeEntityPosition(prop, true)
            
            table.insert(spawnedProps, prop)
            SetModelAsNoLongerNeeded(model)
            return prop
        end
    end
    
    return nil
end

-- Function to spawn beach prop
function SpawnBeachProp(location)
    if not Config.BeachProps then return nil end
    
    local propType = Config.BeachProps[math.random(#Config.BeachProps)]
    local model = GetHashKey(propType)
    RequestModel(model)
    
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(model) and GetGameTimer() < timeout do 
        Wait(50) 
    end
    
    if HasModelLoaded(model) then
        local offset = vector3(math.random(-8, 8) * 0.1, math.random(-8, 8) * 0.1, 0)
        local prop = CreateObject(model, location.x + offset.x, location.y + offset.y, location.z, true, false, true)
        
        if prop and DoesEntityExist(prop) then
            PlaceObjectOnGroundProperly(prop)
            SetEntityHeading(prop, math.random(0, 359) + 0.0)
            FreezeEntityPosition(prop, true)
            
            table.insert(spawnedProps, prop)
            SetModelAsNoLongerNeeded(model)
            return prop
        end
    end
    
    return nil
end

-- Function to select a vehicle type based on weights
local function SelectVehicleType()
    -- If no weights defined, use equal distribution
    if not Config.SurferGang.vehicleSpawnWeights then
        local types = {"atv", "buggy", "van"}
        return types[math.random(#types)]
    end
    
    local totalWeight = 0
    for _, weight in pairs(Config.SurferGang.vehicleSpawnWeights) do
        totalWeight = totalWeight + weight
    end
    
    local randomWeight = math.random(1, totalWeight)
    local currentWeight = 0
    
    for vType, weight in pairs(Config.SurferGang.vehicleSpawnWeights) do
        currentWeight = currentWeight + weight
        if randomWeight <= currentWeight then
            return vType
        end
    end
    
    return "van" -- Default fallback
end

-- Function to spawn surfer vehicle
function SpawnSurferVehicle()
    -- Select a vehicle type based on weights
    local selectedType = SelectVehicleType()
    
    -- Filter vehicles by selected type
    local possibleVehicles = {}
    for _, vehicle in ipairs(beachVehicles) do
        if vehicle.type == selectedType then
            table.insert(possibleVehicles, vehicle)
        end
    end
    
    -- If no vehicles of selected type, use any vehicle
    if #possibleVehicles == 0 then
        possibleVehicles = beachVehicles
    end
    
    -- Select a random vehicle from filtered list
    local vehicleInfo = possibleVehicles[math.random(#possibleVehicles)]
    local vehicleModel = vehicleInfo.hash
    
    RequestModel(vehicleModel)
    
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(vehicleModel) and GetGameTimer() < timeout do
        Wait(100)
    end
    
    if HasModelLoaded(vehicleModel) then
        local spawnPoint = Config.SurferGang.territory.spawnPoints[math.random(#Config.SurferGang.territory.spawnPoints)]
        local offset = vector3(math.random(-10, 10) * 0.1, math.random(-10, 10) * 0.1, 0)
        local vehicle = CreateVehicle(vehicleModel, spawnPoint.x + offset.x, spawnPoint.y + offset.y, spawnPoint.z, math.random(0, 359) + 0.0, true, false)
        
        if vehicle and DoesEntityExist(vehicle) then
            -- Configure vehicle
            SetVehicleModKit(vehicle, 0)
            
            -- Apply gang colors
            local colors = Config.SurferGang.vehicleCustomization and Config.SurferGang.vehicleCustomization.colors or {38}
            local primaryColor = colors[math.random(#colors)]
            local secondaryColor = colors[math.random(#colors)]
            SetVehicleColours(vehicle, primaryColor, secondaryColor)
            SetVehicleDirtLevel(vehicle, 0.0)
            
            -- Add surfboard on top for surfer vans
            if vehicleInfo.model == "surfer" or vehicleInfo.model == "surfer3" then
                SetVehicleExtra(vehicle, 1, false)
            end
            
            -- Apply random mods based on vehicle type
            if vehicleInfo.type == "atv" then
                -- ATV mods
                SetVehicleMod(vehicle, 11, math.random(0, 3), false) -- Engine
                SetVehicleMod(vehicle, 12, math.random(0, 2), false) -- Brakes
                SetVehicleMod(vehicle, 18, math.random(0, 1), false) -- Turbo
            elseif vehicleInfo.type == "buggy" then
                -- Buggy mods
                SetVehicleMod(vehicle, 11, math.random(0, 3), false) -- Engine
                SetVehicleMod(vehicle, 12, math.random(0, 2), false) -- Brakes
                SetVehicleMod(vehicle, 13, math.random(0, 2), false) -- Transmission
                SetVehicleMod(vehicle, 15, math.random(0, 3), false) -- Suspension
                SetVehicleMod(vehicle, 18, 1, false) -- Turbo
            elseif vehicleInfo.type == "van" then
                -- Van mods
                SetVehicleMod(vehicle, 11, math.random(0, 3), false) -- Engine
                SetVehicleMod(vehicle, 12, math.random(0, 2), false) -- Brakes
                SetVehicleMod(vehicle, 13, math.random(0, 2), false) -- Transmission
                
                -- Add surfboards on roof rack
                SetVehicleExtra(vehicle, 1, false)
                
                -- Add custom livery if available
                if GetNumVehicleMods(vehicle, 48) > 0 then
                    SetVehicleMod(vehicle, 48, math.random(0, GetNumVehicleMods(vehicle, 48) - 1), false)
                end
            end
            
            -- Add custom license plate
            local plateTexts = Config.SurferGang.vehicleCustomization and Config.SurferGang.vehicleCustomization.plateTexts or {"RIPTIDE"}
            SetVehicleNumberPlateText(vehicle, plateTexts[math.random(#plateTexts)])
            
            -- Store vehicle info
            table.insert(spawnedVehicles, {
                vehicle = vehicle,
                model = vehicleInfo.model,
                type = vehicleInfo.type
            })
            
            SetModelAsNoLongerNeeded(vehicleModel)
            return vehicle
        end
    end
    
    return nil
end

-- Function to spawn surfer dog
function SpawnSurferDog(ownerPed)
    if not Config.SurferGang.dog then return nil end
    
    local dogModel = GetHashKey(Config.SurferGang.dog)
    RequestModel(dogModel)
    
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(dogModel) and GetGameTimer() < timeout do
        Wait(100)
    end
    
    if HasModelLoaded(dogModel) then
        local ownerCoords = GetEntityCoords(ownerPed)
        local offset = vector3(math.random(-2, 2) * 0.1, math.random(-2, 2) * 0.1, 0)
        local dog = CreatePed(28, dogModel, ownerCoords.x + offset.x, ownerCoords.y + offset.y, ownerCoords.z, math.random(0, 359) + 0.0, true, false)
        
        if dog and DoesEntityExist(dog) then
            -- Configure dog
            SetPedFleeAttributes(dog, 0, false)
            SetPedRelationshipGroupHash(dog, GetPedRelationshipGroupHash(ownerPed))
            TaskFollowToOffsetOfEntity(dog, ownerPed, 0.5, 0.5, 0.0, 5.0, -1, 1.0, true)
            
            table.insert(spawnedDogs, {
                ped = dog,
                owner = ownerPed
            })
            
            SetModelAsNoLongerNeeded(dogModel)
            return dog
        end
    end
    
    return nil
end

-- Spawn surfer gang
function SpawnSurferGang()
    -- Clear any existing surfers first
    ClearSurferGang()
    
    -- Spawn surfers at chill spots
    for i, spot in ipairs(Config.ChillSpots) do
        if i <= Config.SurferBehavior.maxSurfersPerLocation then
            local surfer = SpawnSurfer(spot)
            
            -- Spawn props around surfers
            if surfer then
                SpawnSurfboard(spot)
                SpawnBeachTowel(spot)
                
                -- 30% chance to spawn a dog for this surfer
                if math.random(100) <= 30 then
                    SpawnSurferDog(surfer)
                end
                
                -- 20% chance to spawn additional beach prop
                if math.random(100) <= 20 then
                    SpawnBeachProp(spot)
                end
            end
        end
    end
    
    -- Spawn vehicles based on config
    local vehicleCount = Config.SpawnTiming.vehicleCount and math.random(Config.SpawnTiming.vehicleCount.min, Config.SpawnTiming.vehicleCount.max) or math.random(2, 3)
    for i = 1, vehicleCount do
        SpawnSurferVehicle()
    end
    
    ShowNotification("The " .. Config.SurferGang.name .. " gang has taken over the beach! Don't wipe out on their sand, bro.", "error")
    
    -- Register with Civil Disorder if available
    if Config.Integration.civilDisorder then
        local success = pcall(function()
            TriggerEvent("civil_disorder:registerTemporaryGang", Config.SurferGang)
        end)
        
        if success then
            DebugPrint("Registered with Civil Disorder framework")
        end
    end
end

-- Clear surfer gang
function ClearSurferGang()
    -- Clear surfers
    for _, surfer in ipairs(spawnedSurfers) do
        if DoesEntityExist(surfer.ped) then 
            DeleteEntity(surfer.ped) 
        end
    end
    spawnedSurfers = {}
    
    -- Clear props
    for _, prop in ipairs(spawnedProps) do
        if DoesEntityExist(prop) then 
            DeleteEntity(prop) 
        end
    end
    spawnedProps = {}
    
    -- Clear vehicles
    for _, vehicle in ipairs(spawnedVehicles) do
        if DoesEntityExist(vehicle.vehicle) then 
            DeleteEntity(vehicle.vehicle) 
        end
    end
    spawnedVehicles = {}
    
    -- Clear dogs
    for _, dog in ipairs(spawnedDogs) do
        if DoesEntityExist(dog.ped) then 
            DeleteEntity(dog.ped) 
        end
    end
    spawnedDogs = {}
end

-- Function to handle surfer behavior
local function ManageSurferBehavior()
    for i, surfer in ipairs(spawnedSurfers) do
        if DoesEntityExist(surfer.ped) then
            local surferCoords = GetEntityCoords(surfer.ped)
            local distanceToPlayer = #(playerCoords - surferCoords)
            
            -- Check if player is too close
            if distanceToPlayer < 10.0 then
                -- Check if player has protection
                if playerHasProtection then
                    -- Friendly behavior
                    if surfer.state ~= "friendly" and GetGameTimer() - surfer.lastAction > 10000 then
                        TaskTurnPedToFaceEntity(surfer.ped, playerPed, 1000)
                        surfer.state = "friendly"
                        surfer.lastAction = GetGameTimer()
                        
                        -- Random chance to say something friendly
                        if math.random(100) < 30 then
                            TriggerEvent("chat:addMessage", {
                                args = { "^3[" .. Config.SurferGang.name .. "]", "You're cool with us, brah. Enjoy the waves!" }
                            })
                        end
                    end
                else
                    -- Aggressive or neutral behavior based on distance
                    if distanceToPlayer < 5.0 then
                        -- Very close - get aggressive
                        if surfer.state ~= "aggressive" and surfer.state ~= "attacking" then
                            TaskTurnPedToFaceEntity(surfer.ped, playerPed, 1000)
                            surfer.state = "aggressive"
                            surfer.lastAction = GetGameTimer()
                            
                            -- Select appropriate dialogue based on ped type
                            local dialogLines
                            if surfer.isLeader then
                                dialogLines = Config.SurferBehavior.leaderDialogLines
                            elseif surfer.isFemale then
                                dialogLines = Config.SurferBehavior.femaleDialogLines
                            else
                                dialogLines = Config.SurferBehavior.dialogLines
                            end
                            
                            -- Say something aggressive
                            TriggerEvent("chat:addMessage", {
                                args = { "^3[" .. Config.SurferGang.name .. "]", dialogLines[math.random(#dialogLines)] }
                            })
                            
                            -- Random chance to attack based on aggression level
                            -- Leaders are more aggressive
                            local aggressionChance = 20 * Config.SurferBehavior.aggressionLevel
                            if surfer.isLeader then aggressionChance = aggressionChance * 1.5 end
                            
                            if math.random(100) < aggressionChance then
                                Wait(1500) -- Brief delay before attacking
                                if DoesEntityExist(surfer.ped) and distanceToPlayer < 5.0 then
                                    TaskCombatPed(surfer.ped, playerPed, 0, 16)
                                    surfer.state = "attacking"
                                end
                            end
                        end
                    elseif distanceToPlayer < 8.0 then
                        -- Medium distance - watch player
                        if surfer.state ~= "watching" and GetGameTimer() - surfer.lastAction > 8000 then
                            TaskTurnPedToFaceEntity(surfer.ped, playerPed, 1000)
                            surfer.state = "watching"
                            surfer.lastAction = GetGameTimer()
                        end
                    end
                end
            else
                -- Player is far away, resume normal activities
                if (surfer.state == "watching" or surfer.state == "aggressive" or surfer.state == "friendly") and 
                   GetGameTimer() - surfer.lastAction > 10000 then
                    -- Return to idle or patrol
                    if math.random(100) < 70 then
                        -- Select from regular or extra scenarios
                        local scenarioPool = Config.SurferBehavior.scenarios
                        if Config.SurferBehavior.extraScenarios and math.random(100) <= 30 then
                            scenarioPool = Config.SurferBehavior.extraScenarios
                        end
                        
                        local scenario = scenarioPool[math.random(#scenarioPool)]
                        TaskStartScenarioInPlace(surfer.ped, scenario, 0, true)
                        surfer.state = "idle"
                    else
                        -- Find patrol point
                        if Config.SurferGang.territory.patrolRoutes and #Config.SurferGang.territory.patrolRoutes > 0 then
                            local route = Config.SurferGang.territory.patrolRoutes[math.random(#Config.SurferGang.territory.patrolRoutes)]
                            if #route > 0 then
                                local point = route[math.random(#route)]
                                TaskGoToCoordAnyMeans(surfer.ped, point.x, point.y, point.z, 1.0, 0, false, 786603, 0xbf800000)
                                surfer.state = "patrolling"
                            end
                        end
                    end
                    surfer.lastAction = GetGameTimer()
                end
            end
        end
    end
end

-- Function to rent a surfboard
function RentSurfboard()
    if activeRentedSurfboard then
        -- Already have a surfboard
        ShowNotification("You already have a rented surfboard!", "error")
        return
    end
    
    local surfboardModel = Config.SurferServices.surfboardRental.models[math.random(#Config.SurferServices.surfboardRental.models)]
    local model = GetHashKey(surfboardModel)
    RequestModel(model)
    
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(model) and GetGameTimer() < timeout do 
        Wait(50) 
    end
    
    if HasModelLoaded(model) then
        local playerPos = GetEntityCoords(playerPed)
        local surfboard = CreateObject(model, playerPos.x, playerPos.y, playerPos.z, true, false, true)
        
        if surfboard and DoesEntityExist(surfboard) then
            -- Attach to player
            AttachEntityToEntity(surfboard, playerPed, GetPedBoneIndex(playerPed, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
            
            activeRentedSurfboard = {
                prop = surfboard,
                endTime = GetGameTimer() + (Config.SurferServices.surfboardRental.duration * 60 * 1000)
            }
            
            -- Set timer to remove surfboard
            CreateThread(function()
                local endTime = activeRentedSurfboard.endTime
                while GetGameTimer() < endTime and activeRentedSurfboard do
                    Wait(1000)
                end
                
                if activeRentedSurfboard then
                    ReturnRentedSurfboard()
                    ShowNotification("Your surfboard rental has expired.", "error")
                end
            end)
            
            ShowNotification("You've rented a surfboard for " .. Config.SurferServices.surfboardRental.duration .. " minutes!", "success")
            return true
        end
    end
    
    ShowNotification("Failed to rent surfboard.", "error")
    return false
end

-- Function to return rented surfboard
function ReturnRentedSurfboard()
    if activeRentedSurfboard and DoesEntityExist(activeRentedSurfboard.prop) then
        DeleteEntity(activeRentedSurfboard.prop)
    end
    activeRentedSurfboard = nil
end

-- Function to rent a vehicle
function RentBeachVehicle()
    if not Config.SurferServices.vehicleRental then return false end
    
    -- Select a vehicle from available rentals
    local availableVehicles = Config.SurferServices.vehicleRental.available
    if not availableVehicles or #availableVehicles == 0 then
        availableVehicles = {"blazer", "bifta"}
    end
    
    local selectedModel = availableVehicles[math.random(#availableVehicles)]
    local vehicleHash = nil
    
    -- Find the hash for the selected model
    for _, vehicle in ipairs(beachVehicles) do
        if vehicle.model == selectedModel then
            vehicleHash = vehicle.hash
            break
        end
    end
    
    if not vehicleHash then
        ShowNotification("No rental vehicles available.", "error")
        return false
    end
    
    RequestModel(vehicleHash)
    
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(vehicleHash) and GetGameTimer() < timeout do
        Wait(100)
    end
    
    if HasModelLoaded(vehicleHash) then
        local playerPos = GetEntityCoords(playerPed)
        local spawnPos = vector3(playerPos.x + 3.0, playerPos.y + 1.0, playerPos.z)
        local vehicle = CreateVehicle(vehicleHash, spawnPos.x, spawnPos.y, spawnPos.z, GetEntityHeading(playerPed), true, false)
        
        if vehicle and DoesEntityExist(vehicle) then
            -- Configure vehicle
            SetVehicleModKit(vehicle, 0)
            SetVehicleColours(vehicle, 0, 0) -- White color for rentals
            SetVehicleDirtLevel(vehicle, 0.0)
            SetVehicleNumberPlateText(vehicle, "RENTAL")
            
            -- Set as mission entity so it doesn't despawn
            SetEntityAsMissionEntity(vehicle, true, true)
            
            -- Set rental timer
            local rentalDuration = Config.SurferServices.vehicleRental.duration * 60 * 1000
            local rentalEndTime = GetGameTimer() + rentalDuration
            
            -- Create thread to monitor rental time
            CreateThread(function()
                while GetGameTimer() 
