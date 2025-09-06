fx_version 'cerulean'
game 'gta5'

name 'vehicle_customization'
author 'Randy Webb'
description 'Vehicle customization system for Civil Unrest RP'
version '1.0.0'

client_scripts {
    'data/colors.lua',
    'data/upgrades.lua',
    'data/vehicles.lua',
    'client.lua'
}

exports {
    'spawnVehicle',
    'customizeVehicle',
    'applyVehicleMod'
}
