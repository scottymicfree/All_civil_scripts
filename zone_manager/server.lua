-- Add to server.lua
-- Enhanced Zone Manager with Gang Territory Integration

-- Zone ownership tracking
local zoneOwnership = {}
local zoneCaptureStatus = {}
local zoneConflicts = {}
local serverZones = {} -- Added missing serverZones table

-- Load zone ownership from database or file
function LoadZoneOwnership()
    -- Placeholder for database integration
    -- For now, we'll use a simple table
    zoneOwnership = {
        ["Downtown Turf"] = "The Families",
        ["East Side"] = "The Ballas",
        ["Beach Front"] = "none"
    }
    
    -- Sync to all clients
    TriggerClientEvent("zone_manager:syncOwnership", -1, zoneOwnership)
end

-- Save zone ownership
function SaveZoneOwnership()
    -- Placeholder for database integration
    print("^2[ZONE_MANAGER]^0 Zone ownership saved.")
end -- Added missing end

-- Register a zone with ownership
function RegisterServerZoneWithOwnership(name, coords, radius, priority, zoneType, data, owner)
    if not serverZones[name] then
        serverZones[name] = {
            coords = coords,
            radius = radius,
            priority = priority or 0,
            type = zoneType or "generic",
            data = data or {}
        }
        
        -- Set ownership if provided
        if owner then
            zoneOwnership[name] = owner
        end
        
        -- Sync to all clients
        TriggerClientEvent("zone_manager:syncZone", -1, name, coords, radius, priority, zoneType, data)
        TriggerClientEvent("zone_manager:syncZoneOwnership", -1, name, zoneOwnership[name] or "none")
        
        return true
    else
        print("Warning: Server zone '" .. name .. "' already exists.")
        return false
    end
end -- Added missing end

-- Update zone ownership
function UpdateZoneOwnership(zoneName, newOwner)
    if serverZones[zoneName] then
        local oldOwner = zoneOwnership[zoneName] or "none"
        zoneOwnership[zoneName] = newOwner
        
        -- Sync to all clients
        TriggerClientEvent("zone_manager:syncZoneOwnership", -1, zoneName, newOwner)
        
        -- Log ownership change
        print("^3[ZONE_MANAGER]^0 Zone '" .. zoneName .. "' ownership changed from '" .. oldOwner .. "' to '" .. newOwner .. "'")
        
        -- Trigger event for other resources
        TriggerEvent("zone_manager:ownershipChanged", zoneName, oldOwner, newOwner)
        
        return true
    else
        print("Warning: Server zone '" .. zoneName .. "' doesn't exist.")
        return false
    end
end -- Added missing end

-- Start zone capture process
function StartZoneCapture(zoneName, gangName, playerId)
    if not serverZones[zoneName] then
        return false, "Zone doesn't exist"
    end
    
    -- Check if zone is already being captured
    if zoneCaptureStatus[zoneName] then
        return false, "Zone is already being captured"
    end
    
    -- Start capture process
    zoneCaptureStatus[zoneName] = {
        gang = gangName,
        startTime = os.time(),
        players = {playerId},
        progress = 0
    }
    
    -- Notify all clients
    TriggerClientEvent("zone_manager:captureStarted", -1, zoneName, gangName)
    
    -- Log capture start
    print("^3[ZONE_MANAGER]^0 Zone '" .. zoneName .. "' capture started by gang '" .. gangName .. "'")
    
    return true, "Capture started"
end -- Added missing end

-- Update zone capture progress
function UpdateZoneCapture(zoneName, progress)
    if zoneCaptureStatus[zoneName] then
        zoneCaptureStatus[zoneName].progress = progress
        
        -- Sync to all clients
        TriggerClientEvent("zone_manager:captureProgress", -1, zoneName, progress)
        
        -- Check if capture is complete
        if progress >= 100 then
            CompleteZoneCapture(zoneName)
        end
        
        return true
    else
        return false
    end
end

-- Complete zone capture
function CompleteZoneCapture(zoneName)
    if zoneCaptureStatus[zoneName] then
        local capturingGang = zoneCaptureStatus[zoneName].gang
        
        -- Update ownership
        UpdateZoneOwnership(zoneName, capturingGang)
        
        -- Clear capture status
        zoneCaptureStatus[zoneName] = nil
        
        -- Notify all clients
        TriggerClientEvent("zone_manager:captureComplete", -1, zoneName, capturingGang)
        
        -- Log capture completion
        print("^2[ZONE_MANAGER]^0 Zone '" .. zoneName .. "' captured by gang '" .. capturingGang .. "'")
        
        -- Save changes
        SaveZoneOwnership()
        
        return true
    else
        return false
    end
end

-- Cancel zone capture
function CancelZoneCapture(zoneName, reason)
    if zoneCaptureStatus[zoneName] then
        local capturingGang = zoneCaptureStatus[zoneName].gang
        
        -- Clear capture status
        zoneCaptureStatus[zoneName] = nil
        
        -- Notify all clients
        TriggerClientEvent("zone_manager:captureCancelled", -1, zoneName, reason)
        
        -- Log capture cancellation
        print("^1[ZONE_MANAGER]^0 Zone '" .. zoneName .. "' capture by gang '" .. capturingGang .. "' cancelled: " .. reason)
        
        return true
    else
        return false
    end
end

-- Check if player is in a gang
function IsPlayerInGang(playerId, gangName)
    -- Placeholder for gang system integration
    -- This should be replaced with your actual gang system check
    return true
end

-- Register server events
RegisterNetEvent("zone_manager:requestCapture")
AddEventHandler("zone_manager:requestCapture", function(zoneName)
    local src = source
    local gangName = "Unknown Gang" -- Replace with your gang system
    
    -- Check if player is in a gang
    if not IsPlayerInGang(src, gangName) then
        TriggerClientEvent("zone_manager:captureResponse", src, false, "You are not in a gang")
        return
    end
    
    -- Start capture
    local success, message = StartZoneCapture(zoneName, gangName, src)
    TriggerClientEvent("zone_manager:captureResponse", src, success, message)
end)

-- Initialize
Citizen.CreateThread(function()
    -- Load zone ownership
    LoadZoneOwnership()
    
    -- Set up periodic saving
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(300000) -- Save every 5 minutes
            SaveZoneOwnership()
        end
    end)
    
    print("^2[ZONE_MANAGER]^0 Enhanced Zone Manager initialized")
end)

-- Export functions
exports('RegisterServerZoneWithOwnership', RegisterServerZoneWithOwnership)
exports('UpdateZoneOwnership', UpdateZoneOwnership)
exports('StartZoneCapture', StartZoneCapture)
exports('UpdateZoneCapture', UpdateZoneCapture)
exports('CompleteZoneCapture', CompleteZoneCapture)
exports('CancelZoneCapture', CancelZoneCapture)
