local playerJob = "unemployed"
local playerGang = nil
local playerMoney = 0
local playerBank = 0
local playerXP = 0
local playerLevel = 1
local playerRank = 1

-- Register events to receive data from server
RegisterNetEvent('standalone-framework:setPlayerData')
AddEventHandler('standalone-framework:setPlayerData', function(data)
    if data.job then playerJob = data.job end
    if data.gang then playerGang = data.gang end
    if data.money then playerMoney = data.money end
    if data.bank then playerBank = data.bank end
    if data.xp then playerXP = data.xp end
    if data.level then playerLevel = data.level end
    if data.rank then playerRank = data.rank end
end)

RegisterNetEvent('standalone-framework:updatePlayerData')
AddEventHandler('standalone-framework:updatePlayerData', function(key, value)
    if key == "job" then playerJob = value end
    if key == "gang" then playerGang = value end
    if key == "money" then playerMoney = value end
    if key == "bank" then playerBank = value end
    if key == "xp" then playerXP = value end
    if key == "level" then playerLevel = value end
    if key == "rank" then playerRank = value end
end)

RegisterNetEvent('standalone-framework:setJob')
AddEventHandler('standalone-framework:setJob', function(job)
    playerJob = job
end)

RegisterNetEvent('standalone-framework:setGang')
AddEventHandler('standalone-framework:setGang', function(gang)
    playerGang = gang
end)

-- Notification function
function ShowNotification(message, type)
    if type == nil then type = "inform" end
    
    -- Check if mythic_notify is available
    if exports['mythic_notify'] then
        exports['mythic_notify']:DoHudText(type, message)
    else
        -- Fallback to native notification
        SetNotificationTextEntry('STRING')
        AddTextComponentString(message)
        DrawNotification(false, false)
    end
end

-- Register notification event
RegisterNetEvent('standalone-framework:notify')
AddEventHandler('standalone-framework:notify', function(message, type)
    ShowNotification(message, type)
end)

-- Request player data when resource starts
Citizen.CreateThread(function()
    Citizen.Wait(1000) -- Wait for everything to initialize
    TriggerServerEvent('standalone-framework:requestPlayerData')
end)

-- Export functions
function GetPlayerJob()
    return playerJob
end

function GetPlayerGang()
    return playerGang
end

function GetPlayerMoney()
    return playerMoney
end

function GetPlayerBank()
    return playerBank
end

function GetPlayerXP()
    return playerXP
end

function GetPlayerLevel()
    return playerLevel
end

function GetPlayerRank()
    return playerRank
end

function AddMoney(amount)
    TriggerServerEvent('standalone-framework:addMoney', amount)
end

function RemoveMoney(amount)
    TriggerServerEvent('standalone-framework:removeMoney', amount)
end

-- Register exports
exports('GetPlayerJob', GetPlayerJob)
exports('GetPlayerGang', GetPlayerGang)
exports('GetPlayerMoney', GetPlayerMoney)
exports('GetPlayerBank', GetPlayerBank)
exports('GetPlayerXP', GetPlayerXP)
exports('GetPlayerLevel', GetPlayerLevel)
exports('GetPlayerRank', GetPlayerRank)
exports('AddMoney', AddMoney)
exports('RemoveMoney', RemoveMoney)
exports('ShowNotification', ShowNotification)
