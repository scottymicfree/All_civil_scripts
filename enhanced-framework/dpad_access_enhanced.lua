-- Function to create NPC interaction menu (UP on D-pad)
function CreateNPCInteractionMenu()
    -- Create menu using NativeUI
    local menuPool = NativeUI.CreatePool()
    local mainMenu = NativeUI.CreateMenu("NPC Interactions", "~b~Interact with nearby NPCs")
    menuPool:Add(mainMenu)
    menuPool:MouseControlsEnabled(false)
    menuPool:MouseEdgeEnabled(false)
    menuPool:ControlDisablingEnabled(true)
    menuPool:ControllerEnabled(true)

    -- Find nearby NPCs
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local foundNPC = false

    -- Check for nearby job NPCs
    for job, data in pairs(Config.Jobs or {}) do
        for _, station in ipairs(data.locations or {}) do
            local distance = #(playerCoords - vector3(station.x, station.y, station.z))
            if distance < 5.0 then
                local item = NativeUI.CreateItem(data.title, "Interact with " .. data.title)
                mainMenu:AddItem(item)
                foundNPC = true
                
                item.Activated = function(sender, selectedItem)
                    if selectedItem == item then
                        -- Use existing job menu function if available
                        if CreateJobMenu then
                            CreateJobMenu(job)
                        else
                            -- Fallback to basic interaction
                            TriggerEvent('myframework:notify', "Interacting with " .. data.title)
                        end
                        mainMenu:Visible(false)
                    end
                end
            end
        end
    end

    -- Check for nearby gang NPCs
    for gang, data in pairs(Config.Gangs or {}) do
        for _, location in ipairs(data.locations or {}) do
            local distance = #(playerCoords - vector3(location.x, location.y, location.z))
            if distance < 5.0 then
                local item = NativeUI.CreateItem(data.name, "Interact with " .. data.name)
                mainMenu:AddItem(item)
                foundNPC = true
                
                item.Activated = function(sender, selectedItem)
                    if selectedItem == item then
                        -- Use existing gang menu function if available
                        if CreateGangMenu then
                            CreateGangMenu(gang)
                        else
                            -- Fallback to basic interaction
                            TriggerEvent('myframework:notify', "Interacting with " .. data.name)
                        end
                        mainMenu:Visible(false)
                    end
                end
            end
        end
    end

    -- Check for any other interactive NPCs
    local entities = GetGamePool('CPed')
    for _, entity in ipairs(entities) do
        if entity ~= playerPed and not IsPedAPlayer(entity) and DoesEntityExist(entity) then
            local entityCoords = GetEntityCoords(entity)
            local distance = #(playerCoords - entityCoords)
            
            if distance < 3.0 then
                -- Check if this NPC has any special properties
                local npcType = "Unknown"
                if DecorExistOn(entity, "npc_type") then
                    npcType = DecorGetString(entity, "npc_type")
                end
                
                local item = NativeUI.CreateItem("Interact with " .. npcType .. " NPC", "Talk to this NPC")
                mainMenu:AddItem(item)
                foundNPC = true
                
                item.Activated = function(sender, selectedItem)
                    if selectedItem == item then
                        -- Generic NPC interaction
                        TriggerEvent('myframework:npcInteraction', entity, npcType)
                        mainMenu:Visible(false)
                    end
                end
            end
        end
    end

    -- If no NPCs found, add a message
    if not foundNPC then
        local item = NativeUI.CreateItem("No NPCs Nearby", "Move closer to an NPC to interact")
        mainMenu:AddItem(item)
    end

    menuPool:RefreshIndex()
    mainMenu:Visible(true)

    -- Return menu and pool
    return {
        menu = mainMenu,
        pool = menuPool
    }
end
