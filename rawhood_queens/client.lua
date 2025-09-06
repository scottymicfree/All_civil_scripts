-- CIVIL UNREST SCRIPT
-- Author: Randy Webb
-- System: Rawhood Queens - Client

local activeQueens = {}
local queensBlips = {}
local playerProtected = false
local protectionEndTime = 0
local playerPed = nil
local playerCoords = nil
local isInQueenTerritory = false

-- Check if Civil Disorder framework is available
local civilDisorderAvailable = false
Citizen.CreateThread(function()
    if Config.Integration.civilDisorder then
        local success = pcall(function()
            return exports["civil_disorder"] ~= nil
        end)
        civilDisorderAvailable = success
    end
end)

-- Function to check if player is in queen territory
local function IsPlayerInQueenTerritory()
    playerPed = PlayerPedId()
    playerCoords = GetEntityCoords(playerPed)
    
    local distance = #(playerCoords - Config.QueenGang.territory.center)
    return distance <= Config.QueenGang.territory.radius
end

-- Function to create queen blips
local function CreateQueenBlips()
    -- Create gang HQ blip
    local blip = AddBlipForCoord(Config.QueenGang.territory.center)
    SetBlipSprite(blip, 378) -- Gang icon
    SetBlipColour(blip, Config.QueenGang.blipColor)
    SetBlipScale(blip, 0.8)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.QueenGang.name)
    EndTextCommandSetBlipName(blip)
    table.insert(queensBlips, blip)
    
    -- Create territory blip
    local territoryBlip = AddBlipForRadius(Config.QueenGang.territory.center, Config.QueenGang.territory.radius)
    SetBlipColour(territoryBlip, Config.QueenGang.territory.color)
    SetBlipAlpha(territoryBlip, 128)
    table.insert(queensBlips, territoryBlip)
end

-- Function to spawn a queen
function SpawnQueen(location)
    local model = GetHashKey(Config.QueenGang.model)
    RequestModel(model)
    
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(model) and GetGameTimer() < timeout do 
        Wait(10) 
    end
    
    if HasModelLoaded(model) then
        local ped = CreatePed(4, model, location, math.random(0, 360), false, true)
        
        -- Configure ped
        SetPedArmour(ped, 50)
        SetPedCanSwitchWeapon(ped, true)
        SetPedDropsWeaponsWhenDead(ped, true)
        SetPedFleeAttributes(ped, 0, false)
        SetPedCombatAttributes(ped, 46, true)
        SetPedCombatMovement(ped, 2)
        
        -- Give random weapon from configured types
        local weaponType = Config.QueenBehavior.weaponTypes[math.random(#Config.QueenBehavior.weaponTypes)]
        GiveWeaponToPed(ped, GetHashKey(weaponType), 1, false, true)
        
        -- Set initial task
        TaskStartScenarioInPlace(ped, "WORLD_HUMAN_HANG_OUT_STREET", 0, true)
        
        -- Add to active queens
        table.insert(activeQueens, {
            ped = ped,
            spawnPoint = location,
            lastAction = GetGameTimer(),
            state = "idle"
        })
        
        SetModelAsNoLongerNeeded(model)
        return ped
    end
    
    return nil
end

-- Function to spawn queen vehicle
function SpawnQueenVehicle()
    if #activeQueens < 2 then return nil end
    
    local vehicleModel = GetHashKey(Config.QueenGang.vehicle)
    RequestModel(vehicleModel)
    
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(vehicleModel) and GetGameTimer() < timeout do
        Wait(100)
    end
    
    if HasModelLoaded(vehicleModel) then
        local spawnPoint = Config.QueenGang.territory.spawnPoints[math.random(#Config.QueenGang.territory.spawnPoints)]
        local vehicle = CreateVehicle(vehicleModel, spawnPoint, 0.0, true, false)
        
        -- Configure vehicle
        SetVehicleModKit(vehicle, 0)
        SetVehicleColours(vehicle, Config.QueenGang.territory.color, Config.QueenGang.territory.color)
        SetVehicleDirtLevel(vehicle, 0.0)
        
        -- Add custom modifications
        SetVehicleMod(vehicle, 0, 1, false) -- Spoiler
        SetVehicleMod(vehicle, 1, 1, false) -- Front Bumper
        SetVehicleMod(vehicle, 48, 1, false) -- Livery
        
        SetModelAsNoLongerNeeded(vehicleModel)
        return vehicle
    end
    
    return nil
end

-- Function to handle queen behavior
local function ManageQueenBehavior()
    for i, queen in ipairs(activeQueens) do
        if DoesEntityExist(queen.ped) then
            local queenCoords = GetEntityCoords(queen.ped)
            local distanceToPlayer = #(playerCoords - queenCoords)
            
            -- Check if player is too close
            if distanceToPlayer < 15.0 then
                -- Check if player is protected
                if playerProtected then
                    -- Friendly behavior
                    if queen.state ~= "friendly" and GetGameTimer() - queen.lastAction > 10000 then
                        TaskTurnPedToFaceEntity(queen.ped, playerPed, 1000)
                        queen.state = "friendly"
                        queen.lastAction = GetGameTimer()
                        
                        -- Random chance to say something friendly
                        if math.random(100) < 30 then
                            TriggerEvent("chat:addMessage", {
                                args = { "^6[" .. Config.QueenGang.name .. "]", "Hey sugar, you're under our protection now." }
                            })
                        end
                    end
                else
                    -- Aggressive or neutral behavior based on distance
                    if distanceToPlayer < 5.0 then
                        -- Very close - get aggressive
                        if queen.state ~= "aggressive" and queen.state ~= "attacking" then
                            TaskTurnPedToFaceEntity(queen.ped, playerPed, 1000)
                            queen.state = "aggressive"
                            queen.lastAction = GetGameTimer()
                            
                            -- Say something sassy
                            TriggerEvent("chat:addMessage", {
                                args = { "^6[" .. Config.QueenGang.name .. "]", Config.SassyLines[math.random(#Config.SassyLines)] }
                            })
                            
                            -- Random chance to attack based on aggression level
                            if math.random(100) < (20 * Config.QueenBehavior.aggressionLevel) then
                                Wait(1500) -- Brief delay before attacking
                                if DoesEntityExist(queen.ped) and distanceToPlayer < 5.0 then
                                    TaskCombatPed(queen.ped, playerPed, 0, 16)
                                    queen.state = "attacking"
                                end
                            end
                        end
                    elseif distanceToPlayer < 10.0 then
                        -- Medium distance - watch player
                        if queen.state ~= "watching" and GetGameTimer() - queen.lastAction > 8000 then
                            TaskTurnPedToFaceEntity(queen.ped, playerPed, 1000)
                            queen.state = "watching"
                            queen.lastAction = GetGameTimer()
                            
                            -- Random chance to say something
                            if math.random(100) < 40 then
                                TriggerEvent("chat:addMessage", {
                                    args = { "^6[" .. Config.QueenGang.name .. "]", Config.SassyLines[math.random(#Config.SassyLines)] }
                                })
                            end
                        end
                    end
                end
            else
                -- Player is far away, resume normal activities
                if (queen.state == "watching" or queen.state == "aggressive" or queen.state == "friendly") and 
                   GetGameTimer() - queen.lastAction > 10000 then
                    -- Return to idle or patrol
                    if math.random(100) < 70 then
                        TaskStartScenarioInPlace(queen.ped, "WORLD_HUMAN_HANG_OUT_STREET", 0, true)
                        queen.state = "idle"
                    else
                        -- Find patrol point
                        if Config.QueenGang.territory.patrolRoutes and #Config.QueenGang.territory.patrolRoutes > 0 then
                            local route = Config.QueenGang.territory.patrolRoutes[math.random(#Config.QueenGang.territory.patrolRoutes)]
                            if #route > 0 then
                                local point = route[math.random(#route)]
                                TaskGoToCoordAnyMeans(queen.ped, point.x, point.y, point.z, 1.0, 0, false, 786603, 0xbf800000)
                                queen.state = "patrolling"
                            end
                        end
                    end
                    queen.lastAction = GetGameTimer()
                end
            end
        end
    end
end

-- Function to show queen interaction menu
function ShowQueenInteractionMenu(queen)
    if Config.Integration.interiorZoneManager then
        -- Use Interior Zone Manager's native menu system
        local interactions = {
            {
                label = "Buy Protection ($" .. Config.QueenServices.protection.price .. ")",
                value = "buy_protection",
                description = "Get protection from the " .. Config.QueenGang.name
            },
            {
                label = "Buy Information ($" .. Config.QueenServices.information.price .. ")",
                value = "buy_information",
                description = "Purchase street information"
            },
            {
                label = "Shop Contraband",
                value = "shop_contraband",
                description = "Browse special items"
            },
            {
                label = "Leave",
                value = "leave",
                description = "Walk away"
            }
        }
        
        -- Create temporary zone for interaction
        local tempZone = {
            name = Config.QueenGang.name .. " Member",
            type = "gang",
            interactions = interactions
        }
        
        -- Show menu using Interior Zone Manager
        TriggerEvent("interior_zone_manager:showNativeMenu", tempZone)
        
        -- Handle interaction result
        RegisterNetEvent("interior_zone_manager:onInteraction")
        AddEventHandler("interior_zone_manager:onInteraction", function(action, zone)
            if zone.name == Config.QueenGang.name .. " Member" then
                HandleQueenInteraction(action, queen)
            end
        end)
    else
        -- Fallback to basic interaction
        local options = {"Buy Protection", "Buy Information", "Shop Contraband", "Leave"}
        
        -- Show basic notification
        BeginTextCommandThefeedPost("STRING")
        AddTextComponentSubstringPlayerName("Press 1-4 to select an option")
        EndTextCommandThefeedPostTicker(true, false)
        
        -- Wait for key press
        CreateThread(function()
            local keyPressed = false
            while not keyPressed do
                if IsControlJustReleased(0, 157) then -- 1 key
                    keyPressed = true
                    HandleQueenInteraction("buy_protection", queen)
                elseif IsControlJustReleased(0, 158) then -- 2 key
                    keyPressed = true
                    HandleQueenInteraction("buy_information", queen)
                elseif IsControlJustReleased(0, 160) then -- 3 key
                    keyPressed = true
                    HandleQueenInteraction("shop_contraband", queen)
                elseif IsControlJustReleased(0, 164) then -- 4 key
                    keyPressed = true
                    HandleQueenInteraction("leave", queen)
                end
                
                Wait(0)
            end
        end)
    end
end

-- Function to handle queen interaction
function HandleQueenInteraction(action, queen)
    if action == "buy_protection" then
        -- Try to buy protection
        TriggerServerEvent("rawhood_queens:buyProtection", Config.QueenServices.protection.price)
    elseif action == "buy_information" then
        -- Try to buy information
        TriggerServerEvent("rawhood_queens:buyInformation", Config.QueenServices.information.price)
    elseif action == "shop_contraband" then
        -- Open contraband shop
        TriggerServerEvent("rawhood_queens:openContrabandShop")
    elseif action == "leave" then
        -- Walk away
        BeginTextCommandThefeedPost("STRING")
        AddTextComponentSubstringPlayerName("You walk away from the " .. Config.QueenGang.name .. " member")
        EndTextCommandThefeedPostTicker(true, false)
    end
end

-- Proximity-based spawn/despawn
CreateThread(function()
    while true do
        playerPed = PlayerPedId()
        playerCoords = GetEntityCoords(playerPed)
        isInQueenTerritory = IsPlayerInQueenTerritory()
        
        if isInQueenTerritory then
            -- Check if we need to spawn queens
            local queenCount = #activeQueens
            local maxQueens = #Config.QueenGang.territory.spawnPoints * Config.QueenBehavior.maxQueensPerLocation
            
            if queenCount < maxQueens then
                -- Spawn more queens
                for _, spawnPoint in ipairs(Config.QueenGang.territory.spawnPoints) do
                    if #activeQueens < maxQueens and #(playerCoords - spawnPoint) < 80.0 and #(playerCoords - spawnPoint) > 20.0 then
                        SpawnQueen(spawnPoint)
                        Wait(1000)
                    end
                end
                
                -- Spawn vehicle if needed
                if not activeQueens.vehicle then
                    activeQueens.vehicle = SpawnQueenVehicle()
                end
            end
        else
            -- Clean up queens if player is far away
            if #activeQueens > 0 then
                for i, queen in ipairs(activeQueens) do
                    if DoesEntityExist(queen.ped) then
                        DeleteEntity(queen.ped)
                    end
                end
                
                if activeQueens.vehicle and DoesEntityExist(activeQueens.vehicle) then
                    DeleteEntity(activeQueens.vehicle)
                end
                
                activeQueens = {}
                print("[" .. Config.QueenGang.name .. "] Cleared distant queens.")
            end
        end
        
        -- Check protection status
        if playerProtected and GetGameTimer() > protectionEndTime then
            playerProtected = false
            TriggerEvent("chat:addMessage", {
                args = { "^6[" .. Config.QueenGang.name .. "]", "Your protection has expired." }
            })
        end
        
        Wait(5000)
    end
end)

-- Queen behavior management
CreateThread(function()
    while true do
        if isInQueenTerritory and #activeQueens > 0 then
            ManageQueenBehavior()
            Wait(1000)
        else
            Wait(3000)
        end
    end
end)

-- Interaction prompt
CreateThread(function()
    while true do
        Wait(0)
        
        if isInQueenTerritory and #activeQueens > 0 then
            -- Find closest queen
            local closestQueen = nil
            local closestDistance = 999.0
            
            for _, queen in ipairs(activeQueens) do
                if DoesEntityExist(queen.ped) and not IsPedDeadOrDying(queen.ped) then
                    local distance = #(playerCoords - GetEntityCoords(queen.ped))
                    if distance < closestDistance and distance < 5.0 then
                        closestQueen = queen
                        closestDistance = distance
                    end
                end
            end
            
            -- Show interaction prompt if close enough
            if closestQueen and closestDistance < 3.0 and closestQueen.state ~= "attacking" then
                BeginTextCommandDisplayHelp("STRING")
                AddTextComponentSubstringPlayerName("Press ~INPUT_CONTEXT~ to interact with " .. Config.QueenGang.name .. " member")
                EndTextCommandDisplayHelp(0, false, true, -1)
                
                if IsControlJustReleased(0, 38) then -- E key
                    ShowQueenInteractionMenu(closestQueen)
                end
            end
        else
            Wait(1000)
        end
    end
end)

-- Event handlers
RegisterNetEvent("rawhood_queens:protectionPurchased")
AddEventHandler("rawhood_queens:protectionPurchased", function(duration)
    playerProtected = true
    protectionEndTime = GetGameTimer() + (duration * 60 * 1000)
    
    TriggerEvent("chat:addMessage", {
        args = { "^6[" .. Config.QueenGang.name .. "]", "You're under our protection for " .. duration .. " minutes, sugar." }
    })
end)

RegisterNetEvent("rawhood_queens:informationPurchased")
AddEventHandler("rawhood_queens:informationPurchased", function(infoType)
    -- Handle different types of information
    if infoType == "gang" then
        -- Information about nearby gangs
        TriggerEvent("chat:addMessage", {
            args = { "^6[" .. Config.QueenGang.name .. "]", "Word on the street is Ballas moving product on Grove Street. Families ain't happy about it." }
        })
    elseif infoType == "police" then
        -- Information about police activity
        TriggerEvent("chat:addMessage", {
            args = { "^6[" .. Config.QueenGang.name .. "]", "Police setting up checkpoints near Strawberry tonight. Better avoid that area, honey." }
        })
    elseif infoType == "business" then
        -- Information about business opportunities
        TriggerEvent("chat:addMessage", {
            args = { "^6[" .. Config.QueenGang.name .. "]", "Heard the pawn shop owner's desperate for some new jewelry. Paying top dollar, no questions asked." }
        })
    end
end)

RegisterNetEvent("rawhood_queens:openContrabandShopMenu")
AddEventHandler("rawhood_queens:openContrabandShopMenu", function(items)
    -- Display shop menu using native UI or framework UI
    -- This would depend on your UI system
    print("Opening contraband shop with " .. #items .. " items")
    
    -- Example notification
    TriggerEvent("chat:addMessage", {
        args = { "^6[" .. Config.QueenGang.name .. "]", "Check out my special items, sugar. Don't ask where they came from." }
    })
    
    -- Here you would trigger your menu system
    -- For example with ESX:
    -- TriggerEvent('esx_menu:openMenu', 'contraband', items)
end)

-- Initialize
CreateThread(function()
    -- Create blips
    CreateQueenBlips()
    
    -- Register with Civil Disorder if available
    if civilDisorderAvailable then
        exports["civil_disorder"]:RegisterExternalGang(Config.QueenGang)
    end
    
    print("[" .. Config.QueenGang.name .. "] Client loaded.")
end)
