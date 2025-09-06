-- Civil Disorder AI Framework - Server Script
local playerGangReputation = {}
local activeGangMissions = {}
local gangShopInventory = {}

-- Initialize framework integration
local Framework = nil
local ESX = nil -- Made ESX local
local QBCore = nil -- Made QBCore local

if Config.Integration.useESX then
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    Framework = ESX
elseif Config.Integration.useQBCore then
    QBCore = exports['qb-core']:GetCoreObject()
    Framework = QBCore
elseif Config.Integration.useCustomFramework then
    Framework = exports[Config.Integration.frameworkExport]:GetFramework()
end

-- Debug function
local function DebugPrint(message)
    if Config.Debug then
        print("[Civil Disorder] " .. message)
    end
end

-- Function to get player identifier
local function GetPlayerIdentifier(source, idType)
    idType = idType or "steam" -- Default to steam if not specified
    
    if Config.Integration.useESX then
        local xPlayer = ESX.GetPlayerFromId(source)
        return xPlayer and xPlayer.identifier
    elseif Config.Integration.useQBCore then
        local Player = QBCore.Functions.GetPlayer(source)
        return Player and Player.PlayerData.citizenid
    elseif Config.Integration.useCustomFramework then
        return Framework.GetIdentifier(source)
    else
        for _, v in pairs(GetPlayerIdentifiers(source)) do
            if string.sub(v, 1, 6) == "steam:" then
                return v
            end
        end
    end
    return nil
end

-- Function to initialize gang shop inventory
local function InitializeGangShops()
    -- Weapons shop items
    gangShopInventory.weapons = {
        {name = "WEAPON_KNIFE", label = "Knife", price = 1000},
        {name = "WEAPON_BAT", label = "Baseball Bat", price = 1500},
        {name = "WEAPON_PISTOL", label = "Pistol", price = 5000},
        {name = "WEAPON_PISTOL_AMMO", label = "Pistol Ammo", price = 500, count = 24},
        {name = "WEAPON_KNUCKLE", label = "Brass Knuckles", price = 1200},
        {name = "WEAPON_SWITCHBLADE", label = "Switchblade", price = 1800}
    }
    
    -- Drugs shop items
    gangShopInventory.drugs = {
        {name = "weed", label = "Weed Bag", price = 500, count = 5},
        {name = "joint", label = "Joint", price = 120, count = 1},
        {name = "cocaine", label = "Cocaine Bag", price = 1500, count = 5},
        {name = "meth", label = "Meth Bag", price = 1200, count = 5},
        {name = "ecstasy", label = "Ecstasy Pill", price = 300, count = 1}
    }
    
    -- Vehicles shop items
    gangShopInventory.vehicles = {
        {name = "blista", label = "Blista", price = 15000},
        {name = "asbo", label = "Asbo", price = 12000},
        {name = "faction", label = "Faction", price = 25000},
        {name = "club", label = "Club", price = 18000},
        {name = "gauntlet", label = "Gauntlet", price = 35000}
    }
end

-- Function to get player by source
local function GetPlayer(source)
    if Config.Integration.useESX then
        return ESX.GetPlayerFromId(source)
    elseif Config.Integration.useQBCore then
        return QBCore.Functions.GetPlayer(source)
    elseif Config.Integration.useCustomFramework then
        return Framework.GetPlayer(source)
    else
        return {source = source}
    end
end

-- Function to give item to player
local function GivePlayerItem(source, item, count)
    local player = GetPlayer(source)
    
    if Config.Integration.useESX then
        player.addInventoryItem(item, count)
        return true
    elseif Config.Integration.useQBCore then
        return player.Functions.AddItem(item, count)
    elseif Config.Integration.useCustomFramework and Config.Integration.useCustomInventory then
        return exports[Config.Integration.inventoryExport]:AddItem(source, item, count)
    else
        -- Fallback to basic event
        TriggerClientEvent("civil_disorder:receivedItem", source, item, count)
        return true
    end
end

-- Function to remove money from player
local function RemovePlayerMoney(source, amount, cashType)
    local player = GetPlayer(source)
    cashType = cashType or "cash"
    
    if Config.Integration.useESX then
        if player.getMoney() >= amount then
            player.removeMoney(amount)
            return true
        end
        return false
    elseif Config.Integration.useQBCore then
        return player.Functions.RemoveMoney(cashType, amount)
    elseif Config.Integration.useCustomFramework then
        return Framework.RemoveMoney(source, cashType, amount)
    else
        -- Fallback to basic event
        TriggerClientEvent("civil_disorder:removeMoney", source, amount)
        return true
    end
end

-- Function to give money to player
local function GivePlayerMoney(source, amount, cashType)
    local player = GetPlayer(source)
    cashType = cashType or "cash"
    
    if Config.Integration.useESX then
        player.addMoney(amount)
        return true
    elseif Config.Integration.useQBCore then
        return player.Functions.AddMoney(cashType, amount)
    elseif Config.Integration.useCustomFramework then
        return Framework.AddMoney(source, cashType, amount)
    else
        -- Fallback to basic event
        TriggerClientEvent("civil_disorder:receivedMoney", source, amount)
        return true
    end
end

-- Function to give weapon to player
local function GivePlayerWeapon(source, weapon, ammo)
    local player = GetPlayer(source)
    
    if Config.Integration.useESX then
        player.addWeapon(weapon, ammo)
        return true
    elseif Config.Integration.useQBCore then
        return GivePlayerItem(source, weapon, 1)
    elseif Config.Integration.useCustomFramework then
        return Framework.GiveWeapon(source, weapon, ammo)
    else
        -- Fallback to basic event
        TriggerClientEvent("civil_disorder:receivedWeapon", source, weapon, ammo)
        return true
    end
end

-- Function to check if player has enough money
local function HasEnoughMoney(source, amount, cashType)
    local player = GetPlayer(source)
    cashType = cashType or "cash"
    
    if Config.Integration.useESX then
        return player.getMoney() >= amount
    elseif Config.Integration.useQBCore then
        return player.Functions.GetMoney(cashType) >= amount
    elseif Config.Integration.useCustomFramework then
        return Framework.GetMoney(source, cashType) >= amount
    else
        -- Fallback to client check
        return true
    end
end

-- Function to save player gang reputation
local function SavePlayerGangReputation(source)
    local identifier = GetPlayerIdentifier(source, "steam") -- Added second parameter
    if not identifier then return end
    
    -- Save to database or other persistent storage
    -- This is a placeholder - implement your own storage solution
    DebugPrint("Saved gang reputation for player " .. source)
end

-- Function to load player gang reputation
local function LoadPlayerGangReputation(source)
    local identifier = GetPlayerIdentifier(source, "steam") -- Added second parameter
    if not identifier then return {} end
    
    -- Load from database or other persistent storage
    -- This is a placeholder - implement your own storage solution
    
    -- Initialize with neutral reputation for all gangs
    local reputation = {}
    for _, gang in pairs(Config.Gangs) do
        reputation[gang.name] = Config.PlayerInteraction.neutralGangReputation
    end
    
    return reputation
end

-- Function to generate a random gang mission
local function GenerateGangMission(gangName)
    local gang = nil
    for _, g in pairs(Config.Gangs) do
        if g.name == gangName then
            gang = g
            break
        end
    end
    
    if not gang then return nil end
    
    local missionTypes = {
        "delivery",
        "elimination",
        "theft",
        "protection",
        "intimidation"
    }
    
    local missionType = missionTypes[math.random(#missionTypes)]
    local mission = {
        id = gangName .. "_" .. missionType .. "_" .. os.time(),
        type = missionType,
        gang = gangName,
        reward = math.random(1000, 5000),
        reputation = math.random(3, 10),
        timeLimit = math.random(10, 30) -- minutes
    }
    
    -- Set mission-specific data
    if missionType == "delivery" then
        mission.description = "Deliver a package for " .. gangName
        mission.location = gang.territory.spawnPoints[math.random(#gang.territory.spawnPoints)]
        mission.targetLocation = vector3(
            gang.territory.center.x + math.random(-500, 500),
            gang.territory.center.y + math.random(-500, 500),
            gang.territory.center.z
        )
        mission.item = "package"
    elseif missionType == "elimination" then
        mission.description = "Eliminate a target for " .. gangName
        mission.location = vector3(
            gang.territory.center.x + math.random(-800, 800),
            gang.territory.center.y + math.random(-800, 800),
            gang.territory.center.z
        )
        mission.targetModel = "a_m_y_business_03"
    elseif missionType == "theft" then
        mission.description = "Steal a vehicle for " .. gangName
        mission.location = vector3(
            gang.territory.center.x + math.random(-1000, 1000),
            gang.territory.center.y + math.random(-1000, 1000),
            gang.territory.center.z
        )
        mission.vehicleModel = "sentinel"
        mission.dropLocation = gang.territory.spawnPoints[math.random(#gang.territory.spawnPoints)]
    elseif missionType == "protection" then
        mission.description = "Protect a " .. gangName .. " asset"
        mission.location = gang.territory.spawnPoints[math.random(#gang.territory.spawnPoints)]
        mission.duration = math.random(3, 8) -- minutes
        mission.waves = math.random(2, 4)
    elseif missionType == "intimidation" then
        mission.description = "Intimidate a local business for " .. gangName
        mission.location = vector3(
            gang.territory.center.x + math.random(-600, 600),
            gang.territory.center.y + math.random(-600, 600),
            gang.territory.center.z
        )
        mission.businessName = "Local Business"
        mission.intimidationMethod = math.random(1, 3) -- 1: threaten, 2: damage property, 3: beat up owner
    end
    
    return mission
end

-- Function to reward player for gang mission
local function RewardPlayerForMission(source, mission)
    -- Give money reward
    GivePlayerMoney(source, mission.reward)
    
    -- Update reputation
    if playerGangReputation[source] and playerGangReputation[source][mission.gang] then
        playerGangReputation[source][mission.gang] = playerGangReputation[source][mission.gang] + mission.reputation
        
        -- Sync with client
        TriggerClientEvent("civil_disorder:syncGangReputation", source, playerGangReputation[source])
        
        -- Save to persistent storage
        SavePlayerGangReputation(source)
    end
    
    -- Notify player
    TriggerClientEvent("civil_disorder:endGangMission", source, mission.gang, true, mission.reward)
    
    DebugPrint("Player " .. source .. " completed mission for " .. mission.gang)
end

-- Initialize the resource
CreateThread(function() -- Changed from Citizen.CreateThread
    -- Initialize gang shops
    InitializeGangShops()
    
    DebugPrint("Civil Disorder AI Framework Server initialized")
end)

-- Event handlers
RegisterNetEvent("civil_disorder:getGangReputation")
AddEventHandler("civil_disorder:getGangReputation", function()
    local source = source
    
    -- Load or initialize player's gang reputation
    if not playerGangReputation[source] then
        playerGangReputation[source] = LoadPlayerGangReputation(source)
    end
    
    -- Sync with client
    TriggerClientEvent("civil_disorder:syncGangReputation", source, playerGangReputation[source])
end)

RegisterNetEvent("civil_disorder:updateGangReputation")
AddEventHandler("civil_disorder:updateGangReputation", function(gangName, reputation)
    local source = source
    
    -- Initialize if needed
    if not playerGangReputation[source] then
        playerGangReputation[source] = LoadPlayerGangReputation(source)
    end
    
    -- Update reputation
    playerGangReputation[source][gangName] = reputation
    
    -- Save to persistent storage
    SavePlayerGangReputation(source)
    
    DebugPrint("Updated reputation for player " .. source .. " with " .. gangName .. ": " .. reputation)
end)

RegisterNetEvent("civil_disorder:openGangShop")
AddEventHandler("civil_disorder:openGangShop", function(gangName, shopType)
    local source = source
    
    -- Check if shop type exists
    if not gangShopInventory[shopType] then
        TriggerClientEvent("civil_disorder:notification", source, "This shop is not available")
        return
    end
    
    -- Check player reputation with gang
    local reputation = playerGangReputation[source] and playerGangReputation[source][gangName] or Config.PlayerInteraction.neutralGangReputation
    if reputation < 10 then
        TriggerClientEvent("civil_disorder:notification", source, gangName .. " doesn't trust you enough yet")
        return
    end
    
    -- Send shop inventory to client
    TriggerClientEvent("civil_disorder:openShopMenu", source, gangName, shopType, gangShopInventory[shopType])
end)

RegisterNetEvent("civil_disorder:buyShopItem")
AddEventHandler("civil_disorder:buyShopItem", function(gangName, shopType, itemIndex)
    local source = source
    
    -- Check if shop and item exist
    if not gangShopInventory[shopType] or not gangShopInventory[shopType][itemIndex] then
        TriggerClientEvent("civil_disorder:notification", source, "Item not available")
        return
    end
    
    local item = gangShopInventory[shopType][itemIndex]
    
    -- Check if player has enough money
    if not HasEnoughMoney(source, item.price) then
        TriggerClientEvent("civil_disorder:notification", source, "You don't have enough money")
        return
    end
    
    -- Process purchase based on shop type
    if shopType == "weapons" then
        -- Remove money
        if RemovePlayerMoney(source, item.price) then
            -- Give weapon
            if string.sub(item.name, 1, 7) == "WEAPON_" then
                if string.find(item.name, "_AMMO") then
                    -- Give ammo
                    GivePlayerItem(source, item.name, item.count or 1)
                else
                    -- Give weapon
                    GivePlayerWeapon(source, item.name, 0)
                end
                
                TriggerClientEvent("civil_disorder:notification", source, "Purchased " .. item.label)
                
                -- Increase reputation slightly
                if playerGangReputation[source] and playerGangReputation[source][gangName] then
                    playerGangReputation[source][gangName] = playerGangReputation[source][gangName] + 1
                    TriggerClientEvent("civil_disorder:syncGangReputation", source, playerGangReputation[source])
                    SavePlayerGangReputation(source)
                end
            end
        end
    elseif shopType == "drugs" then
        -- Remove money
        if RemovePlayerMoney(source, item.price) then
            -- Give item
            GivePlayerItem(source, item.name, item.count or 1)
            
            TriggerClientEvent("civil_disorder:notification", source, "Purchased " .. item.label)
            
            -- Increase reputation slightly
            if playerGangReputation[source] and playerGangReputation[source][gangName] then
                playerGangReputation[source][gangName] = playerGangReputation[source][gangName] + 1
                TriggerClientEvent("civil_disorder:syncGangReputation", source, playerGangReputation[source])
                SavePlayerGangReputation(source)
            end
        end
    elseif shopType == "vehicles" then
        -- Remove money
        if RemovePlayerMoney(source, item.price) then
            -- Spawn vehicle for player
            TriggerClientEvent("civil_disorder:spawnPurchasedVehicle", source, item.name)
            
            TriggerClientEvent("civil_disorder:notification", source, "Purchased " .. item.label)
            
            -- Increase reputation slightly
            if playerGangReputation[source] and playerGangReputation[source][gangName] then
                playerGangReputation[source][gangName] = playerGangReputation[source][gangName] + 2
                TriggerClientEvent("civil_disorder:syncGangReputation", source, playerGangReputation[source])
                SavePlayerGangReputation(source)
            end
        end
    end
end)

RegisterNetEvent("civil_disorder:requestGangMission")
AddEventHandler("civil_disorder:requestGangMission", function(gangName)
    local source = source
    
    -- Check if player already has an active mission for this gang
    if activeGangMissions[source] and activeGangMissions[source][gangName] then
        TriggerClientEvent("civil_disorder:notification", source, "You already have an active mission for " .. gangName)
        return
    end
    
    -- Check player reputation with gang
    local reputation = playerGangReputation[source] and playerGangReputation[source][gangName] or Config.PlayerInteraction.neutralGangReputation
    if reputation < 0 then
        TriggerClientEvent("civil_disorder:notification", source, gangName .. " doesn't trust you")
        return
    end
    
    -- Generate mission
    local mission = GenerateGangMission(gangName)
    if not mission then
        TriggerClientEvent("civil_disorder:notification", source, "No missions available right now")
        return
    end
    
    -- Store mission
    if not activeGangMissions[source] then
        activeGangMissions[source] = {}
    end
    activeGangMissions[source][gangName] = mission
    
    -- Send mission to client
    TriggerClientEvent("civil_disorder:startGangMission", source, gangName, mission.type, mission)
    
    DebugPrint("Player " .. source .. " started mission for " .. gangName)
end)

RegisterNetEvent("civil_disorder:completeMission")
AddEventHandler("civil_disorder:completeMission", function(gangName, missionId)
    local source = source
    
    -- Check if mission exists and matches
    if not activeGangMissions[source] or not activeGangMissions[source][gangName] or 
       activeGangMissions[source][gangName].id ~= missionId then
        TriggerClientEvent("civil_disorder:notification", source, "Mission not found or already completed")
        return
    end
    
    local mission = activeGangMissions[source][gangName]
    
    -- Reward player
    RewardPlayerForMission(source, mission)
    
    -- Clear mission
    activeGangMissions[source][gangName] = nil
end)

RegisterNetEvent("civil_disorder:failMission")
AddEventHandler("civil_disorder:failMission", function(gangName)
    local source = source
    
    -- Check if mission exists
    if not activeGangMissions[source] or not activeGangMissions[source][gangName] then
        return
    end
    
    -- Notify client
    TriggerClientEvent("civil_disorder:endGangMission", source, gangName, false, 0)
    
    -- Update reputation negatively
    if playerGangReputation[source] and playerGangReputation[source][gangName] then
        playerGangReputation[source][gangName] = playerGangReputation[source][gangName] - 3
        TriggerClientEvent("civil_disorder:syncGangReputation", source, playerGangReputation[source])
        SavePlayerGangReputation(source)
    end
    
    -- Clear mission
    activeGangMissions[source][gangName] = nil
    
    DebugPrint("Player " .. source .. " failed mission for " .. gangName)
end)

RegisterNetEvent("civil_disorder:bribeGangMember")
AddEventHandler("civil_disorder:bribeGangMember", function(gangName, amount)
    local source = source
    
    -- Check if player has enough money
    if not HasEnoughMoney(source, amount) then
        TriggerClientEvent("civil_disorder:notification", source, "You don't have enough money")
        return
    end
    
    -- Remove money
    if RemovePlayerMoney(source, amount) then
        -- Increase reputation
        if playerGangReputation[source] and playerGangReputation[source][gangName] then
            local reputationGain = math.floor(amount / 100) -- $100 = 1 reputation point
            playerGangReputation[source][gangName] = playerGangReputation[source][gangName] + reputationGain
            
            -- Sync with client
            TriggerClientEvent("civil_disorder:syncGangReputation", source, playerGangReputation[source])
            
            -- Save to persistent storage
            SavePlayerGangReputation(source)
            
            -- Notify player
            TriggerClientEvent("civil_disorder:notification", source, "You bribed the " .. gangName .. " member")
        end
    end
end)

-- Integration with Interior Zone Manager
if Config.Integration.interiorZoneManager then
    -- Register gang territories as zones
    CreateThread(function() -- Changed from Citizen.CreateThread
        -- Wait for Interior Zone Manager to initialize
        Wait(5000)
        
        -- Check if export exists
        if not pcall(function() return exports["interior_zone_manager"] end) then
            DebugPrint("Interior Zone Manager not found, skipping zone registration")
            return
        end
        
        -- Register gang territories as zones
        for _, gang in pairs(Config.Gangs) do
            if gang.enabled and gang.territory then
                -- Register zone
                exports["interior_zone_manager"]:RegisterServerZone(
                    gang.name .. " Territory",
                    gang.territory.center,
                    {
                        radius = gang.territory.radius,
                        type = "gang_territory",
                        subType = gang.offer,
                        showBlip = true,
                        blipColor = gang.territory.color,
                        blipName = gang.name .. " Territory",
                        data = {
                            gangName = gang.name,
                            rivals = gang.territory.rivals,
                            allies = gang.territory.allies
                        }
                    }
                )
                
                DebugPrint("Registered " .. gang.name .. " territory with Interior Zone Manager")
            end
        end
    end)
end

-- Player disconnect handler
AddEventHandler("playerDropped", function()
    local source = source
    
    -- Save gang reputation
    if playerGangReputation[source] then
        SavePlayerGangReputation(source)
    end
    
    -- Clear active missions
    activeGangMissions[source] = nil
    
    -- Clear gang reputation cache
    playerGangReputation[source] = nil
end)

-- Original event handler for backward compatibility
RegisterNetEvent("givePlayerReward")
AddEventHandler("givePlayerReward", function(type)
    local src = source
    print(("Rewarding player %s with %s..."):format(src, type))
    
    -- Add reward based on type
    if type == "money" then
        GivePlayerMoney(src, 1000)
    elseif type == "item" then
        GivePlayerItem(src, "package", 1)
    elseif type == "weapon" then
        GivePlayerWeapon(src, "WEAPON_PISTOL", 12)
    end
end)

-- Export functions
exports('GetPlayerGangReputation', function(source, gangName)
    if not playerGangReputation[source] then
        return Config.PlayerInteraction.neutralGangReputation
    end
    
    if gangName then
        return playerGangReputation[source][gangName] or Config.PlayerInteraction.neutralGangReputation
    else
        return playerGangReputation[source]
    end
end)

exports('SetPlayerGangReputation', function(source, gangName, reputation)
    if not playerGangReputation[source] then
        playerGangReputation[source] = LoadPlayerGangReputation(source)
    end
    
    playerGangReputation[source][gangName] = reputation
    TriggerClientEvent("civil_disorder:syncGangReputation", source, playerGangReputation[source])
    SavePlayerGangReputation(source)
    
    return true
end)

exports('GetActiveGangMissions', function(source)
    return activeGangMissions[source] or {}
end)

exports('GenerateGangMission', GenerateGangMission)
