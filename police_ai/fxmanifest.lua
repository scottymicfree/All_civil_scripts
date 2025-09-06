fx_version 'cerulean'
game 'gta5'

author 'Randy Webb'
description 'A comprehensive police NPC interaction system'
version '1.1.0'

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
    'interior_zone_manager'
}

lua54 'yes'
