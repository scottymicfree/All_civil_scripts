fx_version 'cerulean'
game 'gta5'

author 'Randy Webb'
description 'Interior zone management system with conflict resolution'
version '1.0.0'

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

exports {
    'RegisterInteriorZone',
    'UpdateInteriorZone',
    'RemoveInteriorZone',
    'GetActiveZoneAtPosition',
    'GetAllZonesAtPosition',
    'IsPlayerInZoneType'
}