fx_version 'cerulean'
game 'gta5'

name 'civil_unrest_core'
author 'Randy Webb'
description 'Civil Unrest Core - Gang warfare and turf control system'
version '1.0.0'

shared_scripts {
    'config.lua',
    'zones.lua'
}

client_scripts {
    'client.lua',
    'gang_control.lua',
    'blips.lua',
    'vmenu_gangtools.lua',
    'safezones.lua'  -- Added safezones as client script
}

server_scripts {
    'server.lua',
    'main.lua',
    'gangzones.lua'
}

dependencies {
    -- If you're using these resources, uncomment them
    -- 'vMenu',
    -- 'mission_system',
    -- 'npc_interaction',
    -- 'npc_logic'
}

lua54 'yes'
