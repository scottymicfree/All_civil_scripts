-- =========================================================
-- [ server.lua ]
-- Handles server-side events for the EMS NPC.
-- =========================================================

-- Add cooldown tracking to prevent spam
local playerCooldowns = {}

-- Event to handle a player interacting with the EMS NPC
RegisterServerEvent("ems:assist")
AddEventHandler("ems:assist", function()
    local src = source
    
    -- Check cooldown
    local currentTime = os.time()
    if playerCooldowns[src] and currentTime - playerCooldowns[src] < 5 then
        -- Player is on cooldown, ignore request
        return
    end
    
    -- Set cooldown
    playerCooldowns[src] = currentTime
    
    -- Log interaction
    print("[EMS NPC] Player " .. src .. " checked in with EMS.")
    
    -- Send the configured chat message back to the player
    TriggerClientEvent("chat:addMessage", src, {
        args = { "[EMS]", Config.NpcChatMessage }
    })
    
    -- Heal the player (optional)
    TriggerClientEvent("ems:heal", src)
end)

-- Clean up cooldowns when player disconnects
AddEventHandler("playerDropped", function()
    local src = source
    if playerCooldowns[src] then
        playerCooldowns[src] = nil
    end
end)
