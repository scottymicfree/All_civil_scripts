fx_version 'cerulean'
games { 'gta5' }

name 'gang_zones'
author 'Randy Webb'
description 'Gang Zones configuration for Civil Unrest RP'
version '1.0.0'

shared_scripts {
    'zone.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

dependencies {
    'standalone-framework',
    'civil_unrest_core',
    'spawnmanager',
    'job_wheel',
    'npc_spawner'
}

exports {
    'GetGangZones',
    'GetZoneByName',
    'GetPlayerZone'
}