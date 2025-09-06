-- riptides/server.lua
-- Enhanced Surfer Gang System for FiveM
-- Author: Randy Webb & Emma, Improved by Grok

-- =============================================
-- INITIALIZATION
-- =============================================

print("[RIPTIDES] Server script loaded.")

-- Framework detection
local ESX, QBCore = nil, nil
local frameworkDetected = false

-- Try to load ESX
if GetResourceState('es_extended') ~= 'missing' then
    ESX = exports['es_extended']:getSharedObject()
    frameworkDetected = true
    print("[RIPTIDES] ESX framework detected")
-- Try to load QBCore if ESX isn't available
elseif GetResourceState('qb-core') ~= 'missing' then
    QBCore = exports['qb-core']:GetCoreObject()
    frameworkDetected = true
    print("[RIPTIDES] QBCore framework detected")
end

-- State variables
local chillCooldown = 0
local activeSurfers = false
local unrestLevel = 0
local activeBeachParties = {}
local playerProtections = {}
local rentedVehicles = {}

-- Initialize Config if it doesn't exist yet
if not Config then
    Config = {
        Debug = false,
        SpawnTiming = {
            activeHoursStart = 9,
            activeHoursEnd = 18,
            minCooldown = 210,
            maxCooldown = 340,
            spawnDuration = 200
        },
        SurferGang = {
            name = "The Riptides",
            territory = {
                center = vector3(-1495.42, -1387.6, 2.13),
                radius = 100.0
            }
        },
        SurferServices = {
            weed = {
                price = 150,
                quality = "beach grown"
            },
            surfLessons = {
                price = 300,
                duration = 10
            },
            beachParty = {
                price = 500,
                duration = 15
            },
            vehicleRental = {
                price = 750,
                duration = 30
            }
        },
        UnrestSystem = {
            maxUnrest = 100,
            unrestIncreasePerSpawn = 5,
            unrestDecreasePerDespawn = 10,
            unrestEffects = {
                ["25"] = "Minor beach disturbances",
                ["50"] = "Increased surfer gang activity",
                ["75"] = "Aggressive territorial behavior",
                ["100"] = "Full beach takeover"
            }
        },
        ConflictZones = {
            gangZones = {},
            safeZones = {},
            riotZones = {
                vector3(-75.0, -818.0, 326.2),
                vector3(252.0, -1000.0, 29.3),
                vector3(180.0, -1300.0, 29.2)
            }
        },
        ChillSpots = {
            vector4(-1495.42, -1387.6, 2.13, 180.0),
            vector4(-1499.0, -1385.0, 2.13, 90.0),
            vector4(-1502.0, -1382.0, 2.13, 270.0)
        }
    }
end

-- =============================================
-- UTILITY FUNCTIONS
-- =============================================

-- Debug function
local function DebugPrint(message)
    if Config.Debug then
        print("[RIPTIDES] " .. message)
    end
end

-- Function to check if coordinates are in a conflict zone
local function IsInConflictZone(coords)
    -- Check gang zones
    if Config.ConflictZones and Config.ConflictZones.gangZones then
        for _, zone in pairs(Config.ConflictZones.gangZones) do
            if #(coords - zone.center) < zone.radius then
                return true, "gang turf (" .. zone.name .. ")"
            end
        end
    end
    
    -- Check safe zones
    if Config.ConflictZones and Config.ConflictZones.safeZones then
        for _, zone in pairs(Config.ConflictZones.safeZones) do
            if #(coords - zone.center) < zone.radius then
                return true, "safe zone (" .. zone.name .. ")"
            end
        end
    end
    
    -- Check riot zones
    if Config.ConflictZones and Config.ConflictZones.riotZones then
        for _, loc in ipairs(Config.ConflictZones.riotZones) do
            if #(coords - loc) < 80.0 then
                return true, "riot zone"
            end
        end
    end
    
    return false, nil
end

-- Function to update conflict zones from other resources
local function UpdateConflictZones()
    -- Try to get gang zones from Civil Disorder
    if GetResourceState('civil_disorder') ~= 'missing' then
        local success, gangZones = pcall(function()
            return exports['civil_disorder']:GetAllGangTerritories()
        end)
        
        if success and gangZones then
            Config.ConflictZones.gangZones = gangZones
            DebugPrint("Updated gang zones from Civil Disorder: " .. #gangZones .. " zones")
        end
    end
    
    -- Try to get safe zones from Interior Zone Manager
    if GetResourceState('interior_zone_manager') ~= 'missing' then
        local success, safeZones = pcall(function()
            return exports['interior_zone_manager']:GetAllSafeZones()
        end)
        
        if success and safeZones then
            Config.ConflictZones.safeZones = safeZones
            DebugPrint("Updated safe zones from Interior Zone Manager: " .. #safeZones .. " zones")
        end
    end
end

-- Function to notify all players in beach area
local function NotifyBeachPlayers(message)
    local players = GetPlayers()
    for _, playerId in ipairs(players) do
        local playerIdNum = tonumber(playerId)
        if not playerIdNum then goto continue end
        
        local playerPed = GetPlayerPed(playerIdNum)
        if not playerPed or not DoesEntityExist(playerPed) then goto continue end
        
        local playerCoords = GetEntityCoords(playerPed)
        local distance = #(playerCoords - Config.SurferGang.territory.center)
        
        if distance <= Config.SurferGang.territory.radius * 1.5 then
            TriggerClientEvent("chat:addMessage", playerIdNum, {
                args = { "^3[" .. Config.SurferGang.name .. "]", message }
            })
        end
        
        ::continue::
    end
end

-- =============================================
-- PLAYER INTERACTION FUNCTIONS
-- =============================================

-- Function to get player money
local function GetPlayerMoney(source)
    if ESX then
        local xPlayer = ESX.GetPlayerFromId(source)
        return xPlayer and xPlayer.getMoney() or 0
    elseif QBCore then
        local Player = QBCore.Functions.GetPlayer(source)
        return Player and Player.PlayerData.money.cash or 0
    else
        -- Fallback for standalone mode
        return 10000 -- Assume player has money in standalone mode
    end
end

-- Function to remove player money
local function RemovePlayerMoney(source, amount)
    if ESX then
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer and xPlayer.getMoney() >= amount then
            xPlayer.removeMoney(amount)
            return true
        end
    elseif QBCore then
        local Player = QBCore.Functions.GetPlayer(source)
        if Player and Player.PlayerData.money.cash >= amount then
            Player.Functions.RemoveMoney('cash', amount)
            return true
        end
    else
        -- Fallback for standalone mode
        return true
    end
    return false
end

-- Function to give item to player
local function GivePlayerItem(source, item, count)
    if ESX then
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            xPlayer.addInventoryItem(item, count)
            return true
        end
    elseif QBCore then
        local Player = QBCore.Functions.GetPlayer(source)
        if Player then
            if Player.Functions.AddItem(item, count) then
                TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[item], 'add')
                return true
            end
        end
    else
        -- Fallback for standalone mode
        TriggerClientEvent("riptides:receivedItem", source, item, count)
        return true
    end
    return false
end

-- Function to get player identifier
local function GetPlayerIdentifier(source)
    if ESX then
        local xPlayer = ESX.GetPlayerFromId(source)
        return xPlayer and xPlayer.identifier
    elseif QBCore then
        local Player = QBCore.Functions.GetPlayer(source)
        return Player and Player.PlayerData.citizenid
    else
        for _, v in pairs(GetPlayerIdentifiers(source)) do
            if string.sub(v, 1, 6) == "steam:" then
                return v
            end
        end
    end
    return tostring(source) -- Fallback to source as string
end

-- Function to start a beach party
local function StartBeachParty(source)
    local partyId = "party_" .. math.random(1000, 9999)
    local playerName = GetPlayerName(source)
    
    activeBeachParties[partyId] = {
        host = source,
        hostName = playerName,
        startTime = os.time(),
        endTime = os.time() + (Config.SurferServices.beachParty.duration * 60),
        participants = {source}
    }
    
    -- Notify beach area players
    NotifyBeachPlayers(playerName .. " is hosting a beach party! Come join the fun!")
    
    -- Trigger client event for visual effects
    TriggerClientEvent("riptides:beachPartyStarted", -1, Config.SurferGang.territory.center, Config.SurferServices.beachParty.duration)
    
    -- Set timer to end party
    SetTimeout(Config.SurferServices.beachParty.duration * 60 * 1000, function()
        if activeBeachParties[partyId] then
            NotifyBeachPlayers("The beach party hosted by " .. playerName .. " has ended!")
            TriggerClientEvent("riptides:beachPartyEnded", -1)
            activeBeachParties[partyId] = nil
        end
    end)
    
    return partyId
end

-- Function to check if surfers can spawn
local function CanSurfersSpawn()
    if activeSurfers or chillCooldown > 0 then
        return false
    end
    
    local hour = GetClockHours()
    if hour < Config.SpawnTiming.activeHoursStart or hour > Config.SpawnTiming.activeHoursEnd then
        return false
    end
    
    -- Check for conflicts in spawn locations
    local conflict = false
    local chillSpots = Config.ChillSpots or {
        vector4(-1495.42, -1387.6, 2.13, 180.0),
        vector4(-1499.0, -1385.0, 2.13, 90.0),
        vector4(-1502.0, -1382.0, 2.13, 270.0)
    }
    
    for _, spot in ipairs(chillSpots) do
        local spotVec3 = vector3(spot.x, spot.y, spot.z)
        local inConflict, conflictType = IsInConflictZone(spotVec3)
        if inConflict then
            DebugPrint("Spawn skipped: " .. conflictType .. " at " .. spot.x .. ", " .. spot.y .. ", " .. spot.z)
            conflict = true
            break
        end
    end
    
    return not conflict
end

-- Function to spawn surfers
local function SpawnSurfers()
    TriggerClientEvent("riptides:spawn", -1)
    activeSurfers = true
    unrestLevel = math.min(unrestLevel + (Config.UnrestSystem.unrestIncreasePerSpawn or 5), Config.UnrestSystem.maxUnrest)
    DebugPrint("Spawned surfers. Unrest level: " .. unrestLevel)
    
    -- Check unrest effects
    if Config.UnrestSystem.unrestEffects then
        for level, effect in pairs(Config.UnrestSystem.unrestEffects) do
            if unrestLevel >= tonumber(level) and math.random(1, 100) <= 30 then
                NotifyBeachPlayers(effect)
                break
            end
        end
    end
    
    -- Set despawn timer
    SetTimeout(Config.SpawnTiming.spawnDuration * 1000, function()
        DespawnSurfers()
    end)
end

-- Function to despawn surfers
local function DespawnSurfers()
    TriggerClientEvent("riptides:despawn", -1)
    activeSurfers = false
    chillCooldown = math.random(Config.SpawnTiming.minCooldown, Config.SpawnTiming.maxCooldown)
    unrestLevel = math.max(unrestLevel - (Config.UnrestSystem.unrestDecreasePerDespawn or 10), 0)
    DebugPrint("Despawned surfers. Unrest level: " .. unrestLevel)
end

-- Function to handle vehicle rental
local function RentVehicleToPlayer(source)
    local identifier = GetPlayerIdentifier(source)
    
    -- Check if player already has a rented vehicle
    if rentedVehicles[identifier] then
        TriggerClientEvent("chat:addMessage", source, {
            args = { "^3[" .. Config.SurferGang.name .. "]", "You already have a rented vehicle, dude! Return it first." }
        })
        return false
    end
    
    -- Create rental record
    rentedVehicles[identifier] = {
        startTime = os.time(),
        endTime = os.time() + (Config.SurferServices.vehicleRental.duration * 60),
        player = source
    }
    
    -- Trigger client event to spawn vehicle
    TriggerClientEvent("riptides:vehicleRentalStarted", source, Config.SurferServices.vehicleRental.duration)
    
    -- Set timer to end rental
    SetTimeout(Config.SurferServices.vehicleRental.duration * 60 * 1000, function()
        if rentedVehicles[identifier] then
            TriggerClientEvent("riptides:vehicleRentalEnded", source)
            rentedVehicles[identifier] = nil
        end
    end)
    
    return true
end

-- =============================================
-- MAIN THREAD
-- =============================================

-- Main thread for spawn timing
CreateThread(function()
    -- Update conflict zones initially
    UpdateConflictZones()
    
    while true do
        Wait(15000)
        
        -- Update conflict zones periodically
        if math.random(1, 10) == 1 then
            UpdateConflictZones()
        end
        
        -- Check if we should spawn surfers
        if CanSurfersSpawn() then
            SpawnSurfers()
        else
            -- Decrease cooldown if needed
            if chillCooldown > 0 then
                chillCooldown = chillCooldown - 15
            end
        end
    end
end)

-- =============================================
-- EVENT HANDLERS
-- =============================================

-- Event to request surfer spawn
RegisterNetEvent("riptides:requestSpawn")
AddEventHandler("riptides:requestSpawn", function()
    local src = source
    
    -- Only allow if conditions are met
    if CanSurfersSpawn() then
        SpawnSurfers()
    end
end)

-- Event to buy weed from surfers
RegisterNetEvent("riptides:buyWeed")
AddEventHandler("riptides:buyWeed", function(price)
    local src = source
    
    -- Check if player has enough money
    if GetPlayerMoney(src) >= price then
        -- Remove money
        if RemovePlayerMoney(src, price) then
            -- Select a random weed item if available
            local weedItem = "weed"
            if Config.SurferServices.weed.items and #Config.SurferServices.weed.items > 0 then
                weedItem = Config.SurferServices.weed.items[math.random(#Config.SurferServices.weed.items)]
            end
            
            -- Give weed item
            local success = GivePlayerItem(src, weedItem, 1)
            
            if success then
                -- Notify player
                TriggerClientEvent("chat:addMessage", src, {
                    args = { "^3[" .. Config.SurferGang.name .. "]", "Here's your " .. Config.SurferServices.weed.quality .. " weed, dude. Enjoy the high!" }
                })
                
                -- Add temporary protection
                local identifier = GetPlayerIdentifier(src)
                playerProtections[identifier] = os.time() + (10 * 60) -- 10 minutes protection
                TriggerClientEvent("riptides:protectionGranted", src, 10)
                
                -- Log transaction
                DebugPrint("Player " .. GetPlayerName(src) .. " purchased weed for $" .. price)
            else
                -- Refund if item couldn't be given
                TriggerClientEvent("chat:addMessage", src, {
                    args = { "^3[" .. Config.SurferGang.name .. "]", "Can't give you the goods right now, bro. Here's your money back." }
                })
            end
        else
            TriggerClientEvent("chat:addMessage", src, {
                args = { "^3[" .. Config.SurferGang.name .. "]", "Transaction failed. Try again later, dude." }
            })
        end
    else
        TriggerClientEvent("chat:addMessage", src, {
            args = { "^3[" .. Config.SurferGang.name .. "]", "You don't have enough cash, bro!" }
        })
    end
end)

-- Event to buy surf lessons
RegisterNetEvent("riptides:buySurfLessons")
AddEventHandler("riptides:buySurfLessons", function(price)
    local src = source
    
    -- Check if player has enough money
    if GetPlayerMoney(src) >= price then
        -- Remove money
        if RemovePlayerMoney(src, price) then
            -- Grant surf lessons benefits
            TriggerClientEvent("riptides:surfLessonsStarted", src, Config.SurferServices.surfLessons.duration)
            
            -- Add temporary protection
            local identifier = GetPlayerIdentifier(src)
            playerProtections[identifier] = os.time() + (Config.SurferServices.surfLessons.duration * 60)
            TriggerClientEvent("riptides:protectionGranted", src, Config.SurferServices.surfLessons.duration)
            
            -- Notify player
            TriggerClientEvent("chat:addMessage", src, {
                args = { "^3[" .. Config.SurferGang.name .. "]", "Time to learn how to shred those waves, bro! Your lessons start now." }
            })
            
            -- Log transaction
            DebugPrint("Player " .. GetPlayerName(src) .. " purchased surf lessons for $" .. price)
        else
            TriggerClientEvent("chat:addMessage", src, {
                args = { "^3[" .. Config.SurferGang.name .. "]", "Transaction failed. Try again later, dude." }
            })
        end
    else
        TriggerClientEvent("chat:addMessage", src, {
            args = { "^3[" .. Config.SurferGang.name .. "]", "You don't have enough cash, bro!" }
        })
    end
end)

-- Event to buy beach party
RegisterNetEvent("riptides:buyBeachParty")
AddEventHandler("riptides:buyBeachParty", function(price)
    local src = source
    
    -- Check if player has enough money
    if GetPlayerMoney(src) >= price then
        -- Remove money
        if RemovePlayerMoney(src, price) then
            -- Start beach party
            local partyId = StartBeachParty(src)
            
            -- Add temporary protection
            local identifier = GetPlayerIdentifier(src)
            playerProtections[identifier] = os.time() + (Config.SurferServices.beachParty.duration * 60)
            TriggerClientEvent("riptides:protectionGranted", src, Config.SurferServices.beachParty.duration)
            
            -- Notify player
            TriggerClientEvent("chat:addMessage", src, {
                args = { "^3[" .. Config.SurferGang.name .. "]", "Let's get this party started, dude! You're the host for the next " .. Config.SurferServices.beachParty.duration .. " minutes!" }
            })
            
            -- Log transaction
            DebugPrint("Player " .. GetPlayerName(src) .. " started beach party " .. partyId .. " for $" .. price)
        else
            TriggerClientEvent("chat:addMessage", src, {
                args = { "^3[" .. Config.SurferGang.name .. "]", "Transaction failed. Try again later, dude." }
            })
        end
    else
        TriggerClientEvent("chat:addMessage", src, {
            args = { "^3[" .. Config.SurferGang.name .. "]", "You don't have enough cash, bro!" }
        })
    end
end)

-- Event to rent surfboard
RegisterNetEvent("riptides:rentSurfboard")
AddEventHandler("riptides:rentSurfboard", function(price)
    local src = source
    
    -- Check if player has enough money
    if GetPlayerMoney(src) >= price then
        -- Remove money
        if RemovePlayerMoney(src, price) then
            -- Trigger client event to spawn surfboard
            TriggerClientEvent("riptides:surfboardRentalStarted", src)
            
            -- Add temporary protection
            local identifier = GetPlayerIdentifier(src)
            playerProtections[identifier] = os.time() + (Config.SurferServices.surfboardRental.duration * 60)
            TriggerClientEvent("riptides:protectionGranted", src, Config.SurferServices.surfboardRental.duration)
            
            -- Notify player
            TriggerClientEvent("chat:addMessage", src, {
                args = { "^3[" .. Config.SurferGang.name .. "]", "Here's your board, dude! Catch some gnarly waves!" }
            })
            
            -- Log transaction
            DebugPrint("Player " .. GetPlayerName(src) .. " rented a surfboard for $" .. price)
        else
            TriggerClientEvent("chat:addMessage", src, {
                args = { "^3[" .. Config.SurferGang.name .. "]", "Transaction failed. Try again later, dude." }
            })
        end
    else
        TriggerClientEvent("chat:addMessage", src, {
            args = { "^3[" .. Config.SurferGang.name .. "]", "You don't have enough cash, bro!" }
        })
    end
end)

-- Event to rent vehicle
RegisterNetEvent("riptides:rentVehicle")
AddEventHandler("riptides:rentVehicle", function(price)
    local src = source
    
    -- Check if player has enough money
    if GetPlayerMoney(src) >= price then
        -- Remove money
        if RemovePlayerMoney(src, price) then
            -- Rent vehicle to player
            if RentVehicleToPlayer(src) then
                -- Notify player
                TriggerClientEvent("chat:addMessage", src, {
                    args = { "^3[" .. Config.SurferGang.name .. "]", "Here's your ride, dude! Bring it back in one piece!" }
                })
                
                -- Add temporary protection
                local identifier = GetPlayerIdentifier(src)
                playerProtections[identifier] = os.time() + (Config.SurferServices.vehicleRental.duration * 60)
                TriggerClientEvent("riptides:protectionGranted", src, Config.SurferServices.vehicleRental.duration)
                
                -- Log transaction
                DebugPrint("Player " .. GetPlayerName(src) .. " rented a vehicle for $" .. price)
            end
        else
            TriggerClientEvent("chat:addMessage", src, {
                args = { "^3[" .. Config.SurferGang.name .. "]", "Transaction failed. Try again later, dude." }
            })
        end
    else
        TriggerClientEvent("chat:addMessage", src, {
            args = { "^3[" .. Config.SurferGang.name .. "]", "You don't have enough cash, bro!" }
        })
    end
end)

-- Event to join beach party
RegisterNetEvent("riptides:joinBeachParty")
AddEventHandler("riptides:joinBeachParty", function(partyId)
    local src = source
    
    if activeBeachParties[partyId] then
        -- Add player to party participants
        table.insert(activeBeachParties[partyId].participants, src)
        
        -- Notify player
        TriggerClientEvent("chat:addMessage", src, {
            args = { "^3[" .. Config.SurferGang.name .. "]", "You joined the beach party hosted by " .. activeBeachParties[partyId].hostName .. "!" }
        })
        
        -- Notify host
        TriggerClientEvent("chat:addMessage", activeBeachParties[partyId].host, {
            args = { "^3[" .. Config.SurferGang.name .. "]", GetPlayerName(src) .. " joined your beach party!" }
        })
        
        -- Add temporary protection
        local identifier = GetPlayerIdentifier(src)
        local remainingTime = activeBeachParties[partyId].endTime - os.time()
        if remainingTime > 0 then
            playerProtections[identifier] = os.time() + remainingTime
            TriggerClientEvent("riptides:protectionGranted", src, math.floor(remainingTime / 60))
        end
    else
        TriggerClientEvent("chat:addMessage", src, {
            args = { "^3[" .. Config.SurferGang.name .. "]", "That party doesn't exist anymore, dude!" }
        })
    end
end)

-- Event to check player protection
RegisterNetEvent("riptides:checkProtection")
AddEventHandler("riptides:checkProtection", function()
    local src = source
    local identifier = GetPlayerIdentifier(src)
    
    if playerProtections[identifier] and playerProtections[identifier] > os.time() then
        local remainingTime = math.floor((playerProtections[identifier] - os.time()) / 60)
        TriggerClientEvent("riptides:protectionStatus", src, true, remainingTime)
    else
        TriggerClientEvent("riptides:protectionStatus", src, false, 0)
    end
end)

-- Event to return rented vehicle
RegisterNetEvent("riptides:returnRentedVehicle")
AddEventHandler("riptides:returnRentedVehicle", function()
    local src = source
    local identifier = GetPlayerIdentifier(src)
    
    if rentedVehicles[identifier] then
        rentedVehicles[identifier] = nil
        TriggerClientEvent("chat:addMessage", src, {
            args = { "^3[" .. Config.SurferGang.name .. "]", "Thanks for returning the vehicle, dude! Come back anytime!" }
        })
    end
end)

-- Legacy event for backward compatibility
RegisterNetEvent("riptides:rewardPlayer")
AddEventHandler("riptides:rewardPlayer", function()
    local src = source
    
    -- Check if this is a valid request (could add anti-cheat here)
    local playerPed = GetPlayerPed(src)
    if playerPed and DoesEntityExist(playerPed) then
        local playerCoords = GetEntityCoords(playerPed)
        local distance = #(playerCoords - Config.SurferGang.territory.center)
        
        if distance <= Config.SurferGang.territory.radius * 1.5 then
            -- Give money reward
            if ESX then
                local xPlayer = ESX.GetPlayerFromId(src)
                if xPlayer then
                    xPlayer.addMoney(100)
                end
            elseif QBCore then
                local Player = QBCore.Functions.GetPlayer(src)
                if Player then
                    Player.Functions.AddMoney('cash', 100)
                end
            else
                TriggerEvent("myframework:addMoney", src, 100)
            end
            
            -- Notify player
            TriggerClientEvent("chat:addMessage", src, {
                args = { "^3[" .. Config.SurferGang.name .. "]", "Here's $100 for helping us out, dude!" }
            })
            
            DebugPrint("Rewarded player " .. GetPlayerName(src) .. " with $100")
        else
            DebugPrint("Player " .. GetPlayerName(src) .. " attempted to claim reward but was too far from beach")
        end
    end
end)

-- =============================================
-- ADMIN COMMANDS
-- =============================================

-- Command to force spawn surfers (admin only)
RegisterCommand("spawnsurfers", function(source, args, rawCommand)
    if source == 0 or IsPlayerAceAllowed(source, "command.spawnsurfers") then
        SpawnSurfers()
        
        if source == 0 then
            print("[RIPTIDES] Admin spawned surfers via console. Unrest level: " .. unrestLevel)
        else
            DebugPrint("Admin " .. GetPlayerName(source) .. " spawned surfers. Unrest level: " .. unrestLevel)
            TriggerClientEvent("chat:addMessage", source, {
                args = { "^3[ADMIN]", "Surfers spawned successfully. Unrest level: " .. unrestLevel }
            })
        end
    else
        TriggerClientEvent("chat:addMessage", source, {
            args = { "^1[ERROR]", "You don't have permission to use this command." }
        })
    end
end, false)

-- Command to force despawn surfers (admin only)
RegisterCommand("despawnsurfers", function(source, args, rawCommand)
    if source == 0 or IsPlayerAceAllowed(source, "command.despawnsurfers") then
        DespawnSurfers()
        
        if source == 0 then
            print("[RIPTIDES] Admin despawned surfers via console. Un
