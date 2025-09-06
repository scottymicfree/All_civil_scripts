-- Local variables
local isRadarHidden = false

-- Debug function
local function DebugPrint(message)
    if Config.Debug then
        print("[Realism] " .. message)
    end
end

-- Function to update radar visibility
local function UpdateRadarVisibility()
    -- Skip if auto-hide radar is disabled
    if not Config.UI.autoHideRadar then
        return
    end
    
    local playerPed = PlayerPedId()
    local shouldShowRadar = IsPedInAnyVehicle(playerPed, false)
    
    -- Update radar visibility if needed
    if shouldShowRadar ~= (not isRadarHidden) then
        DisplayRadar(shouldShowRadar)
        isRadarHidden = not shouldShowRadar
    end
end

-- Function to display time on screen
local function DisplayTimeOnScreen()
    -- Skip if time display is disabled
    if not Config.UI.showTimeDisplay then
        return
    end
    
    -- Get current time
    local hour = GetClockHours()
    local minute = GetClockMinutes()
    
    -- Format time string
    local timeString = string.format("%02d:%02d", hour, minute)
    
    -- Display time
    SetTextFont(4)
    SetTextScale(0.45, 0.45)
    SetTextColour(255, 255, 255, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(timeString)
    DrawText(0.015, 0.025)
end

-- Main thread for UI updates
Citizen.CreateThread(function()
    -- Wait for game to load
    Citizen.Wait(5000)
    
    DebugPrint("UI system initialized")
    
    -- Main loop for radar visibility
    while true do
        -- Update radar visibility
        UpdateRadarVisibility()
        
        -- Wait before next check
        Citizen.Wait(1000)
    end
end)

-- Thread for time display
Citizen.CreateThread(function()
    -- Wait for game to load
    Citizen.Wait(5000)
    
    -- Main loop for time display
    while Config.UI.showTimeDisplay do
        -- Display time
        DisplayTimeOnScreen()
        
        -- Wait one frame
        Citizen.Wait(0)
    end
end)

-- Register command
RegisterCommand("toggleradar", function(source, args, rawCommand)
    -- Toggle auto-hide radar
    Config.UI.autoHideRadar = not Config.UI.autoHideRadar
    
    -- Reset radar visibility
    DisplayRadar(true)
    isRadarHidden = false
    
    -- Notify player
    TriggerEvent("chat:addMessage", {
        color = {255, 255, 0},
        multiline = false,
        args = {"System", "Auto-hide radar " .. (Config.UI.autoHideRadar and "enabled" or "disabled")}
    })
end, false)
