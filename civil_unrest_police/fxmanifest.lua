fx_version 'cerulean'
game 'gta5'

author 'Randy Webb'
description 'Police NPC system with controller-friendly interactions'
version '1.0.0'

client_scripts {
    '@NativeUI/NativeUI.lua',
    'client.lua',
    'patrol.lua',
    'undercover.lua',
    'wanted.lua'
}

server_scripts {
    'server.lua'
}

dependencies {
    'NativeUI',
    'standalone-framework'
}