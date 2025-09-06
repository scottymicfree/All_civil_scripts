-- Vehicle Customization System for Civil Unrest RP
-- Created by Randy Webb

-- Load data files
local colors = {}
local upgrades = {}
local vehicles = {}

-- Initialize system
Citizen.CreateThread(function()
    print("[Vehicle System] Initializing...")
    
    -- Wait for resources to load
    Citizen.Wait(1000)
    
    -- Register command handlers
    RegisterCommand("vehicle", handleVehicleCommand)
    RegisterCommand("v", handleVehicleCommand) -- Shorthand
    
    -- Register keybinds
    RegisterKeyMapping('vehicle repair', 'Repair Vehicle', 'keyboard', 'F3')
    
    print("[Vehicle System] Initialized successfully")
end)

-- Main vehicle spawning function
function SpawnVehicle(model, customization, persistent)
    -- Default values
    persistent = persistent or false
    customization = customization or {}
    
    -- Validate model
    if type(model) ~= "string" then
        print("[Vehicle System] Invalid vehicle model")
        return nil
    end
    
    -- Get hash and request model
    local modelHash = GetHashKey(model)
    RequestModel(modelHash)
    
    -- Wait for model to load with timeout
    local timeout = 0
    while not HasModelLoaded(modelHash) do
        timeout = timeout + 100
        citizen.Wait(100)
        
        if timeout > 5000 then
            print("[Vehicle System] Model load timeout: " .. model)
            return nil
        end
    end

    -- Get spawn position (offset from player)
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local heading = GetEntityHeading(playerPed)
    local forward = GetEntityForwardVector(playerPed)
    local x = coords.x + forward.x * 4.0
    local y = coords.y + forward.y * 4.0
    local z = coords.z
    
    -- Find ground Z coordinate
    local groundZ = 0
    local ground, newZ = GetGroundZFor_3dCoord(x, y, z, 0)
    if ground then
        groundZ = newZ + 0.5
    else
        groundZ = z
    end
    
    -- Create vehicle
    local vehicle = CreateVehicle(modelHash, x, y, groundZ, heading, true, false)
    
    -- Set player into vehicle
    SetPedIntoVehicle(playerPed, vehicle, -1)
    
    -- Apply customization if provided
    if customization then
        customizeVehicle(vehicle, customization)
    end
    
    -- Set as mission entity if persistent
    if persistent then
        SetEntityAsMissionEntity(vehicle, true, true)
    end
    
    -- Clean up
    SetModelAsNoLongerNeeded(modelHash)
    
    -- Notify
    showNotification("Vehicle spawned: " .. GetLabelText(GetDisplayNameFromVehicleModel(modelHash)))
    
    return vehicle
end

-- Apply a specific vehicle modification
function ApplyVehicleMod(vehicle, modType, mod)
    if not DoesEntityExist(vehicle) then return false end
    
    -- Ensure vehicle mod kit is applied
    SetVehicleModKit(vehicle, 0)
    
    -- Apply the mod based on type
    if type(mod) == "boolean" then
        ToggleVehicleMod(vehicle, modType, mod)
    else
        SetVehicleMod(vehicle, modType, mod, false)
    end
    
    return true
end

-- Apply full customization to a vehicle
function CustomizeVehicle(vehicle, options)
    if not DoesEntityExist(vehicle) then return false end
    
    -- Ensure vehicle mod kit is applied
    SetVehicleModKit(vehicle, 0)
    
    -- Apply colors
    if options.colors then
        if options.colors.primary then
            if options.colors.secondary then
                SetVehicleColours(vehicle, options.colors.primary, options.colors.secondary)
            else
                SetVehicleColours(vehicle, options.colors.primary, options.colors.primary)
            end
        end
        
        -- Apply extra color options
        if options.colors.pearlescent then
            local _, secondary = GetVehicleColours(vehicle)
            SetVehicleExtraColours(vehicle, options.colors.pearlescent, secondary)
        end
        
        if options.colors.wheel then
            local pearl, _ = GetVehicleExtraColours(vehicle)
            SetVehicleExtraColours(vehicle, pearl, options.colors.wheel)
        end
    end
    
    -- Apply performance upgrades
    if options.upgrades then
        for upgrade, level in pairs(options.upgrades) do
            if upgrades[upgrade] then
                local modType = upgrades[upgrade].type
                local modIndex = nil
                
                -- Find the mod index by name
                if type(level) == "string" and upgrades[upgrade].types[level] then
                    modIndex = upgrades[upgrade].types[level].index
                else
                    modIndex = level
                end
                
                -- Apply the mod
                ApplyVehicleMod(vehicle, modType, modIndex)
            end
        end
    end
    
    -- Apply xenon lights color
    if options.xenonColor then
        ToggleVehicleMod(vehicle, 22, true) -- Enable xenon lights
        SetVehicleXenonLightsColour(vehicle, options.xenonColor)
    end
    
    -- Apply extras
    if options.extras then
        for id, enabled in pairs(options.extras) do
            if DoesExtraExist(vehicle, id) then
                SetVehicleExtra(vehicle, id, enabled and 0 or 1)
            end
        end
    end
    
    -- Apply livery
    if options.livery then
        SetVehicleLivery(vehicle, options.livery)
    end
    
    -- Apply window tint
    if options.windowTint then
        SetVehicleWindowTint(vehicle, options.windowTint)
    end
    
    -- Apply neon lights
    if options.neon then
        if options.neon.enabled then
            for i = 0, 3 do
                SetVehicleNeonLightEnabled(vehicle, i, true)
            end
        end
        
        if options.neon.color then
            SetVehicleNeonLightsColour(vehicle, 
                options.neon.color[1] or 255, 
                options.neon.color[2] or 255, 
                options.neon.color[3] or 255
            )
        end
    end
    
    -- Apply plate
    if options.plate then
        if options.plate.text then
            SetVehicleNumberPlateText(vehicle, options.plate.text)
        end
        
        if options.plate.type then
            SetVehicleNumberPlateTextIndex(vehicle, options.plate.type)
        end
    end
    
    -- Fix vehicle
    SetVehicleFixed(vehicle)
    SetVehicleDirtLevel(vehicle, 0.0)
    
    return true
end

-- Command handler for vehicle commands
function HandleVehicleCommand(source, args, rawCommand)
    local category = args[1] or "help"
    
    if category == "spawn" then
        -- Spawn vehicle command
        local model = args[2]
        if not model then
            showNotification("Usage: /vehicle spawn [model]")
            return
        end
        
        -- Check if model exists in our vehicle list
        local validModel = false
        for _, category in pairs(vehicles) do
            for _, veh in ipairs(category) do
                if veh:lower() == model:lower() then
                    model = veh -- Use correct case
                    validModel = true
                    break
                end
            end
            if validModel then break end
        end
        
        if not validModel then
            -- Try to use the model name directly
            if not IsModelInCdimage(GetHashKey(model)) then
                showNotification("Invalid vehicle model: " .. model)
                return
            end
        end
        
        -- Spawn the vehicle
        local customization = {
            colors = {
                primary = colors.metal["Pure Gold"] or 158
            }
        }
        
        SpawnVehicle(model, customization, true)
        
    elseif category == "customize" or category == "custom" then
        -- Customize current vehicle
        local veh = GetVehiclePedIsIn(PlayerPedId(), false)
        if veh == 0 then
            showNotification("You must be in a vehicle to customize it")
            return
        end
        
        SetVehicleModKit(veh, 0)
        
        -- Apply best mods
        for modType = 0, 50, 1 do
            local bestMod = GetNumVehicleMods(veh, modType) - 1
            if bestMod >= 0 then
                SetVehicleMod(veh, modType, bestMod, false)
            end
        end
        
        -- Apply performance upgrades
        ApplyVehicleMod(veh, 11, 3) -- Engine
        ApplyVehicleMod(veh, 12, 2) -- Brakes
        ApplyVehicleMod(veh, 13, 2) -- Transmission
        ApplyVehicleMod(veh, 16, 4) -- Armor
        ApplyVehicleMod(veh, 18, true) -- Turbo
        
        -- Apply xenon lights
        ApplyVehicleMod(veh, 22, true)
        SetVehicleXenonLightsColour(veh, 1) -- Blue
        
        showNotification("Vehicle customized with best upgrades")
        
    elseif category == "repair" then
        -- Repair current vehicle
        local veh = GetVehiclePedIsIn(PlayerPedId(), false)
        if veh == 0 then
            showNotification("You must be in a vehicle to repair it")
            return
        end
        
        SetVehicleFixed(veh)
        SetVehicleEngineHealth(veh, 1000.0)
        SetVehicleDirtLevel(veh, 0.0)
        
        showNotification("Vehicle repaired")
        
    elseif category == "doors" then
        -- Toggle doors
        local veh = GetVehiclePedIsIn(PlayerPedId(), false)
        if veh == 0 then
            showNotification("You must be in a vehicle to control doors")
            return
        end
        
        local open = GetVehicleDoorAngleRatio(veh, 0) < 0.1
        if open then
            for i = 0, 7, 1 do
                SetVehicleDoorOpen(veh, i, false, false)
            end
            showNotification("Vehicle doors opened")
        else
            SetVehicleDoorsShut(veh, false)
            showNotification("Vehicle doors closed")
        end
        
    elseif category == "color" then
        -- Change vehicle color
        local veh = GetVehiclePedIsIn(PlayerPedId(), false)
        if veh == 0 then
            showNotification("You must be in a vehicle to change its color")
            return
        end
        
        local colorType = args[2] or "classic"
        local colorName = args[3] or "Red"
        
        local colorIndex = nil
        if colors[colorType] and colors[colorType][colorName] then
            colorIndex = colors[colorType][colorName]
        else
            colorIndex = 0 -- Default to black
        end
        
        SetVehicleColours(veh, colorIndex, colorIndex)
        showNotification("Vehicle color changed to " .. colorName)
        
    elseif category == "extras" then
        -- Toggle extras
        local veh = GetVehiclePedIsIn(PlayerPedId(), false)
        if veh == 0 then
            showNotification("You must be in a vehicle to toggle extras")
            return
        end
        
        local hasExtras = false
        for id = 0, 14 do
            if DoesExtraExist(veh, id) then
                hasExtras = true
                local isOn = IsVehicleExtraTurnedOn(veh, id)
                SetVehicleExtra(veh, id, isOn and 1 or 0)
                showNotification("Extra " .. id .. " toggled " .. (isOn and "off" or "on"))
            end
        end
        
        if not hasExtras then
            showNotification("This vehicle has no extras")
        end
        
    elseif category == "list" then
        -- List available vehicles by category
        local vehicleCategory = args[2] or "all"
        
        if vehicleCategory == "all" then
            local categories = {}
            for cat, _ in pairs(vehicles) do
                table.insert(categories, cat)
            end
            showNotification("Vehicle categories: " .. table.concat(categories, ", "))
            showNotification("Use /vehicle list [category] to see vehicles")
        elseif vehicles[vehicleCategory] then
            -- Show first 5 vehicles in category
            local vehList = {}
            for i = 1, math.min(5, #vehicles[vehicleCategory]) do
                table.insert(vehList, vehicles[vehicleCategory][i])
            end
            showNotification(vehicleCategory .. " vehicles: " .. table.concat(vehList, ", ") .. "...")
            showNotification("Total: " .. #vehicles[vehicleCategory] .. " vehicles in category")
        else
            showNotification("Invalid category: " .. vehicleCategory)
        end
        
    else
        -- Help command
        ShowNotification("Vehicle commands:")
        showNotification("/vehicle spawn [model] - Spawn a vehicle")
        showNotification("/vehicle customize - Apply best upgrades")
        showNotification("/vehicle repair - Fix your vehicle")
        showNotification("/vehicle doors - Toggle doors")
        showNotification("/vehicle color [type] [name] - Change color")
        showNotification("/vehicle extras - Toggle extras")
        showNotification("/vehicle list [category] - List vehicles")
    end
end

-- Helper function to show notifications
function ShowNotification(message)
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandThefeedPostTicker(true, false)
end

-- Load vehicle data files
Citizen.CreateThread(function()
    Citizen.Wait(500) -- Wait for resource to initialize
    
    -- Try to load data files
    local success = pcall(function()
        -- These files should be loaded automatically by the resource manifest
        -- But we'll check if they're loaded correctly
        if not colors or next(colors) == nil then
            print("[Vehicle System] Warning: Colors data not loaded")
        end
        
        if not upgrades or next(upgrades) == nil then
            print("[Vehicle System] Warning: Upgrades data not loaded")
        end
        
        if not vehicles or next(vehicles) == nil then
            print("[Vehicle System] Warning: Vehicles data not loaded")
        end
    end)
    
    if not success then
        print("[Vehicle System] Error loading data files")
    end
end)
