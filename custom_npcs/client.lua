-- Register all NPCs from config
Citizen.CreateThread(function()
    -- Wait for resource to initialize
    Citizen.Wait(1000)
    
    -- Register each NPC
    for _, npc in ipairs(Config.NPCs) do
        exports['npc_interaction']:RegisterNPC(
            npc.id,
            npc.model,
            npc.coords,
            npc.heading,
            npc.animation,
            npc.interactionDistance,
            npc.interactionType,
            npc.data
        )
        
        if Config.Debug then
            print("Registered NPC: " .. npc.id)
        end
    end
    
    print("[Custom NPCs] Registered " .. #Config.NPCs .. " NPCs")
end)

-- Custom interaction handlers
RegisterNetEvent("custom_npcs:homelessInteraction")
AddEventHandler("custom_npcs:homelessInteraction", function(data)
    -- Show options menu
    local elements = {
        {label = "Give $5", value = "give_money"},
        {label = "Ignore", value = "ignore"}
    }
    
    -- Use your menu system here, this is just a placeholder
    -- For example with NativeUI:
    local menu = NativeUI.CreateMenu("Homeless Man", "Choose an action")
    
    for _, element in ipairs(elements) do
        local item = NativeUI.CreateItem(element.label, "")
        menu:AddItem(item)
        item.Activated = function(_, _)
            if element.value == "give_money" then
                TriggerServerEvent("custom_npcs:giveMoney", 5)
                ShowNotification("You gave $5 to the homeless man.")
            elseif element.value == "ignore" then
                ShowNotification("You ignored the homeless man.")
            end
            menu:Visible(false)
        end
    end
    
    menu:Visible(true)
end)

RegisterNetEvent("custom_npcs:mechanicInteraction")
AddEventHandler("custom_npcs:mechanicInteraction", function(data)
    -- Show options menu
    local elements = {
        {label = "Repair Vehicle ($500)", value = "repair"},
        {label = "Customize Vehicle", value = "customize"},
        {label = "Cancel", value = "cancel"}
    }
    
    -- Use your menu system here
    -- For example with NativeUI:
    local menu = NativeUI.CreateMenu("Mechanic", "Choose a service")
    
    for _, element in ipairs(elements) do
        local item = NativeUI.CreateItem(element.label, "")
        menu:AddItem(item)
        item.Activated = function(_, _)
            if element.value == "repair" then
                TriggerServerEvent("custom_npcs:repairVehicle", 500)
            elseif element.value == "customize" then
                -- Open customization menu
                TriggerEvent("custom_npcs:openCustomization")
            end
            menu:Visible(false)
        end
    end
    
    menu:Visible(true)
end)

-- Helper function to show notifications
function ShowNotification(message)
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandThefeedPostTicker(true, false)
end
