local debugMode = false

local function debugLog(msg)
    if debugMode then
        print('[NPCController] ' .. msg)
    end
end

RegisterServerEvent('npc_controller:interaction')
AddEventHandler('npc_controller:interaction', function(npcType, playerJob)
    local src = source
    if not src or type(src) ~= "number" then
        debugLog("Error: Invalid src for npc_controller:interaction: " .. tostring(src))
        return
    end

    debugLog("Player " .. src .. " interacted with " .. npcType .. " as " .. playerJob)
    
    -- Example: Award XP or update mission state
    if playerJob == "police" and npcType == "criminal" then
        TriggerClientEvent('standalone-framework:ShowNotification', src, "Criminal arrested! +10 XP")
    elseif playerJob == "ems" and npcType == "injured" then
        TriggerClientEvent('standalone-framework:ShowNotification', src, "Injured person revived! +15 XP")
    elseif playerJob == "firefighter" and npcType == "civilian" then
        TriggerClientEvent('standalone-framework:ShowNotification', src, "Civilian rescued! +12 XP")
    elseif playerJob == "drugdealer" and npcType == "rival_gang" then
        TriggerClientEvent('standalone-framework:ShowNotification', src, "Rival intimidated! +8 XP")
    end
end)

-- Debug command
RegisterCommand("npccontroller_debug", function(source)
    if source == 0 then
        debugMode = not debugMode
        print("[NPCController] Debug mode " .. (debugMode and "enabled" or "disabled"))
    end
end, false)