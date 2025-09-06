-- gang_system/server.lua
print("[Gang System] Server loaded.")

-- Gang data
local gangs = {
    ["ballas"] = {
        name = "Ballas",
        color = 7, -- Purple
        spawnPoint = vector3(105.4, -1940.5, 20.8),
        members = {}
    },
    ["vagos"] = {
        name = "Los Santos Vagos",
        color = 5, -- Yellow
        spawnPoint = vector3(334.2, -2052.1, 20.8),
        members = {}
    },
    ["families"] = {
        name = "The Families",
        color = 2, -- Green
        spawnPoint = vector3(-173.3, -1634.5, 33.5),
        members = {}
    },
    ["biker"] = {
        name = "Lost MC",
        color = 0, -- Black
        spawnPoint = vector3(977.0, -104.1, 74.8),
        members = {}
    }
}

-- Player joins gang
RegisterNetEvent("gang_system:joinGang")
AddEventHandler("gang_system:joinGang", function(gangId)
    local src = source
    
    if not gangs[gangId] then
        TriggerClientEvent("fxcode:utils:notify", src, "This gang doesn't exist!", "error")
        return
    end
    
    -- Add player to gang
    gangs[gangId].members[tostring(src)] = true
    
    -- Set player's gang in framework
    exports["standalone-framework"]:SetPlayerGang(src, gangId)
    
    -- Notify player
    TriggerClientEvent("fxcode:utils:notify", src, "You joined the " .. gangs[gangId].name .. " gang!", "success")
    
    -- Trigger client event
    TriggerClientEvent("gang_system:setGang", src, gangId, gangs[gangId])
    
    print("[Gang System] Player " .. GetPlayerName(src) .. " joined gang: " .. gangId)
end)

-- Player leaves gang
RegisterNetEvent("gang_system:leaveGang")
AddEventHandler("gang_system:leaveGang", function()
    local src = source
    local currentGang = exports["standalone-framework"]:GetPlayerGang(src)
    
    if not currentGang or not gangs[currentGang] then
        TriggerClientEvent("fxcode:utils:notify", src, "You are not in a gang!", "error")
        return
    end
    
    -- Remove player from gang
    if gangs[currentGang].members[tostring(src)] then
        gangs[currentGang].members[tostring(src)] = nil
    end
    
    -- Reset player's gang in framework
    exports["standalone-framework"]:SetPlayerGang(src, "civilian")
    
    -- Notify player
    TriggerClientEvent("fxcode:utils:notify", src, "You left the " .. gangs[currentGang].name .. " gang!", "info")
    
    -- Trigger client event
    TriggerClientEvent("gang_system:setGang", src, "civilian", nil)
    
    print("[Gang System] Player " .. GetPlayerName(src) .. " left gang: " .. currentGang)
end)

-- Get gang info
RegisterNetEvent("gang_system:getGangInfo")
AddEventHandler("gang_system:getGangInfo", function(gangId)
    local src = source
    
    if not gangId or not gangs[gangId] then
        TriggerClientEvent("fxcode:utils:notify", src, "This gang doesn't exist!", "error")
        return
    end
    
    -- Send gang info to client
    TriggerClientEvent("gang_system:gangInfo", src, gangId, gangs[gangId])
end)

-- Player disconnects
AddEventHandler("playerDropped", function()
    local src = source
    
    -- Clean up gang membership
    for gangId, gang in pairs(gangs) do
        if gang.members[tostring(src)] then
            gang.members[tostring(src)] = nil
            print("[Gang System] Player " .. GetPlayerName(src) .. " removed from gang: " .. gangId)
        end
    end
end)