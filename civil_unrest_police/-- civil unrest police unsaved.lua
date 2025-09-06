-- Function to check if player is in a safe zone
function UpdatePlayerSafeZoneStatus()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local wasInSafeZone = isPlayerInSafeZone
    isPlayerInSafeZone = false

    -- Check police stations
    for _, station in ipairs(Config.PoliceStations) do
        if #(playerCoords - station.coords) < station.radius then
            isPlayerInSafeZone = true
            break
        end
    end

    -- If safe zone status changed, trigger event
    if wasInSafeZone ~= isPlayerInSafeZone then
        TriggerEvent("civil_unrest_police:safeZoneChanged", isPlayerInSafeZone)
    end -- FIX: Changed '}' to 'end'

    return isPlayerInSafeZone
end -- FIX: Changed '}' to 'end'

-- Event handler for showing police options
RegisterNetEvent("civil_unrest_police:showOptions")
AddEventHandler("civil_unrest_police:showOptions", function(ped)
    -- Check if NativeUI is available
    if not NativeUI then
        print("Error: NativeUI is not available. Police interaction menu will not work.")
        return
    end

    -- Create menu using NativeUI
    local menuPool = NativeUI.CreatePool()
    local mainMenu = NativeUI.CreateMenu("Police Officer", "~b~Police Options")
    menuPool:Add(mainMenu)
    menuPool:MouseControlsEnabled(false)
    menuPool:MouseEdgeEnabled(false)
    menuPool:ControlDisablingEnabled(true)
    menuPool:ControllerEnabled(true)

    -- Add report crime option
    local reportCrimeItem = NativeUI.CreateItem("Report Crime", "Report a crime to the officer")
    mainMenu:AddItem(reportCrimeItem)
    reportCrimeItem.Activated = function(sender, item)
        TriggerServerEvent("civil_unrest_police:reportCrime")
        mainMenu:Visible(false)
    end

    -- Add pay ticket option
    local payTicketItem = NativeUI.CreateItem("Pay Ticket", "Pay an outstanding ticket")
    mainMenu:AddItem(payTicketItem)
    payTicketItem.Activated = function(sender, item)
        TriggerServerEvent("civil_unrest_police:payTicket")
        mainMenu:Visible(false)
    end

    -- Add ask directions option
    local askDirectionsItem = NativeUI.CreateItem("Ask for Directions", "Get directions to a location")
    mainMenu:AddItem(askDirectionsItem)
    askDirectionsItem.Activated = function(sender, item)
        TriggerEvent("civil_unrest_police:askDirections")
        mainMenu:Visible(false)
    end

    -- Add request assistance option
    local requestAssistanceItem = NativeUI.CreateItem("Request Assistance", "Request police assistance")
    mainMenu:AddItem(requestAssistanceItem)
    requestAssistanceItem.Activated = function(sender, item)
        local playerCoords = GetEntityCoords(PlayerPedId())
        TriggerServerEvent("civil_unrest_police:requestAssistance", playerCoords)
        mainMenu:Visible(false)
    end

    -- Add bribe option (if player has wanted level)
    if exports['civil_unrest_police']:GetWantedLevel() > 0 then
        local bribeItem = NativeUI.CreateItem("Attempt Bribe", "Try to bribe the officer")
        mainMenu:AddItem(bribeItem)
        bribeItem.Activated = function(sender, item)
            TriggerServerEvent("civil_unrest_police:attemptBribe")
            mainMenu:Visible(false)
        end
    end

    -- Add leave option
    local leaveItem = NativeUI.CreateItem("Leave", "Walk away")
    mainMenu:AddItem(leaveItem)
    leaveItem.Activated = function(sender, item)
        ShowNotification("You walk away from the officer")
        mainMenu:Visible(false)
    end

    -- Show menu
    menuPool:RefreshIndex()
    mainMenu:Visible(true)

    -- Process menu in a separate thread
    CreateThread(function() -- FIX: Changed Citizen.CreateThread to CreateThread
        while mainMenu:Visible() do
            Wait(0)         -- FIX: Changed Citizen.Wait to Wait
            menuPool:ProcessMenus()
        end

        -- Clean up menu resources when done
        menuPool:CloseAllMenus()
    end)
end)
