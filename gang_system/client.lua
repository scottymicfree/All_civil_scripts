-- Gang NPC System
-- This script manages gang NPCs, territories, and interactions

-- Load configuration from config.lua
local gangSpawns = {}
local gangCooldowns = {}
local playerGang = nil
local isInGangZone = false
local currentGangZone = nil
local debugMode = Config.DebugMode or false

-- Function to load player gang from framework
function LoadPlayerGang()
    local success, result = pcall(function()
        return exports['standalone-framework']:GetPlayerGang()
    end)
    
    if success then
        playerGang = result
        return playerGang
    else
        print("[Gang System] Error loading player gang: " .. tostring(result))
        return nil
    end
end

-- Function to check if it's the right time for a gang to be active
function IsGangActiveTime(gang)
    if not gang or not gang.hours then return true end
    
    local hour = GetClockHours()
    local start = gang.hours.start
    local stop = gang.hours.stop
    
    if start < stop then
        -- Simple range (e.g., 10 to 18)
        return hour >= start and hour < stop
    else
        -- Overnight range (e.g., 20 to 4)
        return hour >= start or hour < stop
    end
end

-- Function to spawn gang NPC
function SpawnGangNPC(gangId)
    if gangCooldowns[gangId] and gangCooldowns[gangId] > GetGameTimer() then
        return -- Still on cooldown
    end
    
    local gangData = nil
    
    -- Try to get gang data from Config first
    if Config.Gangs and Config.Gangs[gangId] then
        gangData = Config.Gangs[gangId]
    end
    
    if not gangData then
        if debugMode then
            print("[Gang System] No data found for gang: " .. gangId)
        end
        return
    end
    
    -- Load model
    local modelHash = nil
    local modelName = nil
    
    -- Try to get model from gang data
    if gangData.model then
        modelName = gangData.model
    else
        -- Default models by gang type
        local defaultModels = {
            ballas = "g_m_y_ballasout_01",
            vagos = "g_m_y_mexgoon_01",
            families = "g_m_y_famca_01",
            biker = "g_m_y_lost_01"
        }
        
        modelName = defaultModels[gangId] or "a_m_y_skater_01"
    end
    
    modelHash = GetHashKey(modelName)
    RequestModel(modelHash)
    
    local timeout = 5000
    local startTime = GetGameTimer()
    while not HasModelLoaded(modelHash) do
        if GetGameTimer() - startTime > timeout then
            if debugMode then
                print("[Gang System] Failed to load model for gang: " .. gangId)
            end
            return
        end
        Citizen.Wait(100)
    end
    
    -- Determine spawn position
    local spawnPos = nil
    
    if gangData.spawnPoint then
        spawnPos = gangData.spawnPoint
    elseif gangData.territory and gangData.territory.center then
        spawnPos = gangData.territory.center
    else
        if debugMode then
            print("[Gang System] No spawn point found for gang: " .. gangId)
        end
        return
    end
    
    -- Spawn NPC
    local ped = CreatePed(4, modelHash, spawnPos.x, spawnPos.y, spawnPos.z, 0.0, true, false)
    
    if not ped or not DoesEntityExist(ped) then
        if debugMode then
            print("[Gang System] Failed to create ped for gang: " .. gangId)
        end
        return
    end
    
    -- Give weapon if specified
    local weapons = {
        ballas = "WEAPON_PISTOL",
        vagos = "WEAPON_MICROSMG",
        families = "WEAPON_BAT",
        biker = "WEAPON_SAWNOFFSHOTGUN"
    }
    
    local weapon = weapons[gangId] or "WEAPON_PISTOL"
    GiveWeaponToPed(ped, GetHashKey(weapon), 100, false, true)
    
    -- Set behavior
    TaskStartScenarioInPlace(ped, "WORLD_HUMAN_STAND_IMPATIENT", 0, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedCanBeTargetted(ped, true)
    
    -- Store spawn data
    table.insert(gangSpawns, {
        gang = gangId,
        ped = ped,
        spawnTime = GetGameTimer()
    })
    
    -- Set cooldown for next spawn
    gangCooldowns[gangId] = GetGameTimer() + math.random(240000, 420000) -- 4-7 minutes
    
    if debugMode then
        print("[Gang System] Spawned NPC for gang: " .. gangId)
    end
    
    -- Return the ped
    return ped
end

-- Function to clean up old gang NPCs
function CleanupGangNPCs()
    local currentTime = GetGameTimer()
    local newSpawns = {}
    
    for i, spawn in ipairs(gangSpawns) do
        -- Check if NPC still exists and isn't too old (30 minutes)
        if DoesEntityExist(spawn.ped) and (currentTime - spawn.spawnTime) < 1800000 then
            table.insert(newSpawns, spawn)
        else
            -- Delete the ped if it exists
            if DoesEntityExist(spawn.ped) then
                DeleteEntity(spawn.ped)
            end
            
            if debugMode then
                print("[Gang System] Cleaned up NPC for gang: " .. spawn.gang)
            end
        end
    end
    
    gangSpawns = newSpawns
end

-- Function to handle gang NPC interaction
function InteractWithGangNPC(ped)
    -- Find which gang this NPC belongs to
    local gangType = nil
    for i, spawn in ipairs(gangSpawns) do
        if spawn.ped == ped then
            gangType = spawn.gang
            break
        end
    end
    
    if not gangType or not Config.Gangs[gangType] then
        ShowNotification("You can't interact with this NPC")
        return
    end
    
    local gangData = Config.Gangs[gangType]
    
    -- Show dialogue
    local dialogues = {
        "What do you want?",
        "This is our turf.",
        "You looking for trouble?"
    }
    local dialogue = dialogues[math.random(1, #dialogues)]
    ShowNotification(gangData.name .. ": " .. dialogue)
    
    -- Check if player is in the same gang
    local playerGang = LoadPlayerGang()
    if playerGang == gangType then
        -- Show gang member options
        TriggerEvent("gang_system:showMemberOptions", gangType, gangData)
    else
        -- Show non-member options
        TriggerEvent("gang_system:showNonMemberOptions", gangType, gangData)
    end
end

-- Event handler for showing gang member options
RegisterNetEvent("gang_system:showMemberOptions")
AddEventHandler("gang_system:showMemberOptions", function(gangType, gangData)
    -- Create menu using NativeUI
    local menuPool = NativeUI.CreatePool()
    local mainMenu = NativeUI.CreateMenu(gangData.name, "~b~Gang Member Options")
    menuPool:Add(mainMenu)
    
    -- Add mission options
    local missionsMenu = menuPool:AddSubMenu(mainMenu, "Gang Missions")
    
    -- Low difficulty mission
    local lowMissionItem = NativeUI.CreateItem("Low Risk Mission", "Easy mission with small reward")
    missionsMenu:AddItem(lowMissionItem)
    lowMissionItem.Activated = function(sender, item)
        TriggerEvent("gang_system:startMission", gangType, "low")
        mainMenu:Visible(false)
    end
    
    -- Medium difficulty mission
    local midMissionItem = NativeUI.CreateItem("Medium Risk Mission", "Moderate mission with decent reward")
    missionsMenu:AddItem(midMissionItem)
    midMissionItem.Activated = function(sender, item)
        TriggerEvent("gang_system:startMission", gangType, "mid")
        mainMenu:Visible(false)
    end
    
    -- High difficulty mission
    local highMissionItem = NativeUI.CreateItem("High Risk Mission", "Difficult mission with large reward")
    missionsMenu:AddItem(highMissionItem)
    highMissionItem.Activated = function(sender, item)
        TriggerEvent("gang_system:startMission", gangType, "high")
        mainMenu:Visible(false)
    end
    
    -- Add backup options
    local backupItem = NativeUI.CreateItem("Request Backup", "Call gang members for backup")
    mainMenu:AddItem(backupItem)
    backupItem.Activated = function(sender, item)
        TriggerServerEvent("gang_system:requestBackup", gangType)
        mainMenu:Visible(false)
    end
    
    -- Add vehicle options
    local vehicleItem = NativeUI.CreateItem("Request Vehicle", "Get a gang vehicle")
    mainMenu:AddItem(vehicleItem)
    vehicleItem.Activated = function(sender, item)
        TriggerServerEvent("gang_system:requestVehicle", gangType)
        mainMenu:Visible(false)
    end
    
    -- Show menu
    menuPool:RefreshIndex()
    mainMenu:Visible(true)
    
    -- Process menu in a separate thread
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            menuPool:ProcessMenus()
            
            -- Break loop when menu is closed
            if not mainMenu:Visible() then
                break
            end
        end
    end)
end)

-- Event handler for showing non-member options
RegisterNetEvent("gang_system:showNonMemberOptions")
AddEventHandler("gang_system:showNonMemberOptions", function(gangType, gangData)
    -- Create menu using NativeUI
    local menuPool = NativeUI.CreatePool()
    local mainMenu = NativeUI.CreateMenu(gangData.name, "~b~Gang Options")
    menuPool:Add(mainMenu)
    
    -- Add join option
    local joinItem = NativeUI.CreateItem("Join Gang", "Become a member of " .. gangData.name)
    mainMenu:AddItem(joinItem)
    joinItem.Activated = function(sender, item)
        TriggerServerEvent("gang_system:joinGang", gangType)
        mainMenu:Visible(false)
    end
    
    -- Add bribe option
    local bribeItem = NativeUI.CreateItem("Bribe Gang", "Pay for safe passage")
    mainMenu:AddItem(bribeItem)
    bribeItem.Activated = function(sender, item)
        TriggerServerEvent("gang_system:bribeGang", gangType)
        mainMenu:Visible(false)
    end
    
    -- Add leave option
    local leaveItem = NativeUI.CreateItem("Leave", "Walk away")
    mainMenu:AddItem(leaveItem)
    leaveItem.Activated = function(sender, item)
        ShowNotification("You walk away from the " .. gangData.name .. " member")
        mainMenu:Visible(false)
    end
    
    -- Show menu
    menuPool:RefreshIndex()
    mainMenu:Visible(true)
    
    -- Process menu in a separate thread
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            menuPool:ProcessMenus()
            
            -- Break loop when menu is closed
            if not mainMenu:Visible() then
                break
            end
        end
    end)
end)

-- Event handler for starting a gang mission
RegisterNetEvent("gang_system:startMission")
AddEventHandler("gang_system:startMission", function(gangType, difficulty)
    if not Config.Gangs[gangType] then return end
    
    local gangData = Config.Gangs[gangType]
    
    -- Notify player
    ShowNotification("Mission started: " .. difficulty .. " risk")
    ShowNotification("Complete the mission to earn rewards")
    
    -- Trigger server event to start mission
    TriggerServerEvent("gang_system:startMission", gangType, difficulty)
end)

-- Event handler for receiving backup
RegisterNetEvent("gang_system:receiveBackup")
AddEventHandler("gang_system:receiveBackup", function(gangType, count)
    -- This will be handled by gang_npcs.lua
    TriggerEvent("gang_system:spawnBackup", gangType, count)
    ShowNotification("Backup is on the way!")
end)

-- Event handler for receiving vehicle
RegisterNetEvent("gang_system:receiveVehicle")
AddEventHandler("gang_system:receiveVehicle", function(gangType, model)
    -- This will be handled by gang_npcs.lua
    TriggerEvent("gang_system:spawnVehicle", gangType, model)
    ShowNotification("Your gang vehicle is being delivered.")
end)

-- Main thread for gang NPC management
Citizen.CreateThread(function()
    -- Wait for game to initialize
    Citizen.Wait(5000)
    
    -- Initialize cooldowns
    for gangId, _ in pairs(Config.Gangs) do
        gangCooldowns[gangId] = 0
    end
    
    while true do
        -- Spawn gang NPCs
        for gangId, _ in pairs(Config.Gangs) do
            SpawnGangNPC(gangId)
        end
        
        -- Clean up old NPCs
        CleanupGangNPCs()
        
        -- Wait before next cycle
        Citizen.Wait(60000) -- Check every minute
    end
end)

-- Thread for NPC interaction
Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local nearbyNPC = false
        
        -- Check if player is near any gang NPC
        for i, spawn in ipairs(gangSpawns) do
            if DoesEntityExist(spawn.ped) then
                local pedCoords = GetEntityCoords(spawn.ped)
                local distance = #(playerCoords - pedCoords)
                
                if distance < 3.0 then
                    nearbyNPC = true
                    
                    -- Draw interaction text
                    BeginTextCommandDisplayHelp("STRING")
                    AddTextComponentSubstringPlayerName("Press ~INPUT_CONTEXT~ to interact with gang member")
                    EndTextCommandDisplayHelp(0, false, true, -1)
                    
                    -- Check for interaction
                    if IsControlJustReleased(0, 38) then -- E key
                        InteractWithGangNPC(spawn.ped)
                    end
                end
            end
        end
        
        -- Optimize wait time
        if nearbyNPC then
            Citizen.Wait(0)
        else
            Citizen.Wait(500)
        end
    end
end)

-- Register command for keyboard users
RegisterCommand("gang_interact", function()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    local nearestPed = nil
    local nearestDistance = 3.0 -- Interaction distance
    
    for i, spawn in ipairs(gangSpawns) do
        if DoesEntityExist(spawn.ped) then
            local pedCoords = GetEntityCoords(spawn.ped)
            local distance = #(playerCoords - pedCoords)
            
            if distance < nearestDistance then
                nearestPed = spawn.ped
                nearestDistance = distance
            end
        end
    end
    
    if nearestPed then
        InteractWithGangNPC(nearestPed)
    end
end, false)

-- Register key mapping for keyboard users
RegisterKeyMapping("gang_interact", "Interact with Gang NPC", "keyboard", "E")

-- Notification function
function ShowNotification(message)
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandThefeedPostTicker(true, false)
end

-- Debug command
RegisterCommand("gangs_debug", function()
    debugMode = not debugMode
    ShowNotification("Gang debug mode: " .. (debugMode and "Enabled" or "Disabled"))
end, false)
