-- Interior Zone Conflict Resolver
-- This script manages interior zones and resolves conflicts between different interiors

local interiors = {}
local activeInterior = nil
local debugMode = false

-- Register a new interior
-- name: Unique identifier for the interior
-- coords: vector3 coordinates of interior center
-- radius: Radius of the interior zone
-- priority: Higher priority interiors override lower ones when overlapping
-- ipl: IPL to load for this interior (optional)
-- entitySets: Entity sets to enable for this interior (optional)
-- props: Props to show/hide for this interior (optional)
function RegisterInterior(name, coords, radius, priority, ipl, entitySets, props)
    if not interiors[name] then
        interiors[name] = {
            coords = coords,
            radius = radius,
            priority = priority or 0,
            ipl = ipl,
            entitySets = entitySets or {},
            props = props or {}
        }
        
        -- Load IPL if specified
        if ipl then
            RequestIpl(ipl)
        end
        
        if debugMode then
            print("Registered interior: " .. name)
        end
        
        return true
    else
        print("Warning: Interior '" .. name .. "' already exists.")
        return false
    end
end

-- Update an existing interior
function UpdateInterior(name, coords, radius, priority, ipl, entitySets, props)
    if interiors[name] then
        -- Unload previous IPL if changing
        if interiors[name].ipl and ipl and interiors[name].ipl ~= ipl then
            RemoveIpl(interiors[name].ipl)
        end
        
        interiors[name] = {
            coords = coords or interiors[name].coords,
            radius = radius or interiors[name].radius,
            priority = priority or interiors[name].priority,
            ipl = ipl or interiors[name].ipl,
            entitySets = entitySets or interiors[name].entitySets,
            props = props or interiors[name].props
        }
        
        -- Load new IPL if specified
        if ipl then
            RequestIpl(ipl)
        end
        
        if debugMode then
            print("Updated interior: " .. name)
        end
        
        return true
    else
        print("Warning: Interior '" .. name .. "' doesn't exist.")
        return false
    end
end

-- Remove an interior
function RemoveInterior(name)
    if interiors[name] then
        -- Unload IPL if specified
        if interiors[name].ipl then
            RemoveIpl(interiors[name].ipl)
        end
        
        interiors[name] = nil
        
        if debugMode then
            print("Removed interior: " .. name)
        end
        
        return true
    else
        return false
    end
end

-- Get the highest priority interior at a specific position
function GetActiveInteriorAtPosition(coords)
    local highestPriority = -1
    local activeInterior = nil
    
    for name, interior in pairs(interiors) do
        local distance = #(coords - interior.coords)
        if distance <= interior.radius and interior.priority > highestPriority then
            highestPriority = interior.priority
            activeInterior = name
        end
    end
    
    return activeInterior, interiors[activeInterior]
end

-- Apply interior settings (entity sets, props)
function ApplyInteriorSettings(interiorId, settings)
    if not interiorId or not settings then return end
    
    -- Enable entity sets
    if settings.entitySets then
        for _, entitySet in ipairs(settings.entitySets) do
            if not IsInteriorEntitySetActive(interiorId, entitySet) then
                ActivateInteriorEntitySet(interiorId, entitySet)
                if debugMode then
                    print("Activated entity set: " .. entitySet)
                end
            end
        end
    end
    
    -- Set props
    if settings.props then
        for prop, enabled in pairs(settings.props) do
            if enabled then
                if not IsInteriorPropEnabled(interiorId, prop) then
                    EnableInteriorProp(interiorId, prop)
                    if debugMode then
                        print("Enabled prop: " .. prop)
                    end
                end
            else
                if IsInteriorPropEnabled(interiorId, prop) then
                    DisableInteriorProp(interiorId, prop)
                    if debugMode then
                        print("Disabled prop: " .. prop)
                    end
                end
            end
        end
    end
    
    -- Refresh interior
    RefreshInterior(interiorId)
end

-- Main thread to check player position
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000) -- Check every second
        
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local interiorName, interiorData = GetActiveInteriorAtPosition(playerCoords)
        
        -- Interior changed
        if interiorName ~= activeInterior then
            -- Exit previous interior
            if activeInterior and interiors[activeInterior] then
                TriggerEvent("interior:exit", activeInterior, interiors[activeInterior])
            end
            
            -- Enter new interior
            if interiorName then
                TriggerEvent("interior:enter", interiorName, interiorData)
                
                -- Get native interior ID if player is in an interior
                local interiorId = GetInteriorFromEntity(playerPed)
                if interiorId ~= 0 then
                    ApplyInteriorSettings(interiorId, interiorData)
                end
            end
            
            activeInterior = interiorName
        end
    end
end)

-- Register default interiors
Citizen.CreateThread(function()
    -- Wait for resource to fully start
    Citizen.Wait(1000)
    
    -- Register some common interiors to prevent conflicts
    
    -- FIB Building
    RegisterInterior(
        "fib_building",
        vector3(136.0, -761.0, 45.0),
        50.0,
        10,
        "FIB_01_interior",
        {"fib_01_milo_"},
        {
            ["fib_01_decal_01"] = true,
            ["fib_01_decal_02"] = true,
            ["fib_01_decal_09"] = true,
            ["fib_01_decal_10"] = true,
            ["fib_01_decal_11"] = true
        }
    )
    
    -- Biker Clubhouse
    RegisterInterior(
        "biker_clubhouse_1",
        vector3(1107.04, -3157.399, -37.51),
        30.0,
        10,
        "bkr_biker_interior_01",
        {"biker_interior_01_milo_"},
        {
            ["biker_decor_01"] = true,
            ["biker_decor_02"] = false,
            ["biker_decor_03"] = false,
            ["biker_decor_04"] = false
        }
    )
    
    -- Bunker Interior
    RegisterInterior(
        "bunker_interior",
        vector3(899.5518, -3246.038, -98.04907),
        50.0,
        10,
        "gr_grdlc_interior_01_milo_",
        {"bunker_style_a"},
        {
            ["bunker_style_a"] = true,
            ["bunker_style_b"] = false,
            ["bunker_style_c"] = false,
            ["security_upgrade"] = true,
            ["office_upgrade"] = true,
            ["gun_range_upgrade"] = true,
            ["gun_locker_upgrade"] = true,
            ["gun_wall_upgrade"] = true
        }
    )
    
    -- Nightclub
    RegisterInterior(
        "nightclub_interior",
        vector3(-1604.664, -3012.583, -78.00),
        50.0,
        10,
        "ba_int_placement_ba_interior_0_dlc_int_01_ba_milo_",
        {"ba_int_placement_ba_interior_0_dlc_int_01_ba_milo_"},
        {
            ["Int01_ba_Style01"] = true,
            ["Int01_ba_Style02"] = false,
            ["Int01_ba_Style03"] = false,
            ["Int01_ba_equipment_setup"] = true,
            ["Int01_ba_equipment_upgrade"] = true,
            ["Int01_ba_security_upgrade"] = true,
            ["Int01_ba_dj01"] = true,
            ["Int01_ba_booze_01"] = true,
            ["Int01_ba_dry_ice"] = true
        }
    )
    
    print("^2[INTERIOR_MANAGER]^0 Default interiors registered")
end)

-- Debug command to show all interiors
RegisterCommand("showinteriors", function()
    debugMode = not debugMode
    if debugMode then
        print("Interior debugging enabled")
    else
        print("Interior debugging disabled")
    end
end, true)

-- Debug command to show current interior
RegisterCommand("currentinterior", function()
    local playerCoords = GetEntityCoords(PlayerPedId())
    local interiorName, interiorData = GetActiveInteriorAtPosition(playerCoords)
    
    if interiorName then
        print("Current interior: " .. interiorName .. " (Priority: " .. interiorData.priority .. ")")
    else
        print("Not in any registered interior")
    end
    
    -- Show native interior info
    local interiorId = GetInteriorFromEntity(PlayerPedId())
    if interiorId ~= 0 then
        print("Native interior ID: " .. interiorId)
    else
        print("Not in any native interior")
    end
end, false)

-- Export functions
exports('RegisterInterior', RegisterInterior)
exports('UpdateInterior', UpdateInterior)
exports('RemoveInterior', RemoveInterior)
exports('GetActiveInteriorAtPosition', GetActiveInteriorAtPosition)