-- D-pad Controller Menu System
-- This script provides a controller-friendly menu system using D-pad controls

-- Initialize NativeUI
_G.NativeUI = _G.NativeUI or {}
if not NativeUI.CreatePool then
    -- Try to get NativeUI from the resource export
    local success, result = pcall(function()
        return exports['NativeUI']:GetSharedObject()
    end)
    
    if success and result then
        _G.NativeUI = result
    else
        print("^1ERROR: NativeUI could not be initialized. Menu functionality will be limited.^7")
    end
end

local menuPool = NativeUI and NativeUI.CreatePool() or {}
local mainMenu = nil
local isMenuOpen = false

-- Menu positions for different D-pad directions
local menuPositions = {
    up = nil,    -- NPC interactions (handled by npc_interactions.lua)
    down = nil,  -- Player stats menu
    left = nil,  -- Gang/job menu
    right = nil  -- Vehicle/item menu
}

-- State tracking variables to prevent repeated prompts
local menuStates = {
    down = { isOpen = false, promptShown = false },
    left = { isOpen = false, promptShown = false },
    right = { isOpen = false, promptShown = false }
}

-- Cooldown timers
local lastNotificationTime = 0

-- Create player stats menu (DOWN on D-pad)
function CreatePlayerStatsMenu()
    -- Check if NativeUI is properly initialized
    if not NativeUI or not NativeUI.CreateMenu then
        print("^1ERROR: NativeUI not available for CreatePlayerStatsMenu^7")
        return nil
    end

    local menu = NativeUI.CreateMenu("Player Stats", "~b~Your player statistics")
    menuPool:Add(menu)
    
    -- Safely get player data from player_tracker
    local playerData = {kills = 0, deaths = 0, xp = 0, level = 0}
    local success, result = pcall(function()
        return exports['player_tracker']:GetPlayerData()
    end)
    
    if success and result then
        playerData = result
    end
    
    -- Add stats items
    local killsItem = NativeUI.CreateItem("Kills", "Total kills: " .. playerData.kills)
    menu:AddItem(killsItem)
    
    local deathsItem = NativeUI.CreateItem("Deaths", "Total deaths: " .. playerData.deaths)
    menu:AddItem(deathsItem)
    
    local xpItem = NativeUI.CreateItem("XP", "Experience points: " .. playerData.xp)
    menu:AddItem(xpItem)
    
    local levelItem = NativeUI.CreateItem("Level", "Current level: " .. playerData.level)
    menu:AddItem(levelItem)
    
    -- Job info (from standalone-framework)
    local jobInfo = "Unemployed"
    success, result = pcall(function()
        return exports['standalone-framework']:GetPlayerJob()
    end)
    
    if success and result then
        jobInfo = result or "Unemployed"
    end
    
    local jobItem = NativeUI.CreateItem("Job", "Current job: " .. jobInfo)
    menu:AddItem(jobItem)
    
    -- Gang info (if available)
    local gangInfo = nil
    success, result = pcall(function()
        return exports['standalone-framework']:GetPlayerGang()
    end)
    
    if success and result then
        gangInfo = result
    end
    
    if gangInfo then
        local gangItem = NativeUI.CreateItem("Gang", "Current gang: " .. gangInfo)
        menu:AddItem(gangItem)
    end
    
    -- Refresh button
    local refreshItem = NativeUI.CreateItem("Refresh Stats", "Update your statistics")
    menu:AddItem(refreshItem)
    refreshItem.Activated = function(sender, item)
        -- Refresh player data
        success, result = pcall(function()
            return exports['player_tracker']:GetPlayerData()
        end)
        
        if success and result then
            playerData = result
            killsItem:RightLabel("~b~" .. playerData.kills)
            deathsItem:RightLabel("~b~" .. playerData.deaths)
            xpItem:RightLabel("~b~" .. playerData.xp)
            levelItem:RightLabel("~b~" .. playerData.level)
        end
        
        -- Refresh job info
        success, result = pcall(function()
            return exports['standalone-framework']:GetPlayerJob()
        end)
        
        if success and result then
            jobInfo = result or "Unemployed"
            jobItem:RightLabel("~b~" .. jobInfo)
        end
        
        -- Refresh gang info
        success, result = pcall(function()
            return exports['standalone-framework']:GetPlayerGang()
        end)
        
        if success and result then
            gangInfo = result
            if gangInfo and gangItem then
                gangItem:RightLabel("~b~" .. gangInfo)
            end
        end
        
        ShowNotification("Statistics refreshed")
    end
    
    -- Handle menu closing
    menu.OnMenuClosed = function(menu)
        menuStates.down.isOpen = false
        
        -- Add a delay before showing prompts again
        Citizen.SetTimeout(1000, function()
            menuStates.down.promptShown = false
        end)
    end
    
    return menu
end

-- Create gang/job menu (LEFT on D-pad)
function CreateGangJobMenu()
    -- Check if NativeUI is properly initialized
    if not NativeUI or not NativeUI.CreateMenu then
        print("^1ERROR: NativeUI not available for CreateGangJobMenu^7")
        return nil
    end

    local menu = NativeUI.CreateMenu("Gang & Job", "~b~Gang and job actions")
    menuPool:Add(menu)
    
    -- Gang submenu
    local gangSubmenu = menuPool:AddSubMenu(menu, "Gang Actions")
    
    -- Add gang-specific actions
    local gangInfo = nil
    local success, result = pcall(function()
        return exports['standalone-framework']:GetPlayerGang()
    end)
    
    if success and result then
        gangInfo = result
    end
    
    if gangInfo then
        local callBackupItem = NativeUI.CreateItem("Call Backup", "Request gang backup")
        gangSubmenu:AddItem(callBackupItem)
        callBackupItem.Activated = function(sender, item)
            TriggerEvent("gangrp:callBackup")
            ShowNotification("Backup requested")
        end
        
        local startTurfWarItem = NativeUI.CreateItem("Start Turf War", "Initiate a turf war")
        gangSubmenu:AddItem(startTurfWarItem)
        startTurfWarItem.Activated = function(sender, item)
            TriggerEvent("gangrp:startTurfWar")
            ShowNotification("Turf war initiated")
        end
    else
        local noGangItem = NativeUI.CreateItem("No Gang", "You are not in a gang")
        gangSubmenu:AddItem(noGangItem)
    end
    
    -- Job submenu
    local jobSubmenu = menuPool:AddSubMenu(menu, "Job Actions")
    
    -- Add job-specific actions
    local jobInfo = "Unemployed"
    success, result = pcall(function()
        return exports['standalone-framework']:GetPlayerJob()
    end)
    
    if success and result then
        jobInfo = result or "Unemployed"
    end
    
    if jobInfo == "police" then
        local callBackupItem = NativeUI.CreateItem("Call Police Backup", "Request police backup")
        jobSubmenu:AddItem(callBackupItem)
        callBackupItem.Activated = function(sender, item)
            TriggerEvent("civil_unrest_police:callBackup")
            ShowNotification("Police backup requested")
        end
        
        local wantedListItem = NativeUI.CreateItem("Wanted List", "View wanted criminals")
        jobSubmenu:AddItem(wantedListItem)
        wantedListItem.Activated = function(sender, item)
            TriggerEvent("civil_unrest_police:showWantedList")
        end
    elseif jobInfo == "ems" then
        local callAmbulanceItem = NativeUI.CreateItem("Call Ambulance", "Request ambulance")
        jobSubmenu:AddItem(callAmbulanceItem)
        callAmbulanceItem.Activated = function(sender, item)
            TriggerEvent("civil_unrest_ems:callAmbulance")
            ShowNotification("Ambulance requested")
        end
    elseif jobInfo == "fire" then
        local callFiretruckItem = NativeUI.CreateItem("Call Firetruck", "Request firetruck")
        jobSubmenu:AddItem(callFiretruckItem)
        callFiretruckItem.Activated = function(sender, item)
            TriggerEvent("civil_unrest_fire:callFiretruck")
            ShowNotification("Firetruck requested")
        end
    else
        local noJobItem = NativeUI.CreateItem("No Job Actions", "No special actions available")
        jobSubmenu:AddItem(noJobItem)
    end
    
    -- Handle menu closing
    menu.OnMenuClosed = function(menu)
        menuStates.left.isOpen = false
        
        -- Add a delay before showing prompts again
        Citizen.SetTimeout(1000, function()
            menuStates.left.promptShown = false
        end)
    end
    
    return menu
end

-- Create vehicle/item menu (RIGHT on D-pad)
function CreateVehicleItemMenu()
    -- Check if NativeUI is properly initialized
    if not NativeUI or not NativeUI.CreateMenu then
        print("^1ERROR: NativeUI not available for CreateVehicleItemMenu^7")
        return nil
    end

    local menu = NativeUI.CreateMenu("Vehicles & Items", "~b~Vehicle and item actions")
    menuPool:Add(menu)
    
    -- Vehicle submenu
    local vehicleSubmenu = menuPool:AddSubMenu(menu, "Vehicle Actions")
    
    -- Add vehicle spawn options
    local spawnVehicleItem = NativeUI.CreateItem("Spawn Vehicle", "Open vehicle spawn menu")
    vehicleSubmenu:AddItem(spawnVehicleItem)
    spawnVehicleItem.Activated = function(sender, item)
        TriggerEvent("vmenu:openVehicleMenu")
    end
    
    -- Add vehicle control options
    local vehicleControlItem = NativeUI.CreateItem("Vehicle Controls", "Control your current vehicle")
    vehicleSubmenu:AddItem(vehicleControlItem)
    vehicleControlItem.Activated = function(sender, item)
        local playerPed = PlayerPedId()
        if IsPedInAnyVehicle(playerPed, false) then
            TriggerEvent("vmenu:openVehicleControlMenu")
        else
            ShowNotification("~r~You must be in a vehicle to use this option")
        end
    end
    
    -- Items submenu
    local itemSubmenu = menuPool:AddSubMenu(menu, "Item Actions")
    
    -- Add item options
    local useItemItem = NativeUI.CreateItem("Use Item", "Use an item from your inventory")
    itemSubmenu:AddItem(useItemItem)
    useItemItem.Activated = function(sender, item)
        TriggerEvent("vmenu:openInventoryMenu")
    end
    
    -- Add weapon options
    local weaponSubmenu = menuPool:AddSubMenu(menu, "Weapon Actions")
    
    -- Add weapon options
    local giveAmmoItem = NativeUI.CreateItem("Give Ammo", "Add ammo to current weapon")
    weaponSubmenu:AddItem(giveAmmoItem)
    giveAmmoItem.Activated = function(sender, item)
        TriggerEvent("vmenu:giveAmmo")
    end
    
    -- Handle menu closing
    menu.OnMenuClosed = function(menu)
        menuStates.right.isOpen = false
        
        -- Add a delay before showing prompts again
        Citizen.SetTimeout(1000, function()
            menuStates.right.promptShown = false
        end)
    end
    
    return menu
end

-- Create gang interaction menu
function CreateGangInteractionMenu(gangName, memberNetId)
    -- Check if NativeUI is properly initialized
    if not NativeUI or not NativeUI.CreateMenu then
        print("^1ERROR: NativeUI not available for CreateGangInteractionMenu^7")
        return nil
    end

    local menu = NativeUI.CreateMenu(gangName, "~b~Gang Interaction")
    menuPool:Add(menu)
    
    -- Add mission option
    local missionItem = NativeUI.CreateItem("Request Mission", "Ask for work from " .. gangName)
    menu:AddItem(missionItem)
    missionItem.Activated = function(sender, item)
        TriggerEvent("civil_disorder:requestGangMission", gangName)
        ShowNotification("Requesting mission from " .. gangName)
    end
    
    -- Add shop option
    local shopItem = NativeUI.CreateItem("Gang Shop", "Browse items for sale")
    menu:AddItem(shopItem)
    shopItem.Activated = function(sender, item)
        TriggerEvent("civil_disorder:openGangShop", gangName, "weapons")
        ShowNotification("Opening " .. gangName .. " shop")
    end
    
    -- Add bribe option
    local bribeItem = NativeUI.CreateItem("Bribe Gang Member", "Increase your reputation with money")
    menu:AddItem(bribeItem)
    bribeItem.Activated = function(sender, item)
        OpenBribeMenu(gangName)
    end
    
    -- Add information option
    local infoItem = NativeUI.CreateItem("Gang Information", "Learn about " .. gangName)
    menu:AddItem(infoItem)
    infoItem.Activated = function(sender, item)
        TriggerEvent("civil_disorder:getGangInfo", gangName)
        ShowNotification("Getting information about " .. gangName)
    end
    
    -- Handle menu closing
    menu.OnMenuClosed = function(menu)
        -- Nothing special needed here
    end
    
    menu:Visible(true)
    return menu
}

-- Create bribe menu
function OpenBribeMenu(gangName)
    -- Check if NativeUI is properly initialized
    if not NativeUI or not NativeUI.CreateMenu then
        print("^1ERROR: NativeUI not available for OpenBribeMenu^7")
        return nil
    end

    local menu = NativeUI.CreateMenu("Bribe " .. gangName, "~b~Select amount")
    menuPool:Add(menu)
    
    local amounts = {100, 500, 1000, 5000, 10000}
    
    for _, amount in ipairs(amounts) do
        local bribeItem = NativeUI.CreateItem("$" .. amount, "Gain " .. math.floor(amount / 100) .. " reputation")
        menu:AddItem(bribeItem)
        bribeItem.Activated = function(sender, item)
            TriggerEvent("civil_disorder:bribeGangMember", gangName, amount)
            ShowNotification("Bribing " .. gangName .. " member with $" .. amount)
            menu:Visible(false)
        end
    end
    
    menu:Visible(true)
    return menu
end

-- Initialize menus
function InitializeMenus()
    -- Check if NativeUI is properly initialized
    if not NativeUI or not NativeUI.CreatePool then
        print("^1ERROR: NativeUI not available for InitializeMenus^7")
        return
    end

    -- Create menus for each D-pad direction
    menuPositions.down = CreatePlayerStatsMenu()
    menuPositions.left = CreateGangJobMenu()
    menuPositions.right = CreateVehicleItemMenu()
    
    -- Refresh all menus
    menuPool:RefreshIndex()
}

-- Check if any menu is open
function IsAnyMenuOpen()
    for direction, menu in pairs(menuPositions) do
        if menu and menu.Visible and menu:Visible() then
            return true
        end
    end
    return false
end

-- Show notification with cooldown
function ShowNotification(message)
    local currentTime = GetGameTimer()
    if currentTime - lastNotificationTime > Config.Menu.NotificationCooldown then
        BeginTextCommandThefeedPost("STRING")
        AddTextComponentSubstringPlayerName(message)
        EndTextCommandThefeedPostTicker(true, false)
        
        lastNotificationTime = currentTime
    end
end

-- Initialize D-pad menu system
function InitializeControllerMenu()
    -- Wait for NativeUI to be available
    Citizen.Wait(1000)
    
    -- Initialize menus
    InitializeMenus()
    
    -- Handle D-pad controls
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            
            -- Process menus if NativeUI is available
            if menuPool then
                menuPool:ProcessMenus()
            end
            
            -- Only check for D-pad input if no menu is open
            if not IsAnyMenuOpen() then
                -- D-pad Down (Player Stats)
                if IsControlJustReleased(0, 173) then -- 173 is D-pad Down
                    if menuPositions.down then
                        menuPositions.down:Visible(true)
                        menuStates.down.isOpen = true
                        menuStates.down.promptShown = true
                        PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                        ShowNotification("Player stats menu opened. Use D-pad to navigate.")
                    end
                end
                
                -- D-pad Left (Gang/Job)
                if IsControlJustReleased(0, 174) then -- 174 is D-pad Left
                    if menuPositions.left then
                        menuPositions.left:Visible(true)
                        menuStates.left.isOpen = true
                        menuStates.left.promptShown = true
                        PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                        ShowNotification("Gang & job menu opened. Use D-pad to navigate.")
                    end
                end
                
                -- D-pad Right (Vehicle/Item)
                if IsControlJustReleased(0, 175) then -- 175 is D-pad Right
                    if menuPositions.right then
                        menuPositions.right:Visible(true)
                        menuStates.right.isOpen = true
                        menuStates.right.promptShown = true
                        PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                        ShowNotification("Vehicle & item menu opened. Use D-pad to navigate.")
                    end
                end
            end
        end
    end)
}

-- Event handler for opening gang menu
RegisterNetEvent("controller_menu:openGangMenu")
AddEventHandler("controller_menu:openGangMenu", function(gangName, memberNetId)
    CreateGangInteractionMenu(gangName, memberNetId)
end)

-- Export functions
exports('RefreshMenus', InitializeMenus)
exports('CreateGangInteractionMenu', CreateGangInteractionMenu)
exports('ShowNotification', ShowNotification)
