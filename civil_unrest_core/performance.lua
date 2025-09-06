-- Add to civil_unrest_core/server/performance.lua

local performanceMetrics = {
    playerCount = 0,
    entityCount = 0,
    cpuUsage = 0,
    memoryUsage = 0,
    networkUsage = 0,
    tickTime = 0
}

-- Update metrics every 60 seconds
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60000)
        
        performanceMetrics.playerCount = #GetPlayers()
        performanceMetrics.entityCount = GetEntityCount()
        
        -- Log metrics if they exceed thresholds
        if performanceMetrics.entityCount > 2000 then
            print("^1WARNING: High entity count: " .. performanceMetrics.entityCount)
        end
        
        if performanceMetrics.playerCount > 40 then
            print("^3NOTICE: High player count: " .. performanceMetrics.playerCount)
        end
        
        -- Send metrics to monitoring system
        TriggerEvent("civil_unrest:performanceUpdate", performanceMetrics)
    end
end)

-- Entity cleanup for abandoned vehicles
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(300000) -- 5 minutes
        
        -- Get all vehicles
        local vehicles = GetAllVehicles()
        local cleanupCount = 0
        
        for _, vehicle in ipairs(vehicles) do
            -- Check if vehicle is abandoned (no players nearby)
            if not IsVehicleOccupied(vehicle) and not IsAnyPlayerNearEntity(vehicle, 150.0) then
                -- Check if vehicle is not owned by a player
                if not IsVehicleOwned(vehicle) then
                    DeleteEntity(vehicle)
                    cleanupCount = cleanupCount + 1
                end
            end
        end
        
        if cleanupCount > 0 and Config.DebugMode then
            print("^2Cleaned up " .. cleanupCount .. " abandoned vehicles")
        end
    end
end)
