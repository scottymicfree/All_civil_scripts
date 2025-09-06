-- riptides/server.lua

print("[RIPTIDES] Server script loaded.")

-- Framework detection
local ESX = nil
local QBCore = nil

if GetResourceState('es_extended') ~= 'missing' then
    ESX = exports['es_extended']:getSharedObject()
    print("[RIPTIDES] ESX framework detected")
elseif GetResourceState('qb-core') ~= 'missing' then
    QBCore = exports['qb-core']:GetCoreObject()
    print("[RIPTIDES] QBCore framework detected")
end

-- Variables
local chillCooldown = 0
local activeSurfers = false
local unrestLevel = 0
local maxUnrest = Config and Config.UnrestSystem and Config.UnrestSystem.maxUnrest or 100
local activeBeachParties = {}
local playerProtections = {}

-- Debug function
local function DebugPrint(message)
    if Config and Config.Debug then
        print("[RIPTIDES] " .. message)
    end
end

-- Function to check if coordinates are in a conflict zone
function isInConflictZone(coords)
    -- Check gang zones
    if Config and Config.ConflictZones and Config.ConflictZones.gangZones then
        for _, zone in pairs(Config.ConflictZones.gangZones) do
            if #(coords - zone.center) < zone.radius then
                return true, "gang turf (" .. zone.name .. ")"
            end
        end
    end
    
    -- Check safe zones
    if Config and Config.ConflictZones and Config.ConflictZones.safeZones then
        for _, zone in pairs(Config.ConflictZones.safeZones) do
            if #(coords - zone.center) < zone.radius then
                return true, "safe zone (" .. zone.name .. ")"
            end
        end
    end
    
    -- Check riot zones
    if Config and Config.ConflictZones and Config.ConflictZones.riotZones then
        for _, loc in ipairs(Config.ConflictZones.riotZones) do
            if #(coords - loc) < 80.0 then
                return true, "riot zone"
            end
        end
    end
    
    return false, nil
end

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
        local playerPed = GetPlayerPedtonumber(playerId)
        if playerPed and DoesEntityExist(playerPed) then
            local playerCoords = GetEntityCoords(playerPed)
            local distance = #(playerCoords - Config.SurferGang.territory.center)
            
            if distance <= Config.SurferGang.territory.radius * 1.5 then
                TriggerClientEvent("chat:addMessage", tonumber(playerId), {
                    args = { "^3[" .. Config.SurferGang.name .. "]", message }
                })
            end
        end
    end
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

-- Main thread for spawn timing
CreateThread(function()
    -- Initialize Config if it doesn't exist yet
    if not Config then
        Config = {
            SpawnTiming = {
                activeHoursStart = 9,
                activeHoursEnd = 18,
                minCooldown = 210,
                maxCooldown = 340,
                spawnDuration = 200
            },
            SurferGang = {
                territory = {
                    center = vector3(-1495.42, -1387.6, 2.13)
                }
            },
            UnrestSystem = {
                maxUnrest = 100,
                unrestIncreasePerSpawn = 5,
                unrestDecreasePerDespawn = 10
            },
            ConflictZones = {
                gangZones = {},
                safeZones = {},
                riotZones = {
                    vector3(-75.0, -818.0, 326.2),
                    vector3(252.0, -1000.0, 29.3),
                    vector3(180.0, -1300.0, 29.2)
                }
            }
        }
    end
    
    -- Update conflict zones initially
    UpdateConflictZones()
    
    while true do
        Wait(15000)
        local hour = GetClockHours()
        
        -- Update conflict zones periodically
        if math.random(1, 10) == 1 then
            UpdateConflictZones()
        end
        
        if hour >= Config.SpawnTiming.activeHoursStart and hour <= Config.SpawnTiming.activeHoursEnd then
            if chillCooldown <= 0 and not activeSurfers then
                local conflict = false
                local chillSpots = Config.ChillSpots or {
                    vector4(-1495.42, -1387.6, 2.13, 180.0),
                    vector4(-1499.0, -1385.0, 2.13, 90.0),
                    vector4(-1502.0, -1382.0, 2.13, 270.0)
                }
                
                for _, spot in ipairs(chillSpots) do
                    local spotVec3 = vector3(spot.x, spot.y, spot.z)
                    local inConflict, conflictType = isInConflictZone(spotVec3)
                    if inConflict then
                        DebugPrint("Spawn skipped: " .. conflictType .. " at " .. spot.x .. ", " .. spot.y .. ", " .. spot.z)
                        conflict = true
                        break
                    end
                end
                
                if not conflict then
                    TriggerClientEvent("riptides:spawn", -1)
                    activeSurfers = true
                    unrestLevel = math.min(unrestLevel + (Config.UnrestSystem.unrestIncreasePerSpawn or 5), maxUnrest)
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
                        TriggerClientEvent("riptides:despawn", -1)
                        activeSurfers = false
                        chillCooldown = math.random(Config.SpawnTiming.minCooldown, Config.SpawnTiming.maxCooldown)
                        unrestLevel = math.max(unrestLevel - (Config.UnrestSystem.unrestDecreasePerDespawn or 10), 0)
                        DebugPrint("Despawned surfers. Unrest level: " .. unrestLevel)
                    end)
                end
            else
                chillCooldown = chillCooldown - 15
            end
        end
    end
end)

-- Event to request surfer spawn
RegisterNetEvent("riptides:requestSpawn")
AddEventHandler("riptides:requestSpawn", function()
    local src = source
    
    -- Only allow if not already active and cooldown is ready
    if not activeSurfers and chillCooldown <= 0 then
        -- Check for conflicts
        local conflict = false
        local chillSpots = Config.ChillSpots or {
            vector4(-1495.42, -1387.6, 2.13, 180.0),
            vector4(-1499.0, -1385.0, 2.13, 90.0),
            vector4(-1502.0, -1382.0, 2.13, 270.0)
        }
        
        for _, spot in ipairs(chillSpots) do
            local spotVec3 = vector3(spot.x, spot.y, spot.z)
            local inConflict, conflictType = isInConflictZone(spotVec3)
            if inConflict then
                DebugPrint("Spawn skipped: " .. conflictType .. " at " .. spot.x .. ", " .. spot.y .. ", " .. spot.z)
                conflict = true
                break
            end
        end
        
        if not conflict then
            TriggerClientEvent("riptides:spawn", -1)
            activeSurfers = true
            unrestLevel = math.min(unrestLevel + (Config.UnrestSystem.unrestIncreasePerSpawn or 5), maxUnrest)
            DebugPrint("Spawned surfers. Unrest level: " .. unrestLevel)
            
            -- Set despawn timer
            SetTimeout(Config.SpawnTiming.spawnDuration * 1000, function()
                TriggerClientEvent("riptides:despawn", -1)
                activeSurfers = false
                chillCooldown = math.random(Config.SpawnTiming.minCooldown, Config.SpawnTiming.maxCooldown)
                unrestLevel = math.max(unrestLevel - (Config.UnrestSystem.unrestDecreasePerDespawn or 10), 0)
                DebugPrint("Despawned surfers. Unrest level: " .. unrestLevel)
            end)
        end
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
            -- Give weed item
            local success = GivePlayerItem(src, "weed", 1)
            
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

-- Command to force spawn surfers (admin only)
RegisterCommand("spawnsurfers", function(source, args, rawCommand)
    if source == 0 or IsPlayerAceAllowed(source, "command.spawnsurfers") then
        TriggerClientEvent("riptides:spawn", -1)
        activeSurfers = true
        unrestLevel = math.min(unrestLevel + (Config.UnrestSystem.unrestIncreasePerSpawn or 5), maxUnrest)
        
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
        TriggerClientEvent("riptides:despawn", -1)
        activeSurfers = false
        unrestLevel = math.max(unrestLevel - (Config.UnrestSystem.unrestDecreasePerDespawn or 10), 0)
        
        if source == 0 then
            print("[RIPTIDES] Admin despawned surfers via console. Unrest level: " .. unrestLevel)
        else
            DebugPrint("Admin " .. GetPlayerName(source) .. " despawned surfers. Unrest level: " .. unrestLevel)
            TriggerClientEvent("chat:addMessage", source, {
                args = { "^3[ADMIN]", "Surfers despawned successfully. Unrest level: " .. unrestLevel }
            })
        end
    else
        TriggerClientEvent("chat:addMessage", source, {
            args = { "^1[ERROR]", "You don't have permission to use this command." }
        })
    end
end, false)

-- Command to set unrest level (admin only)
RegisterCommand("setunrest", function(source, args, rawCommand)
    if source == 0 or IsPlayerAceAllowed(source, "command.setunrest") then
        if #args < 1 then
            if source == 0 then
                print("[RIPTIDES] Usage: setunrest [level 0-100]")
            else
                TriggerClientEvent("chat:addMessage", source, {
                    args = { "^3[ADMIN]", "Usage: /setunrest [level 0-100]" }
                })
            end
            return
        end
        
        local level = tonumber(args[1])
        if level and level >= 0 and level <= 100 then
            unrestLevel = level
            
            if source == 0 then
                print("[RIPTIDES] Admin set unrest level to " .. level .. " via console")
            else
                DebugPrint("Admin " .. GetPlayerName(source) .. " set unrest level to " .. level)
                TriggerClientEvent("chat:addMessage", source, {
                    args = { "^3[ADMIN]", "Unrest level set to " .. level }
                })
            end
        else
            if source == 0 then
                print("[RIPTIDES] Invalid unrest level. Must be 0-100.")
            else
                TriggerClientEvent("chat:addMessage", source, {
                    args = { "^1[ERROR]", "Invalid unrest level. Must be 0-100." }
                })
            end
        end
    else
        TriggerClientEvent("chat:addMessage", source, {
            args = { "^1[ERROR]", "You don't have permission to use this command." }
        })
    end
end, false)

-- Player disconnect handler
AddEventHandler"playerDropped function"(reason)
    local src = source
    local identifier = GetPlayerIdentifier(src)
    
    -- Clean up any beach parties hosted by this player
    for partyId, party in pairs(activeBeachParties) do
        if party.host == src then
            -- Notify participants
            for _, participant in ipairs(party.participants) do
                if participant ~= src then
                    TriggerClientEvent("chat:addMessage", participant, {
                        args = { "^3[" .. Config.SurferGang.name .. "]", "The beach party has ended because the host left!" }
                    })
                end
            end
            
            -- End the party
            TriggerClientEvent("riptides:beachPartyEnded", -1)
            activeBeachParties[partyId] = nil
            DebugPrint("Beach party " .. partyId .. " ended because host disconnected")
            break
        end
    end

-- Export functions
exports('GetUnrestLevel', function()
    return unrestLevel
end)

exports('IsPlayerProtected', function(source)
    local identifier = GetPlayerIdentifier(source)
    return playerProtections[identifier] and playerProtections[identifier] > os.time()
end)

exports('AreSurfersActive', function()
    return activeSurfers
end)

exports('GetActiveBeachParties', function()
    return activeBeachParties
end)