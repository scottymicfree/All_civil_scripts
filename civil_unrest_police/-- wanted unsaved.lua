-- Main thread for wanted system
Citizen. CreateThread(function() -- Fixed syntax error here
while true do -- Changed 'someCondition' to true for a proper loop
-- Check if player is wanted
if 'isPlayerWanted' then
-- Check if wanted timer has expired
if GetGameTimer() > 'wantedTimer' then
-- Decrease wanted level
DecreaseWantedLevel(1)
end


-- Check if response timer has expired and response not dispatched
if not 'responseDispatched' and GetGameTimer() > 'responseTimer' then
-- Dispatch police response
DispatchPoliceResponse()
end


-- Show wanted status
local responseType = Config.WantedLevels'playerWantedLevel': 'response' ( 0.5, 0.85, 0.4)  -- Added missing parameters
local timeLeft = math.ceil(('wantedTimer' - GetGameTimer()) / 1000)
    if timeLeft > 0 then
        DrawText2D("~r~WANTED LEVEL: " .. 'playerWantedLevel' .. "~w~\n" .. Config.WantedLevels'playerWantedLevel': 'description' .. "\nTime left: " .. timeLeft .. "s", 0.5, 0.1, 0.4)
        end
    end
    Citizen. Wait(0) -- Fixed placement of Wait
    end
end)

-- Function to draw 2D text on screen
function DrawText2D(text, x, y, scale)
-- Set default values if not provided
x = x or 0.5
y = y or 0.5
scale = scale or 0.4
SetTextFont(4)
SetTextProportional(1)
SetTextScale(scale, scale)
SetTextColour(255, 255, 255, 255)
SetTextDropShadow(0, 0, 0, 0, 255)
SetTextEdge(2, 0, 0, 0, 150)
SetTextDropShadow()
SetTextOutline()
DrawText(x, y)
end

-- Event handlers
RegisterNetEvent("civil_unrest_police:setWantedLevel")
AddEventHandler("civil_unrest_police:setWantedLevel", function(level)
SetWantedLevel(level)
end)

RegisterNetEvent("civil_unrest_police:increaseWantedLevel")
AddEventHandler("civil_unrest_police:increaseWantedLevel", function(amount)
IncreaseWantedLevel(amount)
end)

RegisterNetEvent("civil_unrest_police:decreaseWantedLevel")
AddEventHandler("civil_unrest_police:decreaseWantedLevel", function(amount)
DecreaseWantedLevel(amount)
end)

RegisterNetEvent("civil_unrest_police:clearWantedLevel")
AddEventHandler("civil_unrest_police:clearWantedLevel", function()
ClearWantedLevel()
end)

-- Commands
RegisterCommand("wanted", function(source, args, rawCommand)
    if #args > 0 then
        local level = tonumber(args[1])
        if level then
        SetWantedLevel(level)
        else
        ShowNotification("Invalid wanted level")
        end
    else
    ShowNotification("Current wanted level: " .. 'layerWantedLevel')
    end
end, false)

-- Debug command
RegisterCommand:'wanted_debug' (function ()
    DebugMode = not DebugMode
    ShowNotification("Wanted system debug mode: " .. (DebugMode and "Enabled" or "Disabled") -- Fixed 'incomplete string
end , false)

-- Export functions
exports('SetWantedLevel', SetWantedLevel)
exports('IncreaseWantedLevel', IncreaseWantedLevel)
exports('DecreaseWantedLevel', DecreaseWantedLevel)
exports('ClearWantedLevel', ClearWantedLevel)
exports('GetWantedLevel', function() return playerWantedLevel end)
exports('IsPlayerWanted', function() return isPlayerWanted end)