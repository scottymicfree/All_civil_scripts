-- Local variables
local currentDensitySettings = {
    pedDensity = Config.Traffic.normal.pedDensity,
    vehicleDensity = Config.Traffic.normal.vehicleDensity,
    randomVehicleDensity = Config.Traffic.normal.randomVehicleDensity,
    parkedVehicleDensity = Config.Traffic.normal.parkedVehicleDensity
}

-- Debug function
local function DebugPrint(message)
    if Config.Debug then
        print("[Realism] " .. message)
    end
end

-- Function to determine current traffic settings based on time
local function GetTrafficSettingsForCurrentTime()
    local hour = GetClockHours()
    
    -- Check morning rush hour
    if hour >= Config.Traffic.morningRush.timeStart and hour <= Config.Traffic.morningRush.timeEnd then
        return {
            pedDensity = Config.Traffic.morningRush.pedDensity,
            vehicleDensity = Config.Traffic.morningRush.vehicleDensity,
            randomVehicleDensity = Config.Traffic.morningRush.randomVehicleDensity,
            parkedVehicleDensity = Config.Traffic.morningRush.parkedVehicleDensity
        }
    end
    
    -- Check evening rush hour
    if hour >= Config.Traffic.eveningRush.timeStart and hour <= Config.Traffic.eveningRush.timeEnd then
        return {
            pedDensity = Config.Traffic.eveningRush.pedDensity,
            vehicleDensity = Config.Traffic.eveningRush.vehicleDensity,
            randomVehicleDensity = Config.Traffic.eveningRush.randomVehicleDensity,
            parkedVehicleDensity = Config.Traffic.eveningRush.parkedVehicleDensity
        }
    end
    
    -- Check late night
    if hour >= Config.Traffic.lateNight.timeStart or hour <= Config.Traffic.lateNight.timeEnd then
        return {
            pedDensity = Config.Traffic.lateNight.pedDensity,
            vehicleDensity = Config.Traffic.lateNight.vehicleDensity,
            randomVehicleDensity = Config.Traffic.lateNight.randomVehicleDensity,
            parkedVehicleDensity = Config.Traffic.lateNight.parkedVehicleDensity
        }
    end
    
    -- Default to normal daytime
    return {
        pedDensity = Config.Traffic.normal.pedDensity,
        vehicleDensity = Config.Traffic.normal.vehicleDensity,
        randomVehicleDensity = Config.Traffic.normal.randomVehicleDensity,
        parkedVehicleDensity = Config.Traffic.normal.parkedVehicleDensity
    }
end

-- Function to apply traffic density settings
local function ApplyTrafficDensity()
    -- Get settings for current time
    local settings = GetTrafficSettingsForCurrentTime()
    
    -- Apply settings
    SetPedDensityMultiplierThisFrame(settings.pedDensity)
    SetVehicleDensityMultiplierThisFrame(settings.vehicleDensity)
    SetRandomVehicleDensityMultiplierThisFrame(settings.randomVehicleDensity)
    SetParkedVehicleDensityMultiplierThisFrame(settings.parkedVehicleDensity)
    
    -- Update current settings
    currentDensitySettings = settings
end

-- Main thread for traffic density
Citizen.CreateThread(function()
    -- Wait for game to load
    Citizen.Wait(4000)
    
    DebugPrint("Traffic density system initialized")
    
    -- Main loop
    while Config.Traffic.enabled do
        -- Apply traffic density
        ApplyTrafficDensity()
        
        -- Wait for next update
        Citizen.Wait(Config.Traffic.updateInterval)
    end
end)

-- Thread for continuous density application (needed every frame)
Citizen.CreateThread(function()
    -- Wait for game to load
    Citizen.Wait(4000)
    
    -- Main loop
    while Config.Traffic.enabled do
        -- Apply current density settings every frame
        SetPedDensityMultiplierThisFrame(currentDensitySettings.pedDensity)
        SetVehicleDensityMultiplierThisFrame(currentDensitySettings.vehicleDensity)
        SetRandomVehicleDensityMultiplierThisFrame(currentDensitySettings.randomVehicleDensity)
        SetParkedVehicleDensityMultiplierThisFrame(currentDensitySettings.parkedVehicleDensity)
        
        -- Wait one frame
        Citizen.Wait(0)
    end
end)

-- Register command
RegisterCommand("traffic", function(source, args, rawCommand)
    if not args[1] then
        TriggerEvent("chat:addMessage", {
            color = {255, 255, 0},
            multiline = false,
            args = {"System", "Traffic density: Ped=" .. currentDensitySettings.pedDensity .. 
                    ", Vehicle=" .. currentDensitySettings.vehicleDensity}
        })
        return
    end
    
    local density = tonumber(args[1])
    if not density or density < 0 or density > 2 then
        TriggerEvent("chat:addMessage", {
            color = {255, 0, 0},
            multiline = false,
            args = {"System", "Invalid density. Use a value between 0.0 and 2.0"}
        })
        return
    end
    
    -- Override all density settings
    currentDensitySettings = {
        pedDensity = density,
        vehicleDensity = density,
        randomVehicleDensity = density,
        parkedVehicleDensity = density
    }
    
    TriggerEvent("chat:addMessage", {
        color = {255, 255, 0},
        multiline = false,
        args = {"System", "Traffic density set to " .. density}
    })
end, false)
