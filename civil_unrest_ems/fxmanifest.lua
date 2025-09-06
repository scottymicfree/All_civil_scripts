fx_version 'cerulean'
game 'gta5'

author 'NinjaTech AI'
description 'EMS NPC system with controller-friendly interactions'
version '1.0.0'

client_scripts {
    '@NativeUI/NativeUI.lua',
    'client.lua'
}

server_scripts {
    'server.lua'
}

dependencies {
    'NativeUI',
    'standalone-framework'
}