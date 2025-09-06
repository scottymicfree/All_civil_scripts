local blipRefs = {}
menuPool = NativeUI.CreatePool()
RegisterCommand("opengangmenu", function()
    local menu = NativeUI.CreateMenu("Gang Tools","Turf Controls")
    menuPool:Add(menu)
    menu:AddItem(NativeUI.CreateItem("My Turf Wins","Check your turf capture count."))
    menu:AddItem(NativeUI.CreateItem("View Turf Zones", "Blip all gang zones."))
    menu:AddItem(NativeUI.CreateItem("Teleport to Red Hood Turf", "Admin only teleport."))
    menu:AddItem(NativeUI.CreateItem("Force Takeover Red Hood", "Admin simulate capture."))
    menu:AddItem(NativeUI.CreateItem("Buy Pistol ($500)", "Purchase a basic pistol."))

    menu.OnItemSelect = function(_, item, index)
        if item:Text() == "My Turf Wins" then
            ExecuteCommand("gangstats")
        elseif item:Text() == "View Turf Zones" then
            for _, zone in pairs(GangZones) do
                local b = AddBlipForCoord(zone.center)
                SetBlipSprite(b, 9)
                SetBlipColour(b, zone.color)
                SetBlipScale(b, 0.85)
                SetBlipAsShortRange(b, true) -- prevent cluttering full map
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString(zone.name .. " Turf")
                EndTextCommandSetBlipName(b)
            end
        elseif item:Text() == "Teleport to Red Hood Turf" then
            SetEntityCoords(PlayerPedId(), 213.4, -1800.2, 27.0)
        elseif item:Text() == "Force Takeover Red Hood" then
            local gang = LocalPlayer.state.gang or "unknown"
            TriggerServerEvent("gangzones:takeover", "Red Hood", gang, 11)
        elseif item:Text() == "Buy Pistol ($500)" then
            TriggerServerEvent("civilunrest:buyWeapon", "weapon_pistol", 500)
        end
    end

    menu:Visible(true)
end)

-- D-Pad Combo: LEFT + RIGHT opens Gang Tools Menu
CreateThread(function()
    while true do
        Wait(0)
        _menuPool:ProcessMenus()
        if IsControlPressed(0, 174) and IsControlPressed(0, 175) then
            ExecuteCommand("opengangmenu")
            Wait(2000)
        end
    end
end)
