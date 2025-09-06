-- Variables
local activeMissions = {}

-- Debug function
local function DebugPrint(message)
    if Config.Debug then
        print("[Vigilante Mission] " .. message)
    end
end

-- Event to give reward to player
RegisterServerEvent("vigilante_mission:giveReward")
AddEventHandler("vigilante_mission:giveReward", function(amount)
    local src = source
    
    -- Check if valid amount
    if not amount or amount <= 0 then
        DebugPrint("Invalid reward amount")
        return
    end
    
    -- Check if player has an active mission
    if activeMissions[src] then
        activeMissions[src] = nil
    end
    
    -- Give money to player (using your economy system)
    -- This is a placeholder - replace with your actual money system
    -- Example with standalone framework:
    local success = pcall(function()
        exports["standalone-framework"]:AddPlayerMoney(src, amount)
    end)
    
    -- If no framework, just notify the player
    if not success then
        TriggerClientEvent("chat:addMessage", src, {
            color = {0, 255, 0},
            multiline = false,
            args = {"System", "You received $" .. amount}
        })
    end
    
    DebugPrint("Player " .. src .. " received $" .. amount .. " reward")
end)

-- Clean up when player disconnects
AddEventHandler('playerDropped', function()
    local src = source
    
    -- Remove active mission
    if activeMissions[src] then
        activeMissions[src] = nil
        DebugPrint("Player " .. src .. " disconnected with active mission")
    end
end)

-- Print when resource starts
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        DebugPrint("Vigilante mission system started")
    end
end)
