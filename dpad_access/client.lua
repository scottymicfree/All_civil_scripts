-- D-pad Access Script
-- This script provides controller-friendly D-pad access to various features

-- Configuration
local Config = {
    -- D-pad Up: NPC Interactions (handled by other resources)
    
    -- D-pad Down: Player Stats Menu
    Down = {
        enabled = true,
        cooldown = 1000 -- 1 second cooldown
    },
    
    -- D-pad Left: Gang/Job Menu
    Left = {
        enabled = true,
        cooldown = 1000 -- 1 second cooldown
    },
    
    -- D-pad Right: Vehicle/Item Menu
    Right = {
        enabled = true,
        cooldown = 1000 -- 1 second cooldown
    }
}

-- Variables
local cooldowns = {
    up = 0,
    down = 0,
    left = 0,
    right = 0
}

local menus = {
    down = nil,
    left = nil,
    right = nil
}

local isMenuOpen = false
local debugMode = false

-- Function to create player stats menu (DOWN on D-pad)
function CreatePlayerStatsMenu()
    -- Create menu using NativeUI
    local menuPool = NativeUI.CreatePool()
    local mainMenu = NativeUI.CreateMenu("Player Stats", "~b~Your player statistics")
    menuPool:Add(mainMenu)
    
    -- Get player data from player_tracker
    local playerData = exports['player_tracker']:GetPlayerData()
    
    -- Add stats items
    local killsItem = NativeUI.CreateItem("Kills", "Total kills: " .. playerData.kills)
    killsItem:RightLabel(tostring(playerData.kills))
    mainMenu:AddItem(killsItem)
    
    local deathsItem = NativeUI.CreateItem("Deaths", "Total deaths: " .. playerData.deaths)
    deathsItem:RightLabel(tostring(playerData.deaths))
    mainMenu:AddItem(deathsItem)
    
    local xpItem = NativeUI.CreateItem("XP", "Experience points: " .. playerData.xp)
    xpItem:RightLabel(tostring(playerData.xp))
    mainMenu:AddItem(xpItem)
    
    local levelItem = NativeUI.CreateItem("Level", "Current level: " .. playerData.level)
    levelItem:RightLabel(tostring(playerData.level))
    mainMenu:AddItem(levelItem)
    
    -- Job info (from standalone-framework)
    local jobInfo = exports['standalone-framework']:GetPlayerJob()
    local jobItem = NativeUI.CreateItem("Job", "Current job: " .. (jobInfo or "Unemployed"))
    jobItem:RightLabel(jobInfo or "Unemployed")
    mainMenu:AddItem(jobItem)
    
    -- Gang info (if available)
    local gangInfo = exports['standalone-framework']:GetPlayerGang()
    if gangInfo then
        local gangItem = NativeUI.CreateItem("Gang", "Current gang: " .. gangInfo)
        gangItem:RightLabel(gangInfo)
        mainMenu:AddItem(gangItem)
    end
    
    -- Money info
    local moneyItem = NativeUI.CreateItem("Cash", "Cash on hand")
    moneyItem:RightLabel("$" .. exports['standalone-framework']:GetPlayerMoney())
    mainMenu:AddItem(moneyItem)
    
    local bankItem = NativeUI.CreateItem("Bank", "Bank balance")
    bankItem:RightLabel("$" .. exports['standalone-framework']:GetPlayerBank())
    mainMenu:AddItem(bankItem)
    
    -- Refresh button
    local refreshItem = NativeUI.CreateItem("Refresh Stats", "Update your statistics")
    mainMenu:AddItem(refreshItem)
    refreshItem.Activated = function(sender, item)
        -- Refresh player data
        playerData = exports['player_tracker']:GetPlayerData()
        killsItem:RightLabel(tostring(playerData.kills))
        deathsItem:RightLabel(tostring(playerData.deaths))
        xpItem:RightLabel(tostring(playerData.xp))
        levelItem:RightLabel(tostring(playerData.level))
        
        -- Refresh job info
        jobInfo = exports['standalone-framework']:GetPlayerJob()
        jobItem:RightLabel(jobInfo or "Unemployed")
        
        -- Refresh gang info
        gangInfo = exports['standalone-framework']:GetPlayerGang()
        if gangInfo then
            gangItem:RightLabel(gangInfo)
        end
        
        -- Refresh money info
        moneyItem:RightLabel("$" .. exports['standalone-framework']:GetPlayerMoney())
        bankItem:RightLabel("$" .. exports['standalone-framework']:GetPlayerBank())
        
        ShowNotification("Statistics refreshed")
    end
    
    -- Store menu data
    menus.down = {
        pool = menuPool,
        menu = mainMenu
    }
    
    -- Return menu
    return mainMenu
end

-- Function to create gang/job menu (LEFT on D-pad)
function CreateGangJobMenu()
    -- Create menu using NativeUI
    local menuPool = NativeUI.CreatePool()
    local mainMenu = NativeUI.CreateMenu("Gang & Job", "~b~Gang and job actions")
    menuPool:Add(mainMenu)
    
    -- Gang submenu
    local gangSubmenu = menuPool:AddSubMenu(mainMenu, "Gang Actions")
    
    -- Add gang-specific actions
    local gangInfo = exports['standalone-framework']:GetPlayerGang()
    if gangInfo then
        local callBackupItem = NativeUI.CreateItem("Call Backup", "Request gang backup")
        gangSubmenu:AddItem(callBackupItem)
        callBackupItem.Activated = function(sender, item)
            TriggerEvent("gangrp:callBackup")
            ShowNotification("Backup requested")
            mainMenu:Visible(false)
        end
        
        local startTurfWarItem = NativeUI.CreateItem("Start Turf War", "Initiate a turf war")
        gangSubmenu:AddItem(startTurfWarItem)
        startTurfWarItem.Activated = function(sender, item)
            TriggerEvent("gangrp:startTurfWar")
            ShowNotification("Turf war initiated")
            mainMenu:Visible(false)
        end
    else
        local noGangItem = NativeUI.CreateItem("No Gang", "You are not in a gang")
        gangSubmenu:AddItem(noGangItem)
    end
    
    -- Job submenu
    local jobSubmenu = menuPool:AddSubMenu(mainMenu, "Job Actions")
    
    -- Add job-specific actions
    local jobInfo = exports['standalone-framework']:GetPlayerJob()
    if jobInfo == "police" then
        local callBackupItem = NativeUI.CreateItem("Call Police Backup", "Request police backup")
        jobSubmenu:AddItem(callBackupItem)
        callBackupItem.Activated = function(sender, item)
            TriggerEvent("civil_unrest_police:callBackup")
            ShowNotification("Police backup requested")
            mainMenu:Visible(false)
        end
        
        local wantedListItem = NativeUI.CreateItem("Wanted List", "View wanted criminals")
        jobSubmenu:AddItem(wantedListItem)
        wantedListItem.Activated = function(sender, item)
            TriggerEvent("civil_unrest_police:showWantedList")
            mainMenu:Visible(false)
        end
    elseif jobInfo == "ems" then
        local callAmbulanceItem = NativeUI.CreateItem("Call Ambulance", "Request ambulance")
        jobSubmenu:AddItem(callAmbulanceItem)
        callAmbulanceItem.Activated = function(sender, item)
            TriggerEvent("civil_unrest_ems:callAmbulance")
            ShowNotification("Ambulance requested")
            mainMenu:Visible(false)
        end
    elseif jobInfo == "fire" then
        local callFiretruckItem = NativeUI.CreateItem("Call Firetruck", "Request firetruck")
        jobSubmenu:AddItem(callFiretruckItem)
        callFiretruckItem.Activated = function(sender, item)
            TriggerEvent("civil_unrest_fire:callFiretruck")
            ShowNotification("Firetruck requested")
            mainMenu:Visible(false)
        end
    else
        local noJobItem = NativeUI.CreateItem("No Job Actions", "No special actions available")
        jobSubmenu:AddItem(noJobItem)
    end
    
    -- Store menu data
    menus.left = {
        pool = menuPool,
        menu = mainMenu
    }
    
    -- Return menu
    return mainMenu
end

-- Function to create vehicle/item menu (RIGHT on D-pad)
function CreateVehicleItemMenu()
    -- Create menu using NativeUI
    local menuPool = NativeUI.CreatePool()
    local mainMenu = NativeUI.CreateMenu("Vehicles & Items", "~b~Vehicle and item actions")
    menuPool:Add(mainMenu)
    
    -- Vehicle submenu
    local vehicleSubmenu = menuPool:AddSubMenu(mainMenu, "Vehicle Actions")
    
    -- Add vehicle spawn options
    local spawnVehicleItem = NativeUI.CreateItem("Spawn Vehicle", "Open vehicle spawn menu")
    vehicleSubmenu:AddItem(spawnVehicleItem)
    spawnVehicleItem.Activated = function(sender, item)
        TriggerEvent("vmenu:openVehicleMenu")
        mainMenu:Visible(false)
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
        mainMenu:Visible(false)
    end
    
    -- Items submenu
    local itemSubmenu = menuPool:AddSubMenu(mainMenu, "Item Actions")
    
    -- Add item options
    local useItemItem = NativeUI.CreateItem("Use Item", "Use an item from your inventory")
    itemSubmenu:AddItem(useItemItem)
    useItemItem.Activated = function(sender, item)
        TriggerEvent("vmenu:openInventoryMenu")
        mainMenu:Visible(false)
    end
    
    -- Add weapon options
    local weaponSubmenu = menuPool:AddSubMenu(mainMenu, "Weapon Actions")
    
    -- Add weapon options
    local giveAmmoItem = NativeUI.CreateItem("Give Ammo", "Add ammo to current weapon")
    weaponSubmenu:AddItem(giveAmmoItem)
    giveAmmoItem.Activated = function(sender, item)
        TriggerEvent("vmenu:giveAmmo")
        mainMenu:Visible(false)
    end
    
    -- Store menu data
    menus.right = {
        pool = menuPool,
        menu = mainMenu
    }
    
    -- Return menu
    return mainMenu
end

-- Initialize menus
function InitializeMenus()
    -- Create menus for each D-pad direction
    if Config.Down.enabled then
        CreatePlayerStatsMenu()
    end
    
    if Config.Left.enabled then
        CreateGangJobMenu()
    end
    
    if Config.Right.enabled then
        CreateVehicleItemMenu()
    end
end

-- Handle D-pad controls
Citizen.CreateThread(function()
    -- Wait for resource to fully start
    Citizen.Wait(1000)
    
    -- Initialize menus
    InitializeMenus()
    
    while true do
        Citizen.Wait(0)
        
        -- Process menus
        if menus.down and menus.down.pool then
            menus.down.pool:ProcessMenus()
        end
        
        if menus.left and menus.left.pool then
            menus.left.pool:ProcessMenus()
        end
        
        if menus.right and menus.right.pool then
            menus.right.pool:ProcessMenus()
        end
        
        -- Check if any menu is already open
        local isAnyMenuOpen = false
        if menus.down and menus.down.menu and menus.down.menu:Visible() then
            isAnyMenuOpen = true
        end
        
        if menus.left and menus.left.menu and menus.left.menu:Visible() then
            isAnyMenuOpen = true
        end
        
        if menus.right and menus.right.menu and menus.right.menu:Visible() then
            isAnyMenuOpen = true
        end
        
        -- Only check for D-pad input if no menu is open
        if not isAnyMenuOpen then
            local currentTime = GetGameTimer()
            
            -- D-pad Down (Player Stats)
            if Config.Down.enabled and IsControlJustReleased(0, 173) then -- 173 is D-pad Down
                if currentTime > cooldowns.down then
                    if menus.down and menus.down.menu then
                        menus.down.menu:Visible(true)
                        PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                        ShowNotification("Player stats menu opened. Use D-pad to navigate.")
                    end
                    
                    cooldowns.down = currentTime + Config.Down.cooldown
                end
            end
            
            -- D-pad Left (Gang/Job)
            if Config.Left.enabled and IsControlJustReleased(0, 174) then -- 174 is D-pad Left
                if currentTime > cooldowns.left then
                    if menus.left and menus.left.menu then
                        menus.left.menu:Visible(true)
                        PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                        ShowNotification("Gang & job menu opened. Use D-pad to navigate.")
                    end
                    
                    cooldowns.left = currentTime + Config.Left.cooldown
                end
            end
            
            -- D-pad Right (Vehicle/Item)
            if Config.Right.enabled and IsControlJustReleased(0, 175) then -- 175 is D-pad Right
                if currentTime > cooldowns.right then
                    if menus.right and menus.right.menu then
                        menus.right.menu:Visible(true)
                        PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                        ShowNotification("Vehicle & item menu opened. Use D-pad to navigate.")
                    end
                    
                    cooldowns.right = currentTime + Config.Right.cooldown
                end
            end
        end
    end
end)

-- Notification function
function ShowNotification(message)
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandThefeedPostTicker(true, false)
end

-- Debug command
RegisterCommand("dpad_debug", function()
    debugMode = not debugMode
    ShowNotification("D-pad debug mode: " .. (debugMode and "Enabled" or "Disabled"))
end, false)

-- Export functions
exports('RefreshMenus', InitializeMenus)