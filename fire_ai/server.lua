-- =========================================================
-- [ server.lua ]
-- Handles server-side events for the fire NPC.
-- =========================================================

-- Event to handle a player interacting with the fire NPC
RegisterServerEvent("fire:assist")
AddEventHandler("fire:assist", function()
    local src = source
    print("[Fire NPC] Player " .. src .. " checked in with Fire Department.")
    
    -- Send the configured chat message back to the player
    TriggerClientEvent("chat:addMessage", src, {
        args = { "[Fire Chief]", Config.NpcChatMessage }
    })
end)
