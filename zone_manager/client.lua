-- Add to client.lua
-- Enhanced Interior Zone Manager with Civil Unrest Integration

-- Zone types specific to Civil Unrest
local ZONE_TYPES = {
    SAFEZONE = "safezone",
    GANGZONE = "gangzone",
    INTERIOR = "interior",
    COMBAT = "combat",
    RESTRICTED = "restricted",
    DEALERSHIP = "dealership",
    SHOP = "shop",
    JOB = "job",
    EVENT = "event"
}

-- Zone effects
local zoneEffects = {
    [ZONE_TYPES.SAFEZONE] = {
        pvp = false,
        damage = 0.0,
        weapons = false,
        blip = {sprite = 305, color = 2} -- Green shield
    },
    [ZONE_TYPES.GANGZONE] = {
        pvp = true,
        damage = 1.0,
        weapons = true,
        blip = {sprite = 310, color = 1} -- Red skull
    },
    [ZONE_TYPES.COMBAT] = {
        pvp = true,
        damage = 1.5, -- 50% more damage
        weapons = true,
        blip = {sprite = 310, color = 1}
    },
    [ZONE_TYPES.RESTRICTED] = {
        pvp = false,
        damage = 0.0,
        weapons = false,
        blip = {sprite = 307, color = 1} -- Red restricted
    }
}

-- Active zone effects
local activeEffects = {}
local zoneBlips = {}

-- Enhanced zone registration with visual indicators
function RegisterInteriorZone(name, coords, radius, priority, zoneType, data)
    if not activeZones[name] then
        activeZones[name] = {
            coords = coords,
            radius = radius,
            priority = priority or 0,
            type = zoneType or "generic",
            data = data or {}
        }
        
        -- Create zone blip if specified
        if data and data.showBlip then
            local blipData = zoneEffects[zoneType] and zoneEffects[zoneType].blip or {sprite = 1, color = 0}
            
            -- Create area blip
            local blip = AddBlipForRadius(coords.x, coords.y, coords.z, radius)
            SetBlipRotation(blip, 0)
            SetBlipColour(blip, blipData.color)
            SetBlipAlpha(blip, 128)
            
            -- Create center blip
            local centerBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
            SetBlipSprite(centerBlip, blipData.sprite)
            SetBlipColour(centerBlip, blipData.color)
            SetBlipScale(centerBlip, 0.8)
            SetBlipAsShortRange(centerBlip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(data.name or name)
            EndTextCommandSetBlipName(centerBlip)
            
            -- Store blips for cleanup
            zoneBlips[name] = {area = blip, center = centerBlip}
        }
        
        if debugMode then
            print("Registered zone: " .. name .. " (Type: " .. zoneType .. ", Priority: " .. priority .. ")")
        end
        
        -- Sync with server
        TriggerServerEvent("zone_manager:registerZone", name, coords, radius, priority, zoneType, data)
        
        return true
    else
        print("Warning: Zone '" .. name .. "' already exists. Use UpdateInteriorZone to modify.")
        return false
    end
end

-- Enhanced zone removal with cleanup
function RemoveInteriorZone(name)
    if activeZones[name] then
        -- Remove blips if they exist
        if zoneBlips[name] then
            if DoesBlipExist(zoneBlips[name].area) then
                RemoveBlip(zoneBlips[name].area)
            end
            
            if DoesBlipExist(zoneBlips[name].center) then
                RemoveBlip(zoneBlips[name].center)
            end
            
            zoneBlips[name] = nil
        end
        
        -- Remove zone
        activeZones[name] = nil
        
        -- Sync with server
        TriggerServerEvent("zone_manager:removeZone", name)
        
        if debugMode then
            print("Removed zone: " .. name)
        end
        
        return true
    else
        return false
    end
}

-- Apply zone effects based on zone type
function ApplyZoneEffects(zoneName, zoneType, zoneData)
    -- Clear any existing effects
    ClearZoneEffects()
    
    -- Get effects for this zone type
    local effects = zoneEffects[zoneType]
    if not effects then return end
    
    -- Store active effects
    activeEffects = {
        zoneName = zoneName,
        zoneType = zoneType,
        effects = effects
    }
    
    -- Apply effects
    if effects.pvp == false then
        -- Disable PVP
        NetworkSetFriendlyFireOption(false)
        SetCanAttackFriendly(PlayerPedId(), false, false)
    end
    
    -- Notify player
    if zoneType == ZONE_TYPES.SAFEZONE then
        ShowNotification("~g~Entered Safe Zone~w~\nPVP is disabled here")
    elseif zoneType == ZONE_TYPES.GANGZONE then
        local gangName = zoneData.gang or "Unknown"
        ShowNotification("~r~Entered Gang Territory~w~\nControlled by: " .. gangName)
    elseif zoneType == ZONE_TYPES.COMBAT then
        ShowNotification("~r~Entered Combat Zone~w~\nIncreased damage in this area")
    elseif zoneType == ZONE_TYPES.RESTRICTED then
        ShowNotification("~r~Entered Restricted Zone~w~\nWeapons are disabled here")
    end
    
    -- Trigger event for other resources
    TriggerEvent("civil_unrest_core:zoneEffectsApplied", zoneName, zoneType, effects)
}

-- Clear zone effects
function ClearZoneEffects()
    if not activeEffects.zoneName then return end
    
    -- Reset PVP
    NetworkSetFriendlyFireOption(true)
    SetCanAttackFriendly(PlayerPedId(), true, true)
    
    -- Reset damage multipliers
    SetPlayerWeaponDamageModifier(PlayerId(), 1.0)
    SetPlayerMeleeWeaponDamageModifier(PlayerId(), 1.0)
    
    -- Clear active effects
    activeEffects = {}
}

-- Enhanced zone monitoring thread
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500) -- Check every 500ms to save resources
        
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local zoneName, zoneData = GetActiveZoneAtPosition(playerCoords)
        
        -- Zone changed
        if zoneName ~= currentZone then
            -- Exit previous zone
            if currentZone and activeZones[currentZone] then
                TriggerEvent("zone:exit", currentZone, activeZones[currentZone].type, activeZones[currentZone].data)
                
                -- Specific zone type events
                if activeZones[currentZone].type == ZONE_TYPES.SAFEZONE then
                    TriggerEvent("safezone:exit", currentZone, activeZones[currentZone].data)
                elseif activeZones[currentZone].type == ZONE_TYPES.GANGZONE then
                    TriggerEvent("gangzone:exit", currentZone, activeZones[currentZone].data)
                elseif activeZones[currentZone].type == ZONE_TYPES.INTERIOR then
                    TriggerEvent("interior:exit", currentZone, activeZones[currentZone].data)
                end
                
                -- Clear zone effects
                ClearZoneEffects()
                
                playerInZone = false
            end
            
            -- Enter new zone
            if zoneName then
                TriggerEvent("zone:enter", zoneName, zoneData.type, zoneData.data)
                
                -- Specific zone type events
                if zoneData.type == ZONE_TYPES.SAFEZONE then
                    TriggerEvent("safezone:enter", zoneName, zoneData.data)
                elseif zoneData.type == ZONE_TYPES.GANGZONE then
                    TriggerEvent("gangzone:enter", zoneName, zoneData.data)
                elseif zoneData.type == ZONE_TYPES.INTERIOR then
                    TriggerEvent("interior:enter", zoneName, zoneData.data)
                end
                
                -- Apply zone effects
                ApplyZoneEffects(zoneName, zoneData.type, zoneData.data)
                
                playerInZone = true
            end
            
            currentZone = zoneName
        end
        
        -- Apply continuous effects while in zone
        if playerInZone and activeEffects.effects then
            -- Apply damage modifiers
            if activeEffects.effects.damage ~= 1.0 then
                SetPlayerWeaponDamageModifier(PlayerId(), activeEffects.effects.damage)
                SetPlayerMeleeWeaponDamageModifier(PlayerId(), activeEffects.effects.damage)
            end
            
            -- Disable weapons if needed
            if activeEffects.effects.weapons == false then
                local _, currentWeapon = GetCurrentPedWeapon(playerPed, true)
                if currentWeapon ~= GetHashKey("WEAPON_UNARMED") then
                    SetCurrentPedWeapon(playerPed, GetHashKey("WEAPON_UNARMED"), true)
                end
            end
        end
    end
end)

-- Enhanced debug visualization
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        if debugMode then
            -- Draw all zones
            for name, zone in pairs(activeZones) do
                -- Draw zone circle
                DrawMarker(1, zone.coords.x, zone.coords.y, zone.coords.z - 1.0, 0, 0, 0, 0, 0, 0, 
                    zone.radius * 2.0, zone.radius * 2.0, 0.5, 
                    255, 255, 255, 50, false, false, 2, nil, nil, false)
                
                -- Draw zone name
                local onScreen, screenX, screenY = World3dToScreen2d(zone.coords.x, zone.coords.y, zone.coords.z)
                if onScreen then
                    SetTextScale(0.35, 0.35)
                    SetTextFont(4)
                    SetTextProportional(1)
                    SetTextColour(255, 255, 255, 200)
                    SetTextEntry("STRING")
                    SetTextCentre(1)
                    AddTextComponentString(name .. "\nType: " .. zone.type .. "\nPriority: " .. zone.priority)
                    DrawText(screenX, screenY)
                end
            }
            
            -- Draw current zone info
            if currentZone then
                local zone = activeZones[currentZone]
                SetTextScale(0.5, 0.5)
                SetTextFont(4)
                SetTextProportional(1)
                SetTextColour(255, 255, 255, 255)
                SetTextEntry("STRING")
                SetTextCentre(1)
                AddTextComponentString("Current Zone: " .. currentZone .. "\nType: " .. zone.type)
                DrawText(0.5, 0.05)
            end
        end
    end
end)
