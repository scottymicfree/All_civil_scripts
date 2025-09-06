local PlayerData = {}

-- Initialize player data
function InitPlayerData(source)
    local playerServerId = tostring(source)
    
    if not PlayerData[playerServerId] then
        PlayerData[playerServerId] = {
            job = 'unemployed',
            gang = nil,
            money = Config.StartingMoney,
            bank = Config.StartingBank,
            xp = 0,
            level = 1,
            rank = 1  -- Added default rank
        }
    end
    
    -- Send data to client
    TriggerClientEvent('standalone-framework:setPlayerData', source, PlayerData[playerServerId])
end

-- Get player job
function GetPlayerJob(source)
    local playerServerId = tostring(source)
    if PlayerData[playerServerId] then
        return PlayerData[playerServerId].job
    end
    return 'unemployed'
end

-- Set player job
function SetPlayerJob(source, job)
    local playerServerId = tostring(source)
    
    -- Check if job exists in config
    if not Config.Jobs[job] then
        print("Attempted to set invalid job: " .. job)
        return false
    end
    
    if PlayerData[playerServerId] then
        PlayerData[playerServerId].job = job
        
        -- Update client
        TriggerClientEvent('standalone-framework:updatePlayerData', source, "job", job)
        TriggerClientEvent('standalone-framework:setJob', source, job)
        
        return true
    end
    return false
end

-- Get player gang
function GetPlayerGang(source)
    local playerServerId = tostring(source)
    if PlayerData[playerServerId] then
        return PlayerData[playerServerId].gang
    end
    return nil
end

-- Set player gang
function SetPlayerGang(source, gang)
    local playerServerId = tostring(source)
    
    -- Check if gang exists in config or is nil (no gang)
    if gang ~= nil and not Config.Gangs[gang] then
        print("Attempted to set invalid gang: " .. gang)
        return false
    end
    
    if PlayerData[playerServerId] then
        PlayerData[playerServerId].gang = gang
        
        -- Update client
        TriggerClientEvent('standalone-framework:updatePlayerData', source, "gang", gang)
        TriggerClientEvent('standalone-framework:setGang', source, gang)
        
        return true
    end
    return false
end

-- Add money to player
function AddMoney(source, amount)
    local playerServerId = tostring(source)
    if PlayerData[playerServerId] then
        PlayerData[playerServerId].money = PlayerData[playerServerId].money + amount
        TriggerClientEvent('standalone-framework:updatePlayerData', source, "money", PlayerData[playerServerId].money)
        return true
    end
    return false
end

-- Remove money from player
function RemoveMoney(source, amount)
    local playerServerId = tostring(source)
    if PlayerData[playerServerId] and PlayerData[playerServerId].money >= amount then
        PlayerData[playerServerId].money = PlayerData[playerServerId].money - amount
        TriggerClientEvent('standalone-framework:updatePlayerData', source, "money", PlayerData[playerServerId].money)
        return true
    end
    return false
end

-- Add XP to player
function AddXP(source, amount)
    local playerServerId = tostring(source)
    if PlayerData[playerServerId] then
        PlayerData[playerServerId].xp = PlayerData[playerServerId].xp + amount
        
        -- Level up logic (simple example)
        local newLevel = math.floor(PlayerData[playerServerId].xp / 1000) + 1
        if newLevel > PlayerData[playerServerId].level then
            PlayerData[playerServerId].level = newLevel
            TriggerClientEvent('standalone-framework:updatePlayerData', source, "level", newLevel)
            TriggerClientEvent('standalone-framework:notify', source, "Level Up! You are now level " .. newLevel)
        end
        
        TriggerClientEvent('standalone-framework:updatePlayerData', source, "xp", PlayerData[playerServerId].xp)
        return true
    end
    return false
end

-- Get player value (generic getter for any player data field)
function GetPlayerValue(source, key)
    local playerServerId = tostring(source)
    if PlayerData[playerServerId] and PlayerData[playerServerId][key] ~= nil then
        return PlayerData[playerServerId][key]
    end
    return nil
end

-- Get player rank (for job hierarchy)
function GetPlayerRank(source)
    local playerServerId = tostring(source)
    if PlayerData[playerServerId] and PlayerData[playerServerId].rank then
        return PlayerData[playerServerId].rank
    end
    return 1 -- Default rank
end

-- Set player rank
function SetPlayerRank(source, rank)
    local playerServerId = tostring(source)
    if PlayerData[playerServerId] then
        PlayerData[playerServerId].rank = rank
        TriggerClientEvent('standalone-framework:updatePlayerData', source, "rank", rank)
        return true
    end
    return false
end

-- Check if player is admin
function IsPlayerAdmin(source)
    -- First check if they're in the staff list
    local isStaff, staffData = IsPlayerStaff(source)
    if isStaff and staffData.level >= 50 then
        return true
    end
    
    -- Fallback to ace permissions if available
    if IsPlayerAceAllowed then -- Check if function exists (might not in older FiveM versions)
        return IsPlayerAceAllowed(source, "command.admin")
    end
    
    return false
end

-- Request player data
RegisterNetEvent('standalone-framework:requestPlayerData')
AddEventHandler('standalone-framework:requestPlayerData', function()
    local src = source
    InitPlayerData(src)
end)

-- Handle money events
RegisterNetEvent('standalone-framework:addMoney')
AddEventHandler('standalone-framework:addMoney', function(amount)
    local src = source
    AddMoney(src, amount)
end)

RegisterNetEvent('standalone-framework:removeMoney')
AddEventHandler('standalone-framework:removeMoney', function(amount)
    local src = source
    RemoveMoney(src, amount)
end)

-- Handle job and gang events
RegisterNetEvent('standalone-framework:setJob')
AddEventHandler('standalone-framework:setJob', function(job)
    local src = source
    -- Check if player has permission (admin or staff)
    if IsPlayerAdmin(src) then
        SetPlayerJob(src, job)
    else
        print("Player " .. GetPlayerName(src) .. " tried to set their job without permission")
    end
end)

RegisterNetEvent('standalone-framework:setGang')
AddEventHandler('standalone-framework:setGang', function(gang)
    local src = source
    -- Check if player has permission (admin or staff)
    if IsPlayerAdmin(src) then
        SetPlayerGang(src, gang)
    else
        print("Player " .. GetPlayerName(src) .. " tried to set their gang without permission")
    end
end)

-- Player connecting
AddEventHandler('playerJoining', function(source, oldID)
    InitPlayerData(source)
end)

-- Player dropped
AddEventHandler('playerDropped', function(reason)
    local src = source
    local playerServerId = tostring(src)
    
    -- Clean up player data (or save it if you implement persistence)
    -- PlayerData[playerServerId] = nil
end)

-- Salary payment system
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(Config.SalaryInterval * 60 * 1000) -- Convert minutes to milliseconds
        
        -- Loop through all players and pay salaries
        for playerId, data in pairs(PlayerData) do
            local job = data.job
            if Config.Jobs[job] and Config.Jobs[job].salary > 0 then
                local salary = Config.Jobs[job].salary
                local source = tonumber(playerId)
                
                if GetPlayerName(source) then -- Make sure player is still connected
                    -- Add money to player's bank account
                    PlayerData[playerId].bank = PlayerData[playerId].bank + salary
                    
                    -- Notify player
                    TriggerClientEvent('standalone-framework:updatePlayerData', source, "bank", PlayerData[playerId].bank)
                    TriggerClientEvent('standalone-framework:notify', source, "Salary payment: $" .. salary .. " added to your bank account")
                end
            end
        end
    end
end)

-- Register exports
exports('GetPlayerJob', GetPlayerJob)
exports('SetPlayerJob', SetPlayerJob)
exports('GetPlayerGang', GetPlayerGang)
exports('SetPlayerGang', SetPlayerGang)
exports('AddMoney', AddMoney)
exports('RemoveMoney', RemoveMoney)
exports('AddXP', AddXP)
exports('GetPlayerValue', GetPlayerValue)
exports('GetPlayerRank', GetPlayerRank)
exports('SetPlayerRank', SetPlayerRank)
exports('IsPlayerAdmin', IsPlayerAdmin)
