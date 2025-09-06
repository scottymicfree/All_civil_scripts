fx_version 'cerulean'
game 'gta5'

name 'interior_zone_manager'
author 'Randy Webb'
description 'Interior zone management system for tracking player locations in buildings'
version '1.0.0'

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

shared_scripts {
    'config.lua'
}

exports {
    'RegisterInteriorZone',
    'GetActiveZoneAtPosition'
}

lua54 'yes'
