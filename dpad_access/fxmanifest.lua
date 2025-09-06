fx_version 'cerulean'
game 'gta5'

author 'Randy Webb'
description 'Controller-friendly D-pad access to various features'
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