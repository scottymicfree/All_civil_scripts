fx_version 'cerulean'
game 'gta5'

author 'Randy Webb'
description 'Controller-friendly NPC interaction and menu system for Xbox One'
version '1.1.0'

shared_scripts {
    'config.lua'
}

client_scripts {
    '@NativeUI/NativeUI.lua',
    'controller_menu.lua',
    'npc_interactions.lua',
    'main.lua'
}

dependencies {
    'standalone-framework',
    'NativeUI'
}
