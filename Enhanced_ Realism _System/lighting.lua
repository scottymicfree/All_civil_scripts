-- Local variables
local currentTimecycle = Config.Lighting.timecycleModifier

-- Debug function
local function DebugPrint(message)
    if Config.Debug then
        print("[Realism] " .. message)
    end
end

-- Function to update lighting settings
local function UpdateLighting()
    -- Apply timecycle modifier
    SetTimecycleModifier(currentTimecycle)
    
    -- Set blackout state
    SetBlackout(Config.Lighting.blackoutEnabled)
    
    -- Set artificial lights state
    SetArtificialLightsState(Config.Lighting.artificialLightsState)
    
    -- Enhanced night lighting
    if Config.Environment.enhancedNightLighting then
        local hour = GetClockHours()
        
        -- Apply night-specific enhancements
        if hour >= 20 or hour <= 5 then
            SetTimecycleModifierStrength(0.8)
        else
            SetTimecycleModifierStrength(0.5)
        end
    end
end

-- Function to toggle blackout
function ToggleBlackout(state)
    if state ~= nil then
        Config.Lighting.blackoutEnabled = state
    else
        Config.Lighting.blackoutEnabled = not Config.Lighting.blackoutEnabled
    end
    
    SetBlackout(Config.Lighting.blackoutEnabled)
    DebugPrint("Blackout " .. (Config.Lighting.blackoutEnabled and "enabled" or "disabled"))
    
    return Config.Lighting.blackoutEnabled
end

-- Function to change timecycle modifier
function ChangeTimecycle(modifier)
    if modifier and modifier ~= "" then
        currentTimecycle = modifier
        SetTimecycleModifier(currentTimecycle)
        DebugPrint("Timecycle changed to: " .. modifier)
        return true
    end
    return false
end

-- Main thread for lighting
Citizen.CreateThread(function()
    -- Wait for game to load
    Citizen.Wait(2000)
    
    -- Initial update
    UpdateLighting()
    DebugPrint("Lighting system initialized")
    
    -- Main loop
    while Config.Lighting.enabled do
        -- Update lighting
        UpdateLighting()
        
        -- Wait for next update
        Citizen.Wait(Config.Lighting.updateInterval)
    end
end)

-- Register commands
RegisterCommand("blackout", function(source, args, rawCommand)
    local state = args[1] == "on" and true or args[1] == "off" and false or nil
    local result = ToggleBlackout(state)
    
    -- Notify player
    TriggerEvent("chat:addMessage", {
        color = {255, 255, 0},
        multiline = false,
        args = {"System", "Blackout " .. (result and "enabled" or "disabled")}
    })
end, false)

RegisterCommand("timecycle", function(source, args, rawCommand)
    if not args[1] then
        TriggerEvent("chat:addMessage", {
            color = {255, 255, 0},
            multiline = false,
            args = {"System", "Current timecycle: " .. currentTimecycle}
        })
        return
    end
    
    local result = ChangeTimecycle(args[1])
    
    -- Notify player
    if result then
        TriggerEvent("chat:addMessage", {
            color = {255, 255, 0},
            multiline = false,
            args = {"System", "Timecycle changed to: " .. args[1]}
        })
    else
        TriggerEvent("chat:addMessage", {
            color = {255, 0, 0},
            multiline = false,
            args = {"System", "Invalid timecycle modifier"}
        })
    end
end, false)
