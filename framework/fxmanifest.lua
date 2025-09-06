fx_version 'cerulean'
game 'gta5'

author 'Randy Webb'
description 'Custom Framework: NPCs, Jobs, Gangs, Controller Menus, Missions, Weather & Traffic Control'
version '1.1.0'

shared_scripts {
    'config.lua'
}

client_scripts {
    'client/utils.lua',
    'client/npcs.lua',
    'client/interaction.lua',
    'client/vehicle.lua',
    'client/weather_traffic.lua',
    'client/dispatcher.lua',
    'client/ui.lua'
}

server_scripts {
    'server/main.lua',
    'server/jobs.lua',
    'server/gangs.lua',
    'server/dispatch.lua',
    'server/playerdata.lua',
    'server/version_check.lua'
}

exports {
    'getNpcPeds',
    'isPlayerInVehicle',
    'getClosestVehicle',
    'showNotification',
    'draw3DText'
}

server_exports {
    'getPlayerJob',
    'getPlayerGang',
    'logAction'
}

lua54 'yes'
