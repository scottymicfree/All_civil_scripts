-- Add to client.lua
-- Enhanced XP System with Gang Integration

-- Additional XP multipliers based on player status
local xpMultipliers = {
    gang = 1.2,      -- 20% bonus for gang members
    police = 1.1,    -- 10% bonus for police
    ems = 1.1,       -- 10% bonus for EMS
    vip = 1.5        -- 50% bonus for VIP players
}

-- Track XP sources for analytics
local xpSources = {}

-- Initialization flag for XP system
isInitialized = false

-- XP bar display time in milliseconds
     xpBarDisplayTime = 4000 -- 4 seconds

-- Enhanced AddXP function with multipliers and tracking
function AddXP(amount, reason)
    if not isInitialized then return end
    
-- Apply multipliers based on player status
    local finalAmount = amount
    local appliedMultipliers = {}
    
-- Check if player is in a gang
    local playerGang = exports['gang_system']:GetPlayerGang()
    if playerGang and playerGang ~= "none" and xpMultipliers.gang then
        finalAmount = finalAmount * xpMultipliers.gang
        table.insert(appliedMultipliers, "Gang Member (" .. xpMultipliers.gang .. "x)")
    end
    
-- Check if player is police
    local playerJob = exports['standalone-framework']:GetPlayerJob()
    if playerJob == "police" and xpMultipliers.police then
        finalAmount = finalAmount * xpMultipliers.police
        table.insert(appliedMultipliers, "Police (" .. xpMultipliers.police .. "x)")
    elseif playerJob == "ems" and xpMultipliers.ems then
        finalAmount = finalAmount * xpMultipliers.ems
        table.insert(appliedMultipliers, "EMS (" .. xpMultipliers.ems .. "x)")
    end
    
-- Check if player is VIP
    local isVIP = exports['standalone-framework']:IsPlayerVIP()
    if isVIP and xpMultipliers.vip then
        finalAmount = finalAmount * xpMultipliers.vip
        table.insert(appliedMultipliers, "VIP (" .. xpMultipliers.vip .. "x)")
    end
    
 -- Round the final amount
    finalAmount = math.floor(finalAmount)
    
 -- Track XP source
    if not xpSources[reason] then
        xpSources[reason] = 0
    end
    xpSources[reason] = xpSources[reason] + finalAmount
    
-- Original XP logic
    local oldXP = playerXP
    local oldLevel = playerLevel
    
-- Add XP
    playerXP = playerXP + finalAmount
    
    -- Calculate new level
    local newLevel, remainingXP, xpForNextLevel = CalculateLevel(playerXP)
    playerXP = remainingXP
    
    -- Check for level up
    if newLevel > oldLevel then
        -- Level up!
        playerLevel = newLevel
        TriggerEvent('xp_system:levelUp', oldLevel, newLevel)
        ShowNotification("~g~Level Up!~w~ You are now level " .. newLevel)
        
        -- Play level up sound
        PlaySoundFrontend(-1, "RANK_UP", "HUD_AWARDS", true)
        
        -- Trigger server event for level up
        TriggerServerEvent('xp_system:levelUp', oldLevel, newLevel)
        
            -- Grant level up rewards
            GrantLevelUpRewards(newLevel)
        end
    
    -- Define GrantLevelUpRewards to avoid undefined global error
    function GrantLevelUpRewards(level)
        -- Example: Give cash or items based on level
        -- You can customize this logic as needed
        if level == 5 then
            ShowNotification("~y~Reward:~w~ You received $500 for reaching level 5!")
            TriggerServerEvent('xp_system:giveReward', 'cash', 500)
        elseif level == 10 then
            ShowNotification("~y~Reward:~w~ You received a special item for reaching level 10!")
            TriggerServerEvent('xp_system:giveReward', 'item', 'special_item')
        end
    end
        
        -- Show XP bar with multiplier info
        local multiplierText = ""
    if #appliedMultipliers > 0 then
        multiplierText = " | Bonuses: " .. table.concat(appliedMultipliers, ", ")
    end
    
    ShowXPBar(remainingXP, xpForNextLevel, finalAmount, reason .. multiplierText)
    
    -- Trigger server event to save XP
    TriggerServerEvent('xp_system:updateXP', playerXP, playerLevel)
    
    -- Trigger event for other resources
    TriggerEvent('civil_unrest_core:xpGained', finalAmount, reason, appliedMultipliers)
    
    return newLevel, remainingXP, xpForNextLevel
end

-- Enhanced XP Bar with animations
function ShowXPBar(currentXP, requiredXP, xpGained, reason)
    xpBarVisible = true
    xpBarTimer = GetGameTimer() + xpBarDisplayTime
    
    -- Store XP data for rendering
    local xpData = {
        current = currentXP,
        required = requiredXP,
        gained = xpGained,
        reason = reason or "Action",
        progress = currentXP / requiredXP,
        level = playerLevel,
        animationStart = GetGameTimer(),
        animationDuration = 1000 -- 1 second animation
    }
    
    -- Store in a global for the rendering thread
    _G.xpBarData = xpData
    
    -- Play XP gain sound
    if xpGained > 0 then
        if xpGained > 500 then
            PlaySoundFrontend(-1, "CHALLENGE_UNLOCKED", "HUD_AWARDS", true)
        else
            PlaySoundFrontend(-1, "PICK_UP", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
        end
    end
end

-- Enhanced XP Bar rendering with animations
CreateThread(function()
    while true do
        Wait(0)
        
        if xpBarVisible and _G.xpBarData then
            if GetGameTimer() < xpBarTimer then
                -- Calculate animation progress
                local animProgress = 1.0
                local timeSinceStart = GetGameTimer() - _G.xpBarData.animationStart
                
                if timeSinceStart < _G.xpBarData.animationDuration then
                    animProgress = timeSinceStart / _G.xpBarData.animationDuration
                end
                
                -- Animated progress value
                local displayProgress = _G.xpBarData.progress * animProgress
                
                -- Draw XP bar background with better styling
                DrawRect(0.5, 0.1, 0.3, 0.05, 0, 0, 0, 180)
                
                -- Draw XP progress with animation
                DrawRect(0.5 - (0.3 / 2) + (displayProgress * 0.3 / 2), 0.1, displayProgress * 0.3, 0.05, 0, 150, 255, 200)
                
                -- Draw border
                DrawRect(0.5, 0.1 - 0.025, 0.3, 0.001, 255, 255, 255, 200) -- Top
                DrawRect(0.5, 0.1 + 0.025, 0.3, 0.001, 255, 255, 255, 200) -- Bottom
                DrawRect(0.5 - 0.15, 0.1, 0.001, 0.05, 255, 255, 255, 200) -- Left
                DrawRect(0.5 + 0.15, 0.1, 0.001, 0.05, 255, 255, 255, 200) -- Right
                
                -- Draw text with shadow
                SetTextFont(4)
                SetTextScale(0.5, 0.5)
                SetTextColour(255, 255, 255, 255)
                SetTextCentre(true)
                SetTextDropShadow()
                SetTextEntry("STRING")
                AddTextComponentString(string.format("Level %d - XP: %d/%d (+%d) - %s", 
                    _G.xpBarData.level, 
                    _G.xpBarData.current, 
                    _G.xpBarData.required,
                    _G.xpBarData.gained,
                    _G.xpBarData.reason))
                DrawText(0.5, 0.085)
            else
                xpBarVisible = false
            end
        end
    end
end)

-- Add XP statistics command
RegisterCommand('xpstats', function()
-- code...

-- Calculate total XP gained
    local totalXP = 0
    for source, amount in pairs(xpSources) do
        totalXP = totalXP + amount
    end
    
    -- Show notification with stats
    ShowNotification("XP Level: " .. playerLevel .. "\nTotal XP: " .. totalXP)
    
    -- Show detailed breakdown in chat
    TriggerEvent('chat:addMessage', {
        color = {0, 150, 255},
        multiline = true,
        args = {"XP System", "XP Sources Breakdown:"}
    })
    
    -- Sort sources by amount
    local sortedSources = {}
    for source, amount in pairs(xpSources) do
        table.insert(sortedSources, {source = source, amount = amount})
    end
    
    table.sort(sortedSources, function(a, b) return a.amount > b.amount end)
    
    -- Display top sources
    for i, data in ipairs(sortedSources) do
        if i <= 10 then -- Show top 10
            local percentage = math.floor((data.amount / totalXP) * 100)
            TriggerEvent('chat:addMessage', {
                color = {255, 255, 255},
                args = {"", data.source .. ": " .. data.amount .. " XP (" .. percentage .. "%)"}
            })
        end
    end
end,false)
