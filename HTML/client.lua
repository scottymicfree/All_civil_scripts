print("[HTML-RESOURCE] Client loaded.")

-- Variable to track UI state
local uiVisible = false

-- Function to toggle UI visibility
function ToggleUI(visible, message)
    uiVisible = visible
    
    -- Set NUI focus (allows mouse interaction with UI)
    SetNuiFocus(visible, visible)
    
    -- Send message to UI
    SendNUIMessage({
        type = visible and 'showUI' or 'hideUI',
        message = message or "Hello from Lua!"
    })
    
    -- Debug output
    print("[HTML-RESOURCE] UI " .. (visible and "shown" or "hidden"))
end

-- Register command to show UI
RegisterCommand("showui", function(source, args, rawCommand)
    -- Get optional message from command arguments
    local message = args[1] and table.concat(args, " ") or "Hello from Lua!"
    
    -- Show UI
    ToggleUI(true, message)
end, false)

-- Register command to hide UI
RegisterCommand("hideui", function(source, args, rawCommand)
    ToggleUI(false)
end, false)

-- Listen for NUI callback to close UI
RegisterNUICallback('closeUI', function(data, cb)
    ToggleUI(false)
    cb('ok')
end)

-- Listen for NUI callback for other actions
RegisterNUICallback('action', function(data, cb)
    print("[HTML-RESOURCE] Received action: " .. json.encode(data))
    
    -- Example: Trigger server event
    if data.type == "serverEvent" then
        TriggerServerEvent('ui:serverEvent', data)
    end
    
    -- Example: Show notification
    if data.type == "notification" then
        -- Use native notification
        BeginTextCommandThefeedPost("STRING")
        AddTextComponentSubstringPlayerName(data.message or "Notification from UI")
        EndTextCommandThefeedPostTicker(true, false)
    end
    
    cb('ok')
end)

-- Thread to handle ESC key to close UI
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        -- Check if UI is visible and ESC key is pressed
        if uiVisible and IsControlJustReleased(0, 200) then -- 200 is ESC key
            ToggleUI(false)
        end
    end
end)
