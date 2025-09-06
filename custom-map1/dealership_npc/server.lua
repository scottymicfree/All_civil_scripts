-- dealership_npc/server.lua

-- Variables
local interactionCooldowns = {}

-- Event to open dealership menu
RegisterServerEvent("dealership:openMenu")
AddEventHandler("dealership:openMenu", function()
    local src = source
    
    -- Check for interaction spam
    if interactionCooldowns[src] and os.time() - interactionCooldowns[src] < 3 then
        -- Ignore request if player is spamming
        return
    end
    
    -- Set cooldown
    interactionCooldowns[src] = os.time()
    
    -- Log interaction
    print("[Dealership] Player " .. src .. " is interacting with the dealer.")
    
    -- Send chat message
    TriggerClientEvent("chat:addMessage", src, {
        color = {255, 195, 0},
        multiline = false,
        args = { "[Dealer]", "Hello! Welcome to the dealership. Vehicle purchase is coming soon!" }
    })
    
    -- You can add more functionality here, such as:
    -- TriggerClientEvent("dealership:showVehicleMenu", src)
end)

-- Clean up when player disconnects
AddEventHandler('playerDropped', function()
    local src = source
    if interactionCooldowns[src] then
        interactionCooldowns[src] = nil
    end
end)

-- Print when resource starts
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        print("[Dealership] NPC script started successfully")
    end
end)
