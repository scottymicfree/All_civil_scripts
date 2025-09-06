-- Drug Dealer NPC System
-- This script manages drug dealer NPCs and interactions

-- Import dependencies
local NPCManager = exports['standalone-framework']:GetNPCManager()
local ZoneManager = exports['standalone-framework']:GetZoneManager()

local activeDealers = {
    weed = {
        name = "Weed Dealer",
        model = "a_m_y_hipster_01",
        spawn = vector3(412.45, -1903.77, 25.35),
        hours = { start = 18, stop = 4 },
        dialogue = { "Looking for some green?", "I got that good stuff, man." },
        products = {
            { name = "Weed", price = 100, quality = "low" },
            { name = "Kush", price = 200, quality = "medium" },
            { name = "Premium Weed", price = 300, quality = "high" }
        }
    },
    meth = {
        name = "Meth Dealer",
        model = "a_m_m_skater_01",
        spawn = vector3(-1146.32, -1514.88, 4.18),
        hours = { start = 22, stop = 6 },
        dialogue = { "Need a boost?", "I got that crystal clear." },
        products = {
            { name = "Meth", price = 200, quality = "low" },
            { name = "Blue Crystal", price = 400, quality = "medium" },
            { name = "Pure Meth", price = 600, quality = "high" }
        }
    },
    cocaine = {
        name = "Cocaine Dealer",
        model = "a_m_y_stwhi_01",
        spawn = vector3(233.12, -1761.53, 28.29),
        hours = { start = 20, stop = 8 },
        dialogue = { "Want some snow?", "I got that white powder." },
        products = {
            { name = "Cocaine", price = 300, quality = "low" },
            { name = "Pure Cocaine", price = 600, quality = "medium" },
            { name = "Premium Cocaine", price = 900, quality = "high" }
        }
    }
}

local dealerSpawns = {}
local dealerCooldowns = {}
local activeJobs = {}
local debugMode = false

-- Function to check if it's the right time for a dealer to be active
function IsDealerActiveTime(dealer)
    local hour = GetClockHours()
    local start = dealer.hours.start
    local stop = dealer.hours.stop
    
    if start < stop then
        -- Simple range (e.g., 10 to 18)
        return hour >= start and hour < stop
    else
        -- Overnight range (e.g., 20 to 4)
        return hour >= start or hour < stop
    end
end

-- Function to check if location is safe for dealer
function IsLocationSafeForDealer(position)
    -- Check if we're in a safe zone or restricted area
    if ZoneManager then
        local currentZone = ZoneManager.GetHighestPriorityZone(position)
        if currentZone and (currentZone.type == ZoneManager.ZoneTypes.SAFE or currentZone.type == ZoneManager.ZoneTypes.RESTRICTED) then
            if debugMode then
                print("Location not safe for dealer: " .. currentZone.name .. " (" .. currentZone.type .. ")")
            end
            return false
        end
    end
    
    -- Check if there are too many cops nearby
    local copCount = 0
    local players = GetActivePlayers()
    for _, player in ipairs(players) do
        local playerPed = GetPlayerPed(player)
        local playerJob = GetPlayerJob(player)
        
        if playerJob == "police" then
            local playerCoords = GetEntityCoords(playerPed)
            local distance = #(position - playerCoords)
            
            if distance < 50.0 then
                copCount = copCount + 1
                if copCount >= 2 then
                    if debugMode then
                        print("Too many cops nearby for dealer")
                    end
                    return false
                end
            end
        end
    end
    
    return true
end

-- Function to get player's job
function GetPlayerJob(player)
    -- Try to get from standalone-framework if it exists
    if GetResourceState('standalone-framework') == 'started' then
        local success, job = pcall(function()
            return exports['standalone-framework']:GetPlayerJob()
        end)
        
        if success and job then
            return job
        end
    end
    
    return "civilian"
end

-- Function to spawn drug dealer NPC
function SpawnDrugDealer(dealerType)
    if dealerCooldowns[dealerType] and dealerCooldowns[dealerType] > GetGameTimer() then
        return -- Still on cooldown
    end
    
    local dealerData = activeDealers[dealerType]
    if not dealerData then return end
    
    -- Check if it's the right time for this dealer
    if not IsDealerActiveTime(dealerData) then
        -- Set a short cooldown to check again later
        dealerCooldowns[dealerType] = GetGameTimer() + 60000 -- Check again in 1 minute
        return
    end
    
    -- Determine spawn position
    local spawnPosition = nil
    if type(dealerData.spawn) == "vector3" then
        spawnPosition = dealerData.spawn
    else
        -- Handle case where spawn might be a table of coordinates
        spawnPosition = dealerData.spawn[math.random(1, #dealerData.spawn)]
    end
    
    -- Check if location is safe for dealer
    if not IsLocationSafeForDealer(spawnPosition) then
        dealerCooldowns[dealerType] = GetGameTimer() + 300000 -- Try again in 5 minutes
        return
    }
    
    -- Use NPCManager if available
    if NPCManager then
        local ped = NPCManager.SpawnNPC(NPCManager.NPCTypes.DRUG_DEALER, spawnPosition, 0.0)
        
        if ped then
            -- Store spawn data
            table.insert(dealerSpawns, {
                type = dealerType,
                ped = ped,
                spawnTime = GetGameTimer()
            })
            
            -- Set cooldown for next spawn
            dealerCooldowns[dealerType] = GetGameTimer() + 300000 -- 5 minutes
            
            if debugMode then
                print("Spawned NPC for dealer: " .. dealerType .. " using NPCManager")
            end
            
            -- Return the ped
            return ped
        end
    else
        -- Fallback to direct spawning
        -- Load model
        local pedHash = GetHashKey(dealerData.model)
        RequestModel(pedHash)
        local timeout = 5000
        local startTime = GetGameTimer()
        while not HasModelLoaded(pedHash) do
            if GetGameTimer() - startTime > timeout then
                if debugMode then
                    print("Failed to load model for dealer: " .. dealerType)
                end
                return
            end
            Citizen.Wait(100)
        end
        
        -- Spawn NPC
        local ped = CreatePed(4, pedHash, spawnPosition.x, spawnPosition.y, spawnPosition.z, 0.0, true, false)
        
        if not ped or not DoesEntityExist(ped) then
            if debugMode then
                print("Failed to create ped for dealer: " .. dealerType)
            end
            return
        end
        
        -- Set behavior
        TaskStartScenarioInPlace(ped, "WORLD_HUMAN_SMOKING", 0, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        SetPedCanBeTargetted(ped, true)
        
        -- Set decorators for identification
        DecorSetInt(ped, "npc_managed", 1)
        DecorSetString(ped, "npc_type", "drug_dealer")
        DecorSetString(ped, "dealer_type", dealerType)
        
        -- Store spawn data
        table.insert(dealerSpawns, {
            type = dealerType,
            ped = ped,
            spawnTime = GetGameTimer()
        })
        
        -- Set cooldown for next spawn
        dealerCooldowns[dealerType] = GetGameTimer() + 300000 -- 5 minutes
        
        if debugMode then
            print("Spawned NPC for dealer: " .. dealerType)
        end
        
        -- Return the ped
        return ped
    }
}

-- Function to clean up old dealer NPCs
function CleanupDealerNPCs()
    local currentTime = GetGameTimer()
    local newSpawns = {}
    
    for i, spawn in ipairs(dealerSpawns) do
        -- Check if NPC still exists and isn't too old (30 minutes)
        if DoesEntityExist(spawn.ped) and (currentTime - spawn.spawnTime) < 1800000 then
            -- Check if it's still the right time for this dealer
            local dealerData = activeDealers[spawn.type]
            if dealerData and IsDealerActiveTime(dealerData) then
                table.insert(newSpawns, spawn)
            else
                -- Wrong time, delete the dealer
                if DoesEntityExist(spawn.ped) then
                    DeleteEntity(spawn.ped)
                end
                
                if debugMode then
                    print("Cleaned up NPC for dealer: " .. spawn.type .. " (wrong time)")
                end
            end
        else
            -- Delete the ped if it exists
            if DoesEntityExist(spawn.ped) then
                DeleteEntity(spawn.ped)
            end
            
            if debugMode then
                print("Cleaned up NPC for dealer: " .. spawn.type .. " (expired)")
            end
        end
    end
    
    dealerSpawns = newSpawns
}

-- Function to handle drug dealer interaction
function InteractWithDrugDealer(ped)
    -- Find which dealer this NPC belongs to
    local dealerType = nil
    for i, spawn in ipairs(dealerSpawns) do
        if spawn.ped == ped then
            dealerType = spawn.type
            break
        end
    end
    
    -- If not found in our spawns, check for decorator
    if not dealerType and DecorExistOn(ped, "dealer_type") then
        dealerType = DecorGetString(ped, "dealer_type")
    end
    
    if not dealerType or not activeDealers[dealerType] then
        ShowNotification("You can't interact with this NPC")
        return
    end
    
    local dealerData = activeDealers[dealerType]
    
    -- Show dialogue
    local dialogue = dealerData.dialogue[math.random(1, #dealerData.dialogue)]
    ShowNotification(dealerData.name .. ": " .. dialogue)
    
    -- Show dealer options
    TriggerEvent("drug_dealer:showOptions", dealerType, dealerData)
}

-- Event handler for showing dealer options
RegisterNetEvent("drug_dealer:showOptions")
AddEventHandler("drug_dealer:showOptions", function(dealerType, dealerData)
    -- Create menu using NativeUI
    local menuPool = NativeUI.CreatePool()
    local mainMenu = NativeUI.CreateMenu(dealerData.name, "~b~Drug Dealer Options")
    menuPool:Add(mainMenu)
    menuPool:MouseControlsEnabled(false)
    menuPool:MouseEdgeEnabled(false)
    menuPool:ControlDisablingEnabled(true)
    menuPool:ControllerEnabled(true)
    
    -- Add buy options
    local buyMenu = menuPool:AddSubMenu(mainMenu, "Buy Drugs")
    
    -- Add products
    for i, product in ipairs(dealerData.products) do
        local productItem = NativeUI.CreateItem(product.name, "$" .. product.price .. " - Quality: " .. product.quality)
        buyMenu:AddItem(productItem)
        productItem.Activated = function(sender, item)
            TriggerServerEvent("drug_dealer:buyProduct", dealerType, i)
            mainMenu:Visible(false)
        end
    end
    
    -- Add sell information option
    local sellInfoItem = NativeUI.CreateItem("Sell Information", "Sell information to the dealer")
    mainMenu:AddItem(sellInfoItem)
    sellInfoItem.Activated = function(sender, item)
        TriggerServerEvent("drug_dealer:sellInformation", dealerType)
        mainMenu:Visible(false)
    end
    
    -- Add request job option
    local requestJobItem = NativeUI.CreateItem("Request Job", "Ask for a drug-related job")
    mainMenu:AddItem(requestJobItem)
    requestJobItem.Activated = function(sender, item)
        TriggerServerEvent("drug_dealer:requestJob", dealerType)
        mainMenu:Visible(false)
    end
    
    -- Add leave option
    local leaveItem = NativeUI.CreateItem("Leave", "Walk away")
    mainMenu:AddItem(leaveItem)
    leaveItem.Activated = function(sender, item)
        ShowNotification("You walk away from the " .. dealerData.name)
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

-- Event handler for starting a job
RegisterNetEvent("drug_dealer:startJob")
AddEventHandler("drug_dealer:startJob", function(jobData)
    -- Store job data
    activeJobs[jobData.type] = jobData
    
    -- Create job blip
    local blip = AddBlipForCoord(jobData.location.x, jobData.location.y, jobData.location.z)
    SetBlipSprite(blip, 1)
    SetBlipColour(blip, 5)
    SetBlipRoute(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(jobData.type .. " Job")
    EndTextCommandSetBlipName(blip)
    
    -- Store blip
    activeJobs[jobData.type].blip = blip
    
    -- Show notification
    ShowNotification("Job started: " .. jobData.type .. ". Go to the marked location.")
    
    -- Start job monitoring thread
    Citizen.CreateThread(function()
        while activeJobs[jobData.type] do
            Citizen.Wait(1000)
            
            -- Check if player is near job location
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local jobLocation = activeJobs[jobData.type].location
            local distance = #(playerCoords - vector3(jobLocation.x, jobLocation.y, jobLocation.z))
            
            if distance < 5.0 then
                -- Player reached job location
                ShowNotification("You've reached the job location. Complete the task.")
                
                -- Handle different job types
                if jobData.type == "delivery" then
                    -- Spawn package
                    local packageProp = CreateObject(GetHashKey("prop_drug_package"), jobLocation.x, jobLocation.y, jobLocation.z - 1.0, true, true, true)
                    activeJobs[jobData.type].package = packageProp
                    
                    -- Create marker
                    Citizen.CreateThread(function()
                        while activeJobs[jobData.type] and activeJobs[jobData.type].package do
                            Citizen.Wait(0)
                            DrawMarker(1, jobLocation.x, jobLocation.y, jobLocation.z - 1.0, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 0.5, 255, 0, 0, 100, false, true, 2, nil, nil, false)
                            
                            -- Check if player is near package
                            local playerCoords = GetEntityCoords(playerPed)
                            local packageCoords = GetEntityCoords(activeJobs[jobData.type].package)
                            local distance = #(playerCoords - packageCoords)
                            
                            if distance < 2.0 then
                                -- Show help text
                                BeginTextCommandDisplayHelp("STRING")
                                AddTextComponentSubstringPlayerName("Press ~INPUT_CONTEXT~ to pick up the package")
                                EndTextCommandDisplayHelp(0, false, true, -1)
                                
                                -- Check for interaction
                                if IsControlJustReleased(0, 51) then -- E key
                                    -- Delete package
                                    DeleteObject(activeJobs[jobData.type].package)
                                    activeJobs[jobData.type].package = nil
                                    
                                    -- Complete job
                                    TriggerServerEvent("drug_dealer:completeJob", jobData.dealer, jobData.type)
                                    
                                    -- Remove blip
                                    RemoveBlip(activeJobs[jobData.type].blip)
                                    activeJobs[jobData.type] = nil
                                    
                                    -- Show notification
                                    ShowNotification("Job completed successfully!")
                                    break
                                end
                            end
                        end
                    end)
                    
                    break
                elseif jobData.type == "collection" then
                    -- Spawn NPC to collect from
                    RequestModel(GetHashKey("a_m_y_mexthug_01"))
                    while not HasModelLoaded(GetHashKey("a_m_y_mexthug_01")) do
                        Citizen.Wait(1)
                    end
                    
                    local npc = CreatePed(4, GetHashKey("a_m_y_mexthug_01"), jobLocation.x, jobLocation.y, jobLocation.z, 0.0, true, true)
                    SetEntityAsMissionEntity(npc, true, true)
                    SetBlockingOfNonTemporaryEvents(npc, true)
                    TaskStartScenarioInPlace(npc, "WORLD_HUMAN_SMOKING", 0, true)
                    
                    activeJobs[jobData.type].npc = npc
                    
                    -- Create marker
                    Citizen.CreateThread(function()
                        while activeJobs[jobData.type] and activeJobs[jobData.type].npc do
                            Citizen.Wait(0)
                            DrawMarker(1, jobLocation.x, jobLocation.y, jobLocation.z - 1.0, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 0.5, 255, 0, 0, 100, false, true, 2, nil, nil, false)
                            
                            -- Check if player is near NPC
                            local playerCoords = GetEntityCoords(playerPed)
                            local npcCoords = GetEntityCoords(activeJobs[jobData.type].npc)
                            local distance = #(playerCoords - npcCoords)
                            
                            if distance < 2.0 then
                                -- Show help text
                                BeginTextCommandDisplayHelp("STRING")
                                AddTextComponentSubstringPlayerName("Press ~INPUT_CONTEXT~ to collect the package")
                                EndTextCommandDisplayHelp(0, false, true, -1)
                                
                                -- Check for interaction
                                if IsControlJustReleased(0, 51) then -- E key
                                    -- Delete NPC
                                    DeleteEntity(activeJobs[jobData.type].npc)
                                    activeJobs[jobData.type].npc = nil
                                    
                                    -- Complete job
                                    TriggerServerEvent("drug_dealer:completeJob", jobData.dealer, jobData.type)
                                    
                                    -- Remove blip
                                    RemoveBlip(activeJobs[jobData.type].blip)
                                    activeJobs[jobData.type] = nil
                                    
                                    -- Show notification
                                    ShowNotification("Job completed successfully!")
                                    break
                                end
                            end
                        end
                    end)
                    
                    break
                elseif jobData.type == "protection" then
                    -- Spawn enemies
                    local enemies = {}
                    local enemyCount = math.random(3, 5)
                    
                    RequestModel(GetHashKey("g_m_y_lost_03"))
                    while not HasModelLoaded(GetHashKey("g_m_y_lost_03")) do
                        Citizen.Wait(1)
                    end
                    
                    for i = 1, enemyCount do
                        local offsetX = math.random(-10, 10)
                        local offsetY = math.random(-10, 10)
                        local enemy = CreatePed(4, GetHashKey("g_m_y_lost_03"), jobLocation.x + offsetX, jobLocation.y + offsetY, jobLocation.z, 0.0, true, true)
                        
                        SetEntityAsMissionEntity(enemy, true, true)
                        GiveWeaponToPed(enemy, GetHashKey("WEAPON_PISTOL"), 100, false, true)
                        TaskCombatPed(enemy, playerPed, 0, 16)
                        
                        table.insert(enemies, enemy)
                    end
                    
                    activeJobs[jobData.type].enemies = enemies
                    activeJobs[jobData.type].enemyCount = enemyCount
                    activeJobs[jobData.type].killedEnemies = 0
                    
                    -- Create marker
                    Citizen.CreateThread(function()
                        while activeJobs[jobData.type] do
                            Citizen.Wait(0)
                            DrawMarker(1, jobLocation.x, jobLocation.y, jobLocation.z - 1.0, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 0.5, 255, 0, 0, 100, false, true, 2, nil, nil, false)
                            
                            -- Show progress
                            local progress = "Enemies: " .. activeJobs[jobData.type].killedEnemies .. "/" .. activeJobs[jobData.type].enemyCount
                            DrawText3D(jobLocation.x, jobLocation.y, jobLocation.z + 1.0, progress)
                            
                            -- Check if all enemies are killed
                            if activeJobs[jobData.type].killedEnemies >= activeJobs[jobData.type].enemyCount then
                                -- Complete job
                                TriggerServerEvent("drug_dealer:completeJob", jobData.dealer, jobData.type)
                                
                                -- Remove blip
                                RemoveBlip(activeJobs[jobData.type].blip)
                                activeJobs[jobData.type] = nil
                                
                                -- Show notification
                                ShowNotification("Job completed successfully!")
                                break
                            end
                        end
                    end)
                    
                    break
                end
            end
        end
    end)
end)

-- Main thread for drug dealer NPC management
Citizen.CreateThread(function()
    -- Initialize cooldowns
    for dealerType, _ in pairs(activeDealers) do
        dealerCooldowns[dealerType] = 0
    end
    
    -- Register decorators
    DecorRegister("dealer_type", 3) -- STRING
    
    while true do
        -- Spawn drug dealer NPCs
        for dealerType, _ in pairs(activeDealers) do
            SpawnDrugDealer(dealerType)
        end
        
        -- Clean up old NPCs
        CleanupDealerNPCs()
        
        -- Wait before next cycle
        Citizen.Wait(60000) -- Check every minute
    end
end)

-- Thread for NPC interaction
Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local nearestPed = nil
        local nearestDistance = 3.0 -- Interaction distance
        local isNearDealer = false
        
        -- Check if player is near any drug dealer NPC
        for i, spawn in ipairs(dealerSpawns) do
            if DoesEntityExist(spawn.ped) then
                local pedCoords = GetEntityCoords(spawn.ped)
                local distance = #(playerCoords - pedCoords)
                
                if distance < nearestDistance then
                    nearestPed = spawn.ped
                    nearestDistance = distance
                    isNearDealer = true
                end
            end
        end
        
        -- Show interaction prompt if near a drug dealer NPC
        if isNearDealer then
            BeginTextCommandDisplayHelp("STRING")
            AddTextComponentSubstringPlayerName("Press ~INPUT_FRONTEND_UP~ to interact with drug dealer")
            EndTextCommandDisplayHelp(0, false, true, -1)
            
            -- Check for D-pad up press (controller)
            if IsControlJustReleased(0, 172) then -- 172 is D-pad Up
                InteractWithDrugDealer(nearestPed)
            end
            
            Citizen.Wait(0)
        else
            -- If not near any drug dealer NPC, wait longer to save resources
            Citizen.Wait(500)
        end
    end
end)

-- Event handler for enemy deaths (for protection jobs)
AddEventHandler('gameEventTriggered', function(name, args)
    if name == "CEventNetworkEntityDamage" then
        local victim = args[1]
        local attacker = args[2]
        local fatal = args[6] == 1
        
        if fatal and attacker == PlayerPedId() then
            -- Check if this was a job enemy
            for jobType, jobData in pairs(activeJobs) do
                if jobData.enemies then
                    for i, enemy in ipairs(jobData.enemies) do
                        if victim == enemy then
                            -- Increment kill counter
                            activeJobs[jobType].killedEnemies = activeJobs[jobType].killedEnemies + 1
                            
                            -- Remove from enemies list
                            table.remove(activeJobs[jobType].enemies, i)
                            
                            -- Show notification
                            ShowNotification("Target eliminated: " .. activeJobs[jobType].killedEnemies .. "/" .. activeJobs[jobType].enemyCount)
                            
                            break
                        end
                    end
                end
            end
        end
    end
end)

-- Register command for keyboard users
RegisterCommand("dealer_interact", function()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    local nearestPed = nil
    local nearestDistance = 3.0 -- Interaction distance
    
    for i, spawn in ipairs(dealerSpawns) do
        if DoesEntityExist(spawn.ped) then
            local pedCoords = GetEntityCoords(spawn.ped)
            local distance = #(playerCoords - pedCoords)
            
            if distance < nearestDistance then
                nearestPed = spawn.ped
                nearestDistance = distance
            end
        end
    end
    
    if nearestPed then
        InteractWithDrugDealer(nearestPed)
    end
end, false)

-- Register key mapping for keyboard users
RegisterKeyMapping("dealer_interact", "Interact with Drug Dealer", "keyboard", "E")

-- Function to draw 3D text
function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
    local factor = (string.len(text)) / 370
    DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 41, 11, 41, 68)
end

-- Notification function
function ShowNotification(message)
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandThefeedPostTicker(true, false)
end

-- Debug command
RegisterCommand("dealers_debug", function()
    debugMode = not debugMode
    ShowNotification("Drug dealer debug mode: " .. (debugMode and "Enabled" or "Disabled"))
    
    if debugMode then
        -- Show debug info
        local dealerCount = 0
        for _, _ in pairs(dealerSpawns) do
            dealerCount = dealerCount + 1
        end
        
        ShowNotification("Active dealers: " .. dealerCount)
        
        for dealerType, cooldown in pairs(dealerCooldowns) do
            local timeLeft = math.max(0, (cooldown - GetGameTimer()) / 1000)
            ShowNotification(dealerType .. " cooldown: " .. math.floor(timeLeft) .. "s")
        end
    end
end, false)

-- Register with D-pad system
if RegisterDpadAction then
    RegisterDpadAction("UP", "drug_dealer_interact", function()
        -- This will be called when D-pad Up is pressed
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        
        local nearestPed = nil
        local nearestDistance = 3.0 -- Interaction distance
        
        for i, spawn in ipairs(dealerSpawns) do
            if DoesEntityExist(spawn.ped) then
                local pedCoords = GetEntityCoords(spawn.ped)
                local distance = #(playerCoords - pedCoords)
                
                if distance < nearestDistance then
                    nearestPed = spawn.ped
                    nearestDistance = distance
                end
            end
        end
        
        if nearestPed then
            InteractWithDrugDealer(nearestPed)
            return true -- Interaction handled
        end
        
        return false -- No interaction, let other handlers process
    end)
end
