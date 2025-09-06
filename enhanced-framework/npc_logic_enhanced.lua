-- =============================================================
-- [ npc_logic_enhanced.lua ]
-- Enhanced NPC management system with schedules and behaviors
-- =============================================================


local NPCManager = {}
NPCManager.SpawnedNPCs = {}
NPCManager.NPCTypes = {
    POLICE = "police",
    EMS = "ems",
    FIRE = "firefighter",
    GANG = "gang_member",
    DRUG_DEALER = "drug_dealer",
    MECHANIC = "mechanic",
    CIVILIAN = "civilian"
}


-- NPC Schedule definitions (24-hour format)
NPCManager.Schedules = {
    [NPCManager.NPCTypes.POLICE] = {
        {time = {6, 14}, behavior = "WORLD_HUMAN_CLIPBOARD", location = "station"},
        {time = {14, 22}, behavior = "patrol", location = "patrol_route"},
        {time = {22, 6}, behavior = "WORLD_HUMAN_GUARD_STAND", location = "station"}
    },
    [NPCManager.NPCTypes.EMS] = {
        {time = {6, 14}, behavior = "WORLD_HUMAN_CLIPBOARD", location = "hospital"},
        {time = {14, 22}, behavior = "CODE_HUMAN_MEDIC_TIME_OF_DEATH", location = "hospital"},
        {time = {22, 6}, behavior = "WORLD_HUMAN_STAND_MOBILE", location = "hospital"}
    },
    [NPCManager.NPCTypes.FIRE] = {
        {time = {6, 14}, behavior = "WORLD_HUMAN_STAND_FIRE", location = "station"},
        {time = {14, 22}, behavior = "WORLD_HUMAN_CLIPBOARD", location = "station"},
        {time = {22, 6}, behavior = "WORLD_HUMAN_GUARD_STAND", location = "station"}
    },
    [NPCManager.NPCTypes.GANG] = {
        {time = {6, 14}, behavior = "WORLD_HUMAN_HANG_OUT_STREET", location = "turf"},
        {time = {14, 22}, behavior = "WORLD_HUMAN_SMOKING", location = "turf"},
        {time = {22, 6}, behavior = "WORLD_HUMAN_DRUG_DEALER", location = "turf"}
    },
    [NPCManager.NPCTypes.DRUG_DEALER] = {
        {time = {6, 14}, behavior = "WORLD_HUMAN_STAND_MOBILE", location = "hideout"},
        {time = {14, 22}, behavior = "WORLD_HUMAN_DRUG_DEALER", location = "corner"},
        {time = {22, 6}, behavior = "WORLD_HUMAN_DRUG_DEALER_HARD", location = "corner"}
    },
    [NPCManager.NPCTypes.MECHANIC] = {
        {time = {6, 14}, behavior = "WORLD_HUMAN_VEHICLE_MECHANIC", location = "garage"},
        {time = {14, 22}, behavior = "WORLD_HUMAN_WELDING", location = "garage"},
        {time = {22, 6}, behavior = "WORLD_HUMAN_CLIPBOARD", location = "garage"}
    },
    [NPCManager.NPCTypes.CIVILIAN] = {
        {time = {6, 14}, behavior = "WORLD_HUMAN_CLIPBOARD", location = "random"},
        {time = {14, 22}, behavior = "WORLD_HUMAN_STAND_MOBILE", location = "random"},
        {time = {22, 6}, behavior = "WORLD_HUMAN_STAND_IMPATIENT", location = "random"}
    }
}


-- NPC Models by type
NPCManager.Models = {
    [NPCManager.NPCTypes.POLICE] = {"s_m_y_cop_01", "s_f_y_cop_01"},
    [NPCManager.NPCTypes.EMS] = {"s_m_m_paramedic_01", "s_f_y_scrubs_01"},
    [NPCManager.NPCTypes.FIRE] = {"s_m_y_fireman_01"},
    [NPCManager.NPCTypes.GANG] = {"g_m_y_ballasout_01", "g_m_y_famca_01", "g_m_y_salvagoon_01"},
    [NPCManager.NPCTypes.DRUG_DEALER] = {"g_m_m_chemwork_01", "g_m_y_mexgoon_03"},
    [NPCManager.NPCTypes.MECHANIC] = {"s_m_y_xmech_01", "s_m_m_autoshop_01"},
    [NPCManager.NPCTypes.CIVILIAN] = {"a_m_y_business_01", "a_f_y_business_01", "a_m_y_hipster_01", "a_f_y_hipster_01"}
}


-- NPC Interaction options by type
NPCManager.InteractionOptions = {
    [NPCManager.NPCTypes.POLICE] = {
        {label = "Request Assistance", action = "request_assistance"},
        {label = "Report Crime", action = "report_crime"},
        {label = "Join Police Force", action = "join_police"}
    },
    [NPCManager.NPCTypes.EMS] = {
        {label = "Request Medical Aid", action = "request_medical"},
        {label = "Join EMS", action = "join_ems"}
    },
    [NPCManager.NPCTypes.FIRE] = {
        {label = "Report Fire", action = "report_fire"},
        {label = "Join Fire Department", action = "join_fire"}
    },
    [NPCManager.NPCTypes.GANG] = {
        {label = "Talk to Gang Member", action = "talk_gang"},
        {label = "Request Gang Mission", action = "gang_mission"},
        {label = "Join Gang", action = "join_gang"}
    },
    [NPCManager.NPCTypes.DRUG_DEALER] = {
        {label = "Buy Drugs", action = "buy_drugs"},
        {label = "Sell Drugs", action = "sell_drugs"}
    },
    [NPCManager.NPCTypes.MECHANIC] = {
        {label = "Repair Vehicle", action = "repair_vehicle"},
        {label = "Customize Vehicle", action = "customize_vehicle"},
        {label = "Join Mechanic Job", action = "join_mechanic"}
    },
    [NPCManager.NPCTypes.CIVILIAN] = {
        {label = "Talk to Civilian", action = "talk_civilian"}
    }
}


-- Function to check if a location is in a conflict zone
function NPCManager.IsInConflictZone(coords)
    if GetResourceState('standalone-framework') == 'started' then
        for _, zone in pairs(Config.SafeZones or {}) do
            if #(coords - zone.center) < zone.radius then
                return true, "safe zone (" .. zone.name .. ")"
            end
        end
        for _, zone in pairs(Config.GangZones or {}) do
            if #(coords - zone.center) < zone.radius then
                return true, "gang turf (" .. zone.name .. ")"
            end
        end
    else
        local defaultSafeZones = {
            { center = vector3(426.1, -979.5, 30.7), radius = 100.0, name = "Mission Row PD" },
            { center = vector3(-449.19, -340.94, 34.54), radius = 80.0, name = "Central LS Medical" },
            { center = vector3(-701.37, -148.97, 37.49), radius = 80.0, name = "Davis Fire Station" }
        }
        local defaultGangZones = {
            { center = vector3(333.84, -2040.52, 21.07), radius = 100.0, name = "Vagos Turf" },
            { center = vector3(1205.77, -2620.16, 42.44), radius = 80.0, name = "Grove Street" },
            { center = vector3(-1186.73, 517.16, 83.21), radius = 80.0, name = "Ballas Turf" }
        }
        for _, zone in pairs(defaultSafeZones) do
            if #(coords - zone.center) < zone.radius then
                return true, "safe zone (" .. zone.name .. ")"
            end
        end
        for _, zone in pairs(defaultGangZones) do
            if #(coords - zone.center) < zone.radius then
                return true, "gang turf (" .. zone.name .. ")"
            end
        end
    end
    return false, nil
end


-- Function to get current game hour
function NPCManager.GetCurrentHour()
    return GetClockHours()
end


-- Function to get appropriate behavior based on NPC type and current time
function NPCManager.GetCurrentBehavior(npcType)
    local currentHour = NPCManager.GetCurrentHour()
    local schedule = NPCManager.Schedules[npcType]


if not schedule then
    return "WORLD_HUMAN_STAND_IMPATIENT" -- Default behavior
end

for _, timeSlot in ipairs(schedule) do
    local startHour = timeSlot.time[1]
    local endHour = timeSlot.time[2]
    
    -- Handle time ranges that cross midnight
    if endHour < startHour then
        if currentHour >= startHour or currentHour < endHour then
            return timeSlot.behavior, timeSlot.location
        end
    else
        if currentHour >= startHour and currentHour < endHour then
            return timeSlot.behavior, timeSlot.location
        end
    end
end

-- Default behavior if no matching time slot
return "WORLD_HUMAN_STAND_IMPATIENT", "default"

end


-- Function to spawn an NPC
function NPCManager.SpawnNPC(npcType, position, heading)
    -- Select a random model for this NPC type
    local models = NPCManager.Models[npcType]
    if not models or #models == 0 then
        print("Error: No models defined for NPC type " .. npcType)
        return nil
    end
local modelName = models[math.random(#models)]
local modelHash = GetHashKey(modelName)

-- Check if position is in a conflict zone
local inConflict, conflictType = NPCManager.IsInConflictZone(position)
if inConflict then
    print("Skipping NPC spawn for " .. npcType .. " at " .. position.x .. ", " .. position.y .. ", " .. position.z .. ": " .. conflictType)
    return nil
end

-- Request the model
RequestModel(modelHash)
local timeout = 5000
local startTime = GetGameTimer()

while not HasModelLoaded(modelHash) do
    Citizen. Wait(100)
    if GetGameTimer() - startTime > timeout then
        print("Error: Failed to load model for NPC type " .. npcType)
        return nil
    end
end

-- Create the NPC
local ped = CreatePed(4, modelHash, position.x, position.y, position.z, heading or 0.0, false, true)

-- Set NPC properties
SetEntityAsMissionEntity(ped, true, true)
SetBlockingOfNonTemporaryEvents(ped, true)
SetPedCanBeTargetted(ped, false)
SetPedCanRagdoll(ped, false)

-- Set decorators for identification
DecorSetInt(ped, "npc_managed", 1)
DecorSetString(ped, "npc_type", npcType)

-- Get appropriate behavior based on time
local behavior, location = NPCManager.GetCurrentBehavior(npcType)

-- Apply behavior
if behavior == "patrol" then
    TaskWanderInArea(ped, position.x, position.y, position.z, 50.0, 0, 0)
else
    TaskStartScenarioInPlace(ped, behavior, 0, true)
end

-- Add to managed NPCs
table.insert(NPCManager.SpawnedNPCs, {
    handle = ped,
    type = npcType,
    position = position,
    behavior = behavior,
    location = location,
    lastUpdate = GetGameTimer()
})

-- Clean up model
SetModelAsNoLongerNeeded(modelHash)
return ped
end


-- Function to update NPC behaviors based on time
function NPCManager.UpdateNPCBehaviors()
    for i, npcData in ipairs(NPCManager.SpawnedNPCs) do
        if DoesEntityExist(npcData.handle) then
            local behavior, location = NPCManager.GetCurrentBehavior(npcData.type)


        -- Only update if behavior has changed
        if behavior ~= npcData.behavior then
            ClearPedTasks(npcData.handle)
            
            if behavior == "patrol" then
                TaskWanderInArea(npcData.handle, npcData.position.x, npcData.position.y, npcData.position.z, 50.0, 0, 0)
            else
                TaskStartScenarioInPlace(npcData.handle, behavior, 0, true)
            end
            
            -- Update stored behavior
            NPCManager.SpawnedNPCs[i].behavior = behavior
            NPCManager.SpawnedNPCs[i].location = location
            NPCManager.SpawnedNPCs[i].lastUpdate = GetGameTimer()
        end
    else
        -- NPC no longer exists, remove from list
        table.remove(NPCManager.SpawnedNPCs, i)
    end
end

end


-- Function to get interaction options for an NPC
function NPCManager.GetInteractionOptions(ped)
    if not DoesEntityExist(ped) then return {} end


local npcType = "civilian"
if DecorExistOn(ped, "npc_type") then
    npcType = DecorGetString(ped, "npc_type")
end

return NPCManager.InteractionOptions[npcType] or NPCManager.InteractionOptions[NPCManager.NPCTypes.CIVILIAN]

end


-- Function to handle NPC interaction
function NPCManager.InteractWithNPC(ped, action)
    if not DoesEntityExist(ped) then return end


local npcType = "civilian"
if DecorExistOn(ped, "npc_type") then
    npcType = DecorGetString(ped, "npc_type")
end

-- Handle different interaction types
if action == "request_assistance" then
    ShowNotification("Officer: How can I help you today?")
    -- Additional logic for police assistance
elseif action == "report_crime" then
    ShowNotification("Officer: Please tell me what happened.")
    -- Additional logic for crime reporting
elseif action == "join_police" then
    TriggerServerEvent('myframework:becomePolice')
elseif action == "request_medical" then
    ShowNotification("Paramedic: Do you need medical attention?")
    -- Additional logic for medical assistance
elseif action == "join_ems" then
    TriggerServerEvent('myframework:becomeEms')
elseif action == "report_fire" then
    ShowNotification("Firefighter: Where's the fire?")
    -- Additional logic for fire reporting
elseif action == "join_fire" then
    TriggerServerEvent('myframework:becomeFirefighter')
elseif action == "talk_gang" then
    ShowNotification("Gang Member: What do you want?")
    -- Additional logic for gang conversation
elseif action == "gang_mission" then
    TriggerServerEvent('myframework:requestGangMission')
elseif action == "join_gang" then
    TriggerServerEvent('myframework:joinGang')
elseif action == "buy_drugs" then
    TriggerServerEvent('myframework:buyDrugs')
elseif action == "sell_drugs" then
    TriggerServerEvent('myframework:sellDrugs')
elseif action == "repair_vehicle" then
    TriggerServerEvent('myframework:repairVehicle')
elseif action == "customize_vehicle" then
    TriggerServerEvent('myframework:customizeVehicle')
elseif action == "join_mechanic" then
    TriggerServerEvent('myframework:becomeMechanic')
elseif action == "talk_civilian" then
    ShowNotification("Civilian: Hello there!")
    -- Additional logic for civilian conversation
end

end


-- Function to create interaction menu for an NPC
function NPCManager.CreateInteractionMenu(ped)
    if not DoesEntityExist(ped) then return end


local options = NPCManager.GetInteractionOptions(ped)
if #options == 0 then return end

local menuPool = NativeUI.CreatePool()
local mainMenu = NativeUI.CreateMenu("NPC Interaction", "~b~Choose an action")
menuPool:Add(mainMenu)
menuPool:MouseControlsEnabled(false)
menuPool:MouseEdgeEnabled(false)
menuPool:ControlDisablingEnabled(true)
menuPool:ControllerEnabled(true)

for _, option in ipairs(options) do
    local item = NativeUI.CreateItem(option.label, "")
    mainMenu:AddItem(item)
    
    item.Activated = function(sender, selectedItem)
        if selectedItem == item then
            NPCManager.InteractWithNPC(ped, option.action)
            mainMenu:Visible(false)
        end
    end
end

menuPool:RefreshIndex()
mainMenu:Visible(true)

-- Process menu in a separate thread
Citizen. CreateThread(function()
    while mainMenu:Visible() do
        Citizen. Wait(0)
        menuPool:ProcessMenus()
    end
end)

end


-- Function to find the closest NPC
function NPCManager.GetClosestNPC()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local closestDistance = 3.0
    local closestPed = nil


-- Check managed NPCs first
for _, npcData in ipairs(NPCManager.SpawnedNPCs) do
    if DoesEntityExist(npcData.handle) then
        local pedCoords = GetEntityCoords(npcData.handle)
        local distance = #(playerCoords - pedCoords)
        
        if distance < closestDistance then
            closestDistance = distance
            closestPed = npcData.handle
        end
    end
end

-- If no managed NPC found, check all peds
if not closestPed then
    local peds = GetGamePool('CPed')
    for _, ped in ipairs(peds) do
        if ped ~= playerPed and not IsPedAPlayer(ped) and DoesEntityExist(ped) then
            local pedCoords = GetEntityCoords(ped)
            local distance = #(playerCoords - pedCoords)
            
            if distance < closestDistance then
                closestDistance = distance
                closestPed = ped
            end
        end
    end
end

return closestPed

end


-- Function to show help text for NPC interaction
function NPCManager.ShowInteractionPrompt()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local closestPed = NPCManager.GetClosestNPC()
if closestPed then
    local pedCoords = GetEntityCoords(closestPed)
    local distance = #(playerCoords - pedCoords)
    if distance < 3.0 then
        local npcType = "civilian"
        if DecorExistOn('closestPed', "npc_type") then
            npcType = DecorGetString(closestPed, "npc_type")
        end
        
    -- Show controller-friendly prompt
    BeginTextCommandDisplayHelp("STRING")
    AddTextComponentSubstringPlayerName("Press ~INPUT_CONTEXT~ to interact with " .. npcType)
    EndTextCommandDisplayHelp(0, false, true, -1)
    
    -- Check for interaction button press
    if IsControlJustPressed(1, 51) then -- E key or Xbox controller equivalent
        NPCManager.CreateInteractionMenu(closestPed)
    end

    return true
    end
end

return false

end


-- Helper function to show notifications
function ShowNotification(text)
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandThefeedPostTicker(true, false)
end


-- Thread to update NPC behaviors based on time
Citizen. CreateThread(function()
    while true do
        NPCManager.UpdateNPCBehaviors()
        Citizen. Wait(60000) -- Check every minute
    end
end)


-- Thread to show interaction prompts
Citizen. CreateThread(function()
    while true do
        local showingPrompt = NPCManager.ShowInteractionPrompt()


    -- Only wait a short time if showing prompt, otherwise wait longer
    if showingPrompt then
        Citizen. Wait(0)
    else
        Citizen. Wait(500)
    end
end

end)


-- Event handler for NPC interaction
RegisterNetEvent('myframework:npcInteraction')
AddEventHandler('myframework:npcInteraction', function(ped, npcType)
    NPCManager.CreateInteractionMenu(ped)
end)


-- Initialize
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        ShowNotification("NPC Management System initialized.")


    -- Register decorators
    DecorRegister("npc_managed", 2) -- INT
    DecorRegister("npc_type", 3) -- STRING
end

end)


-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        for _, npcData in ipairs(NPCManager.SpawnedNPCs) do
            if DoesEntityExist(npcData.handle) then
                DeleteEntity(npcData.handle)
            end
        end
        NPCManager.SpawnedNPCs = {}
    end
end)


-- Export the NPCManager
exports('GetNPCManager', function()
    return NPCManager
end)