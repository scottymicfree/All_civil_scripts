-- Local variables
local isTimeFrozen = Config.Time.freezeTime

-- Debug function
local function DebugPrint(message)
    if Config.Debug then
        print("[Realism] " .. message)
    end
end

-- Function to sync time with server time
local function SyncWithServerTime()
    -- Get server time
    local year, month, day, hour, minute, second = GetUtcTime()
    
    -- Set game time
    NetworkOverrideClockTime(hour, minute, second)
    
    DebugPrint("Time synced with server: " .. hour .. ":" .. minute)
end

-- Function to freeze time
local function FreezeTimeAtHour(hour, minute)
    -- Set game time
    NetworkOverrideClockTime(hour, minute, 0)
    
    DebugPrint("Time frozen at " .. hour .. ":" .. minute)
end

-- Function to set time scale
local function SetGameTimeScale(scale)
    -- Set time scale
    SetTimeScale(scale)
    
    DebugPrint("Time scale set to " .. scale)
end

-- Main thread for time management
Citizen.CreateThread(function()
    -- Wait for game to load
    Citizen.Wait(6000)
    
    -- Set initial time scale
    SetGameTimeScale(Config.Time.timeScale)
    
    -- Initial time setup
    if Config.Time.freezeTime then
        FreezeTimeAtHour(Config.Time.frozenHour, Config.Time.frozenMinute)
    elseif Config.Time.syncWithServerTime then
        SyncWithServerTime()
    end
    
    DebugPrint("Time system initialized")
    
    -- Main loop
    while true do
        -- Update time
        if Config.Time.freezeTime then
            FreezeTimeAtHour(Config.Time.frozenHour, Config.Time.frozenMinute)
        elseif Config.Time.syncWithServerTime then
            SyncWithServerTime()
        end
        
        -- Wait before next update
        Citizen.Wait(60000) -- Update every minute
    end
end)

-- Register commands
RegisterCommand("freezetime", function(source, args, rawCommand)
    -- Toggle time freeze
    isTimeFrozen = not isTimeFrozen
    Config.Time.freezeTime = isTimeFrozen
    
    -- Get hour and minute
    local hour = tonumber(args[1]) or GetClockHours()
    local minute = tonumber(args[2]) or GetClockMinutes()
    
    -- Update config
    Config.Time.frozenHour = hour
    Config.Time.frozenMinute = minute
    
    -- Apply time freeze
    if isTimeFrozen then
        FreezeTimeAtHour(hour, minute)
    end
    
    -- Notify player
    TriggerEvent("chat:addMessage", {
        color = {255, 255, 0},
        multiline = false,
        args = {"System", "Time freeze " .. (isTimeFrozen and "enabled at " .. hour .. ":" .. minute or "disabled")}
    })
end, false)

RegisterCommand("timescale", function(source, args, rawCommand)
    if not args[1] then
        TriggerEvent("chat:addMessage", {
            color = {255, 255, 0},
            multiline = false,
            args = {"System", "Current time scale: " .. Config.Time.timeScale}
        })
        return
    end
    
    local scale = tonumber(args[1])
    if not scale or scale < 0.1 or scale > 10.0 then
        TriggerEvent("chat:addMessage", {
            color = {255, 0, 0},
            multiline = false,
            args = {"System", "Invalid time scale. Use a value between 0.1 and 10.0"}
        })
        return
    end
    
    -- Update config
    Config.Time.timeScale = scale
    
    -- Apply time scale
    SetGameTimeScale(scale)
    
    -- Notify player
    TriggerEvent("chat:addMessage", {
        color = {255, 255, 0},
        multiline = false,
        args = {"System", "Time scale set to " .. scale}
    })
end, false)
