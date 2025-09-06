-- UI System
-- Handles user interface elements

-- Store active UI elements
local activeUIs = {}

-- Show help text with fade in/out
function ShowHelpText(text, duration)
duration = duration or 5000
    -- Clear any existing help text
    ClearAllHelpMessages()
    -- Show new help text
    BeginTextCommandDisplayHelp("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayHelp(0, false, true, duration / 1000)
    return true
end

-- Show floating marker
function ShowMarker(type, coords, size, color, bobUpAndDown)
    local markerId = "marker_" .. math.random(100000)
    -- Store marker data
    activeUIs[markerId] = {
    type = "marker",
    coords = coords,
    markerType = type or 1,
    size = size or vector3(1.0, 1.0, 1.0),
    color = color or {r = 255, g = 255, b = 255, a = 100},
    bobUpAndDown = bobUpAndDown or false
    }
    return markerId
end

-- Remove UI element
function RemoveUI(id)
    if activeUIs[id] then
        activeUIs[id] = nil
        return true
    end
    return false
end

-- Draw all active UI elements
CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local hasActiveUI = false
        -- Process all active UI elements
        for id, data in pairs(activeUIs) do
            if data.type == "marker" then
                -- Only draw markers within 50 units
                local dist = #(playerCoords - data.coords)
                if dist < 50.0 then
                hasActiveUI = true
                DrawMarker(
                data.markerType,
                data.coords.x, data.coords.y, data.coords.z,
                0.0, 0.0, 0.0,
                0.0, 0.0, 0.0,
                data.size.x, data.size.y, data.size.z,
                data.color.r, data.color.g, data.color.b, data.color.a,
                false, data.bobUpAndDown, 2, false, nil, nil, false
                )
                end
            end
        end
        -- Optimize wait time based on active UI elements
        if hasActiveUI then
        Wait(0)
        else
        Wait(500)
        end
    end
end)