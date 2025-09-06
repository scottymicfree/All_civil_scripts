-- Server-side Dispatch System
-- Handles emergency calls and notifications

-- Track active emergencies
local activeEmergencies = {}
local robberyInProgress = {}

-- Log action with timestamp
local function logAction(source, action, details)
    if Config.EnableLogging then
        local timestamp = os.date("%Y-%m-%d %H:%M:%S")
        local playerName = GetPlayerName(source) or "Unknown"
        local identifier = GetPlayerIdentifier(source, 0) or "Unknown"
        
        print(string.format("[%s] %s (%s) %s: %s", 
            timestamp, playerName, identifier, action, details or ""))
    end
end

-- Handle robbery events
RegisterNetEvent("cfw:robberyStarted")
AddEventHandler("cfw:robberyStarted", function(nwId)
    local src = source
    
    -- Validate network ID
    if not nwId or type(nwId) ~= "number" then
        logAction(src, "EXPLOIT", "Invalid network ID in robberyStarted event")
        return
    end
    
    -- Check if robbery is already in progress
    if not robberyInProgress[nwId] then
        -- Get store location
        local entity = NetworkGetEntityFromNetworkId(nwId)
        local coords = nil
        
        if DoesEntityExist(entity) then
            coords = GetEntityCoords(entity)
        end
        
        -- Start robbery
        robberyInProgress[nwId] = {
            startTime = os.time(),
            player = src,
            coords = coords
        }
        
        -- Notify police
        TriggerClientEvent('cfw:notifyDispatch', -1, "Robbery in progress at store!")
        
        -- Set timeout to clear robbery status
        Citizen.SetTimeout(Config.Cooldowns.robbery, function()
            robberyInProgress[nwId] = nil
            TriggerClientEvent('cfw:notifyDispatch', -1, "Robbery ended.")
        end)
        
        -- Log action
        logAction(src, "ROBBERY", "Started robbery at store")
    else
        -- Robbery already in progress
        TriggerClientEvent('mythic_notify:client:SendAlert', src, { 
            type = 'error', 
            text = 'Robbery already in progress here.' 
        })
    end
end)

-- Handle EMS heal requests
RegisterNetEvent("cfw:requestEMSHeal")
AddEventHandler("cfw:requestEMSHeal", function()
    local src = source
    local playerName = GetPlayerName(src)
    local playerCoords = GetEntityCoords(GetPlayerPed(src))
    
    -- Notify all EMS personnel
    TriggerClientEvent('cfw:notifyEMS', -1, "Player " .. playerName .. " needs healing.")
    
    -- Heal the player (in a real system, this would be handled by an EMS player)
    TriggerClientEvent('cfw:healPlayer', src)
    
    -- Log action
    logAction(src, "EMS", "Requested healing")
end)

-- Handle vehicle weapon storage access
RegisterNetEvent("cfw:requestVehicleWeapons")
AddEventHandler("cfw:requestVehicleWeapons", function(nwId)
    local src = source
    
    -- Validate network ID
    if not nwId or type(nwId) ~= "number" then
        logAction(src, "EXPLOIT", "Invalid network ID in requestVehicleWeapons event")
        return
    end
    
    -- Get player job
    local playerJob = exports['standalone-framework']:GetPlayerJob(src)
    
    -- Define available weapons based on job
    local weapons = {}
    
    if playerJob == "police" then
        weapons = {
            {name = "WEAPON_PISTOL", ammo = 50},
            {name = "WEAPON_STUNGUN", ammo = 1},
            {name = "WEAPON_NIGHTSTICK", ammo = 1},
            {name = "WEAPON_FLASHLIGHT", ammo = 1}
        }
        
        -- Add rifle for higher ranks
        local playerRank = exports['standalone-framework']:GetPlayerRank(src)
        if playerRank >= 3 then
            table.insert(weapons, {name = "WEAPON_CARBINERIFLE", ammo = 120})
        end
    elseif playerJob == "ems" then
        weapons = {
            {name = "WEAPON_FLASHLIGHT", ammo = 1},
            {name = "WEAPON_FIREEXTINGUISHER", ammo = 1000}
        }
    elseif playerJob == "gang_member" then
        weapons = {
            {name = "WEAPON_PISTOL", ammo = 30},
            {name = "WEAPON_KNIFE", ammo = 1}
        }
    else
        -- Default weapons for civilians
        weapons = {
            {name = "WEAPON_FLASHLIGHT", ammo = 1}
        }
    end
    
    -- Send weapons to client
    TriggerClientEvent("cfw:openWeaponStorageMenu", src, weapons)
    
    -- Log action
    logAction(src, "WEAPONS", "Accessed vehicle weapon storage")
end)

-- Handle backup requests
RegisterNetEvent("cfw:sendBackupRequest")
AddEventHandler("cfw:sendBackupRequest", function(coords, reason)
    local src = source
    local playerName = GetPlayerName(src)
    local playerJob = exports['standalone-framework']:GetPlayerJob(src)
    
    -- Validate request
    if not coords or type(coords) ~= "vector3" then
        logAction(src, "EXPLOIT", "Invalid coordinates in backup request")
        return
    end
    
    -- Create emergency ID
    local emergencyId = "backup_" .. src .. "_" .. os.time()
    
    -- Store emergency details
    activeEmergencies[emergencyId] = {
        type = "backup",
        source = src,
        coords = coords,
        reason = reason,
        time = os.time(),
        job = playerJob
    }
    
    -- Notify appropriate personnel
    if playerJob == "police" then
        -- Notify all police
        TriggerClientEvent('cfw:notifyDispatch', -1, "Officer " .. playerName .. " requesting backup: " .. reason)
    else
        -- Notify all emergency services
        TriggerClientEvent('cfw:notifyDispatch', -1, "Civilian " .. playerName .. " requesting help: " .. reason)
    end
    
    -- Log action
    logAction(src, "BACKUP", "Requested backup: " .. reason)
    
    -- Set timeout to clear emergency after 5 minutes
    Citizen.SetTimeout(300000, function()
        activeEmergencies[emergencyId] = nil
    end)
end)

-- Handle EMS requests
RegisterNetEvent("cfw:requestEMS")
AddEventHandler("cfw:requestEMS", function(reason)
    local src = source
    local playerName = GetPlayerName(src)
    local playerCoords = GetEntityCoords(GetPlayerPed(src))
    
    -- Create emergency ID
    local emergencyId = "ems_" .. src .. "_" .. os.time()
    
    -- Store emergency details
    activeEmergencies[emergencyId] = {
        type = "ems",
        source = src,
        coords = playerCoords,
        reason = reason,
        time = os.time()
    }
    
    -- Notify EMS
    TriggerClientEvent('cfw:notifyEMS', -1, playerName .. " needs medical assistance: " .. reason)
    
    -- Log action
    logAction(src, "EMS", "Requested medical assistance: " .. reason)
    
    -- Set timeout to clear emergency after 5 minutes
    Citizen.SetTimeout(300000, function()
        activeEmergencies[emergencyId] = nil
    end)
end)

-- Get active emergencies
function getActiveEmergencies()
    return activeEmergencies
end

-- Export functions
exports('getActiveEmergencies', getActiveEmergencies)
exports('logAction', logAction)
