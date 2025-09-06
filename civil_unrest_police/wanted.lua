-- Police Wanted System
-- This script handles player wanted levels and police response

-- Configuration
local Config = {
    WantedLevels = {
        [0] = { response = "none", description = "Not wanted" },
        [1] = { response = "investigate", description = "Minor offense" },
        [2] = { response = "arrest", description = "Wanted for arrest" },
        [3] = { response = "lethal", description = "Armed and dangerous" }
    },
    ResponseTimes = {
        investigate = 60, -- seconds
        arrest = 30,      -- seconds
        lethal = 15       -- seconds
    },
    ResponseUnits = {
        investigate = 1,  -- number of units
        arrest = 2,       -- number of units
        lethal = 3        -- number of units
    }
}

-- Variables
local playerWantedLevel = 0
local isPlayerWanted = false
local wantedTimer = 0
local responseTimer = 0
local responseDispatched = false
local debugMode = false

-- Function to set player wanted level
function SetWantedLevel(level)
    -- Validate level
    if level < 0 then level = 0 end
    if level > 3 then level = 3 end
    
    -- Set wanted level
    playerWantedLevel = level
    
    -- Update wanted status
    isPlayerWanted = (level > 0)
    
    -- Reset timers
    if isPlayerWanted then
        wantedTimer = GetGameTimer() + (5 * 60 * 1000) -- 5 minutes wanted time
        responseTimer = GetGameTimer() + (Config.ResponseTimes[Config.WantedLevels[level].response] * 1000)
        responseDispatched = false
    else
        wantedTimer = 0
        responseTimer = 0
        responseDispatched = false
    end
    
    -- Notify player
    if isPlayerWanted then
        ShowNotification("~r~Wanted Level: " .. level .. "~w~\n" .. Config.WantedLevels[level].description)
    else
        ShowNotification("~g~No longer wanted by police")
    end
    
    -- Trigger event for other resources
    TriggerEvent("civil_unrest_police:wantedLevelChanged", playerWantedLevel)
    
    return playerWantedLevel
end

-- Function to increase player wanted level
function IncreaseWantedLevel(amount)
    amount = amount or 1
    return SetWantedLevel(playerWantedLevel + amount)
end

-- Function to decrease player wanted level
function DecreaseWantedLevel(amount)
    amount = amount or 1
    return SetWantedLevel(playerWantedLevel - amount)
end

-- Function to clear player wanted level
function ClearWantedLevel()
    return SetWantedLevel(0)
end

-- Function to dispatch police response
function DispatchPoliceResponse()
    -- Check if player is wanted
    if not isPlayerWanted then return false end
    
    -- Get response type
    local responseType = Config.WantedLevels[playerWantedLevel].response
    if responseType == "none" then return false end
    
    -- Get player position
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    -- Determine number of units
    local numUnits = Config.ResponseUnits[responseType]
    
    -- Spawn police units
    for i = 1, numUnits do
        -- Calculate spawn position (100-200 meters away from player)
        local distance = math.random(100, 200)
        local angle = math.random() * 2 * math.pi
        local spawnX = playerCoords.x + distance * math.cos(angle)
        local spawnY = playerCoords.y + distance * math.sin(angle)
        local spawnZ = playerCoords.z
        
        -- Get ground Z
        local ground, groundZ = GetGroundZFor_3dCoord(spawnX, spawnY, spawnZ + 100.0, 0)
        if ground then
            spawnZ = groundZ
        end
        
        local spawnCoords = vector3(spawnX, spawnY, spawnZ)
        
        -- Spawn police vehicle with officers
        local vehicle = exports['civil_unrest_police']:SpawnPoliceVehicle(spawnCoords, math.random(0, 359))
        
        if vehicle then
            -- Set vehicle as police response
            SetEntityAsMissionEntity(vehicle, true, true)
            
            -- Get driver
            local driver = GetPedInVehicleSeat(vehicle, -1)
            if driver and DoesEntityExist(driver) then
                -- Set driver as mission entity
                SetEntityAsMissionEntity(driver, true, true)
                
                -- Task driver to chase player
                TaskVehicleChase(driver, playerPed)
                SetTaskVehicleChaseBehaviorFlag(driver, 1, true) -- Aggressive
                
                -- Set driver combat attributes based on response type
                if responseType == "investigate" then
                    SetPedCombatAttributes(driver, 46, true) -- BF_CanFightArmedPedsWhenNotArmed
                    SetPedCombatAttributes(driver, 5, true) -- BF_FightDisabled
                elseif responseType == "arrest" then
                    SetPedCombatAttributes(driver, 46, true) -- BF_CanFightArmedPedsWhenNotArmed
                    SetPedCombatAttributes(driver, 5, false) -- BF_FightDisabled
                    TaskCombatPed(driver, playerPed, 0, 16)
                elseif responseType == "lethal" then
                    SetPedCombatAttributes(driver, 46, true) -- BF_CanFightArmedPedsWhenNotArmed
                    SetPedCombatAttributes(driver, 5, false) -- BF_FightDisabled
                    TaskCombatPed(driver, playerPed, 0, 16)
                    SetPedAccuracy(driver, 80)
                end
            end
            
            -- Get passenger
            local passenger = GetPedInVehicleSeat(vehicle, 0)
            if passenger and DoesEntityExist(passenger) then
                -- Set passenger as mission entity
                SetEntityAsMissionEntity(passenger, true, true)
                
                -- Set passenger combat attributes based on response type
                if responseType == "investigate" then
                    SetPedCombatAttributes(passenger, 46, true) -- BF_CanFightArmedPedsWhenNotArmed
                    SetPedCombatAttributes(passenger, 5, true) -- BF_FightDisabled
                elseif responseType == "arrest" then
                    SetPedCombatAttributes(passenger, 46, true) -- BF_CanFightArmedPedsWhenNotArmed
                    SetPedCombatAttributes(passenger, 5, false) -- BF_FightDisabled
                    TaskCombatPed(passenger, playerPed, 0, 16)
                elseif responseType == "lethal" then
                    SetPedCombatAttributes(passenger, 46, true) -- BF_CanFightArmedPedsWhenNotArmed
                    SetPedCombatAttributes(passenger, 5, false) -- BF_FightDisabled
                    TaskCombatPed(passenger, playerPed, 0, 16)
                    SetPedAccuracy(passenger, 80)
                end
            end
        end
    end
    
    -- Mark response as dispatched
    responseDispatched = true
    
    -- Notify player
    ShowNotification("~r~Police response dispatched: " .. responseType)
    
    if debugMode then
        print("Dispatched police response: " .. responseType .. " with " .. numUnits .. " units")
    end
    
    return true
end

-- Main thread for wanted system
Citizen.CreateThreadfunction()
    -- Fix:
while 'someCondition' do
    -- your code
    Wait(0)  -- Add this to prevent freezing
end
 -- Check if player is wanted
 if isPlayerWanted then
    -- Check if wanted timer has expired
    if GetGameTimer() > wantedTimer then
     -- Decrease wanted level
    DecreaseWantedLevel(1)
end

 -- Check if response timer has expired and response not dispatched
     if not responseDispatched and GetGameTimer() > responseTimer then
     -- Dispatch police response
     DispatchPoliceResponse()
 end
            
-- Show wanted status
    local responseType = Config.WantedLevels[playerWantedLevel].response
    local timeLeft = math.ceil((wantedTimer - GetGameTimer()) / 1000)

        if timeLeft > 0 then
        DrawText2D("~r~WANTED LEVEL: " .. playerWantedLevel .. "~w~\n" .. Config.WantedLevels[playerWantedLevel].description .. "\nTime left: " .. timeLeft .. "s", 0.5, 0.1, 0.4)
            end
        endCitizen.Wait(0)
    end
end

-- Function to draw 2D text on screen
function DrawText2D(text, x, y, scale)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextScale(scale, scale)
    SetTextColour(255, 255, 255, 255)
    SetTextDropShadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextDropShadow()
    SetTextOutline()
    SetEntityVisible(ped, true)


    SetTextEntry("STRING")
    AddTextComponentString(text)
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
        ShowNotification("Current wanted level: " .. playerWantedLevel)
    end
end, false)

-- Debug command
RegisterCommand("wanted_debug", function()
    debugMode = not debugMode
    ShowNotification("Wanted system debug mode: " .. (debugMode and "Enabled" or "Disabled"))
end, false)

-- Export functions
exports('SetWantedLevel', SetWantedLevel)
exports('IncreaseWantedLevel', IncreaseWantedLevel)
exports('DecreaseWantedLevel', DecreaseWantedLevel)
exports('ClearWantedLevel', ClearWantedLevel)
exports('GetWantedLevel', function() return playerWantedLevel end)
exports('IsPlayerWanted', function() return isPlayerWanted end)