-- Function to show native menu
function ShowNativeMenu(zone, items)
    -- Generate menu items if not provided
    if not items then
        items = {}
        
        -- Add type-specific interactions
        if zone.type == "gang" then
            local gang = nil
            for _, g in pairs(Config.Gangs) do
                if g.name == zone.name:gsub(" Member", "") then
                    gang = g
                    break
                end
            end
            
            if gang then
                -- Add interactions based on gang offer
                if gang.offer == "guns" then
                    table.insert(items, {label = "Buy Weapons", value = "buy_weapons", desc = "Purchase weapons from " .. gang.name})
                    table.insert(items, {label = "Request Protection", value = "request_protection", desc = "Pay for gang protection"})
                elseif gang.offer == "drugs" then
                    table.insert(items, {label = "Buy Drugs", value = "buy_drugs", desc = "Purchase drugs from " .. gang.name})
                    table.insert(items, {label = "Sell Information", value = "sell_info", desc = "Sell information to the gang"})
                elseif gang.offer == "cars" then
                    table.insert(items, {label = "Buy Stolen Vehicle", value = "buy_vehicle", desc = "Purchase a stolen vehicle"})
                    table.insert(items, {label = "Sell Vehicle", value = "sell_vehicle", desc = "Sell your vehicle to the gang"})
                elseif gang.offer == "mini_mission" then
                    table.insert(items, {label = "Request Job", value = "request_mission", desc = "Ask for work from " .. gang.name})
                end
            end
        end
    end
    
    -- Display the menu
    -- Implementation depends on your menu system
    -- This is a placeholder for your menu display code
    TriggerEvent("civil_disorder:displayMenu", zone.name, items)
end -- ADDED MISSING END STATEMENT HERE
