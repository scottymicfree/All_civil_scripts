-- vMenu Prompt Fix for Civil Unrest RP
-- This script prevents the vMenu prompt from showing repeatedly

local isMenuOpen = false
local promptShown = false
local originalShowHelpText = nil

-- Wait for vMenu to load
CreateThread(function()
    -- Wait a bit for vMenu to initialize
             Wait(5000)
    
    -- Check if vMenu is running
    if GetResourceState('vMenu') ~= 'started' then
        print('[vMenu Fix] vMenu resource not found or not started')
        return
    end
    
    print('[vMenu Fix] Initializing vMenu prompt fix')
    
    -- Override the vMenu help text function if possible
    if ShowNotification then
        originalShowHelpText = ShowNotification
        ShowNotification = function(message)
            -- If it's the vMenu prompt, handle it specially
            if message and type(message) == 'string' and string.find(message, "Press M to open the menu") then
                if not promptShown then
                    originalShowHelpText(message)
                    promptShown = true
                    
                    -- Reset after 10 seconds to allow it to show again later if needed
                    Citizen.SetTimeout(10000, function()
                        promptShown = false
                    end)
                end
            else
                -- For all other notifications, just pass through
                originalShowHelpText(message)
            end
        end
        
        print('[vMenu Fix] Successfully overrode ShowNotification function')
    else
        print('[vMenu Fix] Could not find ShowNotification function to override')
    end
end)

-- Track menu state
CreateThread(function()
    while true do
                 Wait(500)
        
        -- Check if menu is visible
        if IsControlPressed(0, 244) or IsControlPressed(0, 177) then -- M key or BACKSPACE
            isMenuOpen = not isMenuOpen
            
            if isMenuOpen then
                promptShown = true
            else
                -- Reset prompt after menu closes
                Citizen.SetTimeout(2000, function()
                    promptShown = false
                end)
            end
        end
    end
end)

-- Alternative approach: Block the help text display
Citizen.CreateThread(function()
    while true do
                 Wait(0)
        
        -- This is a more aggressive approach that hides all help text when the menu is open
        if isMenuOpen then
            ClearAllHelpMessages()
            
            -- This prevents new help messages from appearing
            BeginTextCommandDisplayHelp("STRING")
            AddTextComponentSubstringPlayerName("")
            EndTextCommandDisplayHelp(0, false, false, -1)
        end
    end
end)

-- Register command to toggle the fix
RegisterCommand("vmenufix", function(source, args, rawCommand)
    if args[1] == "on" then
        promptShown = false
        TriggerEvent('chat:addMessage', {
            color = {0, 255, 0},
            multiline = false,
            args = {"vMenu Fix", "Fix enabled - prompt will show once"}
        })
    elseif args[1] == "off" then
        promptShown = true
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            multiline = false,
            args = {"vMenu Fix", "Fix disabled - prompt will show repeatedly"}
        })
    else
        TriggerEvent('chat:addMessage', {
            color = {255, 255, 0},
            multiline = false,
            args = {"vMenu Fix", "Usage: /vmenufix [on|off]"}
        })
    end
end, false)
