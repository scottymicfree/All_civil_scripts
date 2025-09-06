-- CIVIL UNREST SCRIPT
-- System: Rawhood Queens - Server

-- Check if frameworks are available
local ESX = nil
local QBCore = nil

if GetResourceState('es_extended') ~= 'missing' then
    ESX = exports['es_extended']:getSharedObject()
elseif GetResourceState('qb-core') ~= 'missing' then
    QBCore = exports['qb-core']:GetCoreObject()
end

-- Function to get player money
local function GetPlayerMoney(source)
    if ESX then
        local xPlayer = ESX.GetPlayerFromId(source)
        return xPlayer.getMoney()
    elseif QBCore then
        local Player = QBCore.Functions.GetPlayer(source)
        return Player.PlayerData.money.cash
    else
        -- Fallback for standalone
        return 10000 -- Assume player has money in standalone mode
    end
end

-- Function to remove player money
local function RemovePlayerMoney(source, amount)
    if ESX then
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer.getMoney() >= amount then
            xPlayer.removeMoney(amount)
            return true
        end
    elseif QBCore then
        local Player = QBCore.Functions.GetPlayer(source)
        if Player.PlayerData.money.cash >= amount then
            Player.Functions.RemoveMoney('cash', amount)
            return true
        end
    else
        -- Fallback for standalone
        return true
    end
    return false
end

-- Function to give item to player
local function GivePlayerItem(source, item, count)
    if ESX then
        local xPlayer = ESX.GetPlayerFromId(source)
        xPlayer.addInventoryItem(item, count)
        return true
    elseif QBCore then
        local Player = QBCore.Functions.GetPlayer(source)
        if Player.Functions.AddItem(item, count) then
            TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[item], 'add')
            return true
        end
    else
        -- Fallback for standalone
        TriggerClientEvent("rawhood_queens:receivedItem", source, item, count)
        return true
    end
    return false
end

-- Event handlers
RegisterNetEvent("rawhood_queens:buyProtection")
AddEventHandler("rawhood_queens:buyProtection", function(price)
    local source = source
    
    -- Check if player has enough money
    if GetPlayerMoney(source) >= price then
        -- Remove money
        if RemovePlayerMoney(source, price) then
            -- Grant protection
            TriggerClientEvent("rawhood_queens:protectionPurchased", source, Config.QueenServices.protection.duration)
            
            -- Log transaction
            print("[Rawhood Queens] Player " .. GetPlayerName(source) .. " purchased protection for $" .. price)
        else
            TriggerClientEvent("chat:addMessage", source, {
                args = { "^6[" .. Config.QueenGang.name .. "]", "Transaction failed. Try again later, sugar." }
            })
        end
    else
        TriggerClientEvent("chat:addMessage", source, {
            args = { "^6[" .. Config.QueenGang.name .. "]", "You don't have enough money, honey." }
        })
    end
end)

RegisterNetEvent("rawhood_queens:buyInformation")
AddEventHandler("rawhood_queens:buyInformation", function(price)
    local source = source
    
    -- Check if player has enough money
    if GetPlayerMoney(source) >= price then
        -- Remove money
        if RemovePlayerMoney(source, price) then
            -- Provide random information type
            local infoTypes = {"gang", "police", "business"}
            local infoType = infoTypes[math.random(#infoTypes)]
            
            -- Send information to client
            TriggerClientEvent("rawhood_queens:informationPurchased", source, infoType)
            
            -- Log transaction
            print("[Rawhood Queens] Player " .. GetPlayerName(source) .. " purchased information for $" .. price)
        else
            TriggerClientEvent("chat:addMessage", source, {
                args = { "^6[" .. Config.QueenGang.name .. "]", "Transaction failed. Try again later, sugar." }
            })
        end
    else
        TriggerClientEvent("chat:addMessage", source, {
            args = { "^6[" .. Config.QueenGang.name .. "]", "You don't have enough money, honey." }
        })
    end
end)

RegisterNetEvent("rawhood_queens:openContrabandShop")
AddEventHandler("rawhood_queens:openContrabandShop", function()
    local source = source
    
    -- Send shop items to client
    TriggerClientEvent("rawhood_queens:openContrabandShopMenu", source, Config.QueenServices.contraband.items)
end)

RegisterNetEvent("rawhood_queens:buyContrabandItem")
AddEventHandler("rawhood_queens:buyContrabandItem", function(itemIndex)
    local source = source
    
    -- Check if item exists
    if not Config.QueenServices.contraband.items[itemIndex] then
        TriggerClientEvent("chat:addMessage", source, {
            args = { "^6[" .. Config.QueenGang.name .. "]", "That item isn't available anymore, sugar." }
        })
        return
    end
    
    local item = Config.QueenServices.contraband.items[itemIndex]
    
    -- Check if player has enough money
    if GetPlayerMoney(source) >= item.price then
        -- Remove money
        if RemovePlayerMoney(source, item.price) then
            -- Give item
            if GivePlayerItem(source, item.name, 1) then
                TriggerClientEvent("chat:addMessage", source, {
                    args = { "^6[" .. Config.QueenGang.name .. "]", "Here's your " .. item.label .. ", don't tell anyone where you got it." }
                })
                
                -- Log transaction
                print("[Rawhood Queens] Player " .. GetPlayerName(source) .. " purchased " .. item.label .. " for $" .. item.price)
            else
                -- Refund if item couldn't be given
                -- This would need proper implementation in a production environment
                TriggerClientEvent("chat:addMessage", source, {
                    args = { "^6[" .. Config.QueenGang.name .. "]", "Couldn't give you that item. Your money was refunded." }
                })
            end
        else
            TriggerClientEvent("chat:addMessage", source, {
                args = { "^6[" .. Config.QueenGang.name .. "]", "Transaction failed. Try again later, sugar." }
            })
        end
    else
        TriggerClientEvent("chat:addMessage", source, {
            args = { "^6[" .. Config.QueenGang.name .. "]", "You don't have enough money, honey." }
        })
    end
end)

print("[Rawhood Queens] Server loaded.")
