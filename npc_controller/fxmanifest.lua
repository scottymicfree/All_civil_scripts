fx_version 'cerulean'
games { 'gta5' }

name 'npc_controller'
author 'Randy Webb'
description 'Controller-friendly NPC interaction for Civil Unrest RP'
version '1.0.0'

client_scripts {
    'controller.lua'
}

dependencies {
    'standalone-framework',
    'civil_unrest_core',
    'gang_zones',
    'npc_spawner',
    'job_wheel',
    'bounty_mission'
}