Config = {}

Config.Settings = {
    debug = true, -- Enable debug messages
    updateInterval = 5000 -- Update interval in milliseconds (5 seconds)
}

Config.Commands = {
    ['base'] = {
        description = 'Base command to test the resource',
        args = { { name = 'action', help = 'Action to perform (e.g., test, jobwheel, blips)' } },
        handler = 'baseCommand'
    },
    ['jobwheel'] = {
        description = 'Open the job selection wheel',
        args = {},
        handler = 'jobwheelCommand'
    }
}

-- Job wheel integration settings
Config.JobWheel = {
    enabled = true,
    controllerButton = 307, -- D-pad right
    permissionRequired = false -- Set to true to require the 'bounty.hunter' permission
}

-- Custom job blips integration settings
Config.JobBlips = {
    enabled = true,
    updateOnJobChange = true
}

print('[Base Resource] Config loaded.')
