-- Interior Zone Manager Client Script
local interiorZones = {}
local activeZone = nil
local previousZone = nil
local playerInZone = false
local blips = {}
local isMenuActive = false

-- Debug function
local function DebugPrint(message)
    if Config.Debug then
        print("[Interior Zone Manager] " .. message)
    end
end

-- Function to create a zone blip
local function CreateZoneBlip(zone)
    if not zone.showBlip then return end
    
    local zoneType = Config.ZoneTypes[zone.type] or {}
    
    local blip = AddBlipForCoord(zone.center.x, zone.center.y, zone.center.z)
    SetBlipSprite(blip, zone.blipSprite or zoneType.blipSprite or Config.DefaultZoneSettings.blipSprite)
    SetBlipColour(blip, zone.blipColor or zoneType.blipColor or Config.DefaultZoneSettings.blipColor)
    SetBlipScale(blip, zone.blipScale or zoneType.blipScale or Config.DefaultZoneSettings.blipScale)
    SetBlipAsShortRange(blip, true)
    
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(zone.blipName or zoneType.blipName or zone.name or Config.DefaultZoneSettings.blipName)
    EndTextCommandSetBlipName(blip)
    
    return blip
end

-- Function to check if player is in a zone
local function IsPlayerInZone(zone)
    local playerCoords = GetEntityCoords(PlayerPedId())
    
    -- Box zone check (width, length, height)
    if zone.width and zone.length then
        local halfWidth = zone.width / 2
        local halfLength = zone.length / 2
        local minZ = zone.minZ or (zone.center.z - (zone.height or 10.0) / 2)
        local maxZ = zone.maxZ or (zone.center.z + (zone.height or 10.0) / 2)
        
        -- Check if player is within the box boundaries
        return (
            playerCoords.x >= zone.center.x - halfWidth and
            playerCoords.x <= zone.center.x + halfWidth and
            playerCoords.y >= zone.center.y - halfLength and
            playerCoords.y <= zone.center.y + halfLength and
            playerCoords.z >= minZ and
            playerCoords.z <= maxZ
        )
    end
    
    -- Circle zone check (radius)
    if zone.radius then
        local distance = #(playerCoords - zone.center)
        local minZ = zone.minZ or (zone.center.z - (zone.height or 10.0) / 2)
        local maxZ = zone.maxZ or (zone.center.z + (zone.height or 10.0) / 2)
        
        -- Check if player is within the circle boundaries
        return (
            distance <= zone.radius and
            playerCoords.z >= minZ and
            playerCoords.z <= maxZ
        )
    end
    
    return false
end

-- Function to check if player has access to a zone
local function HasZoneAccess(zone)
    if not zone.allowedJobs and not (Config.ZoneTypes[zone.type] and Config.ZoneTypes[zone.type].allowedJobs) then
        return true -- No job restrictions
    end
    
    local allowedJobs = zone.allowedJobs or (Config.ZoneTypes[zone.type] and Config.ZoneTypes[zone.type].allowedJobs)
    if not allowedJobs then return true end
    
    -- Get player job (replace with your framework's job getter)
    local playerJob = nil
    
    -- Try to get job from standalone-framework
    local success, result = pcall(function()
        return exports["standalone-framework"]:GetPlayerJob()
    end)
    
    if success then
        playerJob = result
    else
        -- Fallback to default job if framework call fails
        playerJob = "civilian"
        DebugPrint("Failed to get player job: " .. tostring(result))
    end
    
    for _, job in ipairs(allowedJobs) do
        if playerJob == job then
            return true
        end
    end
    
    return false
end

-- Function to show notification
local function ShowNotification(message)
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandThefeedPostTicker(true, false)
end

-- Function to register a new interior zone
function RegisterInteriorZone(name, center, options)
    if not name or not center then
        DebugPrint("Failed to register zone: Missing required parameters")
        return false
    end
    
    -- Check if zone already exists
    for i, zone in ipairs(interiorZones) do
        if zone.name == name then
            DebugPrint("Zone '" .. name .. "' already exists, updating it")
            interiorZones[i] = {
                name = name,
                center = center,
                width = options.width,
                length = options.length,
                height = options.height or 10.0,
                radius = options.radius,
                minZ = options.minZ,
                maxZ = options.maxZ,
                type = options.type or "generic",
                subType = options.subType,
                showBlip = options.showBlip,
                blipSprite = options.blipSprite,
                blipColor = options.blipColor,
                blipScale = options.blipScale,
                blipName = options.blipName or name,
                allowedJobs = options.allowedJobs,
                data = options.data or {},
                interactions = options.interactions or {}
            }
            
            -- Update blip if it exists
            if blips[name] then
                RemoveBlip(blips[name])
                blips[name] = CreateZoneBlip(interiorZones[i])
            end
            
            return true
        end
    end
    
    -- Create new zone
    local newZone = {
        name = name,
        center = center,
        width = options.width,
        length = options.length,
        height = options.height or 10.0,
        radius = options.radius,
        minZ = options.minZ,
        maxZ = options.maxZ,
        type = options.type or "generic",
        subType = options.subType,
        showBlip = options.showBlip,
        blipSprite = options.blipSprite,
        blipColor = options.blipColor,
        blipScale = options.blipScale,
        blipName = options.blipName or name,
        allowedJobs = options.allowedJobs,
        data = options.data or {},
        interactions = options.interactions or {}
    }
    
    table.insert(interiorZones, newZone)
    
    -- Create blip if needed
    if newZone.showBlip then
        blips[name] = CreateZoneBlip(newZone)
    end
    
    DebugPrint("Registered new zone: " .. name)
    return true
end

-- Function to get active zone at position
function GetActiveZoneAtPosition(position)
    position = position or GetEntityCoords(PlayerPedId())
    
    for _, zone in ipairs(interiorZones) do
        -- Box zone check
        if zone.width and zone.length then
            local halfWidth = zone.width / 2
            local halfLength = zone.length / 2
            local minZ = zone.minZ or (zone.center.z - (zone.height or 10.0) / 2)
            local maxZ = zone.maxZ or (zone.center.z + (zone.height or 10.0) / 2)
            
            if (
                position.x >= zone.center.x - halfWidth and
                position.x <= zone.center.x + halfWidth and
                position.y >= zone.center.y - halfLength and
                position.y <= zone.center.y + halfLength and
                position.z >= minZ and
                position.z <= maxZ
            ) then
                return zone
            end
        end
        
        -- Circle zone check
        if zone.radius then
            local distance = #(position - zone.center)
            local minZ = zone.minZ or (zone.center.z - (zone.height or 10.0) / 2)
            local maxZ = zone.maxZ or (zone.center.z + (zone.height or 10.0) / 2)
            
            if (
                distance <= zone.radius and
                position.z >= minZ and
                position.z <= maxZ
            ) then
                return zone
            end
        end
    end
    
    return nil
end

-- Function to draw text on screen
function DrawText2D(x, y, text, scale, font, color)
    color = color or {255, 255, 255, 255}
    SetTextFont(font or 4)
    SetTextScale(scale, scale)
    SetTextColour(color[1], color[2], color[3], color[4])
    SetTextDropShadow()
    SetTextOutline()
    SetTextCentre(true)
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(x, y)
end

-- Function to draw rectangle on screen
function DrawRect2D(x, y, width, height, r, g, b, a)
    DrawRect(x, y, width, height, r, g, b, a)
end

-- Function to show native menu
function ShowNativeMenu(zone)
    -- Generate menu items based on zone type
    local elements = {}
    local zoneType = zone.type
    
    -- Add type-specific interactions
    if zoneType == "police" then
        table.insert(elements, {label = "Request Information", value = "police_info", desc = "Ask for information"})
        table.insert(elements, {label = "File a Report", value = "police_report", desc = "File a police report"})
        table.insert(elements, {label = "Check Criminal Records", value = "police_records", desc = "Look up criminal records"})
    elseif zoneType == "hospital" then
        table.insert(elements, {label = "Request Treatment", value = "hospital_treatment", desc = "Ask for medical treatment"})
        table.insert(elements, {label = "Check In", value = "hospital_checkin", desc = "Check in to the hospital"})
        table.insert(elements, {label = "Medical Insurance", value = "hospital_insurance", desc = "Check your medical insurance"})
    elseif zoneType == "shop" then
        table.insert(elements, {label = "Browse Items", value = "shop_browse", desc = "Look at available items"})
        table.insert(elements, {label = "Ask for Assistance", value = "shop_help", desc = "Get help from staff"})
    elseif zoneType == "residential" then
        table.insert(elements, {label = "Enter Apartment", value = "residential_enter", desc = "Go to your apartment"})
        table.insert(elements, {label = "Check Mail", value = "residential_mail", desc = "Check your mailbox"})
    elseif zoneType == "office" then
        table.insert(elements, {label = "Enter Office", value = "office_enter", desc = "Go to your office"})
        table.insert(elements, {label = "Schedule Meeting", value = "office_meeting", desc = "Schedule a business meeting"})
    elseif zoneType == "entertainment" then
        table.insert(elements, {label = "Buy Tickets", value = "entertainment_tickets", desc = "Purchase event tickets"})
        table.insert(elements, {label = "View Schedule", value = "entertainment_schedule", desc = "Check event schedule"})
    end
    
    -- Add custom interactions from zone definition
    if zone.interactions and #zone.interactions > 0 then
        for _, interaction in ipairs(zone.interactions) do
            table.insert(elements, {
                label = interaction.label,
                value = interaction.value or interaction.label:lower():gsub(" ", "_"),
                desc = interaction.description or ""
            })
        end
    end
    
    -- Add exit option
    table.insert(elements, {label = "Exit", value = "exit", desc = "Close the menu"})
    
    -- Show menu
    local selected = 0
    isMenuActive = true
    
    -- Menu loop
    Citizen.CreateThread(function()
        while isMenuActive do
            Citizen.Wait(0)
            
            -- Disable controls while menu is active
            DisableControlAction(0, 1, true) -- LookLeftRight
            DisableControlAction(0, 2, true) -- LookUpDown
            DisableControlAction(0, 142, true) -- MeleeAttackAlternate
            DisableControlAction(0, 18, true) -- Enter
            DisableControlAction(0, 322, true) -- ESC
            DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
            
            -- Draw menu background
            DrawRect2D(0.5, 0.5, 0.3, 0.5, 0, 0, 0, 180)
            
            -- Draw title
            DrawRect2D(0.5, 0.28, 0.3, 0.05, 0, 102, 255, 220)
            DrawText2D(0.5, 0.28, zone.name, 0.5, 4)
            
            -- Draw subtitle
            DrawText2D(0.5, 0.33, "~b~" .. (zone.type:gsub("^%l", string.upper) .. " Interactions"), 0.4, 4)
            
            -- Draw menu items
            local startY = 0.38
            local itemHeight = 0.035
            local maxDisplay = 8
            local startIndex = 0
            
            -- Calculate start index for scrolling
            if #elements > maxDisplay and selected >= maxDisplay then
                startIndex = selected - maxDisplay + 1
            end
            
            for i = 1, math.min(maxDisplay, #elements) do
                local index = i + startIndex
                if elements[index] then
                    local item = elements[index]
                    local y = startY + (i-1) * itemHeight
                    
                    -- Draw selection highlight
                    if selected == index-1 then
                        DrawRect2D(0.5, y, 0.29, itemHeight, 255, 255, 255, 80)
                    end
                    
                    -- Draw item text
                    local textColor = (selected == index-1) and {255, 255, 255, 255} or {200, 200, 200, 255}
                    DrawText2D(0.5, y, item.label, 0.35, 4, textColor)
                    
                    -- Draw description for selected item
                    if selected == index-1 and item.desc and item.desc ~= "" then
                        DrawRect2D(0.5, 0.68, 0.29, 0.05, 0, 0, 0, 180)
                        DrawText2D(0.5, 0.68, item.desc, 0.3, 4, {180, 180, 180, 255})
                    end
                end
            end
            
            -- Draw scroll indicators
            if #elements > maxDisplay then
                if startIndex > 0 then
                    DrawText2D(0.5, startY - itemHeight, "↑", 0.4, 4)
                end
                if startIndex + maxDisplay < #elements then
                    DrawText2D(0.5, startY + maxDisplay * itemHeight, "↓", 0.4, 4)
                end
            end
            
            -- Draw controls help
            DrawRect2D(0.5, 0.73, 0.29, 0.03, 0, 0, 0, 180)
            DrawText2D(0.5, 0.73, "↑/↓: Navigate   Enter: Select   Backspace: Exit", 0.25, 4, {180, 180, 180, 255})
            
            -- Handle navigation
            if IsControlJustPressed(0, 172) then -- Up arrow
                PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                selected = (selected - 1) % #elements
            elseif IsControlJustPressed(0, 173) then -- Down arrow
                PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                selected = (selected + 1) % #elements
            elseif IsControlJustPressed(0, 176) then -- Enter key
                local selectedItem = elements[selected + 1]
                if selectedItem.value == "exit" then
                    isMenuActive = false
                    PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                else
                    -- Handle interaction
                    HandleInteraction(selectedItem.value, zone)
                    isMenuActive = false
                    PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                end
            elseif IsControlJustPressed(0, 177) then -- Backspace
                isMenuActive = false
                PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
            end
        end
    end)
end

-- Function to handle menu interactions
function HandleInteraction(action, zone)
    -- Trigger server event for the interaction
    TriggerServerEvent("interior_zone_manager:interaction", action, zone.name)
    
    -- Handle client-side feedback
    if action == "police_info" then
        ShowNotification("You requested information from the police station")
    elseif action == "police_report" then
        ShowNotification("You filed a police report")
    elseif action == "police_records" then
        ShowNotification("You requested access to criminal records")
    elseif action == "hospital_treatment" then
        ShowNotification("You requested medical treatment")
    elseif action == "hospital_checkin" then
        ShowNotification("You checked in to the hospital")
    elseif action == "hospital_insurance" then
        ShowNotification("You inquired about medical insurance")
    elseif action == "shop_browse" then
        ShowNotification("You browsed the shop items")
    elseif action == "shop_help" then
        ShowNotification("You asked for assistance from staff")
    elseif action == "residential_enter" then
        ShowNotification("Entering your apartment...")
    elseif action == "residential_mail" then
        ShowNotification("Checking your mailbox...")
    elseif action == "office_enter" then
        ShowNotification("Entering your office...")
    elseif action == "office_meeting" then
        ShowNotification("You scheduled a business meeting")
    elseif action == "entertainment_tickets" then
        ShowNotification("You purchased event tickets")
    elseif action == "entertainment_schedule" then
        ShowNotification("You checked the event schedule")
    end
    
    -- Trigger client event for other resources
    TriggerEvent("interior_zone_manager:onInteraction", action, zone)
end

-- Initialize zones from config
Citizen.CreateThread(function()
    -- Register pre-defined zones from config
    for _, zone in ipairs(Config.InteriorZones) do
        RegisterInteriorZone(
            zone.name,
            zone.center,
            {
                width = zone.width,
                length = zone.length,
                height = zone.height,
                radius = zone.radius,
                minZ = zone.minZ,
                maxZ = zone.maxZ,
                type = zone.type,
                subType = zone.subType,
                showBlip = zone.showBlip,
                blipSprite = zone.blipSprite,
                blipColor = zone.blipColor,
                blipScale = zone.blipScale,
                blipName = zone.blipName,
                allowedJobs = zone.allowedJobs,
                data = zone.data,
                interactions = zone.interactions
            }
        )
    end
    
    DebugPrint("Initialized " .. #interiorZones .. " interior zones")
end)

-- Main thread for zone checking
Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local isInAnyZone = false
        local closestZone = nil
        local closestDistance = 9999.0
        
        -- Check all zones
        for _, zone in ipairs(interiorZones) do
            if IsPlayerInZone(zone) then
                isInAnyZone = true
                
                -- Calculate distance to zone center
                local distance = #(playerCoords - zone.center)
                
                -- Track closest zone
                if distance < closestDistance then
                    closestDistance = distance
                    closestZone = zone
                end
            end
        end
        
        -- Handle zone changes
        if closestZone ~= activeZone then
            previousZone = activeZone
            activeZone = closestZone
            
            -- Exiting previous zone
            if previousZone and Config.Notifications.showEnterExit then
                ShowNotification("Exiting: " .. previousZone.name)
                TriggerEvent("interior_zone_manager:exitZone", previousZone)
                TriggerServerEvent("interior_zone_manager:exitZone", previousZone.name)
            end
            
            -- Entering new zone
            if activeZone then
                local hasAccess = HasZoneAccess(activeZone)
                
                if Config.Notifications.showEnterExit then
                    ShowNotification("Entering: " .. activeZone.name)
                end
                
                if not hasAccess and Config.Notifications.showJobRestricted then
                    ShowNotification("~r~This area is restricted")
                end
                
                TriggerEvent("interior_zone_manager:enterZone", activeZone, hasAccess)
                TriggerServerEvent("interior_zone_manager:enterZone", activeZone.name, hasAccess)
            end
        end
        
        -- Update player in zone status
        if isInAnyZone ~= playerInZone then
            playerInZone = isInAnyZone
            TriggerEvent("interior_zone_manager:playerZoneStatusChanged", playerInZone, activeZone)
        end
        
        -- Adjust wait time based on whether player is in a zone
        if isInAnyZone then
            Citizen.Wait(500) -- Check more frequently when in a zone
        else
            Citizen.Wait(1000) -- Check less frequently when not in a zone
        end
    end
end)

-- Thread for interaction prompt
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        -- Only show prompt if player is in a zone and not in a menu
        if activeZone and not isMenuActive then
            -- Show interaction prompt
            BeginTextCommandDisplayHelp("STRING")
            AddTextComponentSubstringPlayerName("Press ~INPUT_CONTEXT~ to interact with " .. activeZone.name)
            EndTextCommandDisplayHelp(0, false, true, -1)
            
            -- Check for E key press (context key)
            if IsControlJustReleased(0, 38) then -- 38 is E key
                ShowNativeMenu(activeZone)
            end
            
            -- Check for controller button press (D-pad Up)
            if IsControlJustReleased(0, 172) then -- 172 is D-pad Up
                ShowNativeMenu(activeZone)
            end
        else
            -- If not in a zone or in a menu, wait longer to save resources
            Citizen.Wait(500)
        end
    end
end)

-- Debug command to show current zone
RegisterCommand("checkzone", function()
    local zone = GetActiveZoneAtPosition()
    if zone then
        ShowNotification("Current zone: " .. zone.name .. " (" .. zone.type .. ")")
    else
        ShowNotification("Not in any interior zone")
    end
end, false)

-- Command to open interaction menu
RegisterCommand("zoneinteract", function()
    if activeZone then
        ShowNativeMenu(activeZone)
    else
        ShowNotification("You are not in any interaction zone")
    end
end, false)

-- Register key mapping for keyboard users
RegisterKeyMapping("zoneinteract", "Interact with Zone", "keyboard", "E")

-- Event handlers
AddEventHandler("interior_zone_manager:enterZone", function(zone, hasAccess)
    DebugPrint("Entered zone: " .. zone.name .. ", Access: " .. tostring(hasAccess))
end)

AddEventHandler("interior_zone_manager:exitZone", function(zone)
    DebugPrint("Exited zone: " .. zone.name)
end)

-- Register net events
RegisterNetEvent("interior_zone_manager:syncZones")
AddEventHandler("interior_zone_manager:syncZones", function(zones)
    -- Clear existing zones
    for name, blip in pairs(blips) do
        RemoveBlip(blip)
    end
    blips = {}
    
    -- Update with synced zones
    interiorZones = zones
    
    -- Recreate blips
    for _, zone in ipairs(interiorZones) do
        if zone.showBlip then
            blips[zone.name] = CreateZoneBlip(zone)
        end
    end
    
    DebugPrint("Synced " .. #interiorZones .. " zones from server")
end)

-- Event for getting player position (used by server commands)
RegisterNetEvent("interior_zone_manager:getPlayerPosition")
AddEventHandler("interior_zone_manager:getPlayerPosition", function(callback)
    local position = GetEntityCoords(PlayerPedId())
    TriggerServerEvent("interior_zone_manager:returnPlayerPosition", position)
end)
