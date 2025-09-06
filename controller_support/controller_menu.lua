-- Controller Menu Support
-- Provides controller-friendly menu navigation

local isControllerEnabled = false

-- Function to detect if controller is being used
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        -- Check if a controller is connected
        if IsInputDisabled(2) == false then
            -- Controller is connected
            if not isControllerEnabled then
                isControllerEnabled = true
                print("Controller detected")
                TriggerEvent("controller:connected")
            end
        else
            -- Controller is disconnected
            if isControllerEnabled then
                isControllerEnabled = false
                print("Controller disconnected")
                TriggerEvent("controller:disconnected")
            end
        end
    end
end)

-- Function to check if controller is currently enabled
function IsControllerEnabled()
    return isControllerEnabled
end

-- Export the function
exports('IsControllerEnabled', IsControllerEnabled)

-- Event handlers for controller connection/disconnection
AddEventHandler("controller:connected", function()
    -- Add your controller connected logic here
    ShowHelpNotification("Controller connected. Press ~INPUT_FRONTEND_PAUSE_ALTERNATE~ to open menu.")
end)

AddEventHandler("controller:disconnected", function()
    -- Add your controller disconnected logic here
    ShowHelpNotification("Controller disconnected. Using keyboard controls.")
end)

-- Helper function to show notifications
function ShowHelpNotification(text)
    BeginTextCommandDisplayHelp("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayHelp(0, false, true, -1)
end
