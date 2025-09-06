fx_version 'cerulean'
game 'gta5'

author 'Randy Webb & Emma, Improved by Grok'
description 'Enhanced Riptides Surfer Gang System'
version '1.2.0'

shared_scripts {
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

dependencies {
    'interior_zone_manager',
    'civil_disorder'
}

lua54 'yes'
