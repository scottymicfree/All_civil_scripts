fx_version 'cerulean'
game 'gta5'

name 'gang_system'
author 'Randy Webb'
description 'Gang system with NPCs, territories, and missions'
version '1.0.0'

shared_scripts {
    'config.lua'
}

client_scripts {
    '@NativeUI/NativeUI.lua',
    'client.lua',
    'gang_npcs.lua'
}

server_scripts {
    'server.lua'
}

dependencies {
    'NativeUI',
    'standalone-framework'
}

lua54 'yes'
