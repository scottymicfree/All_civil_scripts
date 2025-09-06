-- Job Management System
-- Handles player jobs and job-related functionality

-- Track player jobs
local playerJobs = {}

-- Set player job
function setPlayerJob(source, job, rank)
    if not source or not job then return false end
    
    rank = rank or 1
    
    -- Store job data
    playerJobs[source] = {
        name = job,
        rank = rank,
        assignedTime = os.time()
    }
    
    -- Notify player
    TriggerClientEvent('chat:addMessage', source, {
        color = {0, 255, 0},
        multiline = false,
        args = {"Jobs", "Your job has been set to " .. job .. " (Rank " .. rank .. ")"}
    })
    
    -- Log job change
    exports['framework']:logAction(source, "JOB", "Job set to " .. job .. " (Rank " .. rank .. ")")
    
    return true
end

-- Get player job
function getPlayerJob(source)
    if playerJobs[source] then
        return playerJobs[source].name
    end
    return "unemployed"
end

-- Get player job rank
function getPlayerRank(source)
    if playerJobs[source] then
        return playerJobs[source].rank
    end
    return 0
end

-- Clean up player job on disconnect
AddEventHandler('playerDropped', function()
    local source = source
    playerJobs[source] = nil
end)

-- Register job commands
RegisterCommand('setjob', function(source, args, rawCommand)
    -- Check if command is run from console
    if source == 0 then
        if #args < 2 then
            print("Usage: setjob [playerId] [job] [rank]")
            return
        end
        
        local targetId = tonumber(args[1])
        local job = args[2]
        local rank = tonumber(args[3]) or 1
        
        if GetPlayerName(targetId) then
            setPlayerJob(targetId, job, rank)
            print("Set " .. GetPlayerName(targetId) .. "'s job to " .. job .. " (Rank " .. rank .. ")")
        else
            print("Player not found")
        end
    else
        -- Check if player has admin permissions
        -- This would connect to your permission system in a real implementation
        local isAdmin = true
        
        if isAdmin then
            if #args < 2 then
                TriggerClientEvent('chat:addMessage', source, {
                    color = {255, 0, 0},
                    multiline = false,
                    args = {"Jobs", "Usage: /setjob [playerId] [job] [rank]"}
                })
                return
            end
            
            local targetId = tonumber(args[1])
            local job = args[2]
            local rank = tonumber(args[3]) or 1
            
            if GetPlayerName(targetId) then
                setPlayerJob(targetId, job, rank)
                
                TriggerClientEvent('chat:addMessage', source, {
                    color = {0, 255, 0},
                    multiline = false,
                    args = {"Jobs", "Set " .. GetPlayerName(targetId) .. "'s job to " .. job .. " (Rank " .. rank .. ")"}
                })
            else
                TriggerClientEvent('chat:addMessage', source, {
                    color = {255, 0, 0},
                    multiline = false,
                    args = {"Jobs", "Player not found"}
                })
            end
        else
            TriggerClientEvent('chat:addMessage', source, {
                color = {255, 0, 0},
                multiline = false,
                args = {"Jobs", "You don't have permission to use this command"}
            })
        end
    end
end, false)

-- Register job info command
RegisterCommand('job', function(source, args, rawCommand)
    if source > 0 then
        local job = getPlayerJob(source)
        local rank = getPlayerRank(source)
        
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 255, 0},
            multiline = false,
            args = {"Jobs", "Your current job is " .. job .. " (Rank " .. rank .. ")"}
        })
    end
end, false)

-- Export functions
exports('setPlayerJob', setPlayerJob)
exports('getPlayerJob', getPlayerJob)
exports('getPlayerRank', getPlayerRank)
