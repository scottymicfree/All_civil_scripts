-- Function to clean up old fire department entities
function CleanupFireEntities()
    local currentTime = GetGameTimer()
    local newNPCs = {}
    local newVehicles = {}
    
    -- Clean up NPCs
    for i, npc in ipairs(spawnedNPCs) do
        -- Check if NPC still exists and isn't too old (5 minutes)
        if DoesEntityExist(npc.ped) and (currentTime - npc.spawnTime) < 300000 then
            table.insert(newNPCs, npc)
        else
            -- Delete the ped if it exists
            if DoesEntityExist(npc.ped) then
                DeleteEntity(npc.ped)
            end
            
            if debugMode then
                print("Cleaned up firefighter NPC")
            end
        end
    end
    
    -- Clean up vehicles
    for i, veh in ipairs(fireVehicles) do
        -- Check if vehicle still exists and isn't too old (5 minutes)
        if DoesEntityExist(veh.vehicle) and (currentTime - veh.spawnTime) < 300000 then
            table.insert(newVehicles, veh)
        else
            -- Delete the vehicle and driver if they exist
            if DoesEntityExist(veh.vehicle) then
                DeleteEntity(veh.vehicle)
            end
            
            if DoesEntityExist(veh.driver) then
                DeleteEntity(veh.driver)
            end
            
            -- Delete passengers
            for _, passenger in ipairs(veh.passengers or {}) do
                if DoesEntityExist(passenger) then
                    DeleteEntity(passenger)
                end
            end
            
            if debugMode then
                print("Cleaned up fire truck")
            end
        end
    end
    
    spawnedNPCs = newNPCs
    fireVehicles = newVehicles
end
