-- Variables
local activeRewards = {}

-- Debug function
local function DebugPrint(message)
    print("[Civil Disorder] " .. message)
end

-- Initialize
DebugPrint("Server initialized")

-- Event to give player reward
RegisterNetEvent("givePlayerReward")
AddEventHandler("givePlayerReward", function(type)
    local src = source
    
    -- Check for reward spam
    if activeRewards[src] and GetGameTimer() - activeRewards[src] < 60000 then
        DebugPrint("Player " .. src .. " attempted to claim multiple rewards too quickly")
        return
    end
    
    -- Set reward cooldown
    activeRewards[src] = GetGameTimer()
    
    -- Process reward based on type
    if type == "guns" then
        -- Give weapons or weapon parts
        DebugPrint("Rewarding player " .. src .. " with guns")
        TriggerClientEvent("chat:addMessage", src, {
            color = {255, 50, 50},
            multiline = false,
            args = {"Gang", "You received weapon parts from the gang."}
        })
        
    elseif type == "drugs" then
        -- Give drugs
        DebugPrint("Rewarding player " .. src .. " with drugs")
        TriggerClientEvent("chat:addMessage", src, {
            color = {50, 255, 50},
            multiline = false,
            args = {"Gang", "You received drugs from the gang."}
        })
        
    elseif type == "cars" then
        -- Give car or car parts
        DebugPrint("Rewarding player " .. src .. " with car parts")
        TriggerClientEvent("chat:addMessage", src, {
            color = {50, 50, 255},
            multiline = false,
            args = {"Gang", "You received car parts from the gang."}
        })
        
    elseif type == "mini_mission" then
        -- Start mini mission
        DebugPrint("Starting mini mission for player " .. src)
        TriggerClientEvent("chat:addMessage", src, {
            color = {255, 255, 50},
            multiline = false,
            args = {"Gang", "The gang has a job for you. Check your GPS."}
        })
        TriggerClientEvent("civil_disorder:startMission", src)
    end
end)

-- Clean up when player disconnects
AddEventHandler('playerDropped', function()
    local src = source
    if activeRewards[src] then
        activeRewards[src] = nil
    end
end)
