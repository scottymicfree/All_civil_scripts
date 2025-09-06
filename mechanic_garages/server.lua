-- Mechanic Garage System for Civil Unrest RP
-- Server-side script

-- Debug function
local function debugPrint(message)
    if Config.Debug then
        print("^3[MECHANIC SERVER DEBUG] " .. message .. "^7")
    end
end

-- Process repair payment
RegisterServerEvent('mechanic_garages:requestRepair')
AddEventHandler('mechanic_garages:requestRepair', function(repairType, price)
    local src = source
    
    -- Check if player has enough money
    if GetResourceState('standalone-framework') == 'started' then
        local success, playerMoney = pcall(function()
            -- Try GetPlayerMoney first
            local money = exports['standalone-framework']:GetPlayerMoney(src)
            if money == nil then
                -- Fall back to GetPlayerValue
                money = exports['standalone-framework']:GetPlayerValue(src, 'money') or 0
            end
            return money
        end)
        
        if not success then
            debugPrint("Error getting player money: " .. tostring(playerMoney))
            playerMoney = 0
        end
        
        debugPrint("Player " .. GetPlayerName(src) .. " has $" .. playerMoney .. ", repair costs $" .. price)
        
        if playerMoney >= price then
            -- Remove money
            local removed = false
            success, removed = pcall(function()
                return exports['standalone-framework']:RemoveMoney(src, price)
            end)
            
            if not success or not removed then
                debugPrint("Error removing money: " .. tostring(removed))
                TriggerClientEvent('mechanic_garages:paymentDeclined', src)
                return
            end
            
            -- Log transaction
            debugPrint("Player " .. GetPlayerName(src) .. " paid $" .. price .. " for " .. repairType)
            
            -- Approve repair
            TriggerClientEvent('mechanic_garages:repairApproved', src, repairType)
            
            -- Notify player
            TriggerClientEvent('chat:addMessage', src, {
                color = {0, 255, 0},
                multiline = false,
                args = {"Mechanic", "You paid $" .. price .. " for vehicle service."}
            })
        else
            -- Decline payment
            TriggerClientEvent('mechanic_garages:paymentDeclined', src)
            
            -- Notify player
            TriggerClientEvent('chat:addMessage', src, {
                color = {255, 0, 0},
                multiline = false,
                args = {"Mechanic", "You don't have enough money. You need $" .. price .. "."}
            })
        end
    else
        debugPrint("standalone-framework not found, approving repair without payment")
        -- If framework is not available, approve anyway
        TriggerClientEvent('mechanic_garages:repairApproved', src, repairType)
    end
end)

-- Process customization payment
RegisterServerEvent('mechanic_garages:requestCustomization')
AddEventHandler('mechanic_garages:requestCustomization', function(customType, price)
    local src = source
    
    -- Check if player has enough money
    if GetResourceState('standalone-framework') == 'started' then
        local success, playerMoney = pcall(function()
            -- Try GetPlayerMoney first
            local money = exports['standalone-framework']:GetPlayerMoney(src)
            if money == nil then
                -- Fall back to GetPlayerValue
                money = exports['standalone-framework']:GetPlayerValue(src, 'money') or 0
            end
            return money
        end)
        
        if not success then
            debugPrint("Error getting player money: " .. tostring(playerMoney))
            playerMoney = 0
        end
        
        if playerMoney >= price then
            -- Remove money
            local removed = false
            success, removed = pcall(function()
                return exports['standalone-framework']:RemoveMoney(src, price)
            end)
            
            if not success or not removed then
                debugPrint("Error removing money: " .. tostring(removed))
                TriggerClientEvent('mechanic_garages:paymentDeclined', src)
                return
            end
            
            -- Log transaction
            debugPrint("Player " .. GetPlayerName(src) .. " paid $" .. price .. " for " .. customType)
            
            -- Approve customization
            TriggerClientEvent('mechanic_garages:customizationApproved', src, customType)
            
            -- Notify player
            TriggerClientEvent('chat:addMessage', src, {
                color = {0, 255, 0},
                multiline = false,
                args = {"Mechanic", "You paid $" .. price .. " for vehicle customization."}
            })
        else
            -- Decline payment
            TriggerClientEvent('mechanic_garages:paymentDeclined', src)
            
            -- Notify player
            TriggerClientEvent('chat:addMessage', src, {
                color = {255, 0, 0},
                multiline = false,
                args = {"Mechanic", "You don't have enough money. You need $" .. price .. "."}
            })
        end
    else
        debugPrint("standalone-framework not found, approving customization without payment")
        -- If framework is not available, approve anyway
        TriggerClientEvent('mechanic_garages:customizationApproved', src, customType)
    end
end)

-- Add command for mechanics to set repair prices
RegisterCommand('setrepairprice', function(source, args, rawCommand)
    local src = source
    
    -- Check if player is a mechanic
    local isMechanic = false
    
    if GetResourceState('standalone-framework') == 'started' then
        local success, result = pcall(function()
            return exports['standalone-framework']:GetPlayerJob(src) == Config.MechanicJobName
        end)
        
        if success then
            isMechanic = result
        else
            debugPrint("Error checking mechanic job: " .. tostring(result))
        end
    end
    
    if isMechanic then
        if args[1] and tonumber(args[1]) then
            local newPrice = tonumber(args[1])
            
            if newPrice >= 0 then
                -- Update repair cost
                Config.RepairCost = newPrice
                
                -- Notify all mechanics
                local players = GetPlayers()
                for _, player in ipairs(players) do
                    local isPlayerMechanic = false
                    
                    if GetResourceState('standalone-framework') == 'started' then
                        local success, result = pcall(function()
                            return exports['standalone-framework']:GetPlayerJob(player) == Config.MechanicJobName
                        end)
                        
                        if success then
                            isPlayerMechanic = result
                        end
                    end
                    
                    if isPlayerMechanic then
                        TriggerClientEvent('chat:addMessage', player, {
                            color = {0, 255, 0},
                            multiline = false,
                            args = {"Mechanic", "Repair base price has been set to $" .. newPrice .. " by " .. GetPlayerName(src)}
                        })
                    end
                end
            else
                TriggerClientEvent('chat:addMessage', src, {
                    color = {255, 0, 0},
                    multiline = false,
                    args = {"Mechanic", "Price must be a positive number"}
                })
            end
        else
            TriggerClientEvent('chat:addMessage', src, {
                color = {255, 255, 0},
                multiline = false,
                args = {"Mechanic", "Current repair base price: $" .. Config.RepairCost}
            })
            TriggerClientEvent('chat:addMessage', src, {
                color = {255, 255, 0},
                multiline = false,
                args = {"Mechanic", "Usage: /setrepairprice [amount]"}
            })
        end
    else
        TriggerClientEvent('chat:addMessage', src, {
            color = {255, 0, 0},
            multiline = false,
            args = {"Mechanic", "You must be a mechanic to use this command"}
        })
    end
end, false)

-- Helper function to get all players
function GetPlayers()
    local players = {}
    for i = 0, GetNumPlayerIndices() - 1 do
        table.insert(players, GetPlayerFromIndex(i))
    end
    return players
end

-- Command to toggle debug mode server-side
RegisterCommand('mechanic_debug_server', function(source, args)
    if source == 0 then -- Console only
        Config.Debug = not Config.Debug
        print("Mechanic debug mode: " .. (Config.Debug and "Enabled" or "Disabled"))
    end
end, true)
