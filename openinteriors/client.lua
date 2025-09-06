-- Open Interiors Script
-- This script loads interior IPLs and resolves conflicts between them

-- List of interiors to load
local interiors = {
    -- FIB Building
    {
        name = "FIB Building",
        ipl = "FIB_01_interior",
        coords = vector3(136.0, -761.0, 45.0),
        entitySets = {
            "fib_01_milo_"
        },
        props = {
            ["fib_01_decal_01"] = true,
            ["fib_01_decal_02"] = true,
            ["fib_01_decal_09"] = true,
            ["fib_01_decal_10"] = true,
            ["fib_01_decal_11"] = true
        }
    },
    {
        name = "FIB Building Floor 2",
        ipl = "FIB_02_interior",
        coords = vector3(136.0, -761.0, 234.0),
        entitySets = {
            "fib_02_milo_"
        },
        props = {}
    },
    
    -- Biker Clubhouses
    {
        name = "Biker Clubhouse 1",
        ipl = "bkr_biker_interior_01",
        coords = vector3(1107.04, -3157.399, -37.51),
        entitySets = {
            "biker_interior_01_milo_"
        },
        props = {
            ["biker_decor_01"] = true,
            ["biker_decor_02"] = false,
            ["biker_decor_03"] = false,
            ["biker_decor_04"] = false
        }
    },
    {
        name = "Biker Clubhouse 2",
        ipl = "bkr_biker_interior_02",
        coords = vector3(998.4809, -3164.711, -38.90),
        entitySets = {
            "biker_interior_02_milo_"
        },
        props = {
            ["biker_decor_01"] = false,
            ["biker_decor_02"] = true,
            ["biker_decor_03"] = false,
            ["biker_decor_04"] = false
        }
    },
    {
        name = "Biker Clubhouse 3",
        ipl = "bkr_biker_interior_03",
        coords = vector3(1121.897, -3195.338, -40.40),
        entitySets = {
            "biker_interior_03_milo_"
        },
        props = {
            ["biker_decor_01"] = false,
            ["biker_decor_02"] = false,
            ["biker_decor_03"] = true,
            ["biker_decor_04"] = false
        }
    },
    
    -- Bunker
    {
        name = "Bunker Interior",
        ipl = "gr_grdlc_interior_01_milo_",
        coords = vector3(899.5518, -3246.038, -98.04907),
        entitySets = {
            "bunker_style_a"
        },
        props = {
            ["bunker_style_a"] = true,
            ["bunker_style_b"] = false,
            ["bunker_style_c"] = false,
            ["security_upgrade"] = true,
            ["office_upgrade"] = true,
            ["gun_range_upgrade"] = true,
            ["gun_locker_upgrade"] = true,
            ["gun_wall_upgrade"] = true
        }
    },
    
    -- Nightclub
    {
        name = "Nightclub Interior",
        ipl = "ba_int_placement_ba_interior_0_dlc_int_01_ba_milo_",
        coords = vector3(-1604.664, -3012.583, -78.00),
        entitySets = {
            "ba_int_placement_ba_interior_0_dlc_int_01_ba_milo_"
        },
        props = {
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
    },
    
    -- CEO Offices
    {
        name = "CEO Office 1",
        ipl = "ex_dt1_02_office_01a",
        coords = vector3(-141.1987, -620.913, 167.8205),
        entitySets = {},
        props = {}
    },
    {
        name = "CEO Office 2",
        ipl = "ex_dt1_11_office_01b",
        coords = vector3(-75.8466, -826.9893, 242.3859),
        entitySets = {},
        props = {}
    },
    {
        name = "CEO Office 3",
        ipl = "ex_dt1_11_office_02b",
        coords = vector3(-1579.756, -565.0661, 107.6229),
        entitySets = {},
        props = {}
    },
    
    -- Apartments
    {
        name = "Mid-End Apartment",
        ipl = "apa_v_mp_h_01_a",
        coords = vector3(-786.8663, 315.7642, 216.6385),
        entitySets = {},
        props = {}
    },
    {
        name = "High-End Apartment",
        ipl = "apa_v_mp_h_01_c",
        coords = vector3(-786.9563, 315.6229, 186.9136),
        entitySets = {},
        props = {}
    },
    
    -- Casino
    {
        name = "Diamond Casino",
        ipl = "vw_casino_main",
        coords = vector3(1100.000, 220.000, -50.000),
        entitySets = {},
        props = {}
    },
    {
        name = "Diamond Casino Penthouse",
        ipl = "vw_casino_penthouse",
        coords = vector3(976.6364, 70.29476, 115.1641),
        entitySets = {},
        props = {}
    }
}

-- Function to load interior
function LoadInterior(interior)
    -- Request IPL
    if interior.ipl then
        RequestIpl(interior.ipl)
        print("Loaded IPL: " .. interior.ipl)
    end
    
    -- Get interior ID at coordinates
    local interiorId = GetInteriorAtCoords(interior.coords.x, interior.coords.y, interior.coords.z)
    
    -- If interior ID is valid
    if interiorId ~= 0 then
        -- Enable entity sets
        for _, entitySet in ipairs(interior.entitySets) do
            if not IsInteriorEntitySetActive(interiorId, entitySet) then
                ActivateInteriorEntitySet(interiorId, entitySet)
                print("Activated entity set: " .. entitySet)
            end
        end
        
        -- Set props
        for prop, enabled in pairs(interior.props) do
            if enabled then
                if not IsInteriorPropEnabled(interiorId, prop) then
                    EnableInteriorProp(interiorId, prop)
                    print("Enabled prop: " .. prop)
                end
            else
                if IsInteriorPropEnabled(interiorId, prop) then
                    DisableInteriorProp(interiorId, prop)
                    print("Disabled prop: " .. prop)
                end
            end
        end
        
        -- Refresh interior
        RefreshInterior(interiorId)
    end
end

-- Load all interiors
CreateThread(function()
    -- Wait for resource to fully start
         Wait(1000)
    
    -- Load each interior
    for _, interior in ipairs(interiors) do
        LoadInterior(interior)
    end
    
    -- Notify the player that the interiors have been loaded.
    print("^2[openinteriors]^0 All IPLs loaded successfully.")
end)

-- Debug command to reload interiors
RegisterCommand("reloadinteriors", function()
    for _, interior in ipairs(interiors) do
        LoadInterior(interior)
    end
    
    TriggerEvent('fxcode:utils:notify', "Interiors reloaded", "success")
end, false)