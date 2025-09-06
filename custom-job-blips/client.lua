-- Job Blips Client Script  
-- Dependencies: config.lua

print('[CUSTOM-JOB-BLIPS] Client script loaded.')

-- Local variables
local playerJob = "unemployed"
local blips = {}

-- Function to create a job blip
function CreateJobBlip(data)
    if not data or not data.coords then return end
    local blip = AddBlipForCoord(data.coords.x, data.coords.y, data.coords.z)
    SetBlipSprite(blip, data.sprite or 1)
    SetBlipColour(blip, data.color or 0)
    SetBlipScale(blip, data.scale or 1.0)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(data.label or "Job Blip")
    EndTextCommandSetBlipName(blip)
    -- Store blip data
    table.insert(blips, {
        blip = blip,
        job = data.job
    })
    return blip
end

-- Function to remove job blips
function RemoveJobBlips()
    for _, blipData in ipairs(blips) do
        if DoesBlipExist(blipData.blip) then
            RemoveBlip(blipData.blip)
        end
    end
    blips = {}
end

-- Function to update job blips based on player job
function UpdateJobBlips()
    -- Remove existing blips
    RemoveJobBlips()
    -- Create new blips based on config and player job
    if Config and Config.JobBlips then
        for job, jobBlips in pairs(Config.JobBlips) do
            if job == playerJob or playerJob == "admin" then
                for _, blipData in ipairs(jobBlips) do
                    CreateJobBlip({
                        coords = blipData.coords,
                        sprite = blipData.sprite,
                        color = blipData.color,
                        scale = blipData.scale,
                        label = blipData.label,
                        job = job
                    })
                end
            end
        end
    end
end

-- Event to set player job
RegisterNetEvent('custom-job-blips:setJob')
AddEventHandler('custom-job-blips:setJob', function(job)
    playerJob = job
    -- Update blips based on new job
    UpdateJobBlips()
    -- Notify player
    TriggerEvent('chat:addMessage', {
        color = {0, 255, 0},
        multiline = false,
        args = {"Job System", "Job set to: " .. job}
    })
end)

-- Initialize when resource starts
AddEventHandler('onClientResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        -- Wait for config to load
        Citizen.Wait(1000)

        -- Try to get player job from server
        TriggerServerEvent('custom-job-blips:getPlayerJob')

        -- Update blips based on default job
        UpdateJobBlips()

        print('[CUSTOM-JOB-BLIPS] Client initialized.')
    end
end)

-- Register command to set job
RegisterCommand("setjob", function(source, args, rawCommand)
    if args[1] then
        TriggerServerEvent('custom-job-blips:setJob', args[1])
    else
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            multiline = false,
            args = {"Job System", "Usage: /setjob [jobname]"}
        })
    end
end, false)

-- Listen for job wheel job changes
RegisterNetEvent('jobwheel:jobChanged')
AddEventHandler('jobwheel:jobChanged', function(job)
    -- Update our job and blips
    playerJob = job
    UpdateJobBlips()
    
    if Config.Debug then
        print('[CUSTOM-JOB-BLIPS] Job updated from job wheel: ' .. job)
    end
end)
