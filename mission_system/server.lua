-- =============================================================
-- [ mission_system_server.lua ]
-- Server-side script for the Mission System
-- =============================================================


-- Configuration
local Config = {
    -- XP multipliers by difficulty
    XPMultipliers = {
        low = 1.0,
        mid = 1.5,
        high = 2.0
    },


-- Money multipliers by difficulty
MoneyMultipliers = {
    low = 1.0,
    mid = 1.5,
    high = 2.0
},

-- Time bonuses (seconds)
TimeBonuses = {
    low = 300,  -- 5 minutes
    mid = 600,  -- 10 minutes
    high = 900  -- 15 minutes
},

-- Bonus multipliers
BonusMultipliers = {
    xp = 0.2,   -- 20% bonus XP for completing within time limit
    money = 0.2 -- 20% bonus money for completing within time limit
},

-- Cooldown between missions (in milliseconds)
Cooldown = 300000, -- 5 minutes

-- Debug mode
DebugMode = false

}


-- Variables
local playerMissions = {}
local playerCooldowns = {}


-- Event handler for mission completion
RegisterNetEvent("mission_system:missionCompleted")
AddEventHandler("mission_system:missionCompleted", function(missionType, difficulty, timeTaken)
    local source = source
    local identifier = GetPlayerIdentifier(source, 0)


-- Check if player exists
if not identifier then
    if Config.DebugMode then
        print("Player identifier not found for source: " .. source)
    end
    return
end

-- Check if mission type and difficulty are valid
if not missionType or not difficulty then
    if Config.DebugMode then
        print("Invalid mission type or difficulty")
    end
    return
end

-- Calculate rewards
local baseXP = 0
local baseMoney = 0

-- Get base rewards from client config
TriggerClientEvent("mission_system:getBaseRewards", source, missionType, difficulty, function(xp, money)
    baseXP = xp
    baseMoney = money
end)

-- Apply difficulty multipliers
local xpMultiplier = Config.XPMultipliers[difficulty] or 1.0
local moneyMultiplier = Config.MoneyMultipliers[difficulty] or 1.0

local xp = baseXP * xpMultiplier
local money = baseMoney * moneyMultiplier

-- Apply time bonus if completed within time limit
local timeLimit = Config.TimeBonuses[difficulty] or 600
if timeTaken and timeTaken <= timeLimit then
    local bonusXP = xp * Config.BonusMultipliers.xp
    local bonusMoney = money * Config.BonusMultipliers.money
    
    xp = xp + bonusXP
    money = money + bonusMoney
    
    -- Notify player of bonus
    TriggerClientEvent("mission_system:notify", source, "Time Bonus: +" .. math.floor(bonusXP) .. " XP, +$" .. math.floor(bonusMoney))
end

-- Round rewards
xp = math.floor(xp)
money = math.floor(money)

-- Add rewards to player
if GetResourceState('standalone-framework') == 'started' then
    -- Use standalone-framework if available
    exports['standalone-framework']:AddXP(source, xp)
    exports['standalone-framework']:AddMoney(source, money)
else
    -- Fallback to basic events
    TriggerEvent("myframework:addXP", source, xp)
    TriggerEvent("myframework:addMoney", source, money)
end

-- Log mission completion
if not playerMissions[identifier] then
    playerMissions[identifier] = {}
end

table.insert(playerMissions[identifier], {
    type = missionType,
    difficulty = difficulty,
    completed = true,
    timeTaken = timeTaken,
    rewards = {
        xp = xp,
        money = money
    },
    timestamp = os.time()
})

-- Set cooldown
playerCooldowns[identifier] = os.time() + (Config.Cooldown / 1000)

-- Debug log
if Config.DebugMode then
    print("Mission completed by " .. GetPlayerName(source) .. " (" .. identifier .. ")")
    print("Type: " .. missionType .. ", Difficulty: " .. difficulty)
    print("Rewards: " .. xp .. " XP, $" .. money)
end

-- Notify player
TriggerClientEvent("mission_system:notify", source, "Mission rewards: " .. xp .. " XP, $" .. money)

end)


-- Event handler for mission failure
RegisterNetEvent("mission_system:missionFailed")
AddEventHandler("mission_system:missionFailed", function(missionType, difficulty, reason)
    local source = source
    local identifier = GetPlayerIdentifier(source, 0)


-- Check if player exists
if not identifier then
    return
end

-- Log mission failure
if not playerMissions[identifier] then
    playerMissions[identifier] = {}
end

table.insert(playerMissions[identifier], {
    type = missionType,
    difficulty = difficulty,
    completed = false,
    reason = reason,
    timestamp = os.time()
})

-- Set shorter cooldown for failed missions (half the normal cooldown)
playerCooldowns[identifier] = os.time() + (Config.Cooldown / 2000)

-- Debug log
if Config.DebugMode then
    print("Mission failed by " .. GetPlayerName(source) .. " (" .. identifier .. ")")
    print("Type: " .. missionType .. ", Difficulty: " .. difficulty)
    print("Reason: " .. (reason or "Unknown"))
end

end)


-- Command to check mission cooldown
RegisterCommand("missioncooldown", function(source, args, rawCommand)
    local identifier = GetPlayerIdentifier(source, 0)


if not identifier then
    return
end

local cooldown = playerCooldowns[identifier]
if cooldown then
    local currentTime = os.time()
    if cooldown > currentTime then
        local remainingTime = cooldown - currentTime
        TriggerClientEvent("mission_system:notify", source, "Mission cooldown: " .. remainingTime .. " seconds remaining")
    else
        TriggerClientEvent("mission_system:notify", source, "You can start a new mission now")
        playerCooldowns[identifier] = nil
    end
else
    TriggerClientEvent("mission_system:notify", source, "You can start a new mission now")
end

end, false)


-- Command to check mission history
RegisterCommand("missionhistory", function(source, args, rawCommand)
    local identifier = GetPlayerIdentifier(source, 0)


if not identifier then
    return
end

local missions = playerMissions[identifier]
if missions and #missions > 0 then
    -- Get the last 5 missions
    local recentMissions = {}
    local count = math.min(5, #missions)
    
    for i = #missions, #missions - count + 1, -1 do
        if missions[i] then
            table.insert(recentMissions, missions[i])
        end
    end
    
    -- Send mission history to client
    TriggerClientEvent("mission_system:showHistory", source, recentMissions)
else
    TriggerClientEvent("mission_system:notify", source, "You haven't completed any missions yet")
end

end, false)


-- Function to check if player is on cooldown
function IsPlayerOnCooldown(source)
    local identifier = GetPlayerIdentifier(source, 0)


if not identifier then
    return false
end

local cooldown = playerCooldowns[identifier]
if cooldown then
    local currentTime = os.time()
    return cooldown > currentTime
end

return false

end


-- Function to get player's mission history
function GetPlayerMissionHistory(source)
    local identifier = GetPlayerIdentifier(source, 0)


if not identifier then
    return {}
end

return playerMissions[identifier] or {}

end


-- Function to get player's cooldown
function GetPlayerCooldown(source)
    local identifier = GetPlayerIdentifier(source, 0)


if not identifier then
    return 0
end

local cooldown = playerCooldowns[identifier]
if cooldown then
    local currentTime = os.time()
    if cooldown > currentTime then
        return cooldown - currentTime
    end
end

return 0

end


-- Export functions
exports('IsPlayerOnCooldown', IsPlayerOnCooldown)
exports('GetPlayerMissionHistory', GetPlayerMissionHistory)
exports('GetPlayerCooldown', GetPlayerCooldown)