-- Mechanic Garage System for Civil Unrest RP
-- Client-side script

local menuPool = nil
local mainMenu = nil
local isMenuOpen = false
local currentGarage = nil
local isInMarker = false
local hasAlreadyEnteredMarker = false
local lastGarage = nil
local isProcessingPayment = false

-- Debug function
local function debugPrint(message)
    if Config.Debug then
        print("^3[MECHANIC DEBUG] " .. message .. "^7")
    end
end

-- Initialize NativeUI if enabled
Citizen.CreateThread(function()
    if Config.UseNativeUI then
        if not NativeUI then
            print("^1ERROR: NativeUI not found. Make sure it's installed and loaded before mechanic_garages.^7")
            return
        end
        
        menuPool = NativeUI.CreatePool()
        debugPrint("NativeUI initialized")
    end
    
    -- Create blips
    CreateGarageBlips()
    
    debugPrint("Mechanic garages initialized")
end)

-- Create blips for all garages
function CreateGarageBlips()
    if not Config.UseBlips then 
        debugPrint("Blips disabled in config")
        return 
    end
    
    for _, garage in pairs(Config.Garages) do
        debugPrint("Creating blip for " .. garage.name)
        local blip = AddBlipForCoord(garage.position.x, garage.position.y, garage.position.z)
        SetBlipSprite(blip, garage.blip.sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, garage.blip.scale)
        SetBlipColour(blip, garage.blip.color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(garage.blip.name)
        EndTextCommandSetBlipName(blip)
        debugPrint("Blip created for " .. garage.name)
    end
end

-- Check if player is a mechanic
function IsPlayerMechanic()
    local success, result = pcall(function()
        if exports['standalone-framework'] then
            return exports['standalone-framework']:GetPlayerJob() == Config.MechanicJobName
        end
        return false
    end)
    
    if not success then
        debugPrint("Error checking mechanic job: " .. tostring(result))
        return false
    end
    
    return result
end

-- Calculate repair cost with possible discount
function CalculateRepairCost(basePrice)
    local finalPrice = basePrice
    
    -- Apply mechanic discount if player is a mechanic
    if IsPlayerMechanic() then
        finalPrice = finalPrice * Config.MechanicDiscount
    end
    
    return math.floor(finalPrice)
end

-- Create repair menu using NativeUI
function CreateRepairMenu(garage)
    if not Config.UseNativeUI then
        -- Use vMenu's built-in menu system instead
        TriggerEvent("vmenu:openVehicleMenu")
        return
    end
    
    if not menuPool then
        debugPrint("Error: menuPool is nil. NativeUI may not be loaded.")
        ShowNotification("~r~Error loading menu system. Please try again.")
        return
    end
    
    menuPool = NativeUI.CreatePool()
    mainMenu = NativeUI.CreateMenu(garage.name, "~b~Vehicle Services")
    menuPool:Add(mainMenu)
    
    -- Check if player is in a vehicle
    local playerPed = PlayerPedId()
    if not IsPedInAnyVehicle(playerPed, false) then
        local noVehicleItem = NativeUI.CreateItem("No Vehicle", "You must be in a vehicle to use the garage services")
        mainMenu:AddItem(noVehicleItem)
        menuPool:RefreshIndex()
        mainMenu:Visible(true)
        return
    end
    
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    
    -- Repair options submenu
    local repairSubmenu = menuPool:AddSubMenu(mainMenu, "Repair Options", "~b~Fix your vehicle")
    
    for _, option in ipairs(Config.RepairOptions) do
        local price = CalculateRepairCost(option.price)
        local item = NativeUI.CreateItem(option.name, option.description)
        item:RightLabel("$" .. price)
        repairSubmenu:AddItem(item)
        
        item.Activated = function(sender, index)
            if Config.EnablePayment then
                TriggerServerEvent("mechanic_garages:requestRepair", option.action, price)
                isProcessingPayment = true
            else
                ProcessRepair(option.action)
            end
            mainMenu:Visible(false)
        end
    end
    
    -- Customization options submenu
    local customSubmenu = menuPool:AddSubMenu(mainMenu, "Customization Options", "~b~Customize your vehicle")
    
    for _, option in ipairs(Config.CustomizationOptions) do
        local price = CalculateRepairCost(option.price)
        local item = NativeUI.CreateItem(option.name, option.description)
        item:RightLabel("$" .. price)
        customSubmenu:AddItem(item)
        
        item.Activated = function(sender, index)
            if Config.EnablePayment then
                TriggerServerEvent("mechanic_garages:requestCustomization", option.action, price)
                isProcessingPayment = true
            else
                ProcessCustomization(option.action)
            end
            mainMenu:Visible(false)
        end
    end
    
    -- Exit garage option
    local exitItem = NativeUI.CreateItem("Exit Garage", "Leave the garage")
    mainMenu:AddItem(exitItem)
    exitItem.Activated = function(sender, index)
        mainMenu:Visible(false)
    end
    
    menuPool:RefreshIndex()
    mainMenu:Visible(true)
    isMenuOpen = true
end

-- Process repair based on selected option
function ProcessRepair(repairType)
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    
    if not DoesEntityExist(vehicle) then
        ShowNotification("~r~Vehicle not found")
        return
    end
    
    -- Start repair animation
    ShowNotification("~y~Mechanics are working on your vehicle...")
    
    -- Play repair animation
    FreezeEntityPosition(vehicle, true)
    
    -- Different repair types
    if repairType == "basic_repair" then
        -- Basic repair animation and sound
        PlaySoundFromEntity(-1, "Drill_Pin_Break", vehicle, "DLC_HEIST_FLEECA_SOUNDSET", 1, 0)
        
        Citizen.Wait(5000) -- 5 seconds repair time
        
        -- Fix engine and body damage
        SetVehicleEngineHealth(vehicle, 1000.0)
        SetVehicleBodyHealth(vehicle, 1000.0)
        
    elseif repairType == "full_repair" then
        -- Full repair animation and sound
        PlaySoundFromEntity(-1, "Drill_Pin_Break", vehicle, "DLC_HEIST_FLEECA_SOUNDSET", 1, 0)
        
        Citizen.Wait(8000) -- 8 seconds repair time
        
        -- Fix everything
        SetVehicleFixed(vehicle)
        SetVehicleDeformationFixed(vehicle)
        SetVehicleUndriveable(vehicle, false)
        
    elseif repairType == "wash" then
        -- Wash animation and sound
        PlaySoundFromEntity(-1, "Splash_Water", vehicle, "DLC_Apt_Yacht_Ambient_Soundset", 1, 0)
        
        Citizen.Wait(3000) -- 3 seconds wash time
        
        -- Clean vehicle
        SetVehicleDirtLevel(vehicle, 0.0)
    end
    
    FreezeEntityPosition(vehicle, false)
    ShowNotification("~g~Vehicle service completed!")
end

-- Process customization based on selected option
function ProcessCustomization(customType)
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    
    if not DoesEntityExist(vehicle) then
        ShowNotification("~r~Vehicle not found")
        return
    end
    
    if customType == "performance" then
        -- Open performance customization menu
        TriggerEvent("vmenu:openVehiclePerformanceMenu")
        
    elseif customType == "cosmetic" then
        -- Open cosmetic customization menu
        TriggerEvent("vmenu:openVehicleCosmeticMenu")
        
    elseif customType == "full_customize" then
        -- Open full customization menu
        TriggerEvent("vmenu:openVehicleCustomizationMenu")
    end
end

-- Check if player is in a garage marker
function IsPlayerInGarageMarker()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    for i, garage in pairs(Config.Garages) do
        local distance = #(playerCoords - garage.position)
        
        if distance < 3.0 then
            currentGarage = garage
            return true
        end
    end
    
    return false
end

-- Draw markers for all garages
function DrawGarageMarkers()
    if not Config.UseMarkers then return end
    
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    for _, garage in pairs(Config.Garages) do
        local distance = #(playerCoords - garage.position)
        
        if distance < 50.0 then
            DrawMarker(
                garage.marker.type,
                garage.position.x, garage.position.y, garage.position.z - 0.95,
                0.0, 0.0, 0.0,
                0.0, 0.0, 0.0,
                garage.marker.size.x, garage.marker.size.y, garage.marker.size.z,
                garage.marker.color.r, garage.marker.color.g, garage.marker.color.b, garage.marker.color.a,
                false, true, 2, false, nil, nil, false
            )
        end
    end
end

-- Show notification
function ShowNotification(message)
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandThefeedPostTicker(true, false)
end

-- Main thread for marker and menu handling
Citizen.CreateThread(function()
    -- Wait for resources to initialize
    Citizen.Wait(1000)
    
    while true do
        local sleep = 500
        
        -- Process menus if open
        if Config.UseNativeUI and menuPool and isMenuOpen then
            menuPool:ProcessMenus()
            sleep = 0
        end
        
        -- Draw markers
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local nearMarker = false
        
        for _, garage in pairs(Config.Garages) do
            local distance = #(playerCoords - garage.position)
            
            if distance < 50.0 then
                nearMarker = true
                
                if Config.UseMarkers then
                    DrawMarker(
                        garage.marker.type,
                        garage.position.x, garage.position.y, garage.position.z - 0.95,
                        0.0, 0.0, 0.0,
                        0.0, 0.0, 0.0,
                        garage.marker.size.x, garage.marker.size.y, garage.marker.size.z,
                        garage.marker.color.r, garage.marker.color.g, garage.marker.color.b, garage.marker.color.a,
                        false, true, 2, false, nil, nil, false
                    )
                end
                
                if distance < 3.0 then
                    sleep = 0
                    
                    -- Check if mechanic is required
                    if garage.mechanicRequired and not IsPlayerMechanic() then
                        -- Don't show prompt for non-mechanics
                    else
                        -- Show prompt
                        if not isMenuOpen and not isProcessingPayment then
                            DisplayHelpTextThisFrame("Press ~INPUT_CONTEXT~ to access the garage services", false)
                            
                            -- Check for interaction
                            if IsControlJustReleased(0, 38) then
                                if garage.mechanicRequired and not IsPlayerMechanic() then
                                    ShowNotification("~r~Only mechanics can use this garage")
                                else
                                    CreateRepairMenu(garage)
                                end
                            end
                        end
                    end
                    
                    -- Update current garage
                    currentGarage = garage
                else
                    -- If we were in this garage but now we're not
                    if currentGarage == garage and isMenuOpen then
                        if Config.UseNativeUI and mainMenu then
                            mainMenu:Visible(false)
                            isMenuOpen = false
                        end
                    end
                end
            end
        end
        
        -- Optimize wait time
        if nearMarker then
            Citizen.Wait(0)
        else
            Citizen.Wait(sleep)
        end
    end
end)

-- Event handlers
RegisterNetEvent('mechanic_garages:repairApproved')
AddEventHandler('mechanic_garages:repairApproved', function(repairType)
    isProcessingPayment = false
    ProcessRepair(repairType)
end)

RegisterNetEvent('mechanic_garages:customizationApproved')
AddEventHandler('mechanic_garages:customizationApproved', function(customType)
    isProcessingPayment = false
    ProcessCustomization(customType)
end)

RegisterNetEvent('mechanic_garages:paymentDeclined')
AddEventHandler('mechanic_garages:paymentDeclined', function()
    isProcessingPayment = false
    ShowNotification("~r~Payment declined. Insufficient funds.")
end)

-- Command to open nearest garage menu
RegisterCommand("garage", function()
    if currentGarage then
        if currentGarage.mechanicRequired and not IsPlayerMechanic() then
            ShowNotification("~r~Only mechanics can use this garage")
        else
            CreateRepairMenu(currentGarage)
        end
    else
        ShowNotification("~r~You are not near a garage")
    end
end, false)

-- Command to teleport to a garage (for testing)
RegisterCommand("gotogarage", function(source, args)
    if Config.Debug then
        local garageIndex = tonumber(args[1]) or 1
        
        if Config.Garages[garageIndex] then
            local garage = Config.Garages[garageIndex]
            local playerPed = PlayerPedId()
            
            SetEntityCoords(playerPed, garage.position.x, garage.position.y, garage.position.z, false, false, false, false)
            ShowNotification("Teleported to " .. garage.name)
        else
            ShowNotification("Invalid garage index. Available: 1-" .. #Config.Garages)
        end
    else
        ShowNotification("This command is only available in debug mode")
    end
end, false)

-- Command to toggle debug mode
RegisterCommand("mechanic_debug", function()
    Config.Debug = not Config.Debug
    ShowNotification("Debug mode: " .. (Config.Debug and "~g~Enabled" or "~r~Disabled"))
end, false)
