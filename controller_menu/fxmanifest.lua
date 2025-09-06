fx_version 'cerulean'
game 'gta5'

name 'dpad_menu'
author 'Randy Webb'
description 'D-pad controller menu system for Xbox One'
version '1.0.0'

client_scripts {
    '@NativeUI/NativeUI.lua',
    'client.lua'
}

dependencies {
    'NativeUI',
    'player_tracker',
    'standalone-framework'
}

exports {
    'RefreshMenus'
}

lua54 'yes'
