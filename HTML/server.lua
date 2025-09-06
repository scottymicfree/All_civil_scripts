print("[HTML-RESOURCE] Server loaded.")

-- Example server-side event
RegisterServerEvent('ui:serverEvent')
AddEventHandler('ui:serverEvent', function(data)
    local src = source
    local playerName = GetPlayerName(src)
    
    print("[HTML-RESOURCE] Received UI event from " .. playerName .. " (ID: " .. src .. "): " .. json.encode(data))
    
    -- Example: Send response back to client
    if data.action == "button_click" then
        TriggerClientEvent('ui:serverResponse', src, {
            success = true,
            message = "Server received your button click!"
        })
    end
end)

-- Command to trigger UI for a player
RegisterCommand("triggerui", function(source, args, rawCommand)
    if source == 0 then
        -- Console command
        if #args < 2 then
            print("Usage: triggerui [playerId] [message]")
            return
        end
        
        local targetPlayer = tonumber(args[1])
        table.remove(args, 1)
        local message = table.concat(args, " ")
        
        if GetPlayerPing(targetPlayer) > 0 then
            TriggerClientEvent('ui:triggerUI', targetPlayer, message)
            print("[HTML-RESOURCE] Triggered UI for player " .. targetPlayer)
        else
            print("[HTML-RESOURCE] Player not found: " .. targetPlayer)
        end
    else
        -- Player command (requires permission)
        if IsPlayerAceAllowed(source, "command.triggerui") then
            if #args < 2 then
                TriggerClientEvent('chat:addMessage', source, {
                    color = {255, 0, 0},
                    multiline = false,
                    args = {"System", "Usage: /triggerui [playerId] [message]"}
                })
                return
            end
            
            local targetPlayer = tonumber(args[1])
            table.remove(args, 1)
            local message = table.concat(args, " ")
            
            if GetPlayerPing(targetPlayer) > 0 then
                TriggerClientEvent('ui:triggerUI', targetPlayer, message)
                TriggerClientEvent('chat:addMessage', source, {
                    color = {0, 255, 0},
                    multiline = false,
                    args = {"System", "UI triggered for player " .. targetPlayer}
                })
            else
                TriggerClientEvent('chat:addMessage', source, {
                    color = {255, 0, 0},
                    multiline = false,
                    args = {"System", "Player not found: " .. targetPlayer}
                })
            end
        else
            TriggerClientEvent('chat:addMessage', source, {
                color = {255, 0, 0},
                multiline = false,
                args = {"System", "You don't have permission to use this command"}
            })
        end
    end
end, true)
