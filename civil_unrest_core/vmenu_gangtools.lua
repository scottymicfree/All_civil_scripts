-- First, ensure NativeUI is properly imported
local menuPool = nil

-- Initialize NativeUI when resource starts
Citizen.CreateThread(function()
    -- Wait for NativeUI to be available
    while not NativeUI do
        Citizen.Wait(100)
    end
    
    -- Create the menu pool once NativeUI is available
    menuPool = NativeUI.CreatePool()
    
    -- Debug message to confirm NativeUI is loaded
    print("NativeUI loaded successfully for Gang Tools menu")
end)

-- Gang zones definition (should be moved to a config file)
GangZones = {
    {
        name = "Red Hood",
        center = vector3(213.4, -1800.2, 27.0),
        color = 1, -- Red
        owner = "none"
    },
    -- Add other zones here
}

RegisterCommand("opengangmenu", function()
    -- Check if NativeUI is ready
    if not menuPool then
        ShowNotification("~r~Menu system is not ready yet. Please try again.")
        return
    end
    
    local menu = NativeUI.CreateMenu("Gang Tools", "Turf Controls")
    menuPool:Add(menu)
    menu:AddItem(NativeUI.CreateItem("My Turf Wins", "Check your turf capture count."))
    menu:AddItem(NativeUI.CreateItem("View Turf Zones", "Blip all gang zones."))
    menu:AddItem(NativeUI.CreateItem("Teleport to Red Hood Turf", "Admin only teleport."))
    menu:AddItem(NativeUI.CreateItem("Force Takeover Red Hood", "Admin simulate capture."))
    menu:AddItem(NativeUI.CreateItem("Buy Pistol ($500)", "Purchase a basic pistol."))

    menu.OnItemSelect = function(_, item, index)
        if item:Text() == "My Turf Wins" then
            ExecuteCommand("gangstats")
        elseif item:Text() == "View Turf Zones" then
            -- Clear existing blips first
            for _, blip in pairs(blipRefs) do
                if DoesBlipExist(blip) then
                    RemoveBlip(blip)
                end
            end
            blipRefs = {}
            
            -- Create new blips
            for _, zone in pairs(GangZones) do
                local b = AddBlipForCoord(zone.center.x, zone.center.y, zone.center.z)
                SetBlipSprite(b, 9)
                SetBlipColour(b, zone.color)
                SetBlipScale(b, 0.85)
                SetBlipAsShortRange(b, true) -- prevent cluttering full map
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString(zone.name .. " Turf")
                EndTextCommandSetBlipName(b)
                table.insert(blipRefs, b)
            end
            ShowNotification("~g~Gang zones are now visible on the map")
        elseif item:Text() == "Teleport to Red Hood Turf" then
            SetEntityCoords(PlayerPedId(), 213.4, -1800.2, 27.0)
            ShowNotification("~b~Teleported to Red Hood Turf")
        elseif item:Text() == "Force Takeover Red Hood" then
            local gang = LocalPlayer.state.gang or "unknown"
            TriggerServerEvent("gangzones:takeover", "Red Hood", gang, 11)
            ShowNotification("~y~Attempting to take over Red Hood turf")
        elseif item:Text() == "Buy Pistol ($500)" then
            TriggerServerEvent("civilunrest:buyWeapon", "weapon_pistol", 500)
            ShowNotification("~b~Purchasing pistol for $500")
        end
    end

    menu:Visible(true)
    
    -- Process this menu for the current frame
    menuPool:ProcessMenus()
end)

-- D-Pad Combo: LEFT + RIGHT opens Gang Tools Menu
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        -- Only process menus if menuPool is initialized
        if menuPool then
            menuPool:ProcessMenus()
        end
        
        if IsControlPressed(0, 174) and IsControlPressed(0, 175) then
            ExecuteCommand("opengangmenu")
            Citizen.Wait(2000)
        end
    end
end)

-- Helper function for notifications
function ShowNotification(message)
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandThefeedPostTicker(true, false)
end
