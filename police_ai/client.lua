-- =========================================================
-- [ client.lua ]
-- Handles client-side logic for the police NPC.
-- =========================================================

-- Global variables
local npcPed = nil
local additionalNPCs = {}
local isMenuOpen = false
local currentWantedLevel = 0
local playerHasLicense = false
local playerHasFines = false
local playerFines = {}
local inPoliceStation = false

-- Framework integration
local ESX = nil
local QBCore = nil

-- Initialize framework integration
Citizen.CreateThread(function()
    if Config.Integration.useESX then
        while ESX == nil do
            TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
            Wait(10)
        end
    elseif Config.Integration.useQBCore then
        QBCore = exports['qb-core']:GetCoreObject()
    end
end)

-- Debug function
local function DebugPrint(message)
    if Config.Debug then
        print("[Police NPC] " .. message)
    end
end

-- Create the police NPC on a separate thread
Citizen.CreateThread(function()
    -- Request and load the main NPC model
    RequestModel(GetHashKey(Config.NpcModel))
    while not HasModelLoaded(GetHashKey(Config.NpcModel)) do
        Wait(100)
    end

    -- Create the main NPC
    npcPed = CreatePed(4, GetHashKey(Config.NpcModel), Config.NpcCoords.x, Config.NpcCoords.y, Config.NpcCoords.z - 1.0, Config.NpcCoords.w, false, true)

    -- Make the NPC invincible and unmoveable
    SetEntityInvincible(npcPed, true)
    FreezeEntityPosition(npcPed, true)
    SetBlockingOfNonTemporaryEvents(npcPed, true)
    
    -- Set the NPC to use a standing scenario
    TaskStartScenarioInPlace(npcPed, "WORLD_HUMAN_STAND_MOBILE", 0, true)
    
    -- Create additional NPCs if configured
    for _, npcConfig in ipairs(Config.AdditionalNPCs) do
        -- Request and load the model
        RequestModel(GetHashKey(npcConfig.model))
        while not HasModelLoaded(GetHashKey(npcConfig.model)) do
            Wait(100)
        end
        
        -- Create the additional NPC
        local ped = CreatePed(4, GetHashKey(npcConfig.model), npcConfig.coords.x, npcConfig.coords.y, npcConfig.coords.z - 1.0, npcConfig.coords.w, false, true)
        
        -- Make the NPC invincible and unmoveable
        SetEntityInvincible(ped, true)
        FreezeEntityPosition(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        
        -- Set the NPC to use the configured scenario
        if npcConfig.scenario then
            TaskStartScenarioInPlace(ped, npcConfig.scenario, 0, true)
        end
        
        -- Add to our table of NPCs
        table.insert(additionalNPCs, ped)
    end
    
    -- Create station blip if enabled
    if Config.StationBlip.enable then
        local blip = AddBlipForCoord(Config.NpcCoords.x, Config.NpcCoords.y, Config.NpcCoords.z)
        SetBlipSprite(blip, Config.StationBlip.sprite)
        SetBlipColour(blip, Config.StationBlip.color)
        SetBlipScale(blip, Config.StationBlip.scale)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(Config.StationBlip.name)
        EndTextCommandSetBlipName(blip)
    end
    
    -- Register police station as an interior zone if integration is enabled
    if Config.Integration.interiorZoneManager then
        local success = pcall(function()
            exports["interior_zone_manager"]:RegisterInteriorZone(
                "Police Station",
                vector3(Config.NpcCoords.x, Config.NpcCoords.y, Config.NpcCoords.z),
                {
                    width = 30.0,
                    length = 30.0,
                    height = 10.0,
                    minZ = Config.NpcCoords.z - 5.0,
                    maxZ = Config.NpcCoords.z + 5.0,
                    type = "police",
                    showBlip = false,
                    interactions = {
                        {
                            label = "Report Crime",
                            value = "report_crime",
                            description = "File a report with the police"
                        },
                        {
                            label = "Check Wanted Status",
                            value = "check_wanted",
                            description = "Check if you have any warrants"
                        },
                        {
                            label = "Pay Fines",
                            value = "pay_fines",
                            description = "Pay any outstanding fines"
                        },
                        {
                            label = "Check Licenses",
                            value = "check_licenses",
                            description = "Check your license status"
                        }
                    }
                }
            )
        end)
        
        if success then
            DebugPrint("Registered police station with Interior Zone Manager")
        else
            DebugPrint("Failed to register with Interior Zone Manager")
        end
    end
end)

-- Main loop for interaction
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        -- Get player coordinates and calculate distance to the NPC
        local playerCoords = GetEntityCoords(PlayerPedId())
        local distance = #(playerCoords - vector3(Config.NpcCoords.x, Config.NpcCoords.y, Config.NpcCoords.z))

        -- Check if the player is within interaction distance
        if distance < Config.InteractionDistance and not isMenuOpen then
            -- Draw the interaction text
            DrawText3D(Config.NpcCoords.x, Config.NpcCoords.y, Config.NpcCoords.z + 1.0, "[E / →] Talk to Officer")

            -- Check for the 'E' key or right arrow key press to open menu
            if IsControlJustReleased(0, 38) or IsControlJustReleased(0, 175) then
                OpenPoliceMenu()
            end
        else
            -- If we're not near the NPC, we can wait longer between checks
            Citizen.Wait(500)
        end
    end
end)

-- Function to open the police interaction menu
function OpenPoliceMenu()
    isMenuOpen = true
    
    -- Check if Interior Zone Manager is available for menu
    if Config.Integration.interiorZoneManager then
        -- Use Interior Zone Manager's native menu system
        local interactions = {
            {
                label = "Report Crime",
                value = "report_crime",
                description = "File a report with the police"
            },
            {
                label = "Check Wanted Status",
                value = "check_wanted",
                description = "Check if you have any warrants"
            },
            {
                label = "Pay Fines",
                value = "pay_fines",
                description = "Pay any outstanding fines"
            },
            {
                label = "Check Licenses",
                value = "check_licenses",
                description = "Check your license status"
            },
            {
                label = "Leave",
                value = "leave",
                description = "End conversation"
            }
        }
        
        -- Create temporary zone for interaction
        local tempZone = {
            name = "Police Officer",
            type = "police",
            interactions = interactions
        }
        
        -- Show menu using Interior Zone Manager
        TriggerEvent("interior_zone_manager:showNativeMenu", tempZone)
        
        -- Handle interaction result
        RegisterNetEvent("interior_zone_manager:onInteraction")
        AddEventHandler("interior_zone_manager:onInteraction", function(action, zone)
            if zone.name == "Police Officer" then
                HandlePoliceInteraction(action)
            end
        end)
    else
        -- Fallback to basic interaction
        TriggerServerEvent("police:assist")
        
        -- Simple menu using native UI
        ShowNativePoliceMenu()
    end
end

-- Function to show a native police menu
function ShowNativePoliceMenu()
    -- Draw menu background
    Citizen.CreateThread(function()
        local menuActive = true
        local selected = 0
        local options = {
            "Report Crime",
            "Check Wanted Status",
            "Pay Fines",
            "Check Licenses",
            "Leave"
        }
        
        while menuActive do
            Citizen.Wait(0)
            
            -- Draw menu background
            DrawRect(0.5, 0.5, 0.3, 0.5, 0, 0, 0, 150)
            
            -- Draw title
            DrawText2D(0.5, 0.3, "Police Services", 0.7, 4)
            
            -- Draw menu items
            for i, option in ipairs(options) do
                local y = 0.35 + (i-1) * 0.05
                local color = (selected == i-1) and {255, 255, 255, 255} or {200, 200, 200, 255}
                DrawText2D(0.5, y, option, 0.4, 4, color)
            end
            
            -- Handle navigation
            if IsControlJustPressed(0, 172) then -- Up arrow
                selected = (selected - 1) % #options
                PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
            elseif IsControlJustPressed(0, 173) then -- Down arrow
                selected = (selected + 1) % #options
                PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
            elseif IsControlJustPressed(0, 176) then -- Enter key
                PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                
                -- Handle selection
                if selected == 0 then -- Report Crime
                    HandlePoliceInteraction("report_crime")
                elseif selected == 1 then -- Check Wanted Status
                    HandlePoliceInteraction("check_wanted")
                elseif selected == 2 then -- Pay Fines
                    HandlePoliceInteraction("pay_fines")
                elseif selected == 3 then -- Check Licenses
                    HandlePoliceInteraction("check_licenses")
                elseif selected == 4 then -- Leave
                    menuActive = false
                end
            elseif IsControlJustPressed(0, 177) then -- Backspace
                menuActive = false
                PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
            end
        end
        
        isMenuOpen = false
    end)
end

-- Function to handle police interaction
function HandlePoliceInteraction(action)
    if action == "report_crime" then
        TriggerServerEvent("police:reportCrime")
    elseif action == "check_wanted" then
        TriggerServerEvent("police:checkWanted")
    elseif action == "pay_fines" then
        TriggerServerEvent("police:getFines")
    elseif action == "check_licenses" then
        TriggerServerEvent("police:checkLicenses")
    elseif action == "leave" then
        -- Just close the menu
        isMenuOpen = false
    end
end

-- Function to draw 2D text on screen
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

-- Helper function to draw 3D text in the world
function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

-- Event handlers for server responses
RegisterNetEvent("police:showCrimeReportMenu")
AddEventHandler("police:showCrimeReportMenu", function(crimes)
    -- Show crime report menu
    Citizen.CreateThread(function()
        local menuActive = true
        local selected = 0
        
        while menuActive do
            Citizen.Wait(0)
            
            -- Draw menu background
            DrawRect(0.5, 0.5, 0.3, 0.5, 0, 0, 0, 150)
            
            -- Draw title
            DrawText2D(0.5, 0.3, "Report Crime", 0.7, 4)
            
            -- Draw menu items
            for i, crime in ipairs(crimes) do
                local y = 0.35 + (i-1) * 0.05
                local color = (selected == i-1) and {255, 255, 255, 255} or {200, 200, 200, 255}
                DrawText2D(0.5, y, crime, 0.4, 4, color)
            end
            
            -- Add back option
            local y = 0.35 + #crimes * 0.05
            local color = (selected == #crimes) and {255, 255, 255, 255} or {200, 200, 200, 255}
            DrawText2D(0.5, y, "Back", 0.4, 4, color)
            
            -- Handle navigation
            if IsControlJustPressed(0, 172) then -- Up arrow
                selected = (selected - 1) % (#crimes + 1)
                PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
            elseif IsControlJustPressed(0, 173) then -- Down arrow
                selected = (selected + 1) % (#crimes + 1)
                PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
            elseif IsControlJustPressed(0, 176) then -- Enter key
                PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                
                -- Handle selection
                if selected < #crimes then
                    TriggerServerEvent("police:submitCrimeReport", crimes[selected + 1])
                    menuActive = false
                else
                    -- Back option
                    menuActive = false
                    OpenPoliceMenu()
                end
            elseif IsControlJustPressed(0, 177) then -- Backspace
                menuActive = false
                OpenPoliceMenu()
                PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
            end
        end
    end)
end)

RegisterNetEvent("police:showFinesMenu")
AddEventHandler("police:showFinesMenu", function(fines)
    -- Show fines menu
    playerFines = fines
    
    if #fines == 0 then
        TriggerEvent("chat:addMessage", {
            args = { "[Officer]", "You don't have any outstanding fines." }
        })
        return
    end
    
    Citizen.CreateThread(function()
        local menuActive = true
        local selected = 0
        
        while menuActive do
            Citizen.Wait(0)
            
            -- Draw menu background
            DrawRect(0.5, 0.5, 0.3, 0.6, 0, 0, 0, 150)
            
            -- Draw title
            DrawText2D(0.5, 0.25, "Outstanding Fines", 0.7, 4)
            
            -- Draw menu items
            for i, fine in ipairs(fines) do
                local y = 0.3 + (i-1) * 0.05
                local color = (selected == i-1) and {255, 255, 255, 255} or {200, 200, 200, 255}
                DrawText2D(0.5, y, fine.name .. " - $" .. fine.amount, 0.4, 4, color)
                
                -- Draw description if selected
                if selected == i-1 then
                    DrawText2D(0.5, 0.55, fine.description, 0.35, 4, {180, 180, 180, 255})
                end
            end
            
            -- Add pay all option
            local y = 0.3 + #fines * 0.05
            local color = (selected == #fines) and {255, 255, 255, 255} or {200, 200, 200, 255}
            DrawText2D(0.5, y, "Pay All Fines", 0.4, 4, color)
            
            -- Add back option
            y = 0.3 + (#fines + 1) * 0.05
            color = (selected == #fines + 1) and {255, 255, 255, 255} or {200, 200, 200, 255}
            DrawText2D(0.5, y, "Back", 0.4, 4, color)
            
            -- Draw instructions
            DrawText2D(0.5, 0.65, "Press Enter to select, Backspace to return", 0.3, 4, {180, 180, 180, 255})
            
            -- Handle navigation
            if IsControlJustPressed(0, 172) then -- Up arrow
                selected = (selected - 1) % (#fines + 2)
                PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
            elseif IsControlJustPressed(0, 173) then -- Down arrow
                selected = (selected + 1) % (#fines + 2)
                PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
            elseif IsControlJustPressed(0, 176) then -- Enter key
                PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                
                -- Handle selection
                if selected < #fines then
                    -- Pay individual fine
                    TriggerServerEvent("police:payFine", fines[selected + 1].id)
                    menuActive = false
                elseif selected == #fines then
                    -- Pay all fines
                    TriggerServerEvent("police:payAllFines")
                    menuActive = false
                else
                    -- Back option
                    menuActive = false
                    OpenPoliceMenu()
                end
            elseif IsControlJustPressed(0, 177) then -- Backspace
                menuActive = false
                OpenPoliceMenu()
                PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
            end
        end
    end)
end)

RegisterNetEvent("police:showWantedStatus")
AddEventHandler("police:showWantedStatus", function(wantedLevel)
    currentWantedLevel = wantedLevel
    
    local statusMessages = {
        [0] = "You have no active warrants.",
        [1] = "You have minor infractions on record.",
        [2] = "You have outstanding warrants for your arrest.",
        [3] = "You are wanted by law enforcement. Surrender immediately.",
        [4] = "You are a high-priority target for law enforcement.",
        [5] = "MAXIMUM ALERT: You are extremely dangerous and wanted dead or alive."
    }
    
    TriggerEvent("chat:addMessage", {
        args = { "[Officer]", statusMessages[wantedLevel] }
    })
end)

RegisterNetEvent("police:showLicenseStatus")
AddEventHandler("police:showLicenseStatus", function(licenses)
    -- Show license status
    if #licenses == 0 then
        TriggerEvent("chat:addMessage", {
            args = { "[Officer]", "You don't have any licenses on record." }
        })
        return
    end
    
    local licenseMessage = "Your licenses: "
    for i, license in ipairs(licenses) do
        licenseMessage = licenseMessage .. license.name
        if i < #licenses then
            licenseMessage = licenseMessage .. ", "
        end
    end
    
    TriggerEvent("chat:addMessage", {
        args = { "[Officer]", licenseMessage }
    })
end)

-- Integration with Interior Zone Manager
if Config.Integration.interiorZoneManager then
    RegisterNetEvent("interior_zone_manager:enterZone")
    AddEventHandler("interior_zone_manager:enterZone", function(zone)
        if zone.type == "police" then
            inPoliceStation = true
            DebugPrint("Entered police station zone: " .. zone.name)
        end
    end)
    
    RegisterNetEvent("interior_zone_manager:exitZone")
    AddEventHandler("interior_zone_manager:exitZone", function(zone)
        if zone.type == "police" then
            inPoliceStation = false
            DebugPrint("Exited police station zone: " .. zone.name)
        end
    end)
end

-- Integration with Civil Disorder
if Config.Integration.civilDisorder then
    -- Register for gang activity notifications
    RegisterNetEvent("civil_disorder:gangActivityNearby")
    AddEventHandler("civil_disorder:gangActivityNearby", function(gangName, activityType, location)
        if inPoliceStation then
            TriggerEvent("chat:addMessage", {
                args = { "[Police Radio]", "Reports of " .. activityType .. " by " .. gangName .. " in the area." }
            })
        end
    end)
end

-- Resource cleanup
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        -- Delete all NPCs when resource stops
        if DoesEntityExist(npcPed) then
            DeleteEntity(npcPed)
        end
        
        for _, ped in ipairs(additionalNPCs) do
            if DoesEntityExist(ped) then
                DeleteEntity(ped)
            end
        end
    end
end)

print("[Police NPC] Client loaded.")
