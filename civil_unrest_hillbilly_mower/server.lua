-- Initialize
print("[HILLBILLY] Server initialized.")

-- Event: Client is ready
RegisterNetEvent("hillbilly_mower:clientReady")
AddEventHandler("hillbilly_mower:clientReady", function()
    local src = source
    print("[HILLBILLY] Player " .. src .. " client ready. Checking hillbilly spawn condition.")
    TriggerClientEvent("hillbilly_mower:spawn", src)
end)

-- Event: Player entered zone
RegisterNetEvent("hillbilly_mower:playerEnteredZone")
AddEventHandler("hillbilly_mower:playerEnteredZone", function()
    local src = source
    print("[HILLBILLY] Player " .. src .. " entered hillbilly zone")
end)

-- Event: Player left zone
RegisterNetEvent("hillbilly_mower:playerLeftZone")
AddEventHandler("hillbilly_mower:playerLeftZone", function()
    local src = source
    print("[HILLBILLY] Player " .. src .. " left hillbilly zone")
end)

-- Command to spawn hillbillies (admin only)
RegisterCommand("spawnhillbillies", function(source, args, rawCommand)
    local src = source
    
    -- Check if player is admin (basic check)
    if src > 0 and not IsPlayerAceAllowed(src, "command") then
        TriggerClientEvent("chat:addMessage", src, {
            color = {255, 0, 0},
            multiline = false,
            args = {"System", "You don't have permission to use this command."}
        })
        return
    end
    
    -- Spawn hillbillies for all players or specific player
    if args[1] and tonumber(args[1]) then
        local targetPlayer = tonumber(args[1])
        if GetPlayerName(targetPlayer) then
            TriggerClientEvent("hillbilly_mower:spawn", targetPlayer)
            print("[HILLBILLY] Admin " .. src .. " spawned hillbillies for player " .. targetPlayer)
        else
            if src > 0 then
                TriggerClientEvent("chat:addMessage", src, {
                    color = {255, 0, 0},
                    multiline = false,
                    args = {"System", "Player not found."}
                })
            end
        end
    else
        -- Spawn for all players
        TriggerClientEvent("hillbilly_mower:spawn", -1)
        print("[HILLBILLY] Admin " .. src .. " spawned hillbillies for all players")
    end
end, false)
