-- Main Controller Support Script
-- Provides controller-friendly UI and controls

-- Configuration
local config = {
    enableControllerSupport = true,
    enableControllerPrompts = true,
    enableControllerVibration = true,
    enableControllerAim = true
}

-- Initialize controller support
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        if config.enableControllerSupport then
            -- Improve controller aiming
            if config.enableControllerAim and not IsInputDisabled(2) then
                -- Slightly increase aim assist for controllers
                SetPlayerLockon(PlayerId(), true)
                SetPlayerLockonRangeOverride(PlayerId(), 25.0)
            end
            
            -- Add controller-specific controls here
            
            -- Only run this code when necessary
            if IsInputDisabled(2) then -- If using keyboard
                Citizen.Wait(1000) -- Check less frequently
            end
        else
            Citizen.Wait(1000) -- Check less frequently if disabled
        end
    end
end)

-- Function to provide controller vibration feedback
function VibrateController(duration, intensity)
    if config.enableControllerVibration and not IsInputDisabled(2) then
        duration = duration or 500
        intensity = intensity or 1.0
        
        -- Set controller vibration
        SetControlNormal(0, 81, intensity) -- Left motor
        SetControlNormal(0, 82, intensity) -- Right motor
        
        -- Reset vibration after duration
        Citizen.SetTimeout(duration, function()
            SetControlNormal(0, 81, 0.0)
            SetControlNormal(0, 82, 0.0)
        end)
    end
end

-- Export functions
exports('VibrateController', VibrateController)

-- Register commands
RegisterCommand("controllerconfig", function(source, args, rawCommand)
    -- Toggle controller support settings
    if args[1] == "toggle" then
        config.enableControllerSupport = not config.enableControllerSupport
        TriggerEvent("chat:addMessage", {
            color = {255, 255, 0},
            multiline = true,
            args = {"Controller Support", "Controller support " .. (config.enableControllerSupport and "enabled" or "disabled")}
        })
    elseif args[1] == "vibration" then
        config.enableControllerVibration = not config.enableControllerVibration
        TriggerEvent("chat:addMessage", {
            color = {255, 255, 0},
            multiline = true,
            args = {"Controller Support", "Controller vibration " .. (config.enableControllerVibration and "enabled" or "disabled")}
        })
    elseif args[1] == "aim" then
        config.enableControllerAim = not config.enableControllerAim
        TriggerEvent("chat:addMessage", {
            color = {255, 255, 0},
            multiline = true,
            args = {"Controller Support", "Controller aim assist " .. (config.enableControllerAim and "enabled" or "disabled")}
        })
    else
        -- Show help
        TriggerEvent("chat:addMessage", {
            color = {255, 255, 0},
            multiline = true,
            args = {"Controller Support", "Available commands: /controllerconfig toggle, /controllerconfig vibration, /controllerconfig aim"}
        })
    end
end, false)

-- Print initialization message
print("Controller support initialized")
