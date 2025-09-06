-- Variables
local activePlayers = {}
local playerCooldowns = {}

-- Debug function
local function DebugPrint(message)
    if Config.Debug then
        print("[Garbage Job] " .. message)
    end
end

-- Function to check if framework is available
local function IsFrameworkAvailable()
    local success = pcall(function()
        return exports["standalone-framework"]:GetPlayerData()
    end)
    return success
end

-- Function to add money to player
local function AddPlayerMoney(playerId, amount)
    if not IsFrameworkAvailable() then
        -- Fallback if framework is not available
        TriggerClientEvent("garbage:notify", playerId, "You earned $" .. amount, "success")
        return
    end
    
    local success = pcall(function()
        exports["standalone-framework"]:AddPlayerMoney(playerId, amount)
    end)
    
    if success then
        DebugPrint("Added $" .. amount .. " to player " .. playerId)
    else
        DebugPrint("Failed to add money to player " .. playerId)
    end
end

-- Function to add XP to player
local function AddPlayerXP(playerId, amount)
    if not IsFrameworkAvailable() then
        return
    end
    
    local success = pcall(function()
        exports["standalone-framework"]:AddPlayerXP(playerId, amount)
    end)
    
    if success then
        DebugPrint("Added " .. amount .. " XP to player " .. playerId)
    else
        DebugPrint("Failed to add XP to player " .. playerId)
    end
end

-- Event to start garbage route
RegisterServerEvent("garbage:getStart")
AddEventHandler("garbage:getStart", function()
    local src = source
    
    -- Check if player is already on a route
    if activePlayers[src] then
        TriggerClientEvent("garbage:notify", src, "You are already on a garbage route.", "error")
        return
    end
    
    -- Check cooldown
    if playerCooldowns[src] and os.time() - playerCooldowns[src] < (Config.JobCooldown * 60) then
        local remainingTime = math.ceil((Config.JobCooldown * 60) - (os.time() - playerCooldowns[src]))
        TriggerClientEvent("garbage:notify", src, "You must wait " .. remainingTime .. " seconds before starting another route.", "error")
        return
    end
    
    -- Add player to active players
    activePlayers[src] = {
        startTime = os.time(),
        pointsCompleted = 0
    }
    
    -- Set cooldown
    playerCooldowns[src] = os.time()
    
    -- Start route
    TriggerClientEvent("garbage:startRoute", src)
    DebugPrint("Player " .. src .. " started a garbage route")
end)

-- Event when player completes a garbage point
RegisterServerEvent("garbage:pointCompleted")
AddEventHandler("garbage:pointCompleted", function()
    local src = source
    
    -- Check if player is on a route
    if not activePlayers[src] then
        return
    end
    
    -- Increment points completed
    activePlayers[src].pointsCompleted = activePlayers[src].pointsCompleted + 1
    
    -- Add payment per point
    AddPlayerMoney(src, Config.PayPerStop)
    AddPlayerXP(src, Config.XpPerStop)
    
    -- Notify player
    TriggerClientEvent("garbage:notify", src, "Garbage collected. +$" .. Config.PayPerStop, "success")
    
    DebugPrint("Player " .. src .. " completed garbage point " .. activePlayers[src].pointsCompleted)
end)

-- Event when player completes entire route
RegisterServerEvent("garbage:routeCompleted")
AddEventHandler("garbage:routeCompleted", function()
    local src = source
    
    -- Check if player is on a route
    if not activePlayers[src] then
        return
    end
    
    -- Calculate bonus based on points completed
    local bonus = activePlayers[src].pointsCompleted * 25
    
    -- Add bonus payment
    AddPlayerMoney(src, bonus)
    AddPlayerXP(src, bonus / 5)
    
    -- Notify player
    TriggerClientEvent("garbage:notify", src, "Route completed! You earned a bonus of $" .. bonus, "success")
    
    -- Remove player from active players
    activePlayers[src] = nil
    
    DebugPrint("Player " .. src .. " completed a garbage route and earned a bonus of $" .. bonus)
end)

-- Clean up when player disconnects
AddEventHandler('playerDropped', function()
    local src = source
    
    -- Remove player from active players
    if activePlayers[src] then
        activePlayers[src] = nil
        DebugPrint("Player " .. src .. " dropped while on a garbage route")
    end
end)

-- Print when resource starts
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        DebugPrint("Garbage job system started")
    end
end)
